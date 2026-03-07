# Zwesta Trading System - Windows VPS Deployment Guide

## 📋 Prerequisites

### Local Machine
- Windows 10/11 or Server 2019+
- Python 3.8+
- Flutter SDK
- VS Code (optional but recommended)

### Windows VPS Requirements
- Windows Server 2019 or 2022
- Administrator access
- Minimum 2GB RAM
- 10GB free disk space
- Static IP address

---

## 🚀 Quick Start (Automated)

### Step 1: Prepare and Transfer Files

**Via Remote Desktop File Transfer:**
1. Open Remote Desktop Connection to your VPS
2. Before connecting, click "Show Options"
3. Go to "Local Resources" tab
4. Click "More" under "Local devices and resources"
5. Expand "Drives" and select your C: drive
6. Connect to VPS
7. Open "This PC" on VPS and access your local C: drive
8. Copy entire `zwesta-trading` folder to VPS

**Or use PowerShell:**
```powershell
$VPS_IP = "your.vps.ip"
$LocalPath = "C:\zwesta-trader\Zwesta Flutter App"
$RemotePath = "\\$VPS_IP\c$\Applications\zwesta-trading"

Copy-Item -Path $LocalPath -Destination $RemotePath -Recurse -Force
```

### Step 2: Run Deployment on VPS

Connect to VPS via RDP, then:

```powershell
# Open PowerShell as Administrator
cd C:\Applications\zwesta-trading

# Run deployment script
.\deploy-windows-vps.bat
```

---

## 📝 Manual Setup (Step-by-Step)

### Step 1: Install Python

On VPS:
```powershell
# Download Python 3.11
curl https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe -OutFile python-installer.exe

# Run installer - IMPORTANT: Check "Add Python to PATH"
.\python-installer.exe
```

### Step 2: Setup Virtual Environment

```powershell
cd C:\Applications\zwesta-trading

python -m venv venv
.\venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
```

### Step 3: Install Dependencies

```powershell
pip install -r requirements-production.txt
```

### Step 4: Configure Application

```powershell
# Copy and edit configuration
Copy-Item .env.production.example .env.production
notepad .env.production
```

**Key settings:**
```
ZWESTA_ENV=production
MT5_ACCOUNT=104017418
MT5_PASSWORD=your_password
MT5_SERVER=MetaQuotes-Demo
API_HOST=0.0.0.0
API_PORT=9000
```

### Step 5: Create Windows Service

```powershell
# Download NSSM
mkdir C:\tools
cd C:\tools

Invoke-WebRequest "https://nssm.cc/download/nssm-2.24-101-g897c7ad.zip" -OutFile "nssm.zip"
Expand-Archive nssm.zip

# Install service
.\nssm-*/win64/nssm install zwesta-trading "C:\Applications\zwesta-trading\venv\Scripts\gunicorn.exe" --bind 0.0.0.0:9000 --workers 4 wsgi:app

# Start service
.\nssm start zwesta-trading
```

### Step 6: Setup Nginx Reverse Proxy

```powershell
cd C:\Applications

# Download Nginx
Invoke-WebRequest "http://nginx.org/download/nginx-1.25.4.zip" -OutFile nginx.zip
Expand-Archive nginx.zip

# Copy config
Copy-Item nginx-prod.conf nginx-1.25.4\conf\nginx.conf

# Start Nginx
cd nginx-1.25.4
.\nginx.exe
```

### Step 7: Allow Firewall

```powershell
netsh advfirewall firewall add rule name="Zwesta API" dir=in action=allow protocol=tcp localport=9000
netsh advfirewall firewall add rule name="Zwesta HTTP" dir=in action=allow protocol=tcp localport=80
netsh advfirewall firewall add rule name="Zwesta HTTPS" dir=in action=allow protocol=tcp localport=443
```

---

## ✅ Testing

### From VPS Console

```powershell
# Test API
curl http://localhost:9000/api/health

# Check service status
C:\tools\nssm status zwesta-trading

# View logs
Get-Content C:\Applications\zwesta-trading\logs\trading_backend.log -Tail 50
```

### From Your Local Machine

```powershell
$VPS_IP = "your.vps.ip"

# Test connectivity
curl http://$VPS_IP:9000/api/health

# Test connection
Test-NetConnection -ComputerName $VPS_IP -Port 9000
```

---

## 📱 Mobile APK Setup

### Build APK Locally

On your local Windows machine:

```batch
# Navigate to project
cd C:\zwesta-trader\Zwesta Flutter App

# Build APK
build-apk.bat
```

APK will be at: `build\app\outputs\apk\release\app-release.apk`

### Install on Android Device

**Method 1: Via File Transfer**
1. Connect Android device to Windows PC via USB
2. Copy `app-release.apk` to device Downloads folder
3. Open file manager on Android
4. Tap the APK file to install

**Method 2: Via ADB**
```powershell
# Connect device
adb devices

# Install
adb install build\app\outputs\apk\release\app-release.apk

# Launch
adb shell am start -n com.example.zwesta_trading/.MainActivity
```

### Configure Mobile App

1. Open Zwesta app on Android
2. Settings → API Configuration
3. Set API URL: `http://your-vps-ip:9000`
4. Save and restart

---

## 🎯 Local Testing Before VPS

### Run Everything Locally

```batch
# In your local machine, run:
test-local.bat
```

This will:
1. Start Python backend (http://localhost:9000)
2. Start Flutter web app (http://localhost:port)
3. Keep backend logs visible

### Test Endpoints

```powershell
# Health check
curl http://localhost:9000/api/health

# Get accounts
curl http://localhost:9000/api/accounts/list

# Get trades
curl http://localhost:9000/api/trades
```

### Test Mobile Connection (Android/iOS)

Update Flutter app to use local IP:

```dart
// In lib/utils/environment_config.dart
static const String _devApiUrl = 'http://YOUR_LOCAL_IP:9000';
```

Then build and run locally on phone.

---

## 🔄 Managing Remote VPS

### Common RDP Tasks

**Stop Service:**
```powershell
C:\tools\nssm stop zwesta-trading
```

**Start Service:**
```powershell
C:\tools\nssm start zwesta-trading
```

**Restart Service:**
```powershell
C:\tools\nssm restart zwesta-trading
```

**View Logs:**
```powershell
# Real-time logs
Get-Content C:\Applications\zwesta-trading\logs\trading_backend.log -Wait -Tail 20
```

**Update Configuration:**
```powershell
# Edit config
notepad C:\Applications\zwesta-trading\.env.production

# Restart to apply changes
C:\tools\nssm restart zwesta-trading
```

---

## 🚨 Troubleshooting

### Service Won't Start

```powershell
# Check what's wrong
C:\tools\nssm dump zwesta-trading

# Try manual run
C:\Applications\zwesta-trading\venv\Scripts\gunicorn.exe --bind 0.0.0.0:9000 wsgi:app

# Check Python is working
python --version
```

### Port Already in Use

```powershell
# Find process using port 9000
netstat -ano | findstr :9000

# Kill it
taskkill /PID <PID> /F

# Or use different port
# Edit .env.production: API_PORT=9001
```

### Can't Connect from Phone

1. Check VPS firewall: `netsh advfirewall firewall show rule name="Zwesta*"`
2. Test from VPS: `curl http://localhost:9000/api/health`
3. Test from PC: `curl http://vps-ip:9000/api/health`
4. Check network: VPS and phone on same network?

---

## 📊 Deployment Checklist

**Local Testing:**
- [ ] Backend runs on http://localhost:9000
- [ ] Flutter web app loads in browser
- [ ] API endpoints respond
- [ ] Mock data loads properly
- [ ] Android APK builds successfully

**VPS Setup:**
- [ ] Python installed and in PATH
- [ ] Virtual environment created
- [ ] Dependencies installed
- [ ] .env.production configured
- [ ] Service running via NSSM
- [ ] Nginx reverse proxy working
- [ ] Firewall rules added
- [ ] API accessible from internet

**Mobile Testing:**
- [ ] APK installs on Android device
- [ ] App connects to VPS API
- [ ] Can view accounts and trades
- [ ] Settings can be updated

---

**Quick Command Reference**

```powershell
# On VPS - Check everything
curl http://localhost:9000/api/health
C:\tools\nssm status zwesta-trading
netstat -ano | findstr :9000
Get-Content C:\Applications\zwesta-trading\logs\trading_backend.log -Tail 20

# From local machine
curl http://vps-ip:9000/api/health
Test-NetConnection vps-ip -Port 9000
adb install app-release.apk
```

---

**Support**: Check logs in `C:\Applications\zwesta-trading\logs\`
