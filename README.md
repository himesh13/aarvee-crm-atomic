# Atomic CRM

A full-featured CRM built with React, shadcn-admin-kit, and Supabase.

https://github.com/user-attachments/assets/0d7554b5-49ef-41c6-bcc9-a76214fc5c99

Atomic CRM is free and open-source. You can test it online at https://marmelab.com/atomic-crm-demo.

## Features

- 📇 **Organize Contacts**: Keep all your contacts in one easily accessible place.
- ⏰ **Create Tasks & Set Reminders**: Never miss a follow-up or deadline.
- 📝 **Take Notes**: Capture important details and insights effortlessly.
- ✉️ **Capture Emails**: CC Atomic CRM to automatically save communications as notes.
- 📊 **Manage Deals**: Visualize and track your sales pipeline in a Kanban board.
- 🔄 **Import & Export Data**: Easily transfer contacts in and out of the system.
- 🔐 **Control Access**: Log in with Google, Azure, Keycloak, and Auth0.
- 📜 **Track Activity History**: View all interactions in aggregated activity logs.
- 🔗 **Integrate via API**: Connect seamlessly with other systems using our API.
- 🛠️ **Customize Everything**: Add custom fields, change the theme, and replace any component to fit your needs.

## Installation

### Option 1: Docker Setup (Recommended - Simplest)

The easiest way to run the entire stack is using Docker. This method requires minimal setup and handles all services automatically.

**Prerequisites:**
- Docker Desktop (or Docker Engine + Docker Compose)
- Node 22 LTS
- Make

**Quick Start:**

```sh
# Clone the repository
git clone https://github.com/[username]/atomic-crm.git
cd atomic-crm

# Install dependencies (one-time setup)
make docker-install

# Start everything with one command
make docker-start
```

This will start:
- ✅ Supabase (PostgreSQL, REST API, Auth, Storage)
- ✅ Spring Boot custom service
- ✅ React frontend with hot reload

Access the application at [http://localhost:5173/](http://localhost:5173/)

For detailed Docker documentation, see [DOCKER.md](./DOCKER.md).

**Docker Commands:**
```sh
make docker-start     # Start all services
make docker-stop      # Stop all services
make docker-logs      # View logs
make docker-restart   # Restart all services
```

### Option 2: Traditional Setup (Manual)

To run this project locally without Docker for the frontend and Spring Boot (Supabase still uses Docker internally), you will need the following tools installed on your computer:

- Make
- Node 22 LTS
- Docker (required by Supabase)
- Java 17+ and Maven 3.6+ (for Spring Boot service)

Fork the [`marmelab/atomic-crm`](https://github.com/marmelab/atomic-crm) repository to your user/organization, then clone it locally:

```sh
git clone https://github.com/[username]/atomic-crm.git
```

Install dependencies:

```sh
cd atomic-crm
make install
```

This will install the dependencies for the frontend and the backend, including a local Supabase instance.

Once your app is configured, start the app locally with the following command:

```sh
make start
```

This will start the Vite dev server for the frontend, the local Supabase instance for the API, and a Postgres database (thanks to Docker).

You can then access the app via [http://localhost:5173/](http://localhost:5173/). You will be prompted to create the first user.

If you need debug the backend, you can access the following services: 

- Supabase dashboard: [http://localhost:54323/](http://localhost:54323/)
- REST API: [http://127.0.0.1:54321](http://127.0.0.1:54321)
- Attachments storage: [http://localhost:54323/project/default/storage/buckets/attachments](http://localhost:54323/project/default/storage/buckets/attachments)
- Inbucket email testing service: [http://localhost:54324/](http://localhost:54324/)

## Hybrid Architecture: Supabase + Node.js + Spring Boot

This CRM follows a **hybrid architecture** approach:

- **Supabase + Node.js**: Powers existing CRM features (contacts, companies, deals, tasks, notes)
- **Spring Boot**: Custom microservice for business-specific requirements and extensions
- **Shared PostgreSQL Database**: Both services connect to the same Supabase PostgreSQL instance

### Docker Setup (Recommended)

If you used the Docker setup above (`make docker-start`), all services including Spring Boot are already running! Skip to the next section.

### Manual Spring Boot Setup

If you're using the traditional setup and want to run the Spring Boot service manually:

For custom business requirements (e.g., custom fields, workflows, integrations):

```bash
# Navigate to Spring Boot service
cd crm-custom-service-spring

# Copy environment configuration
cp .env.example .env
# The .env.example has default local settings configured
# For production, update .env with your actual Supabase credentials

# Install dependencies
mvn clean install

# Start the custom service (runs on port 3001)
mvn spring-boot:run
```

The Spring Boot service connects to the same PostgreSQL database as Supabase, allowing seamless data integration.

**Important: Authentication Setup**
- The Spring Boot service validates Supabase JWT tokens for authentication
- Frontend automatically includes the Supabase JWT token in API requests to the custom service
- For local development, the JWT secret in `.env` is pre-configured to work with local Supabase
- For production, update `SUPABASE_JWT_SECRET` in `.env` with your actual Supabase JWT secret from the dashboard

**Database Integration Notes:**
- Both services use the same Supabase PostgreSQL database
- Spring Boot connects via standard JDBC with credentials from `.env`
- Supabase handles existing CRM tables (contacts, companies, deals, etc.)
- Spring Boot manages custom tables for business-specific features
- Authentication is handled via Supabase JWT tokens validated by both services

**Local Service URLs:**
- Frontend: http://localhost:5173/
- Supabase API: http://127.0.0.1:54321
- Spring Boot API: http://localhost:3001
- Supabase Dashboard: http://localhost:54323/

See **[AGENTS.md](./AGENTS.md)** for detailed development workflow, architecture patterns, and customization guide. For Spring Boot service details, see **[crm-custom-service-spring/README.md](./crm-custom-service-spring/README.md)**.

## Documentation

For detailed documentation on user guides, deployment, and customization, see the `doc/` directory:
- User Management: `./doc/src/content/docs/users/user-management.mdx`
- Importing/Exporting Data: `./doc/src/content/docs/users/import-contacts.mdx`
- Deployment Guide: `./doc/src/content/docs/developers/deploy.mdx`
- Customization Guide: `./doc/src/content/docs/developers/customizing.mdx`

## Testing Changes

This project contains unit tests. Run them with the following command:

```sh
make test
```

You can add your own unit tests powered by Jest anywhere in the `src` directory. The test files should be named `*.test.tsx` or `*.test.ts`.

## Registry

Atomic CRM components are published as a Shadcn Registry file:
- The `registry.json` file is automatically generated by the `scripts/generate-registry.mjs` script as a pre-commit hook.
- The `http://marmelab.com/atomic-crm/r/atomic-crm.json` file is automatically published by the CI/CD pipeline

> [!WARNING]  
> If the `registry.json` misses some changes you made, you MUST update the `scripts/generate-registry.mjs` to include those changes.

## License

This project is licensed under the MIT License, courtesy of [Marmelab](https://marmelab.com). See the [LICENSE.md](./LICENSE.md) file for details.
