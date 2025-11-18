# Veil Watch-Only Addresses Backup Setup

This guide explains how to set up automated backups of watch-only addresses from your Veil node using cron.

## What This Does

The `backupwatchonlyaddresses` RPC command exports all watch-only addresses to a JSON file. The backup script:

- ✅ Creates timestamped backups automatically
- ✅ Compresses backups to save space
- ✅ Optionally copies backups to remote server via SCP
- ✅ Cleans up old backups (configurable retention)
- ✅ Logs all operations for auditing

## Prerequisites

- Veil node running with RPC enabled
- Access to `veil-cli` command
- Sufficient disk space for backups
- (Optional) SSH access to remote backup server

## Quick Start

### 1. Copy the Example Script

First, create your script from the example template:

```bash
# Copy the example file
cp /home/main/veil-explorer/scripts/backup-watchonly-addresses.sh.example \
   /home/main/veil-explorer/scripts/backup-watchonly-addresses.sh
```

### 2. Configure the Backup Script

Edit the script configuration:

```bash
nano /home/main/veil-explorer/scripts/backup-watchonly-addresses.sh
```

Update these variables at the top:

```bash
# Veil RPC Settings
VEIL_CLI="/home/main/veil/src/veil-cli"          # Path to veil-cli
RPC_PORT="5050"
RPC_USER="veilrpc"
RPC_PASSWORD="your_rpc_password_here"            # UPDATE THIS!

# Backup Settings
BACKUP_DIR="/home/main/veil-backups/watchonly"   # Where to store backups
RETENTION_DAYS=30                                 # Keep backups for 30 days

# Remote Backup (optional)
ENABLE_REMOTE_BACKUP=false                        # Set to true to enable
REMOTE_USER="backup_user"                         # SSH user
REMOTE_HOST="backup-server.example.com"           # Backup server
REMOTE_PATH="/backups/veil/watchonly/"            # Remote path
SSH_KEY="/home/main/.ssh/id_rsa_backup"          # SSH key path (optional)
```

### 3. Make Script Executable

```bash
chmod +x /home/main/veil-explorer/scripts/backup-watchonly-addresses.sh
```

### 4. Test the Script Manually

```bash
/home/main/veil-explorer/scripts/backup-watchonly-addresses.sh
```

Expected output:
```
[2025-01-18 17:30:00] ==========================================
[2025-01-18 17:30:00] Starting Veil watch-only addresses backup
[2025-01-18 17:30:00] ==========================================
[2025-01-18 17:30:00] Checking if veild is running...
[2025-01-18 17:30:01] veild is running. Proceeding with backup...
[2025-01-18 17:30:01] Creating backup at: /home/main/veil-backups/watchonly/watchonly_backup_20250118_173001.dat
[2025-01-18 17:30:01] RPC Response: { "filepath": "...", "addresses_exported": 3 }
[2025-01-18 17:30:01] Addresses exported: 3
[2025-01-18 17:30:01] Backup created successfully: watchonly_backup_20250118_173001.dat (2.1K)
[2025-01-18 17:30:01] Compressing backup...
[2025-01-18 17:30:01] Backup compressed: watchonly_backup_20250118_173001.dat.gz (1.2K)
[2025-01-18 17:30:01] ==========================================
[2025-01-18 17:30:01] Backup completed successfully!
[2025-01-18 17:30:01] Local backup: /home/main/veil-backups/watchonly/watchonly_backup_20250118_173001.dat.gz
[2025-01-18 17:30:01] ==========================================
```

Check the backup file:
```bash
ls -lh /home/main/veil-backups/watchonly/
```

### 5. Set Up Cron Job

Edit your crontab:

```bash
crontab -e
```

Add one of these lines based on your preferred schedule:

#### Daily Backup at 2 AM
```cron
0 2 * * * /home/main/veil-explorer/scripts/backup-watchonly-addresses.sh >> /home/main/veil-backups/logs/cron.log 2>&1
```

#### Every 6 Hours
```cron
0 */6 * * * /home/main/veil-explorer/scripts/backup-watchonly-addresses.sh >> /home/main/veil-backups/logs/cron.log 2>&1
```

#### Weekly on Sundays at 3 AM
```cron
0 3 * * 0 /home/main/veil-explorer/scripts/backup-watchonly-addresses.sh >> /home/main/veil-backups/logs/cron.log 2>&1
```

#### Every Hour (for critical setups)
```cron
0 * * * * /home/main/veil-explorer/scripts/backup-watchonly-addresses.sh >> /home/main/veil-backups/logs/cron.log 2>&1
```

Save and exit (Ctrl+X, then Y, then Enter).

### 6. Verify Cron Job

Check that your cron job is installed:

```bash
crontab -l
```

Wait for the scheduled time, then check if backup ran:

```bash
ls -lth /home/main/veil-backups/watchonly/ | head
tail -50 /home/main/veil-backups/logs/cron.log
```

## Remote Backup Setup (Optional)

If you want to automatically copy backups to a remote server:

### 1. Set Up SSH Key Authentication

On your Veil server:

```bash
# Generate SSH key if you don't have one
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_backup -N ""

# Copy public key to backup server
ssh-copy-id -i ~/.ssh/id_rsa_backup.pub backup_user@backup-server.example.com
```

Test SSH connection:

```bash
ssh -i ~/.ssh/id_rsa_backup backup_user@backup-server.example.com
```

### 2. Create Backup Directory on Remote Server

On the remote server:

```bash
mkdir -p /backups/veil/watchonly
chmod 700 /backups/veil/watchonly
```

### 3. Enable Remote Backup in Script

Edit the script:

```bash
nano /home/main/veil-explorer/scripts/backup-watchonly-addresses.sh
```

Update these settings:

```bash
ENABLE_REMOTE_BACKUP=true
REMOTE_USER="backup_user"
REMOTE_HOST="backup-server.example.com"
REMOTE_PATH="/backups/veil/watchonly/"
SSH_KEY="/home/main/.ssh/id_rsa_backup"
```

### 4. Test Remote Backup

```bash
/home/main/veil-explorer/scripts/backup-watchonly-addresses.sh
```

Verify on remote server:

```bash
ssh backup_user@backup-server.example.com "ls -lh /backups/veil/watchonly/"
```

## Understanding Cron Syntax

Cron format: `minute hour day month day_of_week command`

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6, Sunday = 0)
│ │ │ │ │
│ │ │ │ │
* * * * * command
```

### Common Examples

| Schedule | Cron Expression | Description |
|----------|----------------|-------------|
| Every hour | `0 * * * *` | On the hour |
| Every 6 hours | `0 */6 * * *` | At 00:00, 06:00, 12:00, 18:00 |
| Daily at 2 AM | `0 2 * * *` | Once per day |
| Daily at midnight | `0 0 * * *` | Once per day |
| Every Sunday at 3 AM | `0 3 * * 0` | Weekly |
| Every Monday at 4 AM | `0 4 * * 1` | Weekly |
| 1st of month at 2 AM | `0 2 1 * *` | Monthly |
| Every 15 minutes | `*/15 * * * *` | 4 times per hour |
| Every 30 minutes | `*/30 * * * *` | 2 times per hour |

Use [crontab.guru](https://crontab.guru/) to generate and verify cron expressions.

## Backup File Format

The backup file is a JSON file containing watch-only addresses. Example:

```json
{
  "addresses": [
    {
      "address": "bv1q...",
      "label": "Exchange Deposit",
      "timestamp": 1705593600
    },
    {
      "address": "sv1q...",
      "label": "Cold Wallet",
      "timestamp": 1705593700
    }
  ],
  "exported_at": "2025-01-18T17:30:00Z",
  "version": 1
}
```

## Restoring from Backup

To restore watch-only addresses from a backup:

```bash
# Decompress if needed
gunzip watchonly_backup_20250118_173001.dat.gz

# Verify JSON is valid
cat watchonly_backup_20250118_173001.dat | jq .

# Restore addresses (you may need to import each address manually)
# Check Veil documentation for restore command when available
```

## Monitoring and Maintenance

### View Recent Backups

```bash
ls -lth /home/main/veil-backups/watchonly/ | head -10
```

### Check Backup Logs

```bash
# View latest backup log
ls -t /home/main/veil-backups/logs/backup_watchonly_*.log | head -1 | xargs cat

# View cron execution log
tail -100 /home/main/veil-backups/logs/cron.log

# Follow logs in real-time
tail -f /home/main/veil-backups/logs/cron.log
```

### Check Disk Space

```bash
du -sh /home/main/veil-backups/
df -h /home/main/veil-backups/
```

### Manually Trigger Backup

```bash
/home/main/veil-explorer/scripts/backup-watchonly-addresses.sh
```

### List Cron Jobs

```bash
crontab -l
```

### Edit Cron Jobs

```bash
crontab -e
```

### Remove Cron Job

```bash
crontab -e
# Delete the line with the backup script
# Or remove all cron jobs:
crontab -r
```

## Troubleshooting

### Cron job not running

**Check cron service status:**
```bash
sudo systemctl status cron
# or on some systems:
sudo systemctl status crond
```

**Check system logs:**
```bash
sudo journalctl -u cron -n 50
grep CRON /var/log/syslog | tail -20
```

**Verify cron job exists:**
```bash
crontab -l
```

### Script fails with permission error

```bash
# Make script executable
chmod +x /home/main/veil-explorer/scripts/backup-watchonly-addresses.sh

# Check directory permissions
ls -la /home/main/veil-backups/
```

### Cannot connect to veild

```bash
# Check if veild is running
ps aux | grep veild

# Test RPC connection manually
/home/main/veil/src/veil-cli -rpcport=5050 -rpcuser=veilrpc -rpcpassword=YOUR_PASSWORD getblockchaininfo
```

### Remote backup fails

```bash
# Test SSH connection
ssh -i ~/.ssh/id_rsa_backup backup_user@backup-server.example.com

# Test SCP manually
scp -i ~/.ssh/id_rsa_backup /tmp/test.txt backup_user@backup-server.example.com:/backups/veil/watchonly/
```

### Backup file not created

Check script log:
```bash
ls -t /home/main/veil-backups/logs/backup_watchonly_*.log | head -1 | xargs cat
```

## Security Best Practices

1. **Protect RPC credentials**: Don't commit the script with real passwords to git
2. **Secure SSH keys**: Use `chmod 600 ~/.ssh/id_rsa_backup`
3. **Encrypt remote backups**: Consider encrypting backups before transfer
4. **Limit SSH access**: Use dedicated backup user with restricted permissions
5. **Monitor backup logs**: Regularly check for failures
6. **Test restores**: Periodically test that backups can be restored
7. **Use strong passwords**: For both RPC and SSH

## Advanced: Encrypted Backups

To encrypt backups before sending to remote server:

```bash
# Install GPG if not available
sudo apt-get install gnupg

# Generate GPG key
gpg --gen-key

# Encrypt a backup
gpg --encrypt --recipient your_email@example.com watchonly_backup.dat

# Decrypt
gpg --decrypt watchonly_backup.dat.gpg > watchonly_backup.dat
```

You can modify the script to automatically encrypt backups.

## Summary

After setup, your watch-only addresses will:
- ✅ Backup automatically on schedule
- ✅ Store compressed backups locally
- ✅ Optionally copy to remote server
- ✅ Clean up old backups automatically
- ✅ Log all operations for audit trail

**Recommended Schedule**: Daily at 2 AM
```cron
0 2 * * * /home/main/veil-explorer/scripts/backup-watchonly-addresses.sh >> /home/main/veil-backups/logs/cron.log 2>&1
```

Monitor: `tail -f /home/main/veil-backups/logs/cron.log`
