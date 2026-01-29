#!/bin/bash

# Aarvee CRM Docker Startup Script
# This script simplifies starting the entire CRM stack with Docker

set -e

echo "🚀 Starting Aarvee CRM with Docker..."
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed."
    echo "Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is not installed."
    echo "Please install Node.js 22 LTS from https://nodejs.org/"
    exit 1
fi

# Install npm dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing npm dependencies..."
    npm install
    echo ""
fi

# Start Supabase
echo "🗄️  Starting Supabase..."
npx supabase start

# Wait for Supabase to be ready
echo ""
echo "⏳ Waiting for Supabase to be ready..."
sleep 5

# Start Docker containers
echo ""
echo "🐳 Starting Docker containers (Frontend + Spring Boot)..."
docker compose up -d

echo ""
echo "✅ All services started successfully!"
echo ""
echo "Access the application at:"
echo "  - Frontend:           http://localhost:5173"
echo "  - Spring Boot API:    http://localhost:3001"
echo "  - Supabase Dashboard: http://localhost:54323"
echo "  - Supabase API:       http://localhost:54321"
echo ""
echo "To view logs:     docker compose logs -f"
echo "To stop services: ./docker-stop.sh"
echo ""
