# Veil Daemon (veild) Systemd Service Setup

This guide explains how to set up the Veil daemon (veild) as a systemd service for automatic startup and crash recovery.

## Benefits of systemd Service

- ✅ Auto-starts on server boot
- ✅ Auto-restarts on crash
- ✅ Easy to start/stop/restart
- ✅ Automatic logging via journalctl
- ✅ Runs as specific user for security

## Prerequisites

- Veil node installed and working
- veil.conf configured with RPC settings
- Know the path to your veild binary
- Know the path to your Veil data directory

## Step 1: Find Your Paths

First, identify these paths (examples shown):

```bash
# Find where veild is running from
which veild
# OR if running from source directory:
pwd  # while in the directory where you run ./src/veild

# Common locations:
# /home/USERNAME/veil/bin/veild
# /home/USERNAME/veil-source/src/veild
# /usr/local/bin/veild
```

**Example paths we'll use:**
- veild binary: `/home/main/veil/src/veild`
- Data directory: `/home/main/.veil`
- Config file: `/home/main/.veil/veil.conf`
- User: `main`

## Step 2: Create the Systemd Service File

Create the service file:

```bash
sudo nano /etc/systemd/system/veild.service
```

Paste this configuration (adjust paths as needed):

```ini
[Unit]
Description=Veil Daemon
After=network.target

[Service]
Type=forking
User=main
Group=main

# Path to veild executable
ExecStart=/home/main/veil/src/veild -daemon -conf=/home/main/.veil/veil.conf -datadir=/home/main/.veil -txindex

# PID file location
PIDFile=/home/main/.veil/veild.pid

# Restart policy
Restart=always
RestartSec=10

# Limits
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

# Security settings (optional but recommended)
PrivateTmp=true
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

### Configuration Explained

| Setting | Description |
|---------|-------------|
| `Type=forking` | veild forks to background when using -daemon |
| `User=main` | Run as this user (change to your username) |
| `ExecStart` | Full command to start veild with all flags |
| `Restart=always` | Auto-restart on any exit (crash, killed, etc.) |
| `RestartSec=10` | Wait 10 seconds before restarting |
| `TimeoutStopSec=60s` | Give veild 60 seconds to shut down gracefully |
| `StartLimitBurst=5` | Try restarting up to 5 times in 120s window |

## Step 3: Customize the Paths

**IMPORTANT:** Update these paths in the service file to match your setup:

1. **User/Group**: Change `main` to your actual username
2. **ExecStart**: Update path to your veild binary
3. **-conf**: Path to your veil.conf file
4. **-datadir**: Path to your Veil data directory
5. **PIDFile**: Should be in your data directory

### Example for different setups:

**If veild is in /usr/local/bin:**
```ini
ExecStart=/usr/local/bin/veild -daemon -conf=/home/USERNAME/.veil/veil.conf -datadir=/home/USERNAME/.veil -txindex
```

**If using custom data directory:**
```ini
ExecStart=/home/USERNAME/veil/bin/veild -daemon -conf=/mnt/veil-data/veil.conf -datadir=/mnt/veil-data -txindex
PIDFile=/mnt/veil-data/veild.pid
```

## Step 4: Enable and Start the Service

```bash
# Reload systemd to recognize new service
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable veild

# Start the service now
sudo systemctl start veild

# Check status
sudo systemctl status veild
```

## Step 5: Verify It's Working

```bash
# Check service status
sudo systemctl status veild

# View logs
sudo journalctl -u veild -f

# Check if RPC is responding
./veil-cli -rpcport=5050 -rpcuser=veilrpc -rpcpassword=YOUR_PASSWORD getblockchaininfo
```

## Managing the Service

### Start/Stop/Restart

```bash
# Start veild
sudo systemctl start veild

# Stop veild
sudo systemctl stop veild

# Restart veild
sudo systemctl restart veild

# Check status
sudo systemctl status veild
```

### View Logs

```bash
# Follow logs in real-time
sudo journalctl -u veild -f

# Show last 100 lines
sudo journalctl -u veild -n 100

# Show logs from today
sudo journalctl -u veild --since today

# Show logs with specific priority (errors only)
sudo journalctl -u veild -p err
```

### Disable Auto-Start

```bash
# Disable service (won't start on boot)
sudo systemctl disable veild

# Re-enable
sudo systemctl enable veild
```

## Troubleshooting

### Service won't start

```bash
# Check detailed status
sudo systemctl status veild -l

# View full logs
sudo journalctl -u veild -n 50 --no-pager
```

Common issues:
- **Wrong paths**: Double-check ExecStart paths
- **Permission denied**: Ensure User/Group has access to veild and data directory
- **Already running**: Stop manually running veild first: `pkill veild`
- **Config error**: Check veil.conf syntax

### Test before creating service

Before creating the systemd service, test your command manually:

```bash
# Test starting veild
/path/to/veild -daemon -conf=/path/to/veil.conf -datadir=/path/to/datadir -txindex

# Check if it started
ps aux | grep veild

# Stop it
/path/to/veil-cli -rpcport=5050 stop
```

### Check if service is enabled on boot

```bash
systemctl is-enabled veild
```

Should output: `enabled`

## Migration from Manual Start

If you're currently running veild manually:

1. **Stop the manual process**:
   ```bash
   ./veil-cli -rpcport=5050 stop
   # Or force kill if needed:
   pkill veild
   ```

2. **Verify it's stopped**:
   ```bash
   ps aux | grep veild
   ```

3. **Create and start the service** (follow steps above)

4. **Verify service took over**:
   ```bash
   sudo systemctl status veild
   ss -tlnp | grep 5050
   ```

## Testing Auto-Recovery

Test that veild auto-restarts on crash:

```bash
# Kill the process
sudo killall -9 veild

# Wait a few seconds, then check status
sleep 15
sudo systemctl status veild

# Should show it restarted automatically
```

## Additional Security (Optional)

For extra security, you can create a dedicated `veil` user:

```bash
# Create veil user
sudo adduser --disabled-password --gecos "" veil

# Move veil files
sudo mv /home/main/veil /home/veil/
sudo chown -R veil:veil /home/veil

# Update service file User/Group to 'veil'
sudo nano /etc/systemd/system/veild.service
# Change User=veil and Group=veil

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart veild
```

## Summary

After setup, your Veil daemon will:
- ✅ Start automatically on server boot
- ✅ Restart automatically if it crashes
- ✅ Be manageable via `systemctl` commands
- ✅ Log to system journal for easy debugging
- ✅ Run with proper permissions and security

Monitor with: `sudo systemctl status veild`

View logs with: `sudo journalctl -u veild -f`
