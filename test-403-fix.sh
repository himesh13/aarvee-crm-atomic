#!/bin/bash
#
# Test script to verify the 403 error fix for lead forms
# This script checks if all required services are running and tests basic API access
#

set -e

echo "🔍 Verifying 403 Error Fix..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Supabase is running
echo -n "Checking Supabase... "
if curl -s -f http://127.0.0.1:54321 > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Running on port 54321"
else
    echo -e "${RED}✗${NC} Not running"
    echo -e "${YELLOW}Run: make start-supabase${NC}"
    exit 1
fi

# Check if JWKS endpoint is accessible
echo -n "Checking JWKS endpoint... "
JWKS_RESPONSE=$(curl -s http://127.0.0.1:54321/auth/v1/.well-known/jwks.json 2>/dev/null)
if echo "$JWKS_RESPONSE" | grep -q "keys"; then
    echo -e "${GREEN}✓${NC} Accessible"
    # Extract first key id if available
    KID=$(echo "$JWKS_RESPONSE" | grep -o '"kid":"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ -n "$KID" ]; then
        echo "  Key ID found: $KID"
    fi
else
    echo -e "${RED}✗${NC} Not accessible or invalid response"
    exit 1
fi

# Check if Spring Boot service is running
echo -n "Checking Spring Boot API... "
if curl -s -f http://localhost:3001/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Running on port 3001"
else
    echo -e "${RED}✗${NC} Not running"
    echo -e "${YELLOW}Run: cd crm-custom-service-spring && mvn spring-boot:run${NC}"
    exit 1
fi

# Check if frontend is running
echo -n "Checking Frontend... "
if curl -s -f http://localhost:5173 > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Running on port 5173"
else
    echo -e "${YELLOW}⚠${NC} Not running (optional for backend test)"
    echo -e "${YELLOW}Run: npm run dev${NC}"
fi

echo ""
echo "📝 Manual Testing Steps:"
echo "1. Open http://localhost:5173 in your browser"
echo "2. Login with your credentials"
echo "3. Navigate to 'Leads' page"
echo "4. Click 'Create Lead' button"
echo "5. Fill out the form:"
echo "   - Customer Name: Test Customer"
echo "   - Contact Number: 1234567890"
echo "   - Product: Select any option"
echo "6. Click 'Save'"
echo ""
echo "✅ Expected: Lead is created successfully without 403 errors"
echo "❌ Previous: 403 Forbidden error when loading/saving"
echo ""
echo "📋 To check logs:"
echo "  - Spring Boot: Check console where 'mvn spring-boot:run' is running"
echo "  - Frontend: Open browser DevTools (F12) → Console tab"
echo "  - Look for 'Fetching JWKS from...' and 'Cached public key with kid:...' messages"
echo ""
echo -e "${GREEN}All required services are running!${NC}"
