#!/bin/bash

# Docker Setup Verification Script
# This script verifies that the Docker setup is working correctly

set -e

echo "🔍 Verifying Docker Setup..."
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is running
echo "1. Checking Docker..."
if docker info > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Docker is running"
else
    echo -e "${RED}✗${NC} Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Check if Docker Compose is available
echo "2. Checking Docker Compose..."
if docker compose version > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Docker Compose is available"
else
    echo -e "${RED}✗${NC} Docker Compose is not available"
    exit 1
fi

# Check if Node.js is installed
echo "3. Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}✓${NC} Node.js is installed ($NODE_VERSION)"
else
    echo -e "${RED}✗${NC} Node.js is not installed"
    exit 1
fi

# Check if Supabase is running
echo "4. Checking Supabase status..."
if npx supabase status > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Supabase is running"
    
    # Check if database is accessible
    echo "5. Checking database connection..."
    if npx supabase status | grep -q "DB URL"; then
        echo -e "${GREEN}✓${NC} Database is accessible"
    else
        echo -e "${YELLOW}⚠${NC} Database might not be fully initialized"
    fi
else
    echo -e "${YELLOW}⚠${NC} Supabase is not running (this is OK if you haven't started it yet)"
fi

# Check if Docker containers are running
echo "6. Checking Docker containers..."
if docker compose ps 2>&1 | grep -q "Up"; then
    echo -e "${GREEN}✓${NC} Docker containers are running"
    
    # Check frontend container
    if docker compose ps frontend 2>&1 | grep -q "Up"; then
        echo -e "   ${GREEN}✓${NC} Frontend container is running"
        
        # Check if frontend is responding
        if curl -s http://localhost:5173 > /dev/null 2>&1; then
            echo -e "   ${GREEN}✓${NC} Frontend is responding on http://localhost:5173"
        else
            echo -e "   ${YELLOW}⚠${NC} Frontend port 5173 is not responding yet"
        fi
    else
        echo -e "   ${YELLOW}⚠${NC} Frontend container is not running"
    fi
    
    # Check Spring Boot container
    if docker compose ps spring-service 2>&1 | grep -q "Up"; then
        echo -e "   ${GREEN}✓${NC} Spring Boot container is running"
        
        # Check if Spring Boot is responding
        if curl -s http://localhost:3001/health > /dev/null 2>&1; then
            echo -e "   ${GREEN}✓${NC} Spring Boot is responding on http://localhost:3001"
        else
            echo -e "   ${YELLOW}⚠${NC} Spring Boot might still be starting up"
        fi
    else
        echo -e "   ${YELLOW}⚠${NC} Spring Boot container is not running"
    fi
else
    echo -e "${YELLOW}⚠${NC} Docker containers are not running (this is OK if you haven't started them yet)"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo ""

# Check for port conflicts
echo "7. Checking for port conflicts..."
PORTS_TO_CHECK=(5173 3001 54321 54322 54323)
CONFLICTS=0

for PORT in "${PORTS_TO_CHECK[@]}"; do
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "   ${GREEN}✓${NC} Port $PORT is in use (expected)"
    else
        if [ "$PORT" != "54321" ] && [ "$PORT" != "54322" ] && [ "$PORT" != "54323" ]; then
            echo -e "   ${YELLOW}⚠${NC} Port $PORT is not in use (service may not be running)"
        fi
    fi
done

echo ""
echo "═══════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}Verification complete!${NC}"
echo ""

# Summary
if docker compose ps 2>&1 | grep -q "Up" && npx supabase status > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Your Docker setup appears to be working correctly!${NC}"
    echo ""
    echo "Access your application at:"
    echo "  - Frontend:           http://localhost:5173"
    echo "  - Spring Boot API:    http://localhost:3001"
    echo "  - Supabase Dashboard: http://localhost:54323"
    echo ""
else
    echo -e "${YELLOW}⚠ Your services are not running yet.${NC}"
    echo ""
    echo "To start all services, run:"
    echo "  make docker-start"
    echo "  OR"
    echo "  ./docker-start.sh"
    echo ""
fi
