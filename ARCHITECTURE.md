# Docker Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Developer Machine                            │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    Docker Compose                            │   │
│  │                                                               │   │
│  │  ┌──────────────────┐      ┌──────────────────┐            │   │
│  │  │   Frontend       │      │  Spring Boot     │            │   │
│  │  │   Container      │      │   Container      │            │   │
│  │  │                  │      │                  │            │   │
│  │  │  React + Vite    │◄────►│  Java 17        │            │   │
│  │  │  Node 22         │      │  Maven          │            │   │
│  │  │  Port: 5173      │      │  Port: 3001     │            │   │
│  │  │                  │      │                  │            │   │
│  │  │  Hot Reload ✓    │      │  REST API       │            │   │
│  │  └────────┬─────────┘      └────────┬─────────┘            │   │
│  │           │                         │                       │   │
│  │           │                         │                       │   │
│  │           └─────────┬───────────────┘                       │   │
│  │                     │                                       │   │
│  └─────────────────────┼───────────────────────────────────────┘   │
│                        │                                           │
│           ┌────────────┼────────────┐                             │
│           │   host.docker.internal  │                             │
│           └────────────┬────────────┘                             │
│                        │                                           │
│  ┌─────────────────────▼───────────────────────────────────────┐  │
│  │                 Supabase (via CLI)                          │  │
│  │  ┌─────────────────────────────────────────────────────┐   │  │
│  │  │                                                      │   │  │
│  │  │  PostgreSQL (Port: 54322)                          │   │  │
│  │  │  REST API (Port: 54321)                            │   │  │
│  │  │  Auth Server                                        │   │  │
│  │  │  Storage Server                                     │   │  │
│  │  │  Realtime Server                                    │   │  │
│  │  │  Studio Dashboard (Port: 54323)                    │   │  │
│  │  │  Inbucket Email (Port: 54324)                      │   │  │
│  │  │                                                      │   │  │
│  │  └──────────────────────────────────────────────────────┘   │  │
│  │         (Managed by Supabase Docker containers)             │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘

                           │
                           │
                           ▼
                    ┌────────────┐
                    │  Browser   │
                    │            │
                    │ localhost: │
                    │   5173     │
                    └────────────┘
```

## Component Responsibilities

### Frontend Container (React + Vite)
- **Purpose**: Development server with hot module reload
- **Technology**: Node.js 22 + Vite
- **Port**: 5173
- **Features**:
  - Hot reload on file changes
  - Connects to Supabase API (54321)
  - Connects to Spring Boot API (3001)
  - Volume mounted for live code updates

### Spring Boot Container (Custom Service)
- **Purpose**: Business-specific backend logic
- **Technology**: Java 17 + Spring Boot 3.2 + Maven
- **Port**: 3001
- **Features**:
  - Custom REST API endpoints
  - Connects to Supabase PostgreSQL (54322)
  - JWT authentication via Supabase tokens
  - Multi-stage Docker build for optimization

### Supabase (Managed by Supabase CLI)
- **Purpose**: Backend-as-a-Service
- **Technology**: PostgreSQL + Node.js services
- **Ports**:
  - 54321: REST API
  - 54322: PostgreSQL Database
  - 54323: Studio Dashboard
  - 54324: Email Testing (Inbucket)
- **Features**:
  - Database with migrations
  - Authentication
  - Storage (file uploads)
  - Real-time subscriptions
  - Edge Functions

## Network Flow

1. **Browser** → **Frontend (5173)**
   - User accesses the application

2. **Frontend** → **Supabase API (54321)**
   - Authentication requests
   - Data fetching (contacts, companies, deals, etc.)

3. **Frontend** → **Spring Boot (3001)**
   - Custom business logic requests
   - Extended functionality

4. **Spring Boot** → **PostgreSQL (54322)**
   - Direct database access for custom features
   - Shares same database as Supabase

5. **Supabase** → **PostgreSQL (54322)**
   - Core CRM data operations

## Benefits of This Architecture

✅ **Isolation**: Each service runs in its own container
✅ **Consistency**: Same environment for all developers
✅ **Simplicity**: One command to start everything
✅ **Hot Reload**: Frontend changes reflect immediately
✅ **Networking**: Services communicate via Docker network
✅ **Portability**: Works on Windows, Mac, Linux
✅ **Scalability**: Easy to add more services

## Data Flow Example: Creating a Contact

```
User in Browser
    │
    ▼
Frontend (React)
    │
    ├─► Supabase API ───► PostgreSQL (contacts table)
    │   (Core contact data)
    │
    └─► Spring Boot API ───► PostgreSQL (lead_extensions table)
        (Custom business data)
```

Both services write to the same PostgreSQL database but handle different aspects of the application.

## Starting the Stack

```bash
make docker-start
```

This command:
1. Starts Supabase (including PostgreSQL)
2. Builds and starts Spring Boot container
3. Builds and starts Frontend container
4. Configures networking between all services
5. Applies database migrations

## Stopping the Stack

```bash
make docker-stop
```

This command:
1. Stops Frontend container
2. Stops Spring Boot container
3. Stops Supabase services

## Development Workflow

```
Edit Code → Save File → Hot Reload → See Changes
   (0s)       (0s)        (1-2s)      (immediate)
```

No manual rebuilds or restarts needed for frontend development!

For Spring Boot changes:
```bash
docker compose up -d --build spring-service
```
