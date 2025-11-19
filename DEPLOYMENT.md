# Veil Explorer Deployment Guide

This guide explains how to deploy the Veil Explorer to any custom server with fully configurable URLs.

## Overview

The Veil Explorer has been refactored to eliminate hardcoded URLs. All configuration is now done through environment variables in the `.env` file. This makes it easy to deploy to any domain without modifying code.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment Scenarios](#deployment-scenarios)
- [Validation](#validation)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

- **Docker** (20.10+)
- **Docker Compose** (2.0+)
- **Veil Node** with RPC enabled and `txindex=1`

### Installation

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Git
sudo apt-get install git

# Clone repository
git clone https://github.com/steel97/veil-explorer
cd veil-explorer
```

---

## Quick Start

### 1. Configure Environment

Copy the example configuration:

```bash
cp .env.example .env
```

Edit `.env` and update all URLs for your deployment:

```bash
nano .env
```

**Minimum required changes:**
- `SITE_URL` - Your frontend URL
- `FRONTEND_URL` - Same as SITE_URL
- `BACKEND_API_URL` - Your API URL
- `INTERNAL_API_URL` - Your internal API URL
- `VEIL_RPC_USER` - Your Veil node RPC username
- `VEIL_RPC_PASSWORD` - Your Veil node RPC password
- `POSTGRES_PASSWORD` - Secure database password

### 2. Validate Configuration

Run the validation script to check your configuration:

```bash
./scripts/validate-config.sh
```

This will verify all required variables are set.

### 3. Start Services

```bash
docker compose up -d
```

### 4. Monitor Startup

```bash
# Watch all logs
docker compose logs -f

# Watch just backend sync progress
docker compose logs -f backend
```

---

## Configuration

### Complete Environment Variables Reference

#### Deployment Settings

```bash
DEPLOYMENT_ENV=production              # development, staging, or production
```

#### Frontend URLs

```bash
SITE_URL=http://explorer.yourdomain.com           # Public frontend URL
FRONTEND_URL=http://explorer.yourdomain.com       # Same as SITE_URL (for CORS)
FRONTEND_PORT=3000                                 # Internal port (default: 3000)
```

#### Backend URLs

```bash
BACKEND_API_URL=http://api.yourdomain.com/api              # Public API URL
INTERNAL_API_URL=http://api.yourdomain.com/api/internal    # Internal API URL (SignalR)
BACKEND_PORT=5000                                           # Internal port (default: 5000)
```

#### Database

```bash
POSTGRES_USER=veilexplorer              # Database username
POSTGRES_PASSWORD=changeme              # Database password (CHANGE THIS!)
POSTGRES_HOST=localhost                 # Database host
POSTGRES_PORT=5432                      # Database port
POSTGRES_DB=veilexplorer                # Database name
```

#### Redis Cache

```bash
REDIS_HOST=localhost                    # Redis host
REDIS_PORT=6379                         # Redis port
```

#### Veil Node

```bash
VEIL_NODE_URL=http://host.docker.internal:5050/  # Veil node RPC URL
VEIL_RPC_USER=veilrpc                             # RPC username
VEIL_RPC_PASSWORD=changeme                        # RPC password (CHANGE THIS!)
```

#### External Links (Footer)

```bash
VEIL_PROJECT_URL=https://veil-project.com
VEIL_STATS_URL=https://veil-stats.com
VEIL_TOOLS_URL=https://veil.tools
GITHUB_REPO_URL=https://github.com/steel97/veil-explorer
```

---

## Deployment Scenarios

### Scenario 1: Single Domain with /api Path

**Example:** `https://explorer.example.com`

```bash
SITE_URL=https://explorer.example.com
FRONTEND_URL=https://explorer.example.com
BACKEND_API_URL=https://explorer.example.com/api
INTERNAL_API_URL=https://explorer.example.com/api/internal
```

**Reverse Proxy Configuration (nginx):**

```nginx
server {
    listen 80;
    server_name explorer.example.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api {
        proxy_pass http://localhost:5000/api;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Scenario 2: Separate Subdomains

**Example:** `https://explorer.example.com` and `https://api.example.com`

```bash
SITE_URL=https://explorer.example.com
FRONTEND_URL=https://explorer.example.com
BACKEND_API_URL=https://api.example.com/api
INTERNAL_API_URL=https://api.example.com/api/internal
```

**DNS Configuration:**
- `explorer.example.com` → A record → Server IP
- `api.example.com` → A record → Server IP (or CNAME to explorer)

**Traffic Forwarding:**
- `explorer.example.com:80/443` → Server port 3000
- `api.example.com:80/443` → Server port 5000

### Scenario 3: Custom Ports (Development/Private Network)

**Example:** HTTP with custom ports on private network

```bash
SITE_URL=http://192.168.1.100:3000
FRONTEND_URL=http://192.168.1.100:3000
BACKEND_API_URL=http://192.168.1.100:5000/api
INTERNAL_API_URL=http://192.168.1.100:5000/api/internal
```

**No reverse proxy needed** - just forward ports directly.

### Scenario 4: Behind Load Balancer

**Example:** Cloud deployment with load balancer

```bash
SITE_URL=https://explorer.example.com
FRONTEND_URL=https://explorer.example.com
BACKEND_API_URL=https://explorer.example.com/api
INTERNAL_API_URL=https://explorer.example.com/api/internal
```

**Load Balancer Configuration:**
- Route `/` → Frontend target group (port 3000)
- Route `/api/*` → Backend target group (port 5000)
- Enable sticky sessions for SignalR connections

---

## Validation

### Pre-Deployment Validation

Before deploying, validate your configuration:

```bash
./scripts/validate-config.sh
```

This script checks:
- ✓ All required environment variables are set
- ✓ Configuration file exists
- ⚠ Warns about missing optional variables

### Post-Deployment Validation

After deployment, verify services are running:

```bash
# Check service status
docker compose ps

# All services should show "healthy" or "running"
```

Test endpoints:

```bash
# Test frontend (should return HTML)
curl http://localhost:3000

# Test backend API (should return JSON)
curl http://localhost:5000/api/blockchain/info
```

---

## Troubleshooting

### Problem: Frontend redirects to wrong domain

**Cause:** The frontend was built with wrong `SITE_URL`

**Solution:**
1. Update `SITE_URL` in `.env`
2. Rebuild frontend:
   ```bash
   docker compose down
   docker compose build --no-cache frontend
   docker compose up -d
   ```

### Problem: API connection errors

**Cause:** CORS not configured or wrong API URL

**Solution:**
1. Verify `FRONTEND_URL` matches your actual frontend URL
2. Verify `BACKEND_API_URL` is accessible from browser
3. Check backend logs: `docker compose logs backend`

### Problem: Backend shows "unhealthy"

**Cause:** Can't connect to Veil node, PostgreSQL, or Redis

**Solution:**
1. Check Veil node is running: `curl http://localhost:5050`
2. Verify RPC credentials in `.env` match `veil.conf`
3. Check backend logs: `docker compose logs backend`

### Problem: Database connection failed

**Cause:** PostgreSQL not ready or wrong credentials

**Solution:**
1. Wait for PostgreSQL to be healthy: `docker compose ps`
2. Verify `POSTGRES_PASSWORD` in `.env`
3. Check logs: `docker compose logs postgres`

### Problem: Port already in use

**Cause:** Another service using port 3000 or 5000

**Solution:**
1. Change ports in `.env`:
   ```bash
   FRONTEND_PORT=3001
   BACKEND_PORT=5001
   ```
2. Update docker-compose.yml port mappings if needed
3. Restart: `docker compose up -d`

---

## Production Recommendations

### Security

1. **Use strong passwords**
   - Generate secure passwords for `POSTGRES_PASSWORD` and `VEIL_RPC_PASSWORD`
   - Never commit `.env` file to git

2. **Use HTTPS**
   - Configure SSL/TLS certificates (Let's Encrypt)
   - Set `SITE_URL` and `BACKEND_API_URL` to use `https://`

3. **Firewall**
   - Only expose ports 80/443 publicly
   - Keep ports 3000, 5000, 5432, 6379 internal

### Performance

1. **Database backups**
   ```bash
   docker compose exec postgres pg_dump -U veilexplorer veilexplorer > backup.sql
   ```

2. **Monitor disk space**
   - Logs are rotated (10MB × 3 files per container)
   - Monitor PostgreSQL data volume growth

3. **Resource allocation**
   - Adjust Docker memory limits if needed
   - Monitor with: `docker stats`

### Maintenance

1. **Update application**
   ```bash
   git pull
   docker compose build --no-cache
   docker compose up -d
   ```

2. **View logs**
   ```bash
   docker compose logs -f
   ```

3. **Restart services**
   ```bash
   docker compose restart backend
   docker compose restart frontend
   ```

---

## Support

For issues and support:
- GitHub Issues: https://github.com/steel97/veil-explorer/issues
- Veil Project: https://veil-project.com
- Documentation: [README.md](README.md) and [DOCKER.md](DOCKER.md)

---

## Configuration Examples

### Development (.env.development)

```bash
DEPLOYMENT_ENV=development
SITE_URL=http://localhost:3000
FRONTEND_URL=http://localhost:3000
BACKEND_API_URL=http://localhost:5000/api
INTERNAL_API_URL=http://localhost:5000/api/internal
VEIL_NODE_URL=http://host.docker.internal:5050/
```

### Production Single Domain (.env.production)

```bash
DEPLOYMENT_ENV=production
SITE_URL=https://explorer.yourdomain.com
FRONTEND_URL=https://explorer.yourdomain.com
BACKEND_API_URL=https://explorer.yourdomain.com/api
INTERNAL_API_URL=https://explorer.yourdomain.com/api/internal
VEIL_NODE_URL=http://127.0.0.1:5050/
```

### Production Separate Subdomains (.env.production-subdomains)

```bash
DEPLOYMENT_ENV=production
SITE_URL=https://explorer.yourdomain.com
FRONTEND_URL=https://explorer.yourdomain.com
BACKEND_API_URL=https://api.yourdomain.com/api
INTERNAL_API_URL=https://api.yourdomain.com/api/internal
VEIL_NODE_URL=http://127.0.0.1:5050/
```
