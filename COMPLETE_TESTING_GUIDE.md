# Zwesta Trading System - Complete Testing & Deployment Guide

## 📋 Table of Contents

1. [Local Testing](#local-testing)
2. [Windows VPS Deployment](#windows-vps-deployment)
3. [Mobile APK Build](#mobile-apk-build)
4. [Remote Desktop Setup](#remote-desktop-setup)
5. [Deployment Checklist](#deployment-checklist)

---

## Local Testing

### Quick Test (5 minutes)

#### 1. Ensure Backend is Running
```powershell
# Terminal 1
cd "c:\zwesta-trader\Zwesta Flutter App"
python multi_broker_backend_updated.py

# Should show:
# ✓ Running on http://127.0.0.1:9000
# ✓ Press CTRL+C to quit
```

#### 2. Run API Test Suite
```powershell
# Terminal 2
cd "c:\zwesta-trader\Zwesta Flutter App"
python test_api.py

# Should show:
# ✓ Health check passed
# ✓ Account info retrieved
# ✓ Trades endpoint working
# ✓ Positions endpoint working
# ✓ All tests passed! System is ready.
```

#### 3. Test Frontend (Flutter Web)
```powershell
# Terminal 3
cd "c:\zwesta-trader\Zwesta Flutter App"
flutter run -d chrome --dart-define=ZWESTA_ENV=development

# Should show:
# Launching lib\main.dart on Chrome in debug mode...
# Connected to trading backend at http://localhost:9000
```

### Comprehensive Testing

#### Test Endpoints with cURL
```powershell
# Health Check
curl http://localhost:9000/api/health

# Account Info
curl http://localhost:9000/api/account/info

# List Accounts
curl http://localhost:9000/api/accounts/list

# Get Trades
curl http://localhost:9000/api/trades

# Get Positions
curl http://localhost:9000/api/positions/all

# Account Equity
curl http://localhost:9000/api/account/equity

# Generate Demo Trades
curl -X POST http://localhost:9000/api/demo/generate-trades `
  -H "Content-Type: application/json" `
  -d "{`"count`": 5}"
```

#### Test Trading Operations
```powershell
# Place Demo Trade
curl -X POST http://localhost:9000/api/trade/place `
  -H "Content-Type: application/json" `
  -d "{
    `"accountId`": `"default_mt5`",
    `"symbol`": `"EURUSD`",
    `"type`": `"BUY`",
    `"volume`": 0.1
  }"

# Close Position (requires actual position ID)
curl -X POST http://localhost:9000/api/position/close `
  -H "Content-Type: application/json" `
  -d "{
    `"accountId`": `"default_mt5`",
    `"positionId`": `"12345`"
  }"
```

### Performance Testing

#### Load Testing
```powershell
# Install Apache Bench (already available on Windows)
# Or use: winget install ApacheBench

# Test 100 requests
ab -n 100 -c 10 http://localhost:9000/api/health

# Expected: 
# Requests per second: 50+
# Time per request: <20ms
```

---

## Windows VPS Deployment

### Architecture
```
┌─────────────────────────────────────────┐
│         Windows Server 2019+            │
├─────────────────────────────────────────┤
│  ┌──────────────────────────────────┐   │
│  │  IIS (Port 80/443)               │   │
│  │  - Flutter Web Frontend          │   │
│  │  - SSL/TLS Encryption            │   │
│  └──────────────────────────────────┘   │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │  Windows Service (Port 9000)     │   │
│  │  - Python Backend                │   │
│  │  - Flask API                     │   │
│  │  - MT5 Integration               │   │
│  └──────────────────────────────────┘   │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │  MetaTrader 5                    │   │
│  │  - Access to accounts            │   │
│  │  - Trading operations            │   │
│  └──────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### Step-by-Step Deployment

**See: [WINDOWS_VPS_DEPLOYMENT.md](WINDOWS_VPS_DEPLOYMENT.md) for detailed instructions**

Quick Summary:
```powershell
# 1. Connect via Remote Desktop
mstsc
# Connect to: 38.247.146.198:3389

# 2. Install Prerequisites
winget install Python.Python.3.11
winget install Git.Git
winget install OpenJS.NodeJS

# 3. Clone Project
cd C:\
git clone <repo-url> zwesta-trading
cd zwesta-trading

# 4. Setup Python Environment
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements-production.txt

# 5. Configure Environment
Copy-Item .env.production.example .env.production
# Edit .env.production with your settings

# 6. Create Windows Service
choco install nssm
nssm install ZwestaTrading `
  C:\zwesta-trading\venv\Scripts\python.exe `
  C:\zwesta-trading\multi_broker_backend_updated.py

# 7. Setup IIS Website
# Copy Flutter build: build\web\* → C:\inetpub\zwesta-web
# Configure IIS with web.config for routing

# 8. Add SSL Certificate
# Use Let's Encrypt with Certbot
certbot certonly --standalone -d your-domain.com

# 9. Test API
Invoke-WebRequest -Uri "http://localhost:9000/api/health"

# 10. Verify Service
Get-Service ZwestaTrading
# Should show: Running
```

### VPS Monitoring

```powershell
# Check Service Status
Get-Service ZwestaTrading

# View Logs
Get-Content C:\zwesta-trading\logs\stderr.log -Tail 50

# Monitor in Real-Time
Get-Content C:\zwesta-trading\logs\stderr.log -Wait -Tail 0

# Check Port
netstat -ano | findstr :9000

# CPU/Memory Usage
Get-Process python | Select-Object Name, CPU, Memory

# Disk Space
Get-Volume
```

---

## Mobile APK Build

### Prerequisites Check
```powershell
flutter doctor

# Should show all green:
# ✓ Flutter SDK
# ✓ Android toolchain
# ✓ Android SDK
# ✓ Java
# ✓ Chrome
```

### Build Process

**See: [MOBILE_APK_BUILD.md](MOBILE_APK_BUILD.md) for detailed instructions**

```powershell
# 1. Create Signing Key (one-time)
cd android
keytool -genkey -v -keystore app-release-key.jks `
  -keyalg RSA -keysize 2048 -validity 10950 `
  -alias zwesta-app

# 2. Create Key Configuration
# File: android/key.properties
# Content: storePassword=xxx, keyPassword=xxx, etc.
# ⚠️ Add to .gitignore - NEVER COMMIT!

# 3. Build APK
flutter build apk --release

# 4. Output Location
# build\app\outputs\apk\release\app-release.apk

# 5. Test on Device
adb install -r build\app\outputs\apk\release\app-release.apk

# 6. Build App Bundle (for Play Store)
flutter build appbundle --release
```

### Distribution Methods

| Method | Use Case | Steps |
|--------|----------|-------|
| **Direct APK** | Testing, Internal | 1 command, share APK file |
| **Google Play** | Public Release | Create account, submit app |
| **Firebase** | Beta Testing | Setup Firebase, send links |
| **GitHub** | Open Source | Create release, attach APK |
| **Enterprise** | Company Use | Internal distribution |

---

## Remote Desktop Setup

### Connect to VPS
```powershell
# From Local Machine
mstsc
# Input: 38.247.146.198:3389
# Username: Administrator (or your username)
# Password: (your VPS password)

# Or Command Line
mstsc /v:38.247.146.198:3389 /u:Administrator /p:Password
```

### First Time Setup
```powershell
# 1. Create admin user (recommended)
net user ZwestaAdmin "StrongPassword123!" /add
net localgroup administrators ZwestaAdmin /add

# 2. Change password regularly
net user ZwestaAdmin "NewStrongPassword!"

# 3. Enable Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $false

# 4. Enable Windows Update
Set-Service -Name wuauserv -StartupType Automatic
Start-Service wuauserv
```

### Remote Desktop Optimization

For better performance:
```powershell
# Disable unnecessary visual effects
# Settings → Advanced System Settings → Performance → Adjust for best performance

# Enable RDP Compression
# Settings → Remote Settings → Allow users to connect remotely
# ✓ Allow Remote Desktop

# Increase RDP Security
# Local Group Policy Editor → gpedit.msc
# Computer Config → Admin Templates → Windows Components → RDP
# Set: Security Layer = SSL TLS 1.2
```

---

## Deployment Checklist

### Pre-Deployment (Local)
- [ ] Flask/Python backend running
- [ ] API test suite passing (100%)
- [ ] Flutter web app loads
- [ ] No compilation errors
- [ ] Environment files created
- [ ] Database initialized
- [ ] Logs configured
- [ ] SSL certificates ready

### VPS Setup
- [ ] Remote Desktop connection working
- [ ] Python 3.11 installed
- [ ] Git installed
- [ ] Project cloned
- [ ] Virtual environment created
- [ ] Dependencies installed
- [ ] Environment configured
- [ ] Windows service created
- [ ] IIS website configured
- [ ] SSL certificates installed
- [ ] Firewall rules added
- [ ] Ports verified open

### Testing (VPS)
- [ ] Backend health check ✓
- [ ] API endpoints responding ✓
- [ ] Frontend loads ✓
- [ ] Account info displays ✓
- [ ] Trades load ✓
- [ ] Positions display ✓
- [ ] Reports show ✓
- [ ] Demo trades work ✓

### Production
- [ ] All tests passing
- [ ] Monitoring configured
- [ ] Backups active
- [ ] Certificate renewal scheduled
- [ ] Service auto-restart enabled
- [ ] Log rotation active
- [ ] Documentation complete
- [ ] User access provided

### Mobile (APK)
- [ ] Signing key created
- [ ] key.properties configured
- [ ] API endpoint updated for production
- [ ] Permissions configured
- [ ] APK built successfully
- [ ] APK tested on device
- [ ] Release notes prepared
- [ ] Distribution method selected

---

## Directory Structure

```
Zwesta Flutter App/
├── lib/                          # Flutter source
│   ├── main.dart
│   ├── models/
│   ├── screens/
│   ├── services/
│   ├── utils/
│   │   └── environment_config.dart
│   └── widgets/
├── android/                      # Android app
│   ├── app/
│   ├── app-release-key.jks      # Signing key (in .gitignore)
│   ├── key.properties           # Key config (in .gitignore)
│   └── build.gradle
├── build/                        # Build outputs
│   ├── web/                     # Flutter web build
│   └── app/                     # APK/AAB outputs
├── web/                          # Web assets
│   ├── index.html
│   └── manifest.json
├── python/                       # Python packages/modules
├── multi_broker_backend_updated.py   # Main backend
├── wsgi.py                       # WSGI entry point
├── test_api.py                   # Test suite
├── docker-compose.yml            # Docker configuration
├── Dockerfile                    # Container image
├── requirements-production.txt   # Python deps
├── .env.production.example       # Config template
├── nginx-prod.conf              # Web server config
├── WINDOWS_VPS_DEPLOYMENT.md    # VPS guide
├── MOBILE_APK_BUILD.md          # APK guide
├── PRODUCTION_DEPLOYMENT.md     # General deployment
└── .gitignore                    # Git ignore rules
```

---

## Quick Reference

### Local Development
```powershell
# Terminal 1: Backend
python multi_broker_backend_updated.py

# Terminal 2: Frontend
flutter run -d chrome

# Terminal 3: Tests
python test_api.py
```

### VPS Operations
```powershell
# Start service
Start-Service ZwestaTrading

# Stop service
Stop-Service ZwestaTrading

# View logs
Get-Content C:\zwesta-trading\logs\stderr.log -Tail 50

# Restart service
Restart-Service ZwestaTrading
```

### APK Building
```powershell
flutter build apk --release
# Output: build\app\outputs\apk\release\app-release.apk
```

### Testing
```powershell
curl http://localhost:9000/api/health
python test_api.py
```

---

## Troubleshooting Guide

| Issue | Solution |
|-------|----------|
| Backend not starting | Check Python version (3.8+), virtual env activated |
| Port 9000 in use | `netstat -ano \| findstr :9000` → `taskkill /PID` |
| API connection fails | Check firewall, verify backend running |
| APK won't install | Clear cache: `flutter clean` → rebuild |
| VPS slow | Reduce Gunicorn workers, check RAM usage |
| Service won't start | Check logs, verify path, ensure admin |
| SSL error | Verify certificate path, check IIS binding |

---

## Support Resources

- 📚 [Flutter Documentation](https://flutter.dev/docs)
- 🐍 [Python Flask Docs](https://flask.palletsprojects.com/)
- 🔷 [MetaTrader 5 API](https://www.metatrader5.com/)
- 📱 [Android Development](https://developer.android.com/)
- 🪟 [Windows Server Docs](https://docs.microsoft.com/en-us/windows-server/)

---

## Next Steps

1. ✅ Run local tests
2. ✅ Connect to Windows VPS
3. ✅ Deploy backend
4. ✅ Deploy frontend
5. ✅ Build APK
6. ✅ Test on mobile device
7. ✅ Monitor production
8. ✅ Gather user feedback

---

**Status**: 🚀 Ready for Deployment

**Last Updated**: March 7, 2026  
**Version**: 1.0.0
