# Security Guidelines

## Configuration Files

This repository contains example/template files for configuration. **Never commit files with real credentials to git.**

### Protected Files (Already in .gitignore)

The following files contain sensitive information and are automatically ignored by git:

- `.env` - Docker environment variables with passwords
- `explorer-backend/appsettings.json` - Backend configuration with RPC credentials
- `scripts/backup-watchonly-addresses.sh` - Backup script with credentials

### Setup Instructions

**Always copy from example files and configure with your own credentials:**

#### 1. Docker Environment

```bash
# Copy example file
cp .env.example .env

# Edit with your credentials
nano .env
```

#### 2. Backend Configuration

```bash
# Copy template
cp explorer-backend/appsettings.json.tpl explorer-backend/appsettings.json

# Edit if needed (most settings come from .env)
nano explorer-backend/appsettings.json
```

#### 3. Backup Script

```bash
# Copy example
cp scripts/backup-watchonly-addresses.sh.example scripts/backup-watchonly-addresses.sh

# Configure with your paths and credentials
nano scripts/backup-watchonly-addresses.sh

# Make executable
chmod +x scripts/backup-watchonly-addresses.sh
```

## Before Committing

**Always verify you're not committing secrets:**

```bash
# Check what will be committed
git status

# Review changes
git diff

# Verify .gitignore is working
git check-ignore .env
git check-ignore explorer-backend/appsettings.json
git check-ignore scripts/backup-watchonly-addresses.sh
```

All three commands should output the filename, confirming they're ignored.

## If You Accidentally Commit Secrets

If you accidentally commit credentials to git:

1. **Immediately change all passwords/credentials**
2. **Remove from git history:**

```bash
# Remove file from history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/file" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (if already pushed to remote)
git push origin --force --all
```

3. **Consider the credentials compromised** - rotate all keys/passwords

## Best Practices

### Passwords

- ✅ Use strong, random passwords (20+ characters)
- ✅ Different password for each service
- ✅ Store in password manager
- ✅ Never commit to version control
- ❌ Don't use default passwords in production
- ❌ Don't share passwords in chat/email

### SSH Keys

- ✅ Use SSH keys for remote backups
- ✅ Protect private keys: `chmod 600 ~/.ssh/id_rsa`
- ✅ Use different keys for different purposes
- ❌ Never commit private keys to git
- ❌ Don't reuse keys across servers

### RPC Security

- ✅ Use `rpcauth` (hashed) instead of `rpcuser`/`rpcpassword`
- ✅ Bind RPC to localhost or specific IPs only
- ✅ Use firewall to restrict RPC port access
- ✅ Enable only required RPC methods in whitelist
- ❌ Don't expose RPC port to internet
- ❌ Don't use weak RPC passwords

### Docker

- ✅ Use `network_mode: host` carefully (only when needed)
- ✅ Limit exposed ports to necessary ones
- ✅ Keep images updated
- ✅ Review logs for suspicious activity
- ❌ Don't run containers as root unnecessarily
- ❌ Don't expose internal services publicly

## Reporting Security Issues

If you discover a security vulnerability, please email:
- **DO NOT** open a public GitHub issue
- Contact the maintainers privately
- Allow time for fix before public disclosure

## Regular Security Maintenance

### Weekly

- [ ] Review access logs for suspicious activity
- [ ] Check for failed login attempts
- [ ] Verify backups are working

### Monthly

- [ ] Update Docker images
- [ ] Review and rotate credentials if needed
- [ ] Check for security updates

### Quarterly

- [ ] Full security audit
- [ ] Test backup restoration
- [ ] Review firewall rules
- [ ] Update dependencies

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [SSH Key Security](https://www.ssh.com/academy/ssh/key)
