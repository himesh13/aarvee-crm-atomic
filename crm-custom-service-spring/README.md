# CRM Custom Service - Spring Boot

Custom Spring Boot microservice for Aarvee CRM business requirements.

## Quick Start

### Prerequisites

- Java 17 or higher
- Maven 3.6+
- PostgreSQL (via Supabase local or remote)

### 1. Install Dependencies

```bash
mvn clean install
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your actual Supabase credentials
```

Required environment variables:
- `DATABASE_URL` - PostgreSQL connection URL
- `DATABASE_USERNAME` - Database username
- `DATABASE_PASSWORD` - Database password
- `SUPABASE_JWT_SECRET` - JWT secret from Supabase
  - **Local development**: `super-secret-jwt-token-with-at-least-32-characters-long`
  - **Production**: Get from Supabase Dashboard → Settings → API → JWT Secret

### 3. Run in Development Mode

```bash
mvn spring-boot:run
```

The service will start on http://localhost:3001

### 4. Build for Production

```bash
mvn clean package
java -jar target/crm-custom-service-1.0.0.jar
```

## Available Scripts

- `mvn spring-boot:run` - Start development server
- `mvn clean install` - Install dependencies
- `mvn clean package` - Build production JAR
- `mvn test` - Run tests
- `mvn clean` - Clean build artifacts

## API Endpoints

### Health Check
- `GET /health` - Check service status

### Lead Extensions
- `POST /api/lead_extensions` - Create lead extension
- `GET /api/lead_extensions` - List lead extensions (with pagination)
  - Query params: `page`, `perPage`, `sortField`, `sortOrder`
- `GET /api/lead_extensions/{id}` - Get single lead extension
- `PUT /api/lead_extensions/{id}` - Update lead extension
- `DELETE /api/lead_extensions/{id}` - Delete lead extension

All API endpoints (except /health) require Bearer token authentication.

## Architecture

### Technology Stack
- **Framework**: Spring Boot 3.2.0
- **Language**: Java 17
- **Database**: PostgreSQL (via JPA/Hibernate)
- **Security**: Spring Security + JWT
- **Build Tool**: Maven

### Project Structure

```
src/main/java/com/aarvee/crm/
├── CrmApplication.java          # Main application class
├── config/
│   ├── CorsConfig.java         # CORS configuration
│   └── SecurityConfig.java     # Security configuration
├── controller/
│   ├── HealthController.java   # Health check endpoint
│   └── LeadExtensionController.java
├── dto/
│   ├── ErrorResponse.java
│   └── PageResponse.java
├── entity/
│   ├── BusinessDetail.java
│   ├── LeadExtension.java
│   ├── PropertyDetail.java
│   └── Reminder.java
├── repository/
│   ├── BusinessDetailRepository.java
│   ├── LeadExtensionRepository.java
│   ├── PropertyDetailRepository.java
│   └── ReminderRepository.java
├── security/
│   └── JwtAuthenticationFilter.java
└── service/
    └── LeadExtensionService.java
```

## Configuration

Configuration is managed through `application.yml` and environment variables.

Key configurations:
- Database connection
- JWT authentication
- CORS settings
- Logging levels

## Testing

Run tests with:
```bash
mvn test
```

## Deployment

### Local Development
1. Ensure Supabase is running locally (`make start-supabase`)
2. Run the service (`mvn spring-boot:run`)

### Production
1. Set environment variables on your hosting platform
2. Build the JAR (`mvn clean package`)
3. Run the JAR with proper environment variables

## Integration with Frontend

The frontend uses a composite data provider that routes custom resources (lead_extensions, etc.) to this Spring Boot service.

Environment variable in frontend:
```
VITE_CUSTOM_SERVICE_URL=http://localhost:3001/api
```

### Authentication Flow

1. **Frontend Login**: User logs in via Supabase authentication
2. **Token Storage**: Supabase stores the JWT access token in the session
3. **API Requests**: Frontend retrieves the token from Supabase session and includes it in requests:
   ```typescript
   Authorization: Bearer <supabase-jwt-token>
   ```
4. **Backend Validation**: Spring Boot validates the JWT token using the Supabase JWT secret
5. **User Context**: Upon successful validation, the user ID from the token is used for authorization

The JWT secret must match between Supabase and the Spring Boot service:
- **Local**: Default is `super-secret-jwt-token-with-at-least-32-characters-long`
- **Production**: Get from Supabase Dashboard → Project Settings → API → JWT Secret

If you get a 403 error when accessing API endpoints, check:
1. The user is logged in (Supabase session exists)
2. The `SUPABASE_JWT_SECRET` in `.env` matches your Supabase configuration
3. The frontend `VITE_CUSTOM_SERVICE_URL` points to the correct Spring Boot service URL

## Development

See the main repository's documentation for complete development workflow.
