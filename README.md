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

To run this project locally, you will need the following tools installed on your computer:

- Make
- Node 22 LTS
- Docker (required by Supabase)

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

## User Documentation

1. [User Management](./doc/src/content/docs/users/user-management.mdx)
2. [Importing And Exporting Data](./doc/src/content/docs/users/import-contacts.mdx)
3. [Inbound Email](./doc/src/content/docs/users/inbound-email.mdx)

## Deploying to Production

1. [Configuring Supabase](./doc/src/content/docs/developers/supabase-configuration.mdx)
2. [Configuring Inbound Email](./doc/src/content/docs/developers/inbound-email-configuration.mdx) *(optional)*
3. [Deployment](./doc/src/content/docs/developers/deploy.mdx)

## Customizing Atomic CRM

To customize Atomic CRM, you will need TypeScript and React programming skills as there is no graphical user interface for customization. Here are some resources to assist you in getting started.

1. [Customizing the CRM](./doc/src/content/docs/developers/customizing.mdx)
2. [Creating Migrations](./doc/src/content/docs/developers/migrations.mdx) *(optional)*
3. [Using Fake Rest Data Provider for Development](./doc/src/content/docs/developers/data-providers.mdx) *(optional)*
4. [Architecture Decisions](./doc/src/content/docs/developers/architecture-choices.mdx) *(optional)*

## 🗺️ Product Roadmap & Feature Planning

Want to understand the complete feature set and plan your CRM development? We have comprehensive roadmap documentation:

📋 **[ROADMAP_SUMMARY.md](./ROADMAP_SUMMARY.md)** - Quick overview of all planned features

**Roadmap Documentation**:
- **[ROADMAP.md](./ROADMAP.md)** - Comprehensive feature roadmap with 8 development phases
- **[FEATURE_TASKS.md](./FEATURE_TASKS.md)** - Detailed breakdown of 50+ tasks with acceptance criteria
- **[GITHUB_PROJECT_SETUP.md](./GITHUB_PROJECT_SETUP.md)** - Guide for creating GitHub Project Board
- **[BusinessRequirements.md](./BusinessRequirements.md)** - Original business requirements document

### 🚀 Create Your GitHub Project

We've created an automated script to set up a complete GitHub Project with all feature tasks:

```bash
# Create GitHub Project with all 50+ feature issues
./scripts/create-github-project.sh

# Or create just the project (add issues manually)
./scripts/create-project-only.sh
```

**Timeline Estimate**: 6-8 months for full implementation  
**MVP Ready**: 2-3 months (Phase 1 complete)

## Spring Boot Backend Integration & Custom Requirements

If you need to implement extensive custom requirements, we have comprehensive documentation covering multiple approaches:

📖 **[Implementation Documentation Overview](./IMPLEMENTATION_DOCS_README.md)** - Start here for a complete guide

### Three Implementation Options:

1. **⭐ Hybrid Architecture (Recommended)** - [HYBRID_ARCHITECTURE_GUIDE.md](./HYBRID_ARCHITECTURE_GUIDE.md)
   - Use Supabase for existing CRM features + Spring Boot microservice for custom requirements
   - **Fastest**: 8-10 weeks | **Most cost-effective**: ~$27K-32K
   - Best of both worlds: Keep Supabase benefits + Full custom flexibility
   - **🚀 NEW: [Spring Boot Setup Guide](./SPRING_BOOT_HYBRID_SETUP_GUIDE.md)** - Complete setup instructions
   - **📝 [Development Workflow](./DEVELOPMENT_WORKFLOW.md)** - Day-to-day development guide

2. **Supabase Only** - [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md)
   - Extend Supabase with custom fields and logic
   - **Timeline**: 12 weeks | **Cost**: ~$38K
   - Good for simpler customizations

3. **Full Spring Boot Migration** - [SPRING_BOOT_IMPLEMENTATION_GUIDE.md](./SPRING_BOOT_IMPLEMENTATION_GUIDE.md)
   - Replace Supabase entirely with Spring Boot backend
   - **Timeline**: 20-24 weeks | **Cost**: ~$64K
   - Only if you need complete backend control

**Additional Documentation**:
- [Spring Boot Feasibility Analysis](./SPRING_BOOT_FEASIBILITY.md) - Detailed analysis of all approaches
- [Requirements Mapping](./REQUIREMENTS_MAPPING.md) - Field-by-field implementation details
- [Architecture Diagrams](./ARCHITECTURE_DIAGRAMS.md) - Visual comparison of architectures

**TL;DR**: For custom lead management, business details, disbursements, and reminders → use **Hybrid Architecture** (saves time and money while maintaining flexibility).

### 🎯 Quick Start with Spring Boot Hybrid Architecture

Ready to start building custom features? Follow these steps:

```bash
# 1. Clone and install
git clone https://github.com/himesh13/aarvee-crm-atomic.git
cd aarvee-crm-atomic
make install

# 2. Start Supabase
make start

# 3. Setup custom Spring Boot service
cd crm-custom-service-spring
cp .env.example .env
# Edit .env with your Supabase JWT secret
mvn clean install

# 4. Start custom service
mvn spring-boot:run
```

See **[SPRING_BOOT_HYBRID_SETUP_GUIDE.md](./SPRING_BOOT_HYBRID_SETUP_GUIDE.md)** for complete instructions.

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
