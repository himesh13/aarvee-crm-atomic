# CRM Custom Service

Custom Node.js microservice for Aarvee CRM business requirements.

## Quick Start

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Configure environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your actual Supabase credentials
   ```

3. **Generate Prisma client**:
   ```bash
   npm run prisma:generate
   ```

4. **Run in development mode**:
   ```bash
   npm run dev
   ```

The service will start on http://localhost:3001

## Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Start production server
- `npm run prisma:generate` - Generate Prisma client
- `npm run prisma:migrate` - Create and apply migration
- `npm run prisma:studio` - Open Prisma Studio

## API Endpoints

### Health Check
- `GET /health` - Check service status

### Lead Extensions
- `POST /api/lead_extensions` - Create lead extension
- `GET /api/lead_extensions` - List lead extensions (with pagination)
- `GET /api/lead_extensions/:id` - Get single lead extension
- `PUT /api/lead_extensions/:id` - Update lead extension
- `DELETE /api/lead_extensions/:id` - Delete lead extension

All API endpoints (except /health) require Bearer token authentication.

## Development

See the main [NODEJS_HYBRID_SETUP_GUIDE.md](../NODEJS_HYBRID_SETUP_GUIDE.md) for detailed setup instructions.
