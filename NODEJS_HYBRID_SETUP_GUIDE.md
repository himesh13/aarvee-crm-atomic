# Node.js Hybrid Architecture - Setup Guide

## Overview

This guide helps you set up the **recommended hybrid architecture** for implementing the custom business requirements while keeping the existing Atomic CRM features powered by Supabase.

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
│  Supabase        │            │  Node.js Express API      │
│  PostgreSQL      │◄───────────│  Custom Microservice      │
└──────────────────┘            └──────────────────────────┘
     (Shared Database - Same PostgreSQL Instance)
```

### Why Hybrid Architecture?

✅ **Fastest**: 8-10 weeks (vs 12 weeks Supabase-only, 20-24 weeks Spring Boot)  
✅ **Most Cost-Effective**: ~$27K-32K (vs $39K Supabase-only, $60K-73K Spring Boot)  
✅ **Best of Both Worlds**: Keep Supabase benefits + Full custom flexibility  
✅ **Lower Risk**: Keep what works, add what's needed  

## Question: Same Repo or Separate?

### Answer: **Use the Same Repository** ✅

**Recommended Approach**: Monorepo structure

```
aarvee-crm-atomic/
├── src/                          # Frontend code (React)
├── supabase/                     # Supabase config and migrations
├── crm-custom-service/           # ← NEW: Node.js microservice
│   ├── src/
│   ├── prisma/
│   ├── package.json
│   └── tsconfig.json
├── package.json                  # Root frontend dependencies
├── makefile                      # Development commands
└── README.md
```

**Why Same Repo?**
- ✅ Easier development (single clone)
- ✅ Shared TypeScript types
- ✅ Coordinated deployments
- ✅ Single issue tracker
- ✅ Easier code reviews
- ✅ Shared tooling (ESLint, Prettier)

**When to Separate?**
- ❌ Different teams managing frontend vs backend
- ❌ Different deployment schedules
- ❌ Microservice will be reused by other applications

For your use case, **same repo is better**.

---

## Prerequisites

Before starting, ensure you have:

- ✅ Node.js 20+ (check: `node --version`)
- ✅ npm or yarn (check: `npm --version`)
- ✅ Docker (for Supabase) (check: `docker --version`)
- ✅ Git (check: `git --version`)
- ✅ Make (check: `make --version`)
- ✅ Code editor (VS Code recommended)

---

## Part 1: Setup Custom Node.js Microservice

### Step 1: Create Microservice Directory

From the root of your repository:

```bash
# Navigate to repository root
cd /path/to/aarvee-crm-atomic

# Create the custom service directory
mkdir -p crm-custom-service/src
cd crm-custom-service
```

### Step 2: Initialize Node.js Project

```bash
# Initialize package.json
npm init -y

# Install core dependencies
npm install express typescript ts-node @types/node @types/express
npm install pg @prisma/client prisma
npm install jsonwebtoken @types/jsonwebtoken
npm install dotenv cors helmet express-validator
npm install node-cron
npm install winston  # For logging

# Install development dependencies
npm install --save-dev nodemon @types/cors tsx
npm install --save-dev @types/pg
```

### Step 3: Create TypeScript Configuration

Create `crm-custom-service/tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "types": ["node"]
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### Step 4: Update package.json Scripts

Edit `crm-custom-service/package.json`:

```json
{
  "name": "crm-custom-service",
  "version": "1.0.0",
  "description": "Custom Node.js microservice for Aarvee CRM business requirements",
  "main": "dist/index.js",
  "scripts": {
    "dev": "nodemon --exec tsx src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate dev",
    "prisma:deploy": "prisma migrate deploy",
    "prisma:studio": "prisma studio",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": ["crm", "express", "typescript"],
  "author": "",
  "license": "MIT"
}
```

### Step 5: Create Project Structure

```bash
# Create directory structure
mkdir -p src/{config,controllers,services,routes,middleware,jobs,types,utils}
mkdir -p prisma
```

Your structure should look like:

```
crm-custom-service/
├── src/
│   ├── config/          # Configuration files
│   ├── controllers/     # Route controllers
│   ├── services/        # Business logic
│   ├── routes/          # API routes
│   ├── middleware/      # Express middleware
│   ├── jobs/            # Background jobs (reminders, etc.)
│   ├── types/           # TypeScript type definitions
│   ├── utils/           # Utility functions
│   └── index.ts         # Application entry point
├── prisma/
│   └── schema.prisma    # Database schema
├── package.json
├── tsconfig.json
└── .env.example
```

### Step 6: Create Environment Configuration

Create `crm-custom-service/.env.example`:

```env
# Server Configuration
NODE_ENV=development
PORT=3001
HOST=localhost

# Database Configuration (Use Supabase PostgreSQL)
DATABASE_URL="postgresql://postgres:postgres@localhost:54322/postgres?schema=custom_features"

# Supabase Configuration (for JWT validation)
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_KEY=your-service-key-here
SUPABASE_JWT_SECRET=your-jwt-secret-here

# CORS Configuration
CORS_ORIGIN=http://localhost:5173

# Logging
LOG_LEVEL=debug
```

Create actual `.env` file:

```bash
cp .env.example .env
# Edit .env with actual values from your Supabase instance
```

### Step 7: Initialize Prisma

```bash
# Initialize Prisma
npx prisma init

# This creates:
# - prisma/schema.prisma
# - .env (if it doesn't exist)
```

Edit `crm-custom-service/prisma/schema.prisma`:

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// Lead Extensions Table
model LeadExtension {
  id                   BigInt    @id @default(autoincrement())
  contactId            BigInt    @map("contact_id")
  leadNumber           String    @unique @map("lead_number") @db.VarChar(50)
  product              String?   @db.VarChar(255)
  loanAmountRequired   BigInt?   @map("loan_amount_required")
  location             String?   @db.VarChar(500)
  leadReferredBy       String?   @map("lead_referred_by") @db.VarChar(255)
  shortDescription     String?   @map("short_description") @db.Text
  leadAssignedTo       BigInt?   @map("lead_assigned_to")
  leadStatus           String?   @map("lead_status") @db.VarChar(50)
  businessDetails      Json?     @map("business_details") @db.JsonB
  propertyDetails      Json?     @map("property_details") @db.JsonB
  autoLoanDetails      Json?     @map("auto_loan_details") @db.JsonB
  machineryLoanDetails Json?     @map("machinery_loan_details") @db.JsonB
  createdAt            DateTime  @default(now()) @map("created_at") @db.Timestamp(6)
  updatedAt            DateTime  @updatedAt @map("updated_at") @db.Timestamp(6)

  @@map("lead_extensions")
  @@schema("custom_features")
}

// Business Details (if separated from JSON)
model BusinessDetail {
  id                  BigInt   @id @default(autoincrement())
  leadExtensionId     BigInt   @map("lead_extension_id")
  typeOfEmployment    String?  @map("type_of_employment") @db.VarChar(100)
  typeOfIndustry      String?  @map("type_of_industry") @db.VarChar(100)
  typeOfBusiness      String?  @map("type_of_business") @db.VarChar(100)
  constitution        String?  @db.VarChar(100)
  yearsInBusiness     Int?     @map("years_in_business")
  monthlyNetSalary    BigInt?  @map("monthly_net_salary")
  otherInfo           String?  @map("other_info") @db.Text
  createdAt           DateTime @default(now()) @map("created_at") @db.Timestamp(6)
  updatedAt           DateTime @updatedAt @map("updated_at") @db.Timestamp(6)

  @@map("business_details")
  @@schema("custom_features")
}

// Property Details
model PropertyDetail {
  id                      BigInt   @id @default(autoincrement())
  leadExtensionId         BigInt   @map("lead_extension_id")
  typeOfProperty          String?  @map("type_of_property") @db.VarChar(100)
  isNewPurchase           Boolean? @map("is_new_purchase")
  isBuilderPurchase       Boolean? @map("is_builder_purchase")
  isReadyPossession       Boolean? @map("is_ready_possession")
  classificationOfProperty String? @map("classification_of_property") @db.VarChar(100)
  propertyValue           BigInt?  @map("property_value")
  sellDeedValue           BigInt?  @map("sell_deed_value")
  areaOfProperty          Decimal? @map("area_of_property") @db.Decimal(10, 2)
  areaUnit                String?  @map("area_unit") @db.VarChar(20)
  ageOfProperty           Int?     @map("age_of_property")
  propertyAddress         String?  @map("property_address") @db.Text
  otherInfo               String?  @map("other_info") @db.Text
  createdAt               DateTime @default(now()) @map("created_at") @db.Timestamp(6)
  updatedAt               DateTime @updatedAt @map("updated_at") @db.Timestamp(6)

  @@map("property_details")
  @@schema("custom_features")
}

// Reminders
model Reminder {
  id        BigInt   @id @default(autoincrement())
  contactId BigInt   @map("contact_id")
  type      String   @db.VarChar(50) // 'birthday', 'loan_topup'
  dueDate   DateTime @map("due_date") @db.Date
  message   String   @db.Text
  status    String   @default("pending") @db.VarChar(20) // 'pending', 'sent', 'dismissed'
  sentAt    DateTime? @map("sent_at") @db.Timestamp(6)
  createdAt DateTime @default(now()) @map("created_at") @db.Timestamp(6)

  @@map("reminders")
  @@schema("custom_features")
}
```

Generate Prisma Client:

```bash
npx prisma generate
```

---

## Part 2: Create Database Schema in Supabase

### Step 1: Create Supabase Migration

From the repository root:

```bash
# Make sure Supabase is running
make start

# Create a new migration
npx supabase migration new create_custom_features_schema
```

This creates a file like: `supabase/migrations/[timestamp]_create_custom_features_schema.sql`

### Step 2: Add Migration SQL

Edit the migration file:

```sql
-- Create custom_features schema
CREATE SCHEMA IF NOT EXISTS custom_features;

-- Grant access to service_role
GRANT USAGE ON SCHEMA custom_features TO service_role;
GRANT ALL ON ALL TABLES IN SCHEMA custom_features TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA custom_features TO service_role;

-- Lead Extensions Table
CREATE TABLE custom_features.lead_extensions (
  id BIGSERIAL PRIMARY KEY,
  contact_id BIGINT REFERENCES public.contacts(id) ON DELETE CASCADE,
  lead_number VARCHAR(50) UNIQUE NOT NULL,
  product VARCHAR(255),
  loan_amount_required BIGINT,
  location VARCHAR(500),
  lead_referred_by VARCHAR(255),
  short_description TEXT,
  lead_assigned_to BIGINT REFERENCES public.sales(id),
  lead_status VARCHAR(50) DEFAULT 'new',
  business_details JSONB,
  property_details JSONB,
  auto_loan_details JSONB,
  machinery_loan_details JSONB,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Business Details Table
CREATE TABLE custom_features.business_details (
  id BIGSERIAL PRIMARY KEY,
  lead_extension_id BIGINT REFERENCES custom_features.lead_extensions(id) ON DELETE CASCADE,
  type_of_employment VARCHAR(100),
  type_of_industry VARCHAR(100),
  type_of_business VARCHAR(100),
  constitution VARCHAR(100),
  years_in_business INT,
  monthly_net_salary BIGINT,
  other_info TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Property Details Table
CREATE TABLE custom_features.property_details (
  id BIGSERIAL PRIMARY KEY,
  lead_extension_id BIGINT REFERENCES custom_features.lead_extensions(id) ON DELETE CASCADE,
  type_of_property VARCHAR(100),
  is_new_purchase BOOLEAN,
  is_builder_purchase BOOLEAN,
  is_ready_possession BOOLEAN,
  classification_of_property VARCHAR(100),
  property_value BIGINT,
  sell_deed_value BIGINT,
  area_of_property DECIMAL(10, 2),
  area_unit VARCHAR(20),
  age_of_property INT,
  property_address TEXT,
  other_info TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Reminders Table
CREATE TABLE custom_features.reminders (
  id BIGSERIAL PRIMARY KEY,
  contact_id BIGINT REFERENCES public.contacts(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  due_date DATE NOT NULL,
  message TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  sent_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_lead_extensions_contact_id ON custom_features.lead_extensions(contact_id);
CREATE INDEX idx_lead_extensions_status ON custom_features.lead_extensions(lead_status);
CREATE INDEX idx_business_details_lead_id ON custom_features.business_details(lead_extension_id);
CREATE INDEX idx_property_details_lead_id ON custom_features.property_details(lead_extension_id);
CREATE INDEX idx_reminders_contact_id ON custom_features.reminders(contact_id);
CREATE INDEX idx_reminders_due_date ON custom_features.reminders(due_date);

-- Enable RLS (Row Level Security) - Optional but recommended
ALTER TABLE custom_features.lead_extensions ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_features.business_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_features.property_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_features.reminders ENABLE ROW LEVEL SECURITY;

-- Create policies (adjust based on your auth requirements)
CREATE POLICY "Users can view their own leads" ON custom_features.lead_extensions
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Users can insert leads" ON custom_features.lead_extensions
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update their own leads" ON custom_features.lead_extensions
  FOR UPDATE USING (auth.role() = 'authenticated');

-- Similar policies for other tables...

-- Create function to auto-update updated_at
CREATE OR REPLACE FUNCTION custom_features.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers
CREATE TRIGGER update_lead_extensions_updated_at BEFORE UPDATE ON custom_features.lead_extensions
  FOR EACH ROW EXECUTE FUNCTION custom_features.update_updated_at_column();

CREATE TRIGGER update_business_details_updated_at BEFORE UPDATE ON custom_features.business_details
  FOR EACH ROW EXECUTE FUNCTION custom_features.update_updated_at_column();

CREATE TRIGGER update_property_details_updated_at BEFORE UPDATE ON custom_features.property_details
  FOR EACH ROW EXECUTE FUNCTION custom_features.update_updated_at_column();
```

### Step 3: Apply Migration

```bash
# Apply the migration locally
npx supabase db reset

# Or just migrate up
npx supabase migration up
```

---

## Part 3: Implement Node.js API

### Step 1: Create Configuration Files

**`crm-custom-service/src/config/database.ts`**:

```typescript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

export default prisma;
```

**`crm-custom-service/src/config/logger.ts`**:

```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      ),
    }),
  ],
});

export default logger;
```

### Step 2: Create Authentication Middleware

**`crm-custom-service/src/middleware/auth.ts`**:

```typescript
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import logger from '../config/logger';

interface AuthRequest extends Request {
  user?: any;
}

export const authenticateToken = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  try {
    const jwtSecret = process.env.SUPABASE_JWT_SECRET;
    if (!jwtSecret) {
      logger.error('SUPABASE_JWT_SECRET not configured');
      return res.status(500).json({ error: 'Server configuration error' });
    }

    const decoded = jwt.verify(token, jwtSecret);
    req.user = decoded;
    next();
  } catch (error) {
    logger.error('Token verification failed:', error);
    return res.status(403).json({ error: 'Invalid or expired token' });
  }
};
```

### Step 3: Create Lead Controller

**`crm-custom-service/src/controllers/leadController.ts`**:

```typescript
import { Request, Response } from 'express';
import prisma from '../config/database';
import logger from '../config/logger';

export class LeadController {
  /**
   * Generate a unique lead number
   */
  private async generateLeadNumber(): Promise<string> {
    const today = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const count = await prisma.leadExtension.count({
      where: {
        leadNumber: {
          startsWith: `LEAD-${today}`,
        },
      },
    });
    return `LEAD-${today}-${String(count + 1).padStart(5, '0')}`;
  }

  /**
   * Create a new lead extension
   */
  async create(req: Request, res: Response) {
    try {
      const {
        contactId,
        product,
        loanAmountRequired,
        location,
        leadReferredBy,
        shortDescription,
        leadAssignedTo,
        leadStatus,
        businessDetails,
        propertyDetails,
        autoLoanDetails,
        machineryLoanDetails,
      } = req.body;

      // Validate required fields
      if (!contactId) {
        return res.status(400).json({ error: 'contactId is required' });
      }

      // Generate lead number
      const leadNumber = await this.generateLeadNumber();

      const leadExtension = await prisma.leadExtension.create({
        data: {
          contactId: BigInt(contactId),
          leadNumber,
          product,
          loanAmountRequired: loanAmountRequired ? BigInt(loanAmountRequired) : null,
          location,
          leadReferredBy,
          shortDescription,
          leadAssignedTo: leadAssignedTo ? BigInt(leadAssignedTo) : null,
          leadStatus: leadStatus || 'new',
          businessDetails,
          propertyDetails,
          autoLoanDetails,
          machineryLoanDetails,
        },
      });

      // Convert BigInt to string for JSON serialization
      const response = {
        ...leadExtension,
        id: leadExtension.id.toString(),
        contactId: leadExtension.contactId.toString(),
        loanAmountRequired: leadExtension.loanAmountRequired?.toString(),
        leadAssignedTo: leadExtension.leadAssignedTo?.toString(),
      };

      logger.info(`Created lead extension: ${leadNumber}`);
      res.status(201).json(response);
    } catch (error) {
      logger.error('Error creating lead extension:', error);
      res.status(500).json({ error: 'Failed to create lead extension' });
    }
  }

  /**
   * Get list of lead extensions with pagination and filtering
   */
  async getList(req: Request, res: Response) {
    try {
      const {
        page = '1',
        perPage = '10',
        sortField = 'createdAt',
        sortOrder = 'desc',
        filter = '{}',
      } = req.query;

      const pageNum = parseInt(page as string);
      const perPageNum = parseInt(perPage as string);
      const where = JSON.parse(filter as string);

      const [data, total] = await Promise.all([
        prisma.leadExtension.findMany({
          where,
          skip: (pageNum - 1) * perPageNum,
          take: perPageNum,
          orderBy: { [sortField as string]: sortOrder },
        }),
        prisma.leadExtension.count({ where }),
      ]);

      // Convert BigInt fields to strings
      const serializedData = data.map(item => ({
        ...item,
        id: item.id.toString(),
        contactId: item.contactId.toString(),
        loanAmountRequired: item.loanAmountRequired?.toString(),
        leadAssignedTo: item.leadAssignedTo?.toString(),
      }));

      res.json({ data: serializedData, total });
    } catch (error) {
      logger.error('Error fetching lead extensions:', error);
      res.status(500).json({ error: 'Failed to fetch lead extensions' });
    }
  }

  /**
   * Get a single lead extension by ID
   */
  async getOne(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const leadExtension = await prisma.leadExtension.findUnique({
        where: { id: BigInt(id) },
      });

      if (!leadExtension) {
        return res.status(404).json({ error: 'Lead extension not found' });
      }

      const response = {
        ...leadExtension,
        id: leadExtension.id.toString(),
        contactId: leadExtension.contactId.toString(),
        loanAmountRequired: leadExtension.loanAmountRequired?.toString(),
        leadAssignedTo: leadExtension.leadAssignedTo?.toString(),
      };

      res.json(response);
    } catch (error) {
      logger.error('Error fetching lead extension:', error);
      res.status(500).json({ error: 'Failed to fetch lead extension' });
    }
  }

  /**
   * Update a lead extension
   */
  async update(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const updateData = { ...req.body };

      // Convert string IDs to BigInt
      if (updateData.contactId) {
        updateData.contactId = BigInt(updateData.contactId);
      }
      if (updateData.loanAmountRequired) {
        updateData.loanAmountRequired = BigInt(updateData.loanAmountRequired);
      }
      if (updateData.leadAssignedTo) {
        updateData.leadAssignedTo = BigInt(updateData.leadAssignedTo);
      }

      const leadExtension = await prisma.leadExtension.update({
        where: { id: BigInt(id) },
        data: updateData,
      });

      const response = {
        ...leadExtension,
        id: leadExtension.id.toString(),
        contactId: leadExtension.contactId.toString(),
        loanAmountRequired: leadExtension.loanAmountRequired?.toString(),
        leadAssignedTo: leadExtension.leadAssignedTo?.toString(),
      };

      logger.info(`Updated lead extension: ${id}`);
      res.json(response);
    } catch (error) {
      logger.error('Error updating lead extension:', error);
      res.status(500).json({ error: 'Failed to update lead extension' });
    }
  }

  /**
   * Delete a lead extension
   */
  async delete(req: Request, res: Response) {
    try {
      const { id } = req.params;

      await prisma.leadExtension.delete({
        where: { id: BigInt(id) },
      });

      logger.info(`Deleted lead extension: ${id}`);
      res.json({ message: 'Lead extension deleted successfully' });
    } catch (error) {
      logger.error('Error deleting lead extension:', error);
      res.status(500).json({ error: 'Failed to delete lead extension' });
    }
  }
}
```

### Step 4: Create Routes

**`crm-custom-service/src/routes/leadRoutes.ts`**:

```typescript
import { Router } from 'express';
import { LeadController } from '../controllers/leadController';
import { authenticateToken } from '../middleware/auth';

const router = Router();
const leadController = new LeadController();

// All routes require authentication
router.use(authenticateToken);

// Lead Extension routes
router.post('/lead_extensions', (req, res) => leadController.create(req, res));
router.get('/lead_extensions', (req, res) => leadController.getList(req, res));
router.get('/lead_extensions/:id', (req, res) => leadController.getOne(req, res));
router.put('/lead_extensions/:id', (req, res) => leadController.update(req, res));
router.delete('/lead_extensions/:id', (req, res) => leadController.delete(req, res));

export default router;
```

**`crm-custom-service/src/routes/index.ts`**:

```typescript
import { Router } from 'express';
import leadRoutes from './leadRoutes';

const router = Router();

// Health check endpoint (no auth required)
router.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
router.use('/api', leadRoutes);

export default router;
```

### Step 5: Create Main Application File

**`crm-custom-service/src/index.ts`**:

```typescript
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import routes from './routes';
import logger from './config/logger';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;
const HOST = process.env.HOST || 'localhost';

// Middleware
app.use(helmet()); // Security headers
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:5173',
  credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`);
  next();
});

// Routes
app.use(routes);

// Error handling middleware
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  logger.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, () => {
  logger.info(`🚀 Custom CRM service running on http://${HOST}:${PORT}`);
  logger.info(`Environment: ${process.env.NODE_ENV}`);
});
```

---

## Part 4: Frontend Integration

### Step 1: Create Custom Service Data Provider

Create `src/components/atomic-crm/providers/custom-service/customServiceDataProvider.ts`:

```typescript
import { DataProvider } from 'ra-core';

const API_BASE_URL = import.meta.env.VITE_CUSTOM_SERVICE_URL || 'http://localhost:3001/api';

const getAuthToken = () => {
  return localStorage.getItem('sb-access-token');
};

const fetchJson = async (url: string, options: RequestInit = {}) => {
  const token = getAuthToken();
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...(options.headers as HeadersInit),
  };

  const response = await fetch(url, { ...options, headers });
  
  if (!response.ok) {
    const error = await response.json().catch(() => ({ error: response.statusText }));
    throw new Error(error.error || `HTTP error! status: ${response.status}`);
  }
  
  return response.json();
};

export const customServiceDataProvider: DataProvider = {
  getList: async (resource, params) => {
    const { page, perPage } = params.pagination;
    const { field, order } = params.sort;
    
    const query = new URLSearchParams({
      page: String(page),
      perPage: String(perPage),
      sortField: field,
      sortOrder: order.toLowerCase(),
      filter: JSON.stringify(params.filter),
    });
    
    const url = `${API_BASE_URL}/${resource}?${query.toString()}`;
    const json = await fetchJson(url);
    
    return {
      data: json.data,
      total: json.total,
    };
  },
  
  getOne: async (resource, params) => {
    const url = `${API_BASE_URL}/${resource}/${params.id}`;
    const data = await fetchJson(url);
    return { data };
  },
  
  create: async (resource, params) => {
    const url = `${API_BASE_URL}/${resource}`;
    const data = await fetchJson(url, {
      method: 'POST',
      body: JSON.stringify(params.data),
    });
    return { data };
  },
  
  update: async (resource, params) => {
    const url = `${API_BASE_URL}/${resource}/${params.id}`;
    const data = await fetchJson(url, {
      method: 'PUT',
      body: JSON.stringify(params.data),
    });
    return { data };
  },
  
  updateMany: async (resource, params) => {
    const results = await Promise.all(
      params.ids.map(id =>
        fetchJson(`${API_BASE_URL}/${resource}/${id}`, {
          method: 'PUT',
          body: JSON.stringify(params.data),
        })
      )
    );
    return { data: results.map((_, index) => params.ids[index]) };
  },
  
  delete: async (resource, params) => {
    const url = `${API_BASE_URL}/${resource}/${params.id}`;
    await fetchJson(url, { method: 'DELETE' });
    return { data: params.previousData as any };
  },
  
  deleteMany: async (resource, params) => {
    await Promise.all(
      params.ids.map(id =>
        fetchJson(`${API_BASE_URL}/${resource}/${id}`, { method: 'DELETE' })
      )
    );
    return { data: params.ids };
  },
  
  getMany: async (resource, params) => {
    const results = await Promise.all(
      params.ids.map(id => fetchJson(`${API_BASE_URL}/${resource}/${id}`))
    );
    return { data: results };
  },
  
  getManyReference: async (resource, params) => {
    const { page, perPage } = params.pagination;
    const { field, order } = params.sort;
    
    const query = new URLSearchParams({
      page: String(page),
      perPage: String(perPage),
      sortField: field,
      sortOrder: order.toLowerCase(),
      filter: JSON.stringify({ ...params.filter, [params.target]: params.id }),
    });
    
    const url = `${API_BASE_URL}/${resource}?${query.toString()}`;
    const json = await fetchJson(url);
    
    return {
      data: json.data,
      total: json.total,
    };
  },
};
```

### Step 2: Create Composite Data Provider

Create `src/components/atomic-crm/providers/composite/compositeDataProvider.ts`:

```typescript
import { DataProvider } from 'ra-core';
import { supabaseDataProvider } from '../supabase/dataProvider';
import { customServiceDataProvider } from '../custom-service/customServiceDataProvider';

// Resources handled by the custom service
const CUSTOM_RESOURCES = [
  'lead_extensions',
  'business_details',
  'property_details',
  'reminders',
];

const isCustomResource = (resource: string): boolean => {
  return CUSTOM_RESOURCES.includes(resource);
};

export const compositeDataProvider: DataProvider = {
  getList: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.getList(resource, params);
  },
  
  getOne: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.getOne(resource, params);
  },
  
  create: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.create(resource, params);
  },
  
  update: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.update(resource, params);
  },
  
  updateMany: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.updateMany(resource, params);
  },
  
  delete: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.delete(resource, params);
  },
  
  deleteMany: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.deleteMany(resource, params);
  },
  
  getMany: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.getMany(resource, params);
  },
  
  getManyReference: async (resource, params) => {
    const provider = isCustomResource(resource) ? customServiceDataProvider : supabaseDataProvider;
    return provider.getManyReference(resource, params);
  },
};
```

### Step 3: Update Environment Variables

Add to `.env.development`:

```env
# Custom Service URL
VITE_CUSTOM_SERVICE_URL=http://localhost:3001/api
```

### Step 4: Update App.tsx (Optional - for testing)

You can update `src/App.tsx` to use the composite provider:

```typescript
import { CRM } from "@/components/atomic-crm/root/CRM";
import { compositeDataProvider } from "@/components/atomic-crm/providers/composite/compositeDataProvider";
import { supabaseAuthProvider } from "@/components/atomic-crm/providers/supabase";

const App = () => (
  <CRM 
    dataProvider={compositeDataProvider}
    authProvider={supabaseAuthProvider}
    // ... rest of your config
  />
);

export default App;
```

---

## Part 5: Testing the Setup

### Step 1: Start Supabase

From repository root:

```bash
make start
```

### Step 2: Start Custom Service

In a new terminal:

```bash
cd crm-custom-service
npm run dev
```

You should see:
```
🚀 Custom CRM service running on http://localhost:3001
Environment: development
```

### Step 3: Test Health Endpoint

```bash
curl http://localhost:3001/health
```

Expected response:
```json
{"status":"ok","timestamp":"2026-01-24T..."}
```

### Step 4: Start Frontend

In another terminal:

```bash
cd /path/to/aarvee-crm-atomic
make start  # or npm run dev
```

### Step 5: Test API Endpoints

Create a lead extension:

```bash
# Get Supabase token from browser localStorage (sb-access-token)
TOKEN="your-token-here"

curl -X POST http://localhost:3001/api/lead_extensions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "contactId": "1",
    "product": "Home Loan",
    "loanAmountRequired": "5000000",
    "location": "Mumbai, Maharashtra",
    "leadReferredBy": "John Doe"
  }'
```

Get lead extensions:

```bash
curl http://localhost:3001/api/lead_extensions?page=1&perPage=10 \
  -H "Authorization: Bearer $TOKEN"
```

---

## Part 6: Development Workflow

### Daily Development

1. **Start services**:
   ```bash
   # Terminal 1: Supabase
   make start
   
   # Terminal 2: Custom Service
   cd crm-custom-service && npm run dev
   
   # Terminal 3: Frontend
   npm run dev
   ```

2. **Make changes** to code
3. **Test** your changes
4. **Commit** regularly

### Adding New Features

1. **Update Prisma schema** (`prisma/schema.prisma`)
2. **Generate Prisma client**: `npm run prisma:generate`
3. **Create migration** (if needed): Add to Supabase migrations
4. **Add controller** in `src/controllers/`
5. **Add routes** in `src/routes/`
6. **Add to custom resources** list in composite provider
7. **Test** the new endpoint

### Database Changes

**Supabase Migrations**:
```bash
npx supabase migration new your_migration_name
# Edit the migration file
npx supabase db reset
```

**Prisma Updates**:
```bash
# Update schema.prisma
npm run prisma:generate
```

---

## Part 7: Deployment

### Option 1: Deploy to Vercel (Frontend) + Railway (Backend)

**Frontend** (same as before):
- Deploy to Vercel
- Set environment variables

**Backend** (Railway):
1. Create Railway account
2. Create new project
3. Connect GitHub repo
4. Set root directory to `crm-custom-service`
5. Add environment variables
6. Deploy

### Option 2: Deploy to AWS

**Frontend**: S3 + CloudFront  
**Backend**: EC2 or ECS  
**Database**: Use Supabase managed instance

### Option 3: Docker Compose

Create `docker-compose.yml` in repository root:

```yaml
version: '3.8'

services:
  frontend:
    build: .
    ports:
      - "5173:5173"
    environment:
      - VITE_CUSTOM_SERVICE_URL=http://backend:3001/api
    depends_on:
      - backend

  backend:
    build: ./crm-custom-service
    ports:
      - "3001:3001"
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - SUPABASE_JWT_SECRET=${SUPABASE_JWT_SECRET}
      - NODE_ENV=production
```

---

## Summary

You now have:

✅ **Node.js microservice** for custom features  
✅ **Shared database** (Supabase PostgreSQL)  
✅ **Composite data provider** routing requests  
✅ **Development environment** ready  
✅ **Basic API endpoints** (lead extensions)  
✅ **Authentication** using Supabase JWT  

### Next Steps

1. ✅ Implement remaining business requirements:
   - Business details endpoints
   - Property details endpoints
   - Disbursement tracking
   - Document management
   - Reminder jobs

2. ✅ Add frontend components for new features

3. ✅ Set up background jobs (reminders)

4. ✅ Add PDF/Word export functionality

5. ✅ Deploy to production

### Resources

- **Node.js Documentation**: https://nodejs.org/docs
- **Express Guide**: https://expressjs.com/
- **Prisma Documentation**: https://www.prisma.io/docs
- **Supabase Documentation**: https://supabase.com/docs

---

**Questions?** Review the [HYBRID_ARCHITECTURE_GUIDE.md](./HYBRID_ARCHITECTURE_GUIDE.md) for architecture details.
