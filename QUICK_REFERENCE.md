# Quick Reference - Hybrid Architecture (Spring Boot)

## 🚀 Essential Commands

### Start Development Environment
```bash
# Terminal 1: Supabase
make start

# Terminal 2: Custom Service  
cd crm-custom-service-spring && mvn spring-boot:run

# Terminal 3: Frontend
npm run dev
```

### Access Points
- Frontend: http://localhost:5173
- Custom API: http://localhost:3001
- Supabase Studio: http://localhost:54323

## 📁 Project Structure

```
aarvee-crm-atomic/
├── src/                                    # Frontend (React)
│   └── components/atomic-crm/providers/
│       ├── supabase/                       # Supabase provider
│       ├── custom-service/                 # Custom service provider
│       └── composite/                      # Routes requests to correct backend
├── crm-custom-service-spring/              # Spring Boot microservice
│   ├── src/main/java/com/aarvee/crm/
│   │   ├── controller/                     # REST controllers
│   │   ├── service/                        # Business logic
│   │   ├── repository/                     # Data access layer
│   │   ├── entity/                         # JPA entities
│   │   ├── config/                         # Configuration
│   │   └── security/                       # JWT authentication
│   └── pom.xml                             # Maven dependencies
└── supabase/migrations/                    # Database migrations
```

## 🗄️ Database Architecture

### Schemas
- `public` - Supabase tables (contacts, companies, deals, tasks, notes)
- `custom_features` - Custom service tables (lead_extensions, business_details, etc.)

### Accessing Data
- **Supabase tables**: Frontend → Supabase provider → Supabase API
- **Custom tables**: Frontend → Custom service provider → Spring Boot API → PostgreSQL

## 🔧 Common Tasks

### Add a New Custom Feature

1. **Create entity class** in `entity/` package
2. **Create repository interface** in `repository/` package
3. **Create service class** in `service/` package
4. **Create controller** in `controller/` package
5. **Create migration**: `npx supabase migration new feature_name`
6. **Apply migration**: `npx supabase db reset`
7. **Update composite provider** to include new resource

### Database Operations

```bash
# Create migration
npx supabase migration new migration_name

# Apply migrations
npx supabase db reset

# View database with Supabase Studio
open http://localhost:54323

# Run SQL query
npx supabase db execute -f script.sql
```

### Test API Endpoints

```bash
# Health check
curl http://localhost:3001/health

# Create lead (needs auth token)
curl -X POST http://localhost:3001/api/lead_extensions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"contactId":"1","product":"Home Loan"}'

# List leads
curl http://localhost:3001/api/lead_extensions \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 📝 Code Snippets

### Controller Template

```typescript
import { Request, Response } from 'express';
import prisma from '../config/database';
import logger from '../config/logger';

export class MyController {
  async create(req: Request, res: Response) {
    try {
      const data = await prisma.myModel.create({
        data: req.body
      });
      res.status(201).json(data);
    } catch (error) {
      logger.error('Error:', error);
      res.status(500).json({ error: 'Failed' });
    }
  }

  async getList(req: Request, res: Response) {
    const { page = '1', perPage = '10' } = req.query;
    const pageNum = parseInt(page as string);
    const perPageNum = parseInt(perPage as string);

    const [data, total] = await Promise.all([
      prisma.myModel.findMany({
        skip: (pageNum - 1) * perPageNum,
        take: perPageNum,
      }),
      prisma.myModel.count(),
    ]);

    res.json({ data, total });
  }
}
```

### Route Template

```typescript
import { Router } from 'express';
import { MyController } from '../controllers/myController';
import { authenticateToken } from '../middleware/auth';

const router = Router();
const controller = new MyController();

router.use(authenticateToken);

router.post('/my_resource', (req, res) => controller.create(req, res));
router.get('/my_resource', (req, res) => controller.getList(req, res));

export default router;
```

## 🐛 Troubleshooting

### "Cannot connect to database"
```bash
# Check Supabase is running
docker ps | grep supabase

# Restart Supabase
make stop && make start
```

### "Prisma client not generated"
```bash
cd crm-custom-service
npm run prisma:generate
```

### "Authentication failed"
- Check `.env` has correct `SUPABASE_JWT_SECRET`
- Get fresh token from browser localStorage (`sb-access-token`)

### "Table does not exist"
```bash
npx supabase db reset
```

### "Port already in use"
```bash
# Find process
lsof -i :3001

# Kill it
kill -9 PID
```

## 📚 Documentation Links

| Document | Purpose |
|----------|---------|
| [NODEJS_HYBRID_SETUP_GUIDE.md](./NODEJS_HYBRID_SETUP_GUIDE.md) | Complete setup instructions |
| [DEVELOPMENT_WORKFLOW.md](./DEVELOPMENT_WORKFLOW.md) | Day-to-day development guide |
| [HYBRID_ARCHITECTURE_GUIDE.md](./HYBRID_ARCHITECTURE_GUIDE.md) | Architecture overview |
| [BusinessRequirements.md](./BusinessRequirements.md) | Business requirements |

## 🎯 Feature Checklist

Use this to track which features go where:

### Supabase (Existing)
- ✅ Contacts (basic CRUD)
- ✅ Companies (basic CRUD)
- ✅ Deals (basic CRUD)
- ✅ Tasks
- ✅ Notes
- ✅ Tags
- ✅ Sales (users)
- ✅ Authentication
- ✅ File storage

### Custom Service (New)
- ⬜ Lead extensions (lead number, product, loan amount)
- ⬜ Business details
- ⬜ Property details
- ⬜ Auto loan details
- ⬜ Machinery loan details
- ⬜ Multiple companies per lead
- ⬜ Multiple individuals per lead
- ⬜ References
- ⬜ Disbursement tracking
- ⬜ Document management
- ⬜ Reminders (birthday, loan topup)
- ⬜ PDF/Word export

## 🔐 Environment Variables

### Custom Service (`.env`)
```env
NODE_ENV=development
PORT=3001
DATABASE_URL="postgresql://postgres:postgres@localhost:54322/postgres?schema=custom_features"
SUPABASE_URL=http://localhost:54321
SUPABASE_JWT_SECRET=your-jwt-secret
CORS_ORIGIN=http://localhost:5173
```

### Frontend (`.env.development`)
```env
VITE_CUSTOM_SERVICE_URL=http://localhost:3001/api
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_ANON_KEY=your-anon-key
```

## 💡 Tips

- ✅ Use Prisma Studio for quick database browsing
- ✅ Check logs in all three terminals when debugging
- ✅ Use `logger.info()` for debugging, not `console.log()`
- ✅ Always convert BigInt to string before JSON response
- ✅ Test API endpoints with curl before integrating frontend
- ✅ Create migrations for all schema changes
- ✅ Keep custom resources list updated in composite provider

---

**Quick Help**: For detailed instructions, see [NODEJS_HYBRID_SETUP_GUIDE.md](./NODEJS_HYBRID_SETUP_GUIDE.md)
