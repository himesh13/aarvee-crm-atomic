# Architecture Diagrams

This document provides visual representations of the two backend approaches for implementing the CRM requirements.

## Current Architecture (Supabase)

```
┌─────────────────────────────────────────────────────────────────┐
│                         FRONTEND                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              React Application                           │   │
│  │  • React 19 + TypeScript                                 │   │
│  │  • Vite Dev Server                                       │   │
│  │  • Shadcn UI + Radix UI                                  │   │
│  │  • React Query (TanStack Query)                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                     │
│                            │ HTTP Requests                       │
│                            ▼                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │         Data Provider Layer                              │   │
│  │  • Supabase Data Provider (ra-supabase-core)             │   │
│  │  • Auth Provider                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ REST API Calls
                              │ WebSocket (Real-time)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      SUPABASE BACKEND                            │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              PostgreSQL Database                         │   │
│  │  • contacts, companies, deals, tasks                     │   │
│  │  • contact_notes, deal_notes                             │   │
│  │  • tags, sales (users)                                   │   │
│  │  • Row Level Security (RLS)                              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            ▲                                     │
│                            │                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Auto-generated REST API                     │   │
│  │  • PostgREST                                             │   │
│  │  • GET, POST, PUT, DELETE endpoints                      │   │
│  │  • Filtering, sorting, pagination                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Authentication                              │   │
│  │  • Built-in auth system                                  │   │
│  │  • JWT tokens                                            │   │
│  │  • OAuth providers (Google, Azure, etc.)                 │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Storage                                     │   │
│  │  • File upload/download                                  │   │
│  │  • Avatars, attachments, documents                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Edge Functions (Optional)                   │   │
│  │  • TypeScript serverless functions                       │   │
│  │  • User management, email processing                     │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Pros**:
- ✅ Fast development (backend auto-generated)
- ✅ Built-in authentication
- ✅ Built-in file storage
- ✅ Real-time subscriptions
- ✅ Managed infrastructure
- ✅ Free tier available

**Cons**:
- ⚠️ Less control over backend logic
- ⚠️ Vendor lock-in (mitigated by standard PostgreSQL)
- ⚠️ Edge Functions limited to TypeScript

---

## Spring Boot Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         FRONTEND                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              React Application                           │   │
│  │  • React 19 + TypeScript                                 │   │
│  │  • Vite Dev Server                                       │   │
│  │  • Shadcn UI + Radix UI                                  │   │
│  │  • React Query (TanStack Query)                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                     │
│                            │ HTTP Requests                       │
│                            ▼                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │         Data Provider Layer                              │   │
│  │  • Custom Spring Boot Data Provider                      │   │
│  │  • Custom Auth Provider (JWT)                            │   │
│  │  • Axios/Fetch for HTTP                                  │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ REST API Calls
                              │ JWT Bearer Token
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   SPRING BOOT BACKEND                            │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Spring Boot Application                     │   │
│  │  • Spring Boot 3.2                                       │   │
│  │  • Java 17+                                              │   │
│  │  • Embedded Tomcat                                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              REST Controllers                            │   │
│  │  • ContactController                                     │   │
│  │  • CompanyController                                     │   │
│  │  • DealController                                        │   │
│  │  • TaskController, NoteController                        │   │
│  │  • AuthController                                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Service Layer                               │   │
│  │  • Business Logic                                        │   │
│  │  • Validation                                            │   │
│  │  • Transaction Management                                │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Repository Layer                            │   │
│  │  • Spring Data JPA                                       │   │
│  │  • JPA Repositories                                      │   │
│  │  • Query DSL                                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Security                                    │   │
│  │  • Spring Security                                       │   │
│  │  • JWT Token Provider                                    │   │
│  │  • Authentication Filter                                 │   │
│  │  • Password Encoder (BCrypt)                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              File Storage                                │   │
│  │  • AWS S3 / MinIO                                        │   │
│  │  • File upload service                                   │   │
│  │  • Presigned URLs                                        │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ JDBC
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATABASE                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              PostgreSQL / MySQL                          │   │
│  │  • contacts, companies, deals, tasks                     │   │
│  │  • contact_notes, deal_notes                             │   │
│  │  • tags, sales (users)                                   │   │
│  │  • + Custom tables for requirements                      │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Pros**:
- ✅ Full control over backend logic
- ✅ Can use any Java library
- ✅ Easier integration with Java systems
- ✅ Team expertise in Java/Spring
- ✅ No vendor lock-in

**Cons**:
- ⚠️ More development time (4-6 weeks for backend)
- ⚠️ More infrastructure to manage
- ⚠️ Higher operational costs
- ⚠️ Need to implement auth, storage, etc.

---

## Data Flow Comparison

### Supabase Data Flow

```
User Action → React Component → Data Provider → Supabase Client
                                                      ↓
                                               PostgREST API
                                                      ↓
                                               PostgreSQL
                                                      ↓
                                               Response ← ← ←
```

**Example: Creating a Contact**

```typescript
// Frontend
const { mutate } = useCreate('contacts', {
  data: {
    first_name: 'John',
    last_name: 'Doe',
    email: 'john@example.com'
  }
});

// Data Provider (automatic)
// → POST https://your-project.supabase.co/rest/v1/contacts
// → With body: { first_name: 'John', ... }
// → PostgREST handles the database insert
// ← Returns: { id: 123, first_name: 'John', ... }
```

### Spring Boot Data Flow

```
User Action → React Component → Data Provider → Fetch/Axios
                                                      ↓
                                          Spring Boot Controller
                                                      ↓
                                              Service Layer
                                                      ↓
                                             JPA Repository
                                                      ↓
                                               PostgreSQL
                                                      ↓
                                               Response ← ← ←
```

**Example: Creating a Contact**

```typescript
// Frontend
const { mutate } = useCreate('contacts', {
  data: {
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com'
  }
});

// Custom Data Provider
// → POST https://your-api.com/api/contacts
// → With body: { firstName: 'John', ... }
// → Spring Boot processes request

// Backend (Spring Boot)
@PostMapping("/contacts")
public ResponseEntity<ContactDTO> create(@RequestBody ContactDTO dto) {
  Contact contact = contactService.create(dto);
  return ResponseEntity.ok(toDTO(contact));
}

// ← Returns: { id: 123, firstName: 'John', ... }
```

---

## Migration Path (Supabase → Spring Boot)

If you start with Supabase and later need to migrate to Spring Boot:

```
┌─────────────────────────────────────────────────────────────┐
│                     PHASE 1: Supabase Only                   │
│                                                               │
│  Frontend → Supabase Data Provider → Supabase               │
│                                                               │
│  • Rapid development                                         │
│  • User validation                                           │
│  • Feature completion                                        │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ 3-6 months later (if needed)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  PHASE 2: Parallel Systems                   │
│                                                               │
│  Frontend ─┬→ Supabase Data Provider → Supabase (prod)      │
│            │                                                  │
│            └→ Spring Boot Data Provider → Spring Boot (test)│
│                                                               │
│  • Build Spring Boot backend                                 │
│  • Test with subset of users                                 │
│  • Migrate data incrementally                                │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ After validation
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                 PHASE 3: Spring Boot Only                    │
│                                                               │
│  Frontend → Spring Boot Data Provider → Spring Boot         │
│                                                               │
│  • Switch production traffic                                 │
│  • Deprecate Supabase                                        │
│  • Keep backups                                              │
└─────────────────────────────────────────────────────────────┘
```

**Migration Steps**:

1. **Build Spring Boot backend** matching Supabase schema
2. **Export data** from Supabase PostgreSQL
3. **Import data** to Spring Boot PostgreSQL
4. **Create Spring Boot data provider** in frontend
5. **A/B test** with small user group
6. **Switch environment variable** to use Spring Boot
7. **Monitor and fix** any issues
8. **Deprecate Supabase** but keep backup

---

## Technology Stack Comparison

### Frontend (Same for Both)

| Component | Technology |
|-----------|------------|
| Framework | React 19 |
| Language | TypeScript |
| Build Tool | Vite |
| UI Framework | Shadcn UI + Radix UI |
| Styling | Tailwind CSS v4 |
| State Management | React Query |
| Forms | React Hook Form |
| Routing | React Router v7 |

### Backend Comparison

| Component | Supabase | Spring Boot |
|-----------|----------|-------------|
| Runtime | Node.js (Edge Functions) | JVM (Java 17+) |
| Framework | Supabase Platform | Spring Boot 3.2 |
| API | Auto-generated (PostgREST) | Custom REST controllers |
| Database | PostgreSQL (managed) | PostgreSQL (self-managed) |
| ORM | N/A (direct SQL) | Spring Data JPA |
| Auth | Built-in | Spring Security + JWT |
| Storage | Built-in (S3-like) | AWS S3 / MinIO |
| Real-time | Built-in (WebSocket) | Need to implement |
| Deployment | Managed | Self-hosted (Docker/K8s) |
| Cost | $25/month Pro | $200-300/month infra |

---

## Custom Requirements Implementation

### Example: Lead Number Generation

#### Supabase Approach (PostgreSQL Trigger)

```sql
-- Migration file
CREATE SEQUENCE lead_number_seq START 1;

CREATE OR REPLACE FUNCTION generate_lead_number()
RETURNS TRIGGER AS $$
BEGIN
  NEW.lead_number := 'LEAD-' || 
                     TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' ||
                     LPAD(nextval('lead_number_seq')::TEXT, 5, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_lead_number
BEFORE INSERT ON contacts
FOR EACH ROW
WHEN (NEW.lead_number IS NULL)
EXECUTE FUNCTION generate_lead_number();
```

**No frontend or backend code needed!**

#### Spring Boot Approach (Entity Lifecycle)

```java
// Backend (Entity)
@Entity
public class Contact {
    @Column(name = "lead_number")
    private String leadNumber;
    
    @PrePersist
    protected void onCreate() {
        if (leadNumber == null) {
            leadNumber = generateLeadNumber();
        }
    }
    
    private String generateLeadNumber() {
        // Call repository to get next sequence number
        long seq = sequenceRepository.getNextLeadNumber();
        return String.format("LEAD-%s-%05d",
            LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")),
            seq);
    }
}

// Additional repository needed
public interface SequenceRepository {
    @Query(value = "SELECT nextval('lead_number_seq')", nativeQuery = true)
    Long getNextLeadNumber();
}
```

**More code, but more control.**

---

## Recommended Architecture (Hybrid Approach)

Start with Supabase, but keep Spring Boot option open:

```
┌─────────────────────────────────────────────────────────────┐
│                         FRONTEND                             │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Data Provider Abstraction                     │  │
│  │  (React Admin / ra-core)                              │  │
│  └──────────────────────────────────────────────────────┘  │
│                     │                │                       │
│          ┌──────────┘                └──────────┐           │
│          ▼                                      ▼           │
│  ┌──────────────────┐             ┌──────────────────┐    │
│  │ Supabase         │             │ Spring Boot      │    │
│  │ Data Provider    │             │ Data Provider    │    │
│  │ (Default)        │             │ (Future)         │    │
│  └──────────────────┘             └──────────────────┘    │
└─────────────────────────────────────────────────────────────┘
           │                                    │
           │ Production                         │ Future
           ▼                                    ▼
    ┌─────────────┐                     ┌─────────────┐
    │  Supabase   │                     │ Spring Boot │
    │   Backend   │                     │   Backend   │
    └─────────────┘                     └─────────────┘
```

This approach:
- ✅ Starts fast with Supabase
- ✅ Validates requirements quickly
- ✅ Keeps Spring Boot option available
- ✅ Minimal code changes to switch
- ✅ Best of both worlds

---

## File Structure Comparison

### Supabase Project Structure

```
atomic-crm/
├── src/
│   ├── components/
│   │   └── atomic-crm/
│   │       ├── contacts/        # Contact management
│   │       ├── deals/           # Deal management
│   │       ├── providers/
│   │       │   └── supabase/    # Supabase data provider
│   │       └── ...
│   └── App.tsx
├── supabase/
│   ├── functions/               # Edge functions (TypeScript)
│   ├── migrations/              # Database migrations (SQL)
│   └── config.toml             # Supabase config
└── package.json
```

### Spring Boot Project Structure

```
atomic-crm/
├── frontend/                    # React application
│   ├── src/
│   │   ├── components/
│   │   │   └── atomic-crm/
│   │   │       ├── contacts/
│   │   │       ├── deals/
│   │   │       ├── providers/
│   │   │       │   └── springboot/  # Spring Boot data provider
│   │   │       └── ...
│   │   └── App.tsx
│   └── package.json
└── backend/                     # Spring Boot application
    ├── src/
    │   ├── main/
    │   │   ├── java/com/aarvee/crm/
    │   │   │   ├── controller/  # REST controllers
    │   │   │   ├── service/     # Business logic
    │   │   │   ├── repository/  # Data access
    │   │   │   ├── entity/      # JPA entities
    │   │   │   ├── dto/         # Data transfer objects
    │   │   │   ├── security/    # Auth & JWT
    │   │   │   └── config/      # Configuration
    │   │   └── resources/
    │   │       ├── application.yml
    │   │       └── db/migration/  # Flyway migrations
    │   └── test/
    └── pom.xml
```

---

## Conclusion

Both architectures are viable. The choice depends on:

1. **Timeline**: Need it fast? → Supabase
2. **Team Skills**: Java experts? → Spring Boot, otherwise → Supabase
3. **Integration**: Existing Java systems? → Spring Boot
4. **Budget**: Limited? → Supabase
5. **Control**: Need complete control? → Spring Boot

**Recommended**: Start with Supabase (left side of diagrams), migrate to Spring Boot (right side) only if truly necessary after validating requirements with users.
