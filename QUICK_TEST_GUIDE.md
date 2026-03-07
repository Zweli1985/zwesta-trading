# Quick Start Testing Guide - 3 Simple Steps

## Step 1: Test Everything Locally (5 minutes)

Open PowerShell in your project folder and run:

```powershell
cd "C:\zwesta-trader\Zwesta Flutter App"
.\test-local.bat
```

**What it does:**
- Checks that Python and Flutter are installed
- Installs backend dependencies
- Starts the backend on http://localhost:9000
- Opens your Flutter app in Chrome

**Expected result:**
- Backend starts showing: `Running on http://0.0.0.0:9000`
- Browser opens with the Zwesta Trading app
- App shows "Connected to trading backend at http://localhost:9000"

**Test the app:**
- [ ] Click through different screens (Dashboard, Trades, Accounts)
- [ ] Verify data loads (balance, trades, etc.)
- [ ] No error messages

---

## Step 2: Deploy to Windows VPS (15 minutes)

**On your Windows VPS via Remote Desktop:**

```powershell
# Navigate to folder
cd C:\Applications\zwesta-trading

# Run the deployment script
.\deploy-windows-vps.bat
```

**What it does:**
- Creates Python virtual environment
- Installs all dependencies
- Sets up Windows service (auto-start)
- Configures Nginx reverse proxy
- Generates SSL certificate
- Opens firewall ports (80, 443, 9000)
- Tests the API

**Expected result:**
- Script completes with "✓ Deployment successful"
- Service shows "SERVICE_RUNNING" status
- API responds to http://localhost:9000/api/health

**Verify from your local machine:**

```powershell
# Replace with your VPS IP address
$VPS_IP = "your.vps.ip"

# Test API
curl http://$VPS_IP:9000/api/health

# Should return: {"status": "ok"}
```

---

## Step 3: Build & Test Android APK (10 minutes)

**On your local development machine:**

```powershell
cd "C:\zwesta-trader\Zwesta Flutter App"
.\build-apk.bat
```

**What it does:**
- Builds Flutter release APK
- Signs the app
- Generates APK file: `build\app\outputs\apk\release\app-release.apk`

**Install on Android phone (Option A - USB):**

```powershell
# Connect phone with USB, enable USB debugging
adb install build\app\outputs\apk\release\app-release.apk

# Expected: "Success"
```

**Install on Android phone (Option B - Manual):**
1. Copy `build\app\outputs\apk\release\app-release.apk` to your phone
2. Open file manager on phone
3. Tap the APK file
4. Tap "Install"

**Configure API URL in app:**
1. Open the app on your phone
2. Go to Settings
3. Set "API URL" to: `http://your-vps-ip:9000`
4. Tap Save

**Test functionality:**
- [ ] App connects without errors
- [ ] Can view account info
- [ ] Can see trades (if any exist)
- [ ] Navigation works smoothly

---

## Quick Verification Commands

**Check backend is running:**
```powershell
curl http://localhost:9000/api/health
```

**Check VPS service:**
```powershell
C:\tools\nssm status zwesta-trading
```

**View error logs:**
```powershell
# On VPS
type C:\Applications\zwesta-trading\logs\trading_backend.log

# Or on local
type multi_broker_backend.log
```

**Restart service:**
```powershell
# On VPS
C:\tools\nssm restart zwesta-trading
```

---

## Troubleshooting Quick Fixes

### Backend won't start
```powershell
# Check if port 9000 is in use
netstat -ano | findstr :9000

# If in use, kill the process
taskkill /PID <PID> /F
```

### Flutter app won't connect
```powershell
# Verify API URL in app
# Settings → API URL must be http://localhost:9000 (local)
# Or http://your-vps-ip:9000 (remote)

# Test curl command
curl http://localhost:9000/api/health
```

### APK build fails
```powershell
# Check Flutter toolchain
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
.\build-apk.bat
```

### VPS deployment fails
```powershell
# Check Python is installed
python --version

# Check admin privileges
# (Right-click PowerShell → Run as Administrator)

# Run step-by-step from VPS_SETUP_GUIDE.md
```

---

## Files Created for You

| File | Purpose | Run How |
|------|---------|---------|
| `test-local.bat` | Test everything locally | Double-click or run in PowerShell |
| `deploy-windows-vps.bat` | Deploy to Windows VPS | Run on VPS via RDP |
| `build-apk.bat` | Build Android APK | Run on local machine |
| `VPS_SETUP_GUIDE.md` | Detailed VPS setup | Read in VS Code |
| `TESTING_CHECKLIST.md` | Complete test plan | Follow systematically |

---

## Next Steps

1. **Right now**: Run `test-local.bat` and verify everything works locally
2. **Then**: Copy files to VPS via RDP and run `deploy-windows-vps.bat`
3. **Finally**: Build APK with `build-apk.bat` and test on phone

---

## Support

If you encounter issues:

1. Check the relevant guide:
   - Local issues → See error in console
   - VPS issues → Check `VPS_SETUP_GUIDE.md` → Troubleshooting section
   - Mobile issues → Check `TESTING_CHECKLIST.md` → Phase 2

2. Check logs:
   - Backend: `multi_broker_backend.log`
   - VPS: `C:\Applications\zwesta-trading\logs\trading_backend.log`

3. Common fixes:
   - Restart backend: Close and re-run `test-local.bat`
   - Restart service: `nssm restart zwesta-trading` on VPS
   - Clear cache: `flutter clean` then rebuild

---

**You're all set! Start with Step 1.** 🚀
