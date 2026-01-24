# Development Workflow - Hybrid Architecture

This document provides step-by-step instructions for developing features using the hybrid architecture (Supabase + Node.js microservice).

## Daily Development Workflow

### 1. Starting Your Development Environment

```bash
# Terminal 1: Start Supabase (PostgreSQL + Auth + Storage)
cd /path/to/aarvee-crm-atomic
make start

# Terminal 2: Start Custom Node.js Service
cd crm-custom-service
npm run dev

# Terminal 3: Start Frontend
cd /path/to/aarvee-crm-atomic
npm run dev
```

Your services will be available at:
- Frontend: http://localhost:5173
- Custom Service: http://localhost:3001
- Supabase Studio: http://localhost:54323

### 2. Making Code Changes

#### Adding a New Custom Feature

**Example**: Add "Company Details" to the custom service

##### Step 1: Update Prisma Schema

Edit `crm-custom-service/prisma/schema.prisma`:

```prisma
model CompanyDetail {
  id              BigInt   @id @default(autoincrement())
  leadExtensionId BigInt   @map("lead_extension_id")
  companyName     String   @map("company_name") @db.VarChar(255)
  panNumber       String?  @map("pan_number") @db.VarChar(20)
  registrationNo  String?  @map("registration_no") @db.VarChar(100)
  contactNumber   String?  @map("contact_number") @db.VarChar(20)
  email           String?  @db.VarChar(255)
  createdAt       DateTime @default(now()) @map("created_at") @db.Timestamp(6)
  updatedAt       DateTime @updatedAt @map("updated_at") @db.Timestamp(6)

  @@map("company_details")
  @@schema("custom_features")
}
```

Generate Prisma client:

```bash
cd crm-custom-service
npm run prisma:generate
```

##### Step 2: Create Supabase Migration

```bash
cd /path/to/aarvee-crm-atomic
npx supabase migration new add_company_details
```

Edit the new migration file in `supabase/migrations/`:

```sql
CREATE TABLE custom_features.company_details (
  id BIGSERIAL PRIMARY KEY,
  lead_extension_id BIGINT REFERENCES custom_features.lead_extensions(id) ON DELETE CASCADE,
  company_name VARCHAR(255) NOT NULL,
  pan_number VARCHAR(20),
  registration_no VARCHAR(100),
  contact_number VARCHAR(20),
  email VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_company_details_lead_id ON custom_features.company_details(lead_extension_id);

ALTER TABLE custom_features.company_details ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can manage company details" 
  ON custom_features.company_details
  FOR ALL USING (auth.role() = 'authenticated');

CREATE TRIGGER update_company_details_updated_at 
  BEFORE UPDATE ON custom_features.company_details
  FOR EACH ROW EXECUTE FUNCTION custom_features.update_updated_at_column();
```

Apply the migration:

```bash
npx supabase db reset  # Resets local DB and applies all migrations
# OR
npx supabase migration up  # Applies pending migrations only
```

##### Step 3: Create Controller

Create `crm-custom-service/src/controllers/companyController.ts`:

```typescript
import { Request, Response } from 'express';
import prisma from '../config/database';
import logger from '../config/logger';

export class CompanyController {
  async create(req: Request, res: Response) {
    try {
      const data = req.body;
      
      // Convert IDs to BigInt
      if (data.leadExtensionId) {
        data.leadExtensionId = BigInt(data.leadExtensionId);
      }

      const company = await prisma.companyDetail.create({ data });

      const response = {
        ...company,
        id: company.id.toString(),
        leadExtensionId: company.leadExtensionId.toString(),
      };

      res.status(201).json(response);
    } catch (error) {
      logger.error('Error creating company:', error);
      res.status(500).json({ error: 'Failed to create company' });
    }
  }

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
        prisma.companyDetail.findMany({
          where,
          skip: (pageNum - 1) * perPageNum,
          take: perPageNum,
          orderBy: { [sortField as string]: sortOrder },
        }),
        prisma.companyDetail.count({ where }),
      ]);

      const serializedData = data.map(item => ({
        ...item,
        id: item.id.toString(),
        leadExtensionId: item.leadExtensionId.toString(),
      }));

      res.json({ data: serializedData, total });
    } catch (error) {
      logger.error('Error fetching companies:', error);
      res.status(500).json({ error: 'Failed to fetch companies' });
    }
  }

  // Add getOne, update, delete methods similarly...
}
```

##### Step 4: Create Routes

Create `crm-custom-service/src/routes/companyRoutes.ts`:

```typescript
import { Router } from 'express';
import { CompanyController } from '../controllers/companyController';
import { authenticateToken } from '../middleware/auth';

const router = Router();
const companyController = new CompanyController();

router.use(authenticateToken);

router.post('/company_details', (req, res) => companyController.create(req, res));
router.get('/company_details', (req, res) => companyController.getList(req, res));
// Add other routes...

export default router;
```

Update `crm-custom-service/src/routes/index.ts`:

```typescript
import companyRoutes from './companyRoutes';

// Add to router
router.use('/api', companyRoutes);
```

##### Step 5: Update Frontend Data Provider

Edit `src/components/atomic-crm/providers/composite/compositeDataProvider.ts`:

```typescript
const CUSTOM_RESOURCES = [
  'lead_extensions',
  'business_details',
  'property_details',
  'company_details',  // ← Add this
  'reminders',
];
```

##### Step 6: Test Your Changes

```bash
# Test API endpoint directly
curl -X POST http://localhost:3001/api/company_details \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "leadExtensionId": "1",
    "companyName": "Test Company",
    "panNumber": "ABCDE1234F"
  }'
```

## Common Development Tasks

### Task 1: View Database with Prisma Studio

```bash
cd crm-custom-service
npm run prisma:studio
```

Opens at http://localhost:5555

### Task 2: Check Supabase Database

Navigate to http://localhost:54323 and go to:
- Table Editor → Select schema `custom_features`
- SQL Editor → Run queries

### Task 3: View Logs

**Backend Logs**:
```bash
# Custom service logs appear in Terminal 2
# Check for errors or info messages
```

**Frontend Logs**:
- Open browser DevTools → Console tab

**Database Logs**:
- Supabase Studio → Logs section

### Task 4: Reset Database

```bash
# WARNING: This deletes all data!
cd /path/to/aarvee-crm-atomic
npx supabase db reset
```

### Task 5: Create Sample Data

**Option A**: Use Prisma Studio (GUI)

**Option B**: SQL Script

Create `scripts/seed-custom-data.sql`:

```sql
-- Insert sample lead extension
INSERT INTO custom_features.lead_extensions 
  (contact_id, lead_number, product, loan_amount_required, location, lead_status)
VALUES 
  (1, 'LEAD-20260124-00001', 'Home Loan', 5000000, 'Mumbai, Maharashtra', 'new');
```

Run:

```bash
npx supabase db execute -f scripts/seed-custom-data.sql
```

### Task 6: Update Environment Variables

**Custom Service** (`.env`):
```bash
cd crm-custom-service
# Edit .env file
# Restart: npm run dev
```

**Frontend** (`.env.development`):
```bash
# Edit .env.development
# Restart: npm run dev
```

## Testing Workflow

### 1. Manual Testing

#### Test Backend API:

```bash
# Health check
curl http://localhost:3001/health

# Create lead
curl -X POST http://localhost:3001/api/lead_extensions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"contactId":"1","product":"Home Loan"}'

# Get leads
curl http://localhost:3001/api/lead_extensions \
  -H "Authorization: Bearer TOKEN"
```

#### Test Frontend:

1. Open http://localhost:5173
2. Login
3. Navigate to your new feature
4. Test CRUD operations
5. Check browser console for errors

### 2. Automated Testing (Future)

Add tests in `crm-custom-service/src/__tests__/`:

```typescript
// Example: leadController.test.ts
import { LeadController } from '../controllers/leadController';

describe('LeadController', () => {
  it('should create a lead extension', async () => {
    // Test implementation
  });
});
```

## Debugging

### Debug Backend

**Using VS Code**:

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Custom Service",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "cwd": "${workspaceFolder}/crm-custom-service",
      "skipFiles": ["<node_internals>/**"]
    }
  ]
}
```

Set breakpoints and press F5.

**Using console.log**:

```typescript
logger.info('Debug info:', { variable: value });
logger.error('Error occurred:', error);
```

### Debug Frontend

- Use React DevTools extension
- Check Network tab for API calls
- Use breakpoints in browser DevTools

### Debug Database Issues

```sql
-- Check if table exists
SELECT * FROM information_schema.tables 
WHERE table_schema = 'custom_features';

-- Check data
SELECT * FROM custom_features.lead_extensions LIMIT 10;

-- Check constraints
SELECT * FROM information_schema.table_constraints 
WHERE table_schema = 'custom_features';
```

## Committing Changes

### 1. Check What Changed

```bash
git status
git diff
```

### 2. Stage Files

```bash
# Stage specific files
git add crm-custom-service/
git add src/components/atomic-crm/providers/
git add supabase/migrations/

# Or stage all
git add .
```

### 3. Commit

```bash
git commit -m "feat: add company details feature to custom service"
```

### 4. Push

```bash
git push origin your-branch-name
```

## Deployment Preparation

### 1. Build Custom Service

```bash
cd crm-custom-service
npm run build
```

Check `dist/` folder for compiled files.

### 2. Build Frontend

```bash
cd /path/to/aarvee-crm-atomic
npm run build
```

Check `dist/` folder.

### 3. Update Production Environment Variables

Create `.env.production` for both frontend and backend with production values.

## Troubleshooting

### Issue: "Cannot connect to database"

**Solution**:
```bash
# Check if Supabase is running
docker ps | grep supabase

# Restart Supabase
make stop
make start
```

### Issue: "Prisma client not generated"

**Solution**:
```bash
cd crm-custom-service
npm run prisma:generate
```

### Issue: "Authentication failed"

**Solution**:
1. Check if JWT secret in `.env` matches Supabase
2. Get fresh token from browser localStorage
3. Verify token in https://jwt.io

### Issue: "Table does not exist"

**Solution**:
```bash
# Apply migrations
npx supabase db reset
```

### Issue: "Port already in use"

**Solution**:
```bash
# Find process using port
lsof -i :3001

# Kill process
kill -9 PID
```

## Best Practices

### 1. Code Organization

- ✅ Keep controllers thin, move logic to services
- ✅ Use TypeScript interfaces for type safety
- ✅ Follow consistent naming conventions
- ✅ Add JSDoc comments for public methods

### 2. Database

- ✅ Always create migrations for schema changes
- ✅ Use indexes for frequently queried columns
- ✅ Enable RLS for security
- ✅ Use transactions for multi-table operations

### 3. API Design

- ✅ Use RESTful conventions
- ✅ Return consistent error messages
- ✅ Use proper HTTP status codes
- ✅ Validate input data
- ✅ Handle BigInt serialization

### 4. Security

- ✅ Always validate JWT tokens
- ✅ Sanitize user input
- ✅ Use parameterized queries (Prisma does this)
- ✅ Don't expose sensitive data in errors
- ✅ Keep dependencies updated

### 5. Logging

- ✅ Log all errors with context
- ✅ Use appropriate log levels
- ✅ Don't log sensitive data (passwords, tokens)
- ✅ Structure logs for easy searching

## Next Steps

After setting up the basic workflow:

1. ✅ Implement remaining business requirements
2. ✅ Add frontend components for custom features
3. ✅ Set up background jobs (reminders)
4. ✅ Add PDF/Word export functionality
5. ✅ Write tests
6. ✅ Set up CI/CD pipeline
7. ✅ Deploy to production

## Resources

- **Prisma Docs**: https://www.prisma.io/docs
- **Express Guide**: https://expressjs.com/en/guide/routing.html
- **Supabase Docs**: https://supabase.com/docs
- **TypeScript Handbook**: https://www.typescriptlang.org/docs/

---

For architecture overview, see [NODEJS_HYBRID_SETUP_GUIDE.md](./NODEJS_HYBRID_SETUP_GUIDE.md)
