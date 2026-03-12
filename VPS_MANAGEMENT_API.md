# VPS Management API - Complete Guide

## Overview

The Zwesta backend now includes complete VPS management endpoints to:
- Register and configure multiple VPS instances
- Test VPS connectivity
- Monitor VPS health and MT5 status
- Get RDP connection details for remote access
- Track VPS uptime and resource usage

## VPS Configuration Your Setup

Based on the screenshot, you're running:
- **VPS IP**: 38.247.146.198
- **VPS Port**: 1097 (or default 3389 for RDP)
- **MT5**: Running and connected with account 104254514
- **Status**: ✅ Backend running, market data updating every 2-3 seconds

## Database Schema

### vps_config Table
```sql
CREATE TABLE vps_config (
    vps_id TEXT PRIMARY KEY,                    -- Unique VPS identifier
    user_id TEXT NOT NULL,                      -- Owner of VPS
    vps_name TEXT NOT NULL,                     -- Display name
    vps_ip TEXT NOT NULL,                       -- IP address (38.247.146.198)
    vps_port INTEGER DEFAULT 3389,              -- RDP/SSH port
    username TEXT NOT NULL,                     -- Login username
    password TEXT NOT NULL,                     -- Encrypted login password
    rdp_port INTEGER DEFAULT 3389,              -- RDP remote desktop port
    api_port INTEGER DEFAULT 5000,              -- Backend API port on VPS
    mt5_path TEXT,                              -- Path to MT5 on VPS
    notes TEXT,                                 -- Custom notes
    is_active BOOLEAN DEFAULT 1,                -- Active/inactive status
    last_connection TEXT,                       -- Last successful connection
    status TEXT DEFAULT 'disconnected',         -- Current status
    created_at TEXT,                            -- Creation timestamp
    updated_at TEXT                             -- Last update timestamp
);
```

### vps_monitoring Table
```sql
CREATE TABLE vps_monitoring (
    monitoring_id TEXT PRIMARY KEY,
    vps_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    last_heartbeat TEXT,                        -- Last status report
    mt5_status TEXT DEFAULT 'offline',          -- 'online' or 'offline'
    backend_running BOOLEAN DEFAULT 0,          -- Backend service status
    cpu_usage REAL DEFAULT 0,                   -- CPU % usage
    memory_usage REAL DEFAULT 0,                -- Memory % usage
    uptime_hours INTEGER DEFAULT 0,             -- Hours since last restart
    active_bots INTEGER DEFAULT 0,              -- Number of running bots
    total_value_locked REAL DEFAULT 0,          -- Total TVL in USD
    last_check TEXT,                            -- Last monitoring check
    created_at TEXT
);
```

## API Endpoints

### 1. Add/Update VPS Configuration

**Endpoint**: `POST /api/vps/config`
**Authentication**: Required (X-Session-Token header)

**Request Body**:
```json
{
    "vps_name": "Production VPS",
    "vps_ip": "38.247.146.198",
    "vps_port": 1097,
    "username": "Administrator",
    "password": "your_vps_password",
    "rdp_port": 3389,
    "api_port": 5000,
    "mt5_path": "C:\\Program Files\\MetaTrader 5\\terminal64.exe",
    "notes": "Primary production VPS with MT5"
}
```

**Response**:
```json
{
    "success": true,
    "vps_id": "vps_a1b2c3d4",
    "message": "VPS configuration saved successfully"
}
```

**Example**:
```bash
curl -X POST http://localhost:9000/api/vps/config \
  -H "X-Session-Token: your_token" \
  -H "Content-Type: application/json" \
  -d '{
    "vps_name": "Production VPS",
    "vps_ip": "38.247.146.198",
    "username": "Administrator",
    "password": "password123",
    "rdp_port": 3389,
    "api_port": 5000
  }'
```

---

### 2. List All VPS Configurations

**Endpoint**: `GET /api/vps/list`
**Authentication**: Required

**Response**:
```json
{
    "success": true,
    "vps_configs": [
        {
            "vps_id": "vps_a1b2c3d4",
            "vps_name": "Production VPS",
            "vps_ip": "38.247.146.198",
            "vps_port": 1097,
            "rdp_port": 3389,
            "api_port": 5000,
            "mt5_path": "C:\\Program Files\\MetaTrader 5\\terminal64.exe",
            "status": "connected",
            "last_connection": "2026-03-12T15:08:49.123456",
            "created_at": "2026-03-10T10:30:00.000000"
        }
    ],
    "count": 1
}
```

**Example**:
```bash
curl -H "X-Session-Token: your_token" http://localhost:9000/api/vps/list
```

---

### 3. Test VPS Connection

**Endpoint**: `POST /api/vps/<vps_id>/test-connection`
**Authentication**: Required

Tests:
- ✅ Ping VPS IP (ICMP)
- ✅ API health check on backend API port
- Updates last_connection timestamp in database

**Response**:
```json
{
    "success": true,
    "vps_id": "vps_a1b2c3d4",
    "vps_ip": "38.247.146.198",
    "status": "connected",
    "ping_reachable": true,
    "api_reachable": true,
    "rdp_port": 3389,
    "api_port": 5000,
    "message": "VPS is connected"
}
```

**Example**:
```bash
curl -X POST \
  -H "X-Session-Token: your_token" \
  http://localhost:9000/api/vps/vps_a1b2c3d4/test-connection
```

---

### 4. Get VPS Status and Monitoring Data

**Endpoint**: `GET /api/vps/<vps_id>/status`
**Authentication**: Required

Returns current VPS health metrics and monitoring data.

**Response**:
```json
{
    "success": true,
    "vps_status": {
        "vps_id": "vps_a1b2c3d4",
        "vps_name": "Production VPS",
        "vps_ip": "38.247.146.198",
        "connection_status": "connected",
        "last_connection": "2026-03-12T15:08:49.123456",
        "mt5_status": "online",
        "backend_running": true,
        "cpu_usage": 35.5,
        "memory_usage": 62.3,
        "uptime_hours": 24,
        "active_bots": 3,
        "total_value_locked": 50000.00,
        "last_check": "2026-03-12T15:08:45.000000"
    }
}
```

**Example**:
```bash
curl -H "X-Session-Token: your_token" \
  http://localhost:9000/api/vps/vps_a1b2c3d4/status
```

---

### 5. Get RDP Connection Details

**Endpoint**: `POST /api/vps/<vps_id>/remote-access`
**Authentication**: Required

Provides RDP connection string for remote desktop access to VPS.

**Response**:
```json
{
    "success": true,
    "vps_name": "Production VPS",
    "rdp_server": "38.247.146.198:3389",
    "rdp_port": 3389,
    "username": "Administrator",
    "connection_string": "mstsc /v:38.247.146.198:3389",
    "instructions": [
        "1. Copy the connection string: mstsc /v:38.247.146.198:3389",
        "2. Run it in Windows Run dialog (Win+R)",
        "3. Username: Administrator",
        "4. Enter your password when prompted",
        "5. You will have remote access to MT5 on the VPS"
    ]
}
```

**How to Use**:
1. Copy the `connection_string` value
2. Press Win+R on your computer
3. Paste the string and press Enter
4. Enter username and password when prompted

---

### 6. Delete VPS Configuration

**Endpoint**: `DELETE /api/vps/<vps_id>/delete` or `POST /api/vps/<vps_id>/delete`
**Authentication**: Required

Removes VPS configuration and all associated monitoring data.

**Response**:
```json
{
    "success": true,
    "message": "VPS Production VPS deleted successfully"
}
```

**Example**:
```bash
curl -X DELETE \
  -H "X-Session-Token: your_token" \
  http://localhost:9000/api/vps/vps_a1b2c3d4/delete
```

---

### 7. VPS Heartbeat (For VPS Backend to Report Status)

**Endpoint**: `POST /api/vps/<vps_id>/heartbeat`
**Authentication**: NOT Required (VPS identifies itself)

This endpoint is called by the VPS backend to report its status periodically.

**Request Body**:
```json
{
    "mt5_status": "online",
    "backend_running": true,
    "cpu_usage": 35.5,
    "memory_usage": 62.3,
    "uptime_hours": 24,
    "active_bots": 3,
    "total_value_locked": 50000.00
}
```

**Response**:
```json
{
    "success": true,
    "vps_id": "vps_a1b2c3d4",
    "message": "Heartbeat received"
}
```

**Python Implementation for VPS Backend**:
```python
import requests
import json

def send_vps_heartbeat(vps_id, main_backend_url):
    """Send VPS status report to main backend"""
    
    # Gather VPS metrics
    vps_status = {
        "mt5_status": "online",
        "backend_running": True,
        "cpu_usage": get_cpu_usage(),    # Implement this function
        "memory_usage": get_memory_usage(),  # Implement this function
        "uptime_hours": get_uptime_hours(),  # Implement this function
        "active_bots": count_active_bots(),  # Implement this function
        "total_value_locked": calculate_tvl()  # Implement this function
    }
    
    # Send to main backend
    response = requests.post(
        f"{main_backend_url}/api/vps/{vps_id}/heartbeat",
        json=vps_status,
        timeout=5
    )
    
    if response.status_code == 200:
        print("✅ Heartbeat sent successfully")
    else:
        print(f"❌ Heartbeat failed: {response.text}")

# Call this function every 5 minutes from your VPS backend
while True:
    send_vps_heartbeat("vps_a1b2c3d4", "http://main-backend-ip:9000")
    time.sleep(300)  # Every 5 minutes
```

---

## Setup Your Production VPS

### Step 1: Register Your VPS

```bash
curl -X POST http://localhost:9000/api/vps/config \
  -H "X-Session-Token: your_session_token" \
  -H "Content-Type: application/json" \
  -d '{
    "vps_name": "Production VPS - 38.247.146.198",
    "vps_ip": "38.247.146.198",
    "vps_port": 1097,
    "username": "Administrator",
    "password": "your_secure_password",
    "rdp_port": 3389,
    "api_port": 5000,
    "mt5_path": "C:\\Program Files\\MetaTrader 5\\terminal64.exe",
    "notes": "Primary VPS with MT5 account 104254514"
  }'
```

### Step 2: Test Connection

```bash
curl -X POST \
  -H "X-Session-Token: your_session_token" \
  http://localhost:9000/api/vps/vps_a1b2c3d4/test-connection
```

### Step 3: Monitor VPS Status

```bash
curl -H "X-Session-Token: your_session_token" \
  http://localhost:9000/api/vps/vps_a1b2c3d4/status
```

### Step 4: Get RDP Access

```bash
curl -X POST \
  -H "X-Session-Token: your_session_token" \
  http://localhost:9000/api/vps/vps_a1b2c3d4/remote-access
```

Then use the returned `connection_string` to connect via Remote Desktop.

---

## Implementing VPS Heartbeat on Your VPS Backend

Add this to your VPS backend (multi_broker_backend_updated.py running on VPS):

```python
import threading
import requests
from datetime import datetime

# Configuration
MAIN_BACKEND_URL = "http://main_backend_ip:9000"
VPS_ID = "vps_a1b2c3d4"  # Get this from API response
HEARTBEAT_INTERVAL = 300  # 5 minutes

def get_system_metrics():
    """Gather VPS system metrics"""
    import psutil
    
    return {
        "mt5_status": "online" if check_mt5_running() else "offline",
        "backend_running": True,  # This endpoint proves backend is running
        "cpu_usage": psutil.cpu_percent(interval=1),
        "memory_usage": psutil.virtual_memory().percent,
        "uptime_hours": int((datetime.now() - datetime(2026, 3, 10)).total_seconds() / 3600),
        "active_bots": len(active_bots),
        "total_value_locked": calculate_total_invested()
    }

def check_mt5_running():
    """Check if MT5 is running"""
    try:
        import subprocess
        result = subprocess.run(['tasklist'], capture_output=True, text=True)
        return 'terminal64.exe' in result.stdout or 'terminal.exe' in result.stdout
    except:
        return False

def send_heartbeat():
    """Send periodic heartbeat to main backend"""
    while True:
        try:
            metrics = get_system_metrics()
            response = requests.post(
                f"{MAIN_BACKEND_URL}/api/vps/{VPS_ID}/heartbeat",
                json=metrics,
                timeout=5
            )
            
            if response.status_code == 200:
                logger.info(f"💓 VPS heartbeat sent: CPU={metrics['cpu_usage']:.1f}%, RAM={metrics['memory_usage']:.1f}%")
            else:
                logger.warning(f"⚠️ Heartbeat failed: {response.text}")
        
        except Exception as e:
            logger.error(f"❌ Error sending heartbeat: {e}")
        
        time.sleep(HEARTBEAT_INTERVAL)

# Start heartbeat in background thread on startup
heartbeat_thread = threading.Thread(target=send_heartbeat, daemon=True)
heartbeat_thread.start()
logger.info(f"✅ VPS heartbeat started (interval: {HEARTBEAT_INTERVAL}s)")
```

---

## Monitoring Dashboard Features

Once VPS is configured, your Flutter app can display:

1. **VPS Connection Status** (Connected/Disconnected)
2. **MT5 Status** (Online/Offline)
3. **System Metrics** (CPU, Memory, Uptime)
4. **Active Bots Count** 
5. **Total Value Locked (TVL)**
6. **Quick RDP Access Button**
7. **Last Heartbeat Time**

---

## Security Recommendations

1. **Encrypt passwords** in database transmission
2. **Use VPN** for RDP connections from untrusted networks
3. **Enable Windows Firewall** - whitelist only required ports
4. **Use strong passwords** for VPS accounts
5. **Limit RDP access** to specific IP ranges
6. **Regular backups** of MT5 data and bot configurations
7. **Monitor failed login attempts** to VPS

---

## Troubleshooting

### "VPS is disconnected"
- Check internet connectivity on VPS
- Verify firewall allows outbound connections
- Confirm VPS IP and port are correct

### "API is not reachable"
- Ensure backend is running on VPS
- Verify api_port is correct
- Check firewall inbound rules on VPS

### "MT5 status is offline"
- Restart MT5 on VPS
- Check Windows Event Viewer for errors
- Verify account credentials are correct

### RDP Connection Fails
- Confirm RDP is enabled on VPS
- Check remote desktop port (default 3389)
- Verify firewall allows RDP port

---

## Sample Setup for Your VPS

Your current setup (from screenshot):
```
VPS IP: 38.247.146.198
RDP Port: 3389
MT5 Running: Yes ✅
Account: 104254514
Status: Connected ✅
Backend: Running ✅
Market Data: Updating ✅
```

Register with:
```json
{
    "vps_name": "Production VPS",
    "vps_ip": "38.247.146.198",
    "vps_port": 1097,
    "username": "Administrator",
    "password": "your_password",
    "rdp_port": 3389,
    "api_port": 5000,
    "notes": "MT5 Account 104254514 - Live trading"
}
```

Your VPS is ready for production! 🚀
