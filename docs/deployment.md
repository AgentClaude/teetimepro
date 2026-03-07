# Production Deployment Guide

## Prerequisites

- A VPS with Docker and Docker Compose v2 installed
- A domain pointing to the server's IP (e.g., `app.teetimepro.com`)
- SSH access with a `deploy` user

## Initial Server Setup

### 1. Clone the repository

```bash
ssh deploy@your-server
sudo mkdir -p /opt/teetimepro
sudo chown deploy:deploy /opt/teetimepro
git clone https://github.com/AgentClaude/teetimepro.git /opt/teetimepro
cd /opt/teetimepro
```

### 2. Configure environment

```bash
cp .env.production.example .env
# Edit .env with production values:
#   - Set DOMAIN to your domain
#   - Generate SECRET_KEY_BASE: openssl rand -hex 64
#   - Generate JWT_SECRET_KEY: openssl rand -hex 64
#   - Set strong POSTGRES_PASSWORD and REDIS_PASSWORD
#   - Add Stripe, Twilio, Deepgram keys
#   - Set LETSENCRYPT_EMAIL
nano .env
```

### 3. Obtain SSL certificate

```bash
bin/docker-prod ssl-init
```

This starts a temporary nginx, completes the ACME challenge, and saves the certificate.

### 4. Start all services

```bash
bin/docker-prod up
```

### 5. Verify

```bash
bin/docker-prod status
curl https://app.teetimepro.com/health
```

## Architecture

```
Internet → nginx (80/443)
             ├── /graphql, /api/*  → Rails API (3003)
             ├── /voice/*          → Voice Agent (3005, WebSocket)
             ├── /sidekiq          → Sidekiq Web UI
             ├── /cable            → ActionCable WebSocket
             └── /*                → React Frontend (3000)

Internal:
  ├── PostgreSQL (5432)
  ├── Redis (6379)
  ├── Sidekiq (background jobs)
  └── Certbot (auto-renews SSL every 12h)
```

## Daily Operations

### View logs

```bash
bin/docker-prod logs          # All services
bin/docker-prod logs api      # API only
bin/docker-prod logs nginx    # Nginx access/error logs
```

### Rails console

```bash
bin/docker-prod console
```

### Database backup

```bash
bin/docker-prod backup-db
# Saves to backups/teetimepro_YYYYMMDD_HHMMSS.sql.gz
```

### Database restore

```bash
bin/docker-prod restore-db backups/teetimepro_20260307_120000.sql.gz
```

### Manual deploy

```bash
bin/docker-prod deploy
```

### SSL certificate renewal

Certbot auto-renews every 12 hours. To force:

```bash
bin/docker-prod ssl-renew
```

## CI/CD

Pushes to `main` trigger automatic deployment via GitHub Actions:

1. CI runs (RSpec + TypeScript check + ESLint)
2. If CI passes, SSH deploy to the VPS
3. Rolling restart: API → health check → sidekiq + web + nginx
4. Old Docker images pruned after 7 days

### GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| `VPS_HOST` | Server IP or hostname |
| `VPS_SSH_KEY` | Private SSH key for `deploy` user |

### Skip deploy

Add `[skip deploy]` to your commit message:

```bash
git commit -m "docs: update README [skip deploy]"
```

## Security Notes

- Database and Redis are not exposed externally (no port mappings in prod)
- Redis requires password authentication in production
- PostgreSQL uses `scram-sha-256` authentication
- HTTPS enforced with HSTS (2-year max-age)
- Rate limiting on API endpoints (30 req/s) and login (5 req/min)
- All services run with memory limits

## Troubleshooting

### API won't start

```bash
bin/docker-prod logs api
# Common: missing SECRET_KEY_BASE, database not ready
bin/docker-prod sh api
# Inside: bundle exec rails db:migrate:status
```

### SSL certificate issues

```bash
# Check certificate status
docker run --rm -v teetimepro_certbot_certs:/etc/letsencrypt certbot/certbot certificates

# Force renewal
bin/docker-prod ssl-renew
```

### Out of disk space

```bash
docker system prune -a --volumes  # ⚠️ Removes unused volumes too
```
