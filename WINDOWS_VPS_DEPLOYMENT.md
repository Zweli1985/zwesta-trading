# Zwesta Trading System - Windows VPS Deployment Guide

## Prerequisites

- Windows Server 2019+ or Windows 10/11 Professional
- Remote Desktop Connection
- Administrator access
- At least 4GB RAM, 20GB disk space

## Step 1: Prepare Windows VPS

### 1.1 Remote Desktop Connection
```powershell
# From local machine:
# Press Windows Key + R, type:
mstsc

# Connect to your VPS IP address
# e.g., 38.247.146.198:3389
```

### 1.2 Enable Required Windows Features
```powershell
# Run as Administrator
dism /online /enable-feature /featurename:IIS-WebServer
dism /online /enable-feature /featurename:IIS-StaticContent
dism /online /enable-feature /featurename:IIS-ASPNET45
```

---

## Step 2: Install Dependencies

### 2.1 Install Python 3.11
```powershell
# Download from https://www.python.org/downloads/
# Or use Windows Package Manager:
winget install Python.Python.3.11

# Verify installation
python --version
pip --version
```

### 2.2 Install Git
```powershell
winget install Git.Git
```

### 2.3 Install Node.js (for Flutter web)
```powershell
winget install OpenJS.NodeJS
node --version
npm --version
```

### 2.4 Install Flutter (if building mobile)
```powershell
# Download Flutter from https://flutter.dev/docs/get-started/install/windows
# Add to PATH environment variable

# Verify
flutter --version
```

---

## Step 3: Clone and Setup Project

### 3.1 Clone Repository
```powershell
cd C:\
git clone <your-repo-url> zwesta-trading
cd zwesta-trading
```

### 3.2 Create Virtual Environment
```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1

# If you get execution policy error:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 3.3 Install Python Dependencies
```powershell
pip install -r requirements-production.txt
```

---

## Step 4: Configure Application

### 4.1 Create Environment File
```powershell
# Copy example
Copy-Item .env.production.example .env.production

# Edit with your settings (use Notepad or VS Code)
notepad .env.production
```

### 4.2 Configure for Windows
Edit `.env.production`:
```
ZWESTA_ENV=production
FLASK_DEBUG=false
API_HOST=0.0.0.0
API_PORT=9000
LOG_LEVEL=INFO
LOG_FILE=C:\zwesta-trading\logs\trading_backend.log
MT5_ENABLED=true
```

### 4.3 Create Log Directory
```powershell
New-Item -Path "C:\zwesta-trading\logs" -ItemType Directory -Force
New-Item -Path "C:\zwesta-trading\data" -ItemType Directory -Force
```

---

## Step 5: Setup Windows Service (Recommended)

### 5.1 Install NSSM (Non-Sucking Service Manager)
```powershell
# Download from https://nssm.cc/download
# Or use:
choco install nssm

# Add to PATH if not done automatically
```

### 5.2 Create Windows Service
```powershell
# Create service
nssm install ZwestaTrading `
  C:\zwesta-trading\venv\Scripts\python.exe `
  C:\zwesta-trading\multi_broker_backend_updated.py

# Set working directory
nssm set ZwestaTrading AppDirectory C:\zwesta-trading

# Set startup type to auto
nssm set ZwestaTrading Start SERVICE_AUTO_START

# Configure logging
nssm set ZwestaTrading AppStdout C:\zwesta-trading\logs\stdout.log
nssm set ZwestaTrading AppStderr C:\zwesta-trading\logs\stderr.log

# Start service
nssm start ZwestaTrading

# Verify
Get-Service ZwestaTrading
```

---

## Step 6: Setup Web Server (IIS)

### 6.1 Configure IIS for Flutter Web
```powershell
# Create site directory
New-Item -Path "C:\inetpub\zwesta-web" -ItemType Directory -Force

# Copy Flutter web build
Copy-Item "build\web\*" "C:\inetpub\zwesta-web" -Recurse
```

### 6.2 Create IIS Website
```powershell
# Using IIS Manager or PowerShell:
New-IISSite -Name "Zwesta Trading" `
  -BindingProtocol http `
  -BindingInformation "*:80:" `
  -PhysicalPath "C:\inetpub\zwesta-web"

# Add web.config for routing
```

### 6.3 Create web.config
Create file: `C:\inetpub\zwesta-web\web.config`
```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <rule name="Flutter Routing" stopProcessing="true">
          <match url="^(?!api/)(.*)$" />
          <conditions>
            <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
            <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
          </conditions>
          <action type="Rewrite" url="/index.html" />
        </rule>
      </rules>
    </rewrite>
    <staticContent>
      <mimeMap fileExtension=".dart" mimeType="text/plain" />
    </staticContent>
  </system.webServer>
</configuration>
```

---

## Step 7: Setup Reverse Proxy (Optional but Recommended)

### 7.1 Install IIS URL Rewrite
```powershell
# Download and install from:
# https://www.iis.net/downloads/microsoft/url-rewrite
```

### 7.2 Create Application Request Routing
```powershell
# Install ARR (Application Request Routing)
# Download from Microsoft
```

---

## Step 8: SSL/HTTPS Setup

### 8.1 Get Free Certificate (Let's Encrypt)
```powershell
# Install Certbot for Windows
choco install certbot

# Get certificate
certbot certonly --standalone -d your-domain.com

# Certificates saved to: C:\Certbot\live\your-domain.com\
```

### 8.2 Install Certificate in IIS
```powershell
# Use IIS Manager:
# 1. Server Certificates > Import
# 2. Select cert.pfx from Certbot
# 3. Create HTTPS binding
```

---

## Step 9: Configure Firewall

### 9.1 Allow Required Ports
```powershell
# Allow port 80 (HTTP)
netsh advfirewall firewall add rule `
  name="Allow HTTP" `
  dir=in `
  action=allow `
  protocol=tcp `
  localport=80

# Allow port 443 (HTTPS)
netsh advfirewall firewall add rule `
  name="Allow HTTPS" `
  dir=in `
  action=allow `
  protocol=tcp `
  localport=443

# Allow port 9000 (Backend API)
netsh advfirewall firewall add rule `
  name="Allow Zwesta API" `
  dir=in `
  action=allow `
  protocol=tcp `
  localport=9000

# Check rules
Get-NetFirewallRule -DisplayName "Allow*"
```

---

## Step 10: Testing

### 10.1 Test Backend API
```powershell
# From VPS:
Invoke-WebRequest -Uri "http://localhost:9000/api/health"

# From local machine:
# Replace with VPS IP
Invoke-WebRequest -Uri "http://38.247.146.198:9000/api/health"
```

### 10.2 Test Frontend
```
http://38.247.146.198:80 (IIS Website)
```

### 10.3 Run Full Test Suite
```powershell
cd C:\zwesta-trading
python test_api.py
```

---

## Step 11: Monitoring & Maintenance

### 11.1 View Service Status
```powershell
# Check service status
Get-Service ZwestaTrading

# View service logs
Get-Content C:\zwesta-trading\logs\stderr.log -Tail 50

# View real-time logs
Get-Content C:\zwesta-trading\logs\stderr.log -Wait -Tail 0
```

### 11.2 Restart Service
```powershell
# Stop
Stop-Service ZwestaTrading

# Start
Start-Service ZwestaTrading

# Restart
Restart-Service ZwestaTrading
```

### 11.3 View Event Logs
```powershell
# Application logs
Get-EventLog -LogName Application -Newest 20 | ForEach-Object { Write-Host $_.Message }
```

---

## Troubleshooting

### Issue: Port 9000 already in use
```powershell
# Find process using port
netstat -ano | findstr :9000

# Kill process
taskkill /PID <PID> /F

# Or change port in .env.production
```

### Issue: Python module not found
```powershell
# Ensure venv is activated
.\venv\Scripts\Activate.ps1

# Reinstall requirements
pip install --upgrade pip
pip install -r requirements-production.txt
```

### Issue: MetaTrader5 connection failing
```powershell
# Check if MT5 is installed
# Verify MT5_PATH in .env.production points to correct location
# Default: C:\Program Files\XM Global MT5

# Test connection manually:
python
>>> import MetaTrader5 as mt5
>>> mt5.initialize()
```

### Issue: IIS site not running
```powershell
# Check IIS application pool
Get-WebAppPoolState -Name "Zwesta*"

# Restart application pool
Restart-WebAppPool -Name "DefaultAppPool"
```

---

## Performance Tuning

### 11.1 IIS Application Pool Settings
```powershell
# Increase memory limit
Set-WebConfigurationProperty -pspath "MACHINE/WEBROOT/APPHOST" `
  -filter "system.webServer/applicationPool[@name='ZwestaAppPool']/recycling" `
  -name "." `
  -value @{maxMemory=2048}
```

### 11.2 Python Configuration
Edit `.env.production`:
```
GUNICORN_WORKERS=4
API_TIMEOUT=120
```

---

## Updates

### Update Application
```powershell
cd C:\zwesta-trading

# Stop service
Stop-Service ZwestaTrading

# Pull latest code
git pull origin main

# Update dependencies
pip install -r requirements-production.txt --upgrade

# Start service
Start-Service ZwestaTrading
```

### Update Flutter Web
```powershell
# Rebuild web
flutter build web --release

# Copy to IIS directory
Copy-Item "build\web\*" "C:\inetpub\zwesta-web" -Recurse -Force
```

---

## Backup

### Automated Backup Script
Create file: `C:\zwesta-trading\backup.ps1`
```powershell
$backupDir = "C:\zwesta-trading\backups"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupFile = "$backupDir\backup_$timestamp.zip"

# Create backup directory
if (-not (Test-Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory
}

# Backup data directory
7z a $backupFile "C:\zwesta-trading\data"

Write-Host "Backup created: $backupFile"
```

Schedule with Task Scheduler:
```powershell
# Run daily at 2 AM
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\zwesta-trading\backup.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At 2AM
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Zwesta Backup"
```

---

## Complete Deployment Checklist

- [ ] Remote Desktop connection working
- [ ] Python 3.11 installed and verified
- [ ] Git installed
- [ ] Flutter installed (if needed)
- [ ] Repository cloned
- [ ] Virtual environment created and activated
- [ ] Dependencies installed
- [ ] Environment file configured
- [ ] Windows service created and running
- [ ] IIS website configured
- [ ] Firewall rules added
- [ ] SSL certificate installed
- [ ] API health check passing
- [ ] Frontend accessible
- [ ] Full test suite passing
- [ ] Backups configured

---

## Support Commands

```powershell
# Health check
curl http://localhost:9000/api/health

# View all services
Get-Service | grep Zwesta

# View Python processes
Get-Process python

# Kill all Python processes
Get-Process python | Stop-Process -Force

# View network connections
netstat -ano | findstr LISTENING

# Check disk space
Get-Volume

# Monitor CPU/Memory
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10
```

---

**Setup Complete!** Your Zwesta Trading System is now running on Windows VPS.
