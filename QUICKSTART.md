# Quick Start Guide - Docker Setup

## 🚀 Get Started in 60 Seconds

### Step 1: Install Prerequisites (One-time)

**Install Docker Desktop:**
- Windows/Mac: Download from https://www.docker.com/products/docker-desktop
- Linux: Follow instructions at https://docs.docker.com/engine/install/

**Verify Docker is running:**
```bash
docker --version
```

### Step 2: Clone and Setup (One-time)

```bash
# Clone the repository
git clone https://github.com/[your-username]/aarvee-crm-atomic.git
cd aarvee-crm-atomic

# Install Node dependencies
npm install
```

### Step 3: Start Everything 

**Option A - Using Make (Recommended):**
```bash
make docker-start
```

**Option B - Using Shell Script:**
```bash
./docker-start.sh
```

**That's it!** ✨

Wait 10-30 seconds and access:
- **Application**: http://localhost:5173
- **API**: http://localhost:3001
- **Database Dashboard**: http://localhost:54323

### Step 4: Verify Setup

```bash
make docker-verify
```

### Step 5: Stop When Done

```bash
make docker-stop
# OR
./docker-stop.sh
```

---

## 📝 Common Commands

```bash
# Daily use
make docker-start       # Start everything
make docker-stop        # Stop everything
make docker-restart     # Restart all services

# Development
make docker-logs        # View all logs
make docker-verify      # Check if working

# Troubleshooting
make docker-clean       # Clean and reset
make docker-build       # Rebuild containers
```

---

## 🎯 What This Does

The `make docker-start` command:
1. ✅ Starts Supabase (PostgreSQL, Auth, Storage, API)
2. ✅ Builds and starts Spring Boot custom service
3. ✅ Builds and starts React frontend with hot reload
4. ✅ Configures networking between all services
5. ✅ Applies database migrations automatically

All in **one command**, **one terminal window**.

---

## 🆘 Troubleshooting

### Problem: "Cannot connect to Docker daemon"
**Solution:**
```bash
# Make sure Docker Desktop is running
# On Windows/Mac: Start Docker Desktop application
# On Linux: sudo systemctl start docker
```

### Problem: "Port already in use"
**Solution:**
```bash
# Stop any existing services
make docker-stop
npx supabase stop

# Or find and kill process on specific port
lsof -ti :5173 | xargs kill -9
```

### Problem: "Frontend not loading"
**Solution:**
```bash
# Check if services are running
make docker-verify

# View logs
make docker-logs-frontend

# Restart services
make docker-restart
```

### Problem: "Spring Boot service failing"
**Solution:**
```bash
# Check logs
make docker-logs-spring

# Rebuild Spring Boot container
docker compose up -d --build spring-service
```

### Still Having Issues?
Run the verification script for detailed diagnostics:
```bash
./docker-verify.sh
```

---

## 📚 Learn More

- **Full Docker Guide**: See [DOCKER.md](./DOCKER.md)
- **Setup Comparison**: See [SETUP_COMPARISON.md](./SETUP_COMPARISON.md)
- **Main README**: See [README.md](./README.md)

---

## 💡 Tips

1. **First time?** The first `make docker-start` will take 5-8 minutes to build Docker images. Subsequent starts are 10-30 seconds.

2. **Hot reload works!** Edit files in `src/` and changes appear instantly in the browser.

3. **Multiple projects?** Each project uses Docker Compose, so you can run multiple CRMs on different ports.

4. **Clean slate?** Use `make docker-clean` to remove everything and start fresh.

5. **VS Code users?** The Docker extension provides a nice UI for managing containers.

---

## ✅ Success Indicators

You know everything is working when:
- ✅ `make docker-verify` shows all green checkmarks
- ✅ Frontend loads at http://localhost:5173
- ✅ Spring Boot health check returns success: `curl http://localhost:3001/health`
- ✅ No error logs in `make docker-logs`

---

**Happy Coding! 🎉**
