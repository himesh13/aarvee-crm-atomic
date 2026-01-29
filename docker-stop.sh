#!/bin/bash

# Aarvee CRM Docker Stop Script
# This script stops all services

set -e

echo "🛑 Stopping Aarvee CRM services..."
echo ""

# Stop Docker containers
echo "🐳 Stopping Docker containers..."
docker compose down

# Stop Supabase
echo "🗄️  Stopping Supabase..."
npx supabase stop

echo ""
echo "✅ All services stopped successfully!"
echo ""
