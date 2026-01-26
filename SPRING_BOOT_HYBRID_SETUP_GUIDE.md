# Spring Boot Hybrid Architecture - Setup Guide

## Overview

This guide helps you set up the **hybrid architecture** using Spring Boot for implementing the custom business requirements while keeping the existing Atomic CRM features powered by Supabase.

### Architecture Summary

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend (React + TypeScript)             │
│                   Composite Data Provider                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐            ┌──────────────────────┐   │
│  │ Supabase Provider│            │ Custom Service       │   │
│  │                  │            │ Provider             │   │
│  │ • Contacts       │            │ • Lead Extensions    │   │
│  │ • Companies      │            │ • Business Details   │   │
│  │ • Deals          │            │ • Property Details   │   │
│  │ • Tasks          │            │ • Disbursements      │   │
│  │ • Notes          │            │ • Reminders          │   │
│  └──────────────────┘            └──────────────────────┘   │
│         ▼                                  ▼                 │
└─────────────────────────────────────────────────────────────┘
          │                                  │
          ▼                                  ▼
┌──────────────────┐            ┌──────────────────────────┐
│  Supabase        │            │  Spring Boot REST API     │
│  PostgreSQL      │◄───────────│  Custom Microservice      │
└──────────────────┘            └──────────────────────────┘
     (Shared Database - Same PostgreSQL Instance)
```

### Why Hybrid Architecture with Spring Boot?

✅ **Enterprise-Ready**: Proven, production-grade framework  
✅ **Type Safety**: Strongly-typed Java with compile-time checks  
✅ **Rich Ecosystem**: Comprehensive Spring ecosystem for any need  
✅ **Performance**: Highly optimized for high-throughput applications  
✅ **Best of Both Worlds**: Keep Supabase benefits + Full custom flexibility  

## Prerequisites

Before starting, ensure you have:

- ✅ Java 17 or higher (check: `java --version`)
- ✅ Maven 3.6+ (check: `mvn --version`)
- ✅ Docker (for Supabase) (check: `docker --version`)
- ✅ Git (check: `git --version`)
- ✅ Make (check: `make --version`)

---

## Quick Start

### Step 1: Navigate to the Microservice Directory

```bash
cd aarvee-crm-atomic/crm-custom-service-spring
```

### Step 2: Configure Environment Variables

```bash
cp .env.example .env
# Edit .env with your actual values
```

**Required Environment Variables:**

```bash
DATABASE_URL=jdbc:postgresql://localhost:54322/postgres
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
SUPABASE_JWT_SECRET=your-jwt-secret-here
PORT=3001
CORS_ALLOWED_ORIGINS=http://localhost:5173
```

**Finding Your JWT Secret:**

For **local development**, use the default Supabase JWT secret:
```bash
SUPABASE_JWT_SECRET=super-secret-jwt-token-with-at-least-32-characters-long
```

For **production**, get your JWT secret from the Supabase dashboard:
1. Go to https://app.supabase.com/project/YOUR_PROJECT/settings/api
2. Under "JWT Settings", copy the "JWT Secret" value
3. Update your `.env` file with this value

### Step 3: Install Dependencies

```bash
mvn clean install
```

### Step 4: Start the Service

```bash
mvn spring-boot:run
```

The service will start on **http://localhost:3001**

### Step 5: Verify the Service

```bash
curl http://localhost:3001/health
```

---

## Full Development Workflow

**Terminal 1: Start Supabase**
```bash
make start-supabase
```

**Terminal 2: Start Spring Boot**
```bash
cd crm-custom-service-spring
mvn spring-boot:run
```

**Terminal 3: Start Frontend**
```bash
make start-app
```

---

## API Endpoints

### Health Check
- `GET /health` - Check service status

### Lead Extensions
- `POST /api/lead_extensions` - Create lead extension
- `GET /api/lead_extensions` - List lead extensions (with pagination)
- `GET /api/lead_extensions/{id}` - Get single lead extension
- `PUT /api/lead_extensions/{id}` - Update lead extension
- `DELETE /api/lead_extensions/{id}` - Delete lead extension

All API endpoints (except /health) require Bearer token authentication.

---

## Testing the API

**Create a Lead Extension:**

```bash
curl -X POST http://localhost:3001/api/lead_extensions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "contactId": 1,
    "product": "Home Loan",
    "loanAmountRequired": 5000000,
    "location": "Mumbai",
    "leadStatus": "new"
  }'
```

---

## Troubleshooting

### Service Won't Start

**Error: "SUPABASE_JWT_SECRET environment variable is not set"**

Solution: Ensure `.env` file exists in `crm-custom-service-spring/` directory with the JWT secret:

```bash
# For local development
SUPABASE_JWT_SECRET=super-secret-jwt-token-with-at-least-32-characters-long
```

### Can't Find the JWT Secret

**For Local Development:**
The default Supabase local development JWT secret is:
```
super-secret-jwt-token-with-at-least-32-characters-long
```

**For Production:**
1. Log in to your Supabase dashboard at https://app.supabase.com
2. Select your project
3. Go to Settings → API
4. Scroll down to "JWT Settings"
5. Copy the "JWT Secret" value

**Note:** The JWT secret is NOT stored in `supabase/config.toml`. This is a common misconception.

### Database Errors

Run migrations:
```bash
npx supabase migration up
```

---

## Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Supabase Documentation](https://supabase.com/docs)
- [Service README](./crm-custom-service-spring/README.md)
