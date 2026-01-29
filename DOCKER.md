# Docker Setup Guide

This guide explains how to run the entire Aarvee CRM stack using Docker for simplified development.

## Quick Start

### Prerequisites

- Docker Desktop (or Docker Engine + Docker Compose)
- Node.js 22 LTS (for initial dependency installation)
- Make (optional, but recommended)

### One-Command Setup

**Using Make (recommended):**

```bash
# Install dependencies (only needed once)
make docker-install

# Start everything with Docker
make docker-start
```

**Using Shell Scripts (alternative):**

```bash
# Start everything
./docker-start.sh

# Stop everything
./docker-stop.sh
```

This single command will:
1. Start Supabase (PostgreSQL, REST API, Auth, Storage)
2. Start the Spring Boot custom service
3. Start the React frontend with hot reload
4. Apply database migrations automatically

### Access the Application

Once started, you can access:
- **Frontend**: http://localhost:5173
- **Spring Boot API**: http://localhost:3001
- **Supabase Dashboard**: http://localhost:54323
- **Supabase API**: http://localhost:54321
- **Inbucket (Email Testing)**: http://localhost:54324

## Available Docker Commands

All Docker-related commands are available via the Makefile:

```bash
make docker-start        # Start all services
make docker-stop         # Stop all services
make docker-restart      # Restart all services
make docker-logs         # View all logs
make docker-logs-frontend    # View frontend logs only
make docker-logs-spring      # View Spring Boot logs only
make docker-build        # Rebuild Docker images
make docker-clean        # Clean up Docker resources
```

## Architecture

The Docker setup consists of:

1. **Supabase** (managed by Supabase CLI)
   - PostgreSQL database
   - REST API server
   - Auth server
   - Storage server
   - Realtime server
   - Studio (dashboard)

2. **Spring Boot Service** (Docker container)
   - Custom business logic
   - Additional API endpoints
   - Connects to Supabase PostgreSQL

3. **Frontend** (Docker container)
   - React + Vite dev server
   - Hot module reload enabled
   - Connects to both Supabase and Spring Boot

## Development Workflow

### Making Changes

#### Frontend Changes
The frontend container uses volume mounts for hot reload. Simply edit files in the `src/` directory and changes will be reflected immediately.

#### Spring Boot Changes
1. Make changes to the Spring Boot code in `crm-custom-service-spring/`
2. Rebuild the Spring Boot container: `docker compose up -d --build spring-service`
3. Or restart everything: `make docker-restart`

### Viewing Logs

```bash
# All logs
make docker-logs

# Frontend only
make docker-logs-frontend

# Spring Boot only
make docker-logs-spring

# Supabase logs (if needed)
npx supabase logs
```

### Database Migrations

Migrations are automatically applied when Supabase starts. To manually apply:

```bash
npx supabase migration up
```

To create a new migration:

```bash
npx supabase migration new <migration_name>
```

## Troubleshooting

### Port Conflicts

If you get port conflict errors, check if services are already running:

```bash
# Check what's using port 5173 (Frontend)
lsof -i :5173

# Check what's using port 3001 (Spring Boot)
lsof -i :3001

# Check what's using port 54321 (Supabase API)
lsof -i :54321
```

Stop conflicting services or change ports in `docker-compose.yml`.

### Spring Boot Can't Connect to Database

Make sure Supabase is running before starting Docker containers:

```bash
npx supabase status
```

If Supabase isn't running, start it:

```bash
npx supabase start
```

### Frontend Can't Connect to Spring Boot

Check if the Spring Boot service is healthy:

```bash
docker compose ps
curl http://localhost:3001/health
```

If the service is not healthy, check logs:

```bash
make docker-logs-spring
```

### Clean Slate

To completely reset everything:

```bash
# Stop and clean Docker
make docker-clean

# Reset Supabase database
npx supabase db reset

# Start fresh
make docker-start
```

## Environment Variables

### Frontend Environment Variables
Defined in `docker-compose.yml`:
- `VITE_SUPABASE_URL`: Supabase API URL
- `VITE_SUPABASE_ANON_KEY`: Supabase anonymous key
- `VITE_CUSTOM_SERVICE_URL`: Spring Boot service URL

### Spring Boot Environment Variables
Defined in `docker-compose.yml`:
- `DATABASE_URL`: PostgreSQL connection string
- `SUPABASE_JWT_SECRET`: JWT secret for token validation
- `CORS_ALLOWED_ORIGINS`: Allowed CORS origins

To override environment variables, create a `.env` file or edit `docker-compose.yml`.

## Production Deployment

This Docker setup is designed for **development only**. For production:

1. Use production-grade Docker images (multi-stage builds are already configured)
2. Use environment-specific configuration
3. Use a managed PostgreSQL service (or Supabase cloud)
4. Use proper secrets management
5. Add reverse proxy (nginx/Traefik)
6. Add SSL certificates
7. Configure health checks and auto-restart policies

See the main README.md for production deployment instructions.

## Comparison: Docker vs Non-Docker Setup

### Without Docker (Traditional)
```bash
# Terminal 1: Start Supabase
make start-supabase

# Terminal 2: Install and start Spring Boot
cd crm-custom-service-spring
cp .env.example .env
mvn clean install
mvn spring-boot:run

# Terminal 3: Start Frontend
npm install
npm run dev
```

### With Docker (Simplified)
```bash
# Single command
make docker-start
```

## Next Steps

- Import test data: http://localhost:5173 → Contacts → Import → Upload `test-data/contacts.csv`
- Explore the Supabase Dashboard: http://localhost:54323
- Check API health: http://localhost:3001/health
- Start building your custom features!

## Support

For issues or questions:
1. Check logs: `make docker-logs`
2. Check service status: `docker compose ps`
3. Check Supabase status: `npx supabase status`
4. Review the main README.md for additional context
