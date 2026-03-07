# Zwesta Trading System - Complete Testing Checklist

## Phase 1: Local Development Testing

### Backend API Testing

**Setup:**
- [ ] Python virtual environment activated
- [ ] Dependencies installed (`pip install -r trading_backend_requirements.txt`)
- [ ] Backend running on http://localhost:9000
- [ ] Logs visible in terminal

**Core Endpoints:**
```powershell
# Health check
curl http://localhost:9000/api/health
# Expected: {"status": "ok"}

# Get accounts
curl http://localhost:9000/api/accounts/list
# Expected: List of connected accounts

# Get trades
curl http://localhost:9000/api/trades
# Expected: {"trades": [...], "success": true}

# Get positions
curl http://localhost:9000/api/positions/all
# Expected: List of open positions

# Get account equity
curl http://localhost:9000/api/account/equity
# Expected: Margin and equity info

# Get reports
curl http://localhost:9000/api/reports/summary
# Expected: Trade statistics and reports

# Generate demo trades
curl -X POST http://localhost:9000/api/demo/generate-trades ^
  -H "Content-Type: application/json" ^
  -d "{\"count\": 5}"
# Expected: 5 mock trades generated
```

**Checklist:**
- [ ] Health endpoint responds (200 OK)
- [ ] All endpoints return valid JSON
- [ ] No error messages in backend logs
- [ ] Response times < 1 second
- [ ] Account information populated
- [ ] Demo trades generated correctly

### Frontend (Flutter Web) Testing

**Setup:**
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] App running on Chrome
- [ ] Connected to localhost:9000

**UI Verification:**
- [ ] Dashboard loads without errors
- [ ] Welcome message displays
- [ ] Portfolio overview shows
- [ ] Navigation tabs visible (Trades, Accounts, etc.)
- [ ] No console errors (F12 → Console)

**Page Navigation:**
- [ ] Dashboard → Loads account data
- [ ] Trades → Shows trade list (or "No trades" message)
- [ ] Accounts → Lists connected accounts
- [ ] Settings → Can be accessed

**Data Binding:**
- [ ] Account balance displays
- [ ] Profit/Loss shows correctly
- [ ] Trade history populates
- [ ] Account list updates

**Error Handling:**
- [ ] Invalid endpoints show error messages
- [ ] Network errors handled gracefully
- [ ] Missing data doesn't crash app

**Checklist:**
- [ ] App loads within 3 seconds
- [ ] No JavaScript errors in console
- [ ] All pages load successfully
- [ ] Data updates in real-time
- [ ] No memory leaks (check Dev Tools)
- [ ] Responsive design works on different sizes

---

## Phase 2: Android APK Testing

### Build Testing

**Build Process:**
```powershell
# Run build script (takes 5-10 minutes)
build-apk.bat

# Expected output:
# ✓ Gradle build successful
# ✓ APK size < 200MB
# ✓ No build warnings/errors
```

**Checklist:**
- [ ] APK builds without errors
- [ ] APK file exists at: `build\app\outputs\apk\release\app-release.apk`
- [ ] APK size reasonable (< 200MB)
- [ ] Build logs show no critical warnings
- [ ] Signing keys exist (or generated)

### Installation Testing

**Connect Android Device:**
```powershell
# List connected devices
adb devices

# Should show device with "device" status:
# List of attached devices
# emulator-5554            device
```

**Install APK:**
```powershell
# Install APK
adb install build\app\outputs\apk\release\app-release.apk

# Expected output:
# Success

# Verify installation
adb shell pm list packages | findstr zwesta
```

**Checklist:**
- [ ] APK installs successfully
- [ ] No "installation blocked" message
- [ ] App icon appears on home screen
- [ ] App name displays correctly
- [ ] App can be launched

### Runtime Testing

**Launch App:**
```powershell
# Start app
adb shell am start -n com.example.zwesta_trading/.MainActivity

# Check for crashes
adb logcat | findstr "E/.*zwesta"
```

**Test Scenarios:**

1. **Initial Launch:**
   - [ ] Splash screen shows
   - [ ] App initializes without crashing
   - [ ] Main dashboard loads

2. **Network Configuration:**
   - [ ] API URL configuration screen accessible
   - [ ] Can set API URL (e.g., http://192.168.0.X:9000)
   - [ ] Settings persist after restart

3. **API Connectivity:**
   - [ ] App connects to local backend
   - [ ] Health endpoint responds
   - [ ] Account data loads if available
   - [ ] Error handling works if API unreachable

4. **Navigation:**
   - [ ] Bottom navigation tabs work
   - [ ] Page transitions smooth
   - [ ] No crashes during navigation

5. **Data Display:**
   - [ ] Dashboard shows account info
   - [ ] Trades list loads (or "No trades" message)
   - [ ] Numbers format correctly
   - [ ] Colors/styling matches web version

6. **User Interactions:**
   - [ ] Buttons respond to touches
   - [ ] Text fields accept input
   - [ ] Settings can be changed
   - [ ] Changes persist

7. **Error Scenarios:**
   - [ ] Wrong API URL shows error
   - [ ] Network disconnect handled gracefully
   - [ ] App doesn't crash on bad data
   - [ ] Error messages are helpful

**Checklist:**
- [ ] App launches without crashes
- [ ] All pages load successfully
- [ ] API connectivity works
- [ ] Data displays correctly
- [ ] Settings configurable
- [ ] No native Android errors in logs
- [ ] Performance is smooth (no lag)
- [ ] Memory usage reasonable

### Device Testing Matrix

Test on multiple devices/versions:

| Device | Android Version | Status | Notes |
|--------|-----------------|--------|-------|
| Phone 1 | API 30 | [ ] | |
| Phone 2 | API 31+ | [ ] | |
| Tablet | API 29+ | [ ] | |
| Emulator | API 30 | [ ] | |

---

## Phase 3: VPS Deployment Testing

### Pre-Deployment on Local VPS Simulation

**Use Docker (if available) or VM:**
```powershell
# Simulate Windows Server environment
# OR copy to another Windows machine for testing

# Run deployment script
.\deploy-windows-vps.bat
```

**Checklist:**
- [ ] Deployment script runs without errors
- [ ] Python environment created
- [ ] Dependencies installed successfully
- [ ] Service created and starts
- [ ] Nginx config applied
- [ ] Firewall rules added
- [ ] SSL certificate generated

### Post-Deployment VPS Testing

**Service Verification:**
```powershell
# Check service status
C:\tools\nssm status zwesta-trading
# Expected: SERVICE_RUNNING

# Check process
Get-Process | Select-Object Name | findstr gunicorn

# Check API port
netstat -ano | findstr :9000
```

**API Testing from VPS:**
```powershell
# Local health check
curl http://localhost:9000/api/health

# Test all endpoints
curl http://localhost:9000/api/accounts/list
curl http://localhost:9000/api/trades
curl http://localhost:9000/api/positions/all
```

**Checklist:**
- [ ] Service runs automatically on reboot
- [ ] API accessible on http://vps-ip:9000
- [ ] All endpoints respond correctly
- [ ] Logs are being written
- [ ] No errors in logs
- [ ] Resource usage reasonable (CPU < 30%, RAM < 1GB)

### Remote Access Testing

**From Your Local Machine:**
```powershell
$VPS_IP = "your.vps.ip.address"

# Test connectivity
Test-NetConnection -ComputerName $VPS_IP -Port 9000

# Test API
curl http://$VPS_IP:9000/api/health

# Connect via RDP
mstsc /v:$VPS_IP
```

**Checklist:**
- [ ] Firewall rules allow external connections
- [ ] API accessible from external network
- [ ] RDP connection works
- [ ] File transfer via RDP works
- [ ] Response times acceptable (< 500ms)

---

## Phase 4: Mobile-to-VPS Integration Testing

### Configure Mobile App for VPS

On Android device:
1. Open Zwesta Trading app
2. Go to Settings
3. Set API URL to: `http://your-vps-ip:9000`
4. Save and restart app

**Checklist:**
- [ ] Settings screen accessible
- [ ] API URL field editable
- [ ] Changes persist after restart
- [ ] App reconnects to new API

### End-to-End Testing

**Scenario 1: View Account Info**
- [ ] App connects to VPS
- [ ] Account data loads
- [ ] Balance displays correctly
- [ ] No connection errors

**Scenario 2: View Trades**
- [ ] Trades list loads
- [ ] Trade details display
- [ ] Profit/loss shown correctly
- [ ] List updates on refresh

**Scenario 3: Network Transitions**
- [ ] WiFi to mobile network: app reconnects
- [ ] Network loss: error displayed, recovers
- [ ] Network slow: data loads eventually

**Scenario 4: Data Accuracy**
- [ ] Web version and mobile show same data
- [ ] Numbers match exactly
- [ ] Formatting consistent
- [ ] Updates synchronized

**Checklist:**
- [ ] Mobile app connects to remote VPS
- [ ] All data displays correctly
- [ ] Performance acceptable (< 2s per action)
- [ ] Error handling works
- [ ] Network transitions handled
- [ ] No crashes or freezes

---

## Phase 5: Load & Stress Testing

### API Load Testing

```powershell
# Using ApacheBench (ab.exe) or similar
# Make 1000 requests to health endpoint

ab -n 1000 -c 10 http://localhost:9000/api/health

# Expected:
# Successful requests: 1000
# Failed requests: 0
# Response time: < 100ms average
```

**Checklist:**
- [ ] API handles 100 concurrent requests
- [ ] No timeout errors
- [ ] No dropped connections
- [ ] Response times stable
- [ ] Memory doesn't leak

### Large Data Testing

```powershell
# Generate many trades
curl -X POST http://localhost:9000/api/demo/generate-trades ^
  -H "Content-Type: application/json" ^
  -d "{\"count\": 1000}"

# Query large result set
curl http://localhost:9000/api/trades
```

**Checklist:**
- [ ] API handles large datasets
- [ ] Response times acceptable
- [ ] No OutOfMemory errors
- [ ] Data integrity preserved

---

## Phase 6: Security Testing

### Authentication & Authorization

- [ ] API endpoints validate input
- [ ] SQL injection attempts fail
- [ ] Invalid tokens rejected
- [ ] CORS properly configured
- [ ] No sensitive data in logs

**Checklist:**
```powershell
# Test CORS
curl -H "Origin: http://evil.com" http://localhost:9000/api/health

# Test invalid input
curl "http://localhost:9000/api/trades?symbol=<script>alert(1)</script>"

# Check headers
curl -i http://localhost:9000/api/health | findstr -i security
```

### Network Security

- [ ] HTTPS enforced on VPS
- [ ] Firewall blocks unwanted ports
- [ ] SSH/RDP only from authorized IPs
- [ ] Credentials not exposed

**Checklist:**
- [ ] VPS port scan shows only 80/443/9000 open
- [ ] NMAP shows hardened system
- [ ] No default ports exposed

---

## Phase 7: Performance Baseline

### Measure Performance

| Metric | Local | VPS | Target |
|--------|-------|-----|--------|
| API Response Time | | | < 200ms |
| Frontend Load Time | | | < 2s |
| APK Size | | | < 150MB |
| Backend Memory | | | < 500MB |
| Backend CPU | Idle | | < 10% |

**Checklist:**
- [ ] Response times measured
- [ ] Load times recorded
- [ ] Performance targets met
- [ ] Baseline established for future comparison

---

## Phase 8: Documentation Verification

### Check All Documentation

- [ ] README.md is accurate
- [ ] VPS_SETUP_GUIDE.md covers all steps
- [ ] PRODUCTION_DEPLOYMENT.md is complete
- [ ] API documentation lists all endpoints
- [ ] Configuration examples work
- [ ] Troubleshooting guide helps resolve common issues

**Checklist:**
- [ ] All docs exist and are readable
- [ ] Code examples run without errors
- [ ] Links work correctly
- [ ] Screenshots/diagrams are clear

---

## Testing Sign-Off

### Final Approval Checklist

**Local Testing:**
- [ ] Backend API fully functional
- [ ] Frontend web app works perfectly
- [ ] All endpoints tested and working
- [ ] Error handling verified

**Mobile Testing:**
- [ ] APK builds successfully
- [ ] Installs on Android device
- [ ] Runs without crashes
- [ ] Connects to API
- [ ] Data displays correctly

**VPS Deployment:**
- [ ] Automated deployment works
- [ ] Manual deployment verified
- [ ] Service auto-starts after reboot
- [ ] Remote access configured
- [ ] Security hardened

**Integration:**
- [ ] Mobile app connects to VPS
- [ ] End-to-end scenarios work
- [ ] Data consistency verified
- [ ] Performance acceptable

### Sign-Off

- **Date Tested**: _______________
- **Tested By**: _______________
- **Status**: Ready for Production [ ] / Needs Fix [ ]
- **Notes**: 

---

## Quick Test Commands

**Save this as a batch file for quick testing:**

```batch
@echo off
echo Testing Zwesta Trading System...

echo [1/7] API Health Check
curl http://localhost:9000/api/health || echo FAILED

echo [2/7] Get Accounts
curl http://localhost:9000/api/accounts/list || echo FAILED

echo [3/7] Get Trades
curl http://localhost:9000/api/trades || echo FAILED

echo [4/7] Generate Demo Data
curl -X POST http://localhost:9000/api/demo/generate-trades -H "Content-Type: application/json" -d "{\"count\": 5}" || echo FAILED

echo [5/7] Check Service
C:\tools\nssm status zwesta-trading || echo Check manually

echo [6/7] Check Logs
echo Last 10 lines of backend log:
type C:\Applications\zwesta-trading\logs\trading_backend.log | for /l %%A in (1,1,10) do @echo.

echo [7/7] Network Test
Test-NetConnection localhost -Port 9000 || echo FAILED

echo.
echo All tests completed!
```

---

**Status**: Testing Complete  
**Last Updated**: March 7, 2026
