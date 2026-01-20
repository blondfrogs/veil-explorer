# Docker Deployment Guide for Veil Explorer

This guide explains how to deploy the Veil Explorer using Docker and Docker Compose.

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Running Veil node with RPC enabled (see [Veil Node Configuration](#veil-node-configuration))

## Quick Start

### 1. Configure Environment Variables

Copy the example environment file and customize it:

```bash
cp .env.example .env
```

Edit `.env` and update the following required variables:
- `POSTGRES_PASSWORD` - Secure password for PostgreSQL
- `VEIL_RPC_USER` - RPC username from your veil.conf
- `VEIL_RPC_PASSWORD` - RPC password from your veil.conf
- `VEIL_NODE_URL` - URL to your Veil node RPC endpoint

### 2. Configure Backend Settings

Copy the backend configuration template:

```bash
cp explorer-backend/appsettings.json.tpl explorer-backend/appsettings.json
```

**Important:** The database and Redis connection strings will be overridden by Docker environment variables, but you may want to customize other settings in this file.

### 3. Start the Services

```bash
docker-compose up -d
```

This will:
- Create and initialize the PostgreSQL database with required schemas
- Start Redis cache server
- Build and start the backend API (processes URL templates during build)
- Build and start the frontend

**Note:** The Docker build automatically processes template files (`fetchtxs.html.tpl`, `_robots.txt.tpl`) and generates final files with your configured URLs. The repository includes development versions with localhost defaults for non-Docker users.

### 4. Access the Explorer

- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:5000
- **Swagger API Docs:** http://localhost:5000/swagger

### 5. Monitor Logs

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres
```

### 6. Initial Synchronization

The backend will automatically start synchronizing with your Veil node. This may take some time depending on the blockchain height. Monitor the backend logs to track progress:

```bash
docker-compose logs -f backend
```

## Veil Node Configuration

Your Veil node **must** be configured with the following settings in `veil.conf`:

### Required Settings

```conf
# Enable server mode
server=1

# Listen for connections
listen=1

# RPC bind address
rpcbind=127.0.0.1

# RPC port
rpcport=5050

# RPC authentication (choose one method below)

# Method 1: rpcauth (recommended)
# Generate with: python3 rpcauth.py <username> <password>
# Download from: https://github.com/Veil-Project/veil/blob/master/share/rpcauth/rpcauth.py
rpcauth=veilrpc:generated_hash_and_salt

# Method 2: rpcuser/rpcpassword (less secure)
# rpcuser=veilrpc
# rpcpassword=yourpassword

# REQUIRED: Enable transaction index
txindex=1
```

### Generating rpcauth

```bash
# Download the rpcauth script
wget https://raw.githubusercontent.com/Veil-Project/veil/master/share/rpcauth/rpcauth.py

# Generate credentials
python3 rpcauth.py veilrpc your_secure_password

# Copy the output rpcauth line to your veil.conf
```

### Important Notes

- **txindex=1 is REQUIRED** - The explorer needs full transaction indexing
- If you're running Veil node on the same machine as Docker, use `VEIL_NODE_URL=http://host.docker.internal:5050/`
- If Veil node is on a different machine, update the URL accordingly and ensure the RPC port is accessible
- The node must be fully synced before the explorer can function properly

## Docker Compose Services

### postgres
- PostgreSQL 15 database
- Stores blockchain data (blocks, transactions)
- Data persisted in `postgres_data` volume
- Schemas automatically initialized on first run

### redis
- Redis 7 cache server
- 512MB memory limit with LRU eviction policy
- Used for caching API responses and blockchain info
- Data persisted in `redis_data` volume

### backend
- ASP.NET Core 8.0 API
- Connects to Veil node via RPC
- Syncs blockchain data to PostgreSQL
- Provides REST API for frontend
- Logs stored in `backend_logs` volume

### frontend
- Nuxt 3 (Vue.js) application
- Server-side rendering
- Connects to backend API
- Responsive web interface

## Configuration

### Environment Variables

See `.env.example` for all available configuration options.

Key variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_PASSWORD` | PostgreSQL password | changeme |
| `VEIL_NODE_URL` | Veil RPC endpoint | http://host.docker.internal:5050/ |
| `VEIL_RPC_USER` | Veil RPC username | veilrpc |
| `VEIL_RPC_PASSWORD` | Veil RPC password | changeme |
| `BACKEND_PORT` | Backend API port | 5000 |
| `FRONTEND_PORT` | Frontend web port | 3000 |
| `SITE_URL` | Public URL for the explorer | http://localhost:3000 |

### Production Deployment

For production deployments:

1. **Use secure passwords** - Change all default passwords in `.env`
2. **Update SITE_URL** - Set to your actual domain
3. **Configure reverse proxy** - Use nginx or similar (see [docs/setup/nginx.md](docs/setup/nginx.md))
4. **Enable HTTPS** - Use Let's Encrypt or similar
5. **Backup volumes** - Regularly backup `postgres_data` volume
6. **Monitor resources** - Adjust memory limits as needed

### Configuring Your Own Domain

The Veil Explorer is designed to be easily deployed with your own domain. All domain-specific URLs are configured through environment variables in the `.env` file.

**Key Environment Variables for Domain Configuration:**

| Variable | Description | Example |
|----------|-------------|---------|
| `SITE_URL` | Public-facing URL for the frontend (used for SEO, canonical URLs, sitemaps) | `https://explorer.yourdomain.com` |
| `FRONTEND_URL` | Frontend application URL (used for CORS) | `https://explorer.yourdomain.com` |
| `BACKEND_API_URL` | Public API endpoint URL | `https://explorer.yourdomain.com/api` |
| `INTERNAL_API_URL` | Internal API endpoint (SignalR, exports) | `https://explorer.yourdomain.com/api/internal` |

**During Docker build, the following files are automatically generated from templates:**
- `explorer-frontend/public/fetchtxs.html` - Transaction export tool (uses `INTERNAL_API_URL`)
- `explorer-frontend/public/_robots.txt` - Search engine robots file (uses `SITE_URL`)

**Common Production Configurations:**

**Single Domain (API under /api path):**
```bash
FRONTEND_URL=https://explorer.yourdomain.com
SITE_URL=https://explorer.yourdomain.com
BACKEND_API_URL=https://explorer.yourdomain.com/api
INTERNAL_API_URL=https://explorer.yourdomain.com/api/internal
```

**Separate Subdomains:**
```bash
FRONTEND_URL=https://explorer.yourdomain.com
SITE_URL=https://explorer.yourdomain.com
BACKEND_API_URL=https://api.yourdomain.com/api
INTERNAL_API_URL=https://api.yourdomain.com/api/internal
```

**Custom Ports (Development/Private Network):**
```bash
FRONTEND_URL=http://192.168.1.100:3000
SITE_URL=http://192.168.1.100:3000
BACKEND_API_URL=http://192.168.1.100:5000/api
INTERNAL_API_URL=http://192.168.1.100:5000/api/internal
```

**Optional External Links (shown in footer):**
```bash
VEIL_PROJECT_URL=https://veil-project.com
VEIL_STATS_URL=https://veil-stats.com
VEIL_TOOLS_URL=https://veil.tools
GITHUB_REPO_URL=https://github.com/yourusername/veil-explorer
```

**After configuring your domain settings:**
```bash
# Rebuild with new configuration
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Management Commands

### Stop Services
```bash
docker-compose down
```

### Stop and Remove Volumes (Warning: Deletes all data)
```bash
docker-compose down -v
```

### Rebuild Services
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Restart a Single Service
```bash
docker-compose restart backend
```

### View Service Status
```bash
docker-compose ps
```

### Execute Commands in Containers
```bash
# Access PostgreSQL
docker-compose exec postgres psql -U veilexplorer

# Access backend shell
docker-compose exec backend /bin/bash

# Access Redis CLI
docker-compose exec redis redis-cli
```

## Troubleshooting

### Backend can't connect to Veil node

**Symptom:** Backend logs show RPC connection errors

**Solutions:**
- Verify Veil node is running and accessible
- Check `VEIL_NODE_URL` in `.env` matches your node's RPC endpoint
- Ensure `txindex=1` is set in veil.conf
- Verify RPC credentials match between veil.conf and `.env`
- For same-machine deployments, use `http://host.docker.internal:5050/`

### Database connection errors

**Symptom:** Backend can't connect to PostgreSQL

**Solutions:**
- Wait for PostgreSQL to be fully ready (check `docker-compose logs postgres`)
- Verify `POSTGRES_PASSWORD` matches in `.env`
- Ensure postgres service is healthy: `docker-compose ps`

### Frontend shows "API not available"

**Symptom:** Frontend loads but shows API connection errors

**Solutions:**
- Verify backend is running: `docker-compose logs backend`
- Check `BACKEND_API_URL` in `.env` is correct
- Ensure CORS origins are configured correctly in `appsettings.json`

### Port already in use

**Symptom:** `Error: bind: address already in use`

**Solutions:**
- Change the conflicting port in `.env` (e.g., `FRONTEND_PORT=3001`)
- Stop the service using that port
- Use `docker-compose down` before restarting

## Volumes and Data Persistence

Docker volumes store persistent data:

- `postgres_data` - Database files
- `redis_data` - Redis cache (can be safely deleted)
- `backend_data` - Backend application data
- `backend_logs` - Application logs

### Backup Database

```bash
# Create backup
docker-compose exec postgres pg_dump -U veilexplorer veilexplorer > backup.sql

# Restore backup
docker-compose exec -T postgres psql -U veilexplorer veilexplorer < backup.sql
```

## Updates and Maintenance

### Updating the Explorer

```bash
# Pull latest code
git pull

# Rebuild and restart services
docker-compose build --no-cache
docker-compose up -d
```

### Viewing Resource Usage

```bash
docker stats
```

## Support

For issues and support:
- GitHub Issues: https://github.com/steel97/veil-explorer/issues
- Veil Project: https://veil-project.com
- Documentation: See [/docs](/docs) directory

## Additional Resources

- [Backend Configuration](docs/backend-configuration.md)
- [Frontend Configuration](docs/frontend-configuration.md)
- [API Documentation](docs/api.md)
- [Full Setup Tutorial](docs/setup/)
