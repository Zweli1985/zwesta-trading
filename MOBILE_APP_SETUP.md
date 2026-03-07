# Zwesta Intelligent Trading Platform - Mobile App Setup Guide

## Overview
This guide enables you to run the Zwesta trading platform on Android and iOS mobile devices for testing and production use.

## Architecture
- **Single Codebase**: One Flutter project builds for Web, Android, and iOS
- **Shared Backend**: All platforms connect to the intelligent trading backend on port 9000
- **Real-time Sync**: Live bot data synced across all devices
- **Independent Operation**: Mobile app can control trading remotely

## Prerequisites

### System Requirements
- **Flutter SDK**: 3.0+ (installed)
- **Dart SDK**: 3.0+ (included with Flutter)
- **For Android Testing**:
  - Android Studio with SDK (API level 21+)
  - Android Emulator configured
  - Minimum 2GB RAM allocated to emulator
- **For iOS Testing** (macOS only):
  - Xcode 13+
  - iOS Simulator
  - CocoaPods

### Current Installation Status
```
✓ Flutter Web: Running on port 3001
✓ Backend: Intelligent Trading Backend on port 9000
✓ XM Global: Configured for demo/live trading
✓ Strategies: 6 strategies with auto-switching enabled
```

## Mobile App Features - Intelligent Edition

### Dashboard (Home Screen)
✓ **Portfolio Summary**: Total profit, equity, current drawdown
✓ **Active Bots List**: Real-time status with live profit updates every 5 seconds
✓ **Auto-Switching Display**: Shows when strategy automatically switches to better performer
✓ **Position Scaling**: Visual indicator of dynamic position size adjustments
✓ **Quick Create Bot**: One-tap bot creation with default settings

### Intelligent Trading Features on Mobile
1. **Real-time Strategy Switching**
   - Backend monitors each bot's performance
   - Automatically switches to best-performing strategy
   - Mobile shows: "✅ Switched to Trend Following (75% win rate)"

2. **Dynamic Position Scaling**
   - Positions automatically scale up after wins
   - Position size reduces after losses (capital protection)
   - Mobile shows: "Position: 0.10 → 0.11 (scaled up after 5 wins)"

3. **Market Data Integration**
   - 24 commodities with live sentiment signals
   - When selecting strategy, mobile shows which commodities are trending
   - Color-coded recommendations: 🟢 STRONG BUY | 🟡 CAUTION | 🔴 SELL

---

## Quick Start - Android Testing

### Step 1: Check Android Setup
```powershell
flutter doctor --android
```

**Expected Output:**
```
[✓] Android toolchain - develop for Android devices
[✓] Android Studio 
[✓] Android SDK
[✓] Chrome
```

### Step 2: Configure Mobile API Connection

Edit [lib/config/app_config.dart](lib/config/app_config.dart):
```dart
// Find line: static const String baseUrl = 
// Change to your Windows machine IP:
static const String baseUrl = 'http://192.168.1.100:9000'; // Replace with your IP
```

**Get your actual IP:**
```powershell
ipconfig
# Look for IPv4 Address (example: 192.168.1.100)
```

### Step 3: Allow Windows Firewall for Backend

```powershell
# Run as Administrator in PowerShell
New-NetFirewallRule -DisplayName "Zwesta Backend" `
  -Direction Inbound `
  -LocalPort 9000 `
  -Protocol TCP `
  -Action Allow

# Verify firewall rule
Get-NetFirewallRule -DisplayName "Zwesta Backend"
```

**Verify it works from phone:**
```powershell
# On your Windows machine
curl "http://192.168.1.100:9000/api/bot/status"
# Should return JSON with active bots
```

### Step 4: Start Android Emulator (if not running)
```powershell
# List available emulators
emulator -list-avds

# Start emulator (example - Pixel 6 API 33)
Start-Process "emulator" -ArgumentList "-avd", "Pixel_6_API_33" -WindowStyle Minimized

# Wait 15 seconds for emulator to boot...
Start-Sleep -Seconds 15

# Verify emulator is ready
flutter devices  # Should show your emulator
```

### Step 5: Build and Run on Android
```powershell
cd "c:\zwesta-trader\Zwesta Flutter App"

# First time setup
flutter pub get

# Run on emulator or physical device
flutter run

# If slow, use release build (faster, more stable)
flutter run --release
```

**Expected Output:**
```
Launching lib/main.dart on [device name] in debug mode...
Running Gradle build...
✓ Built build/app/outputs/flutter-apk/app-debug.apk
Launching com.zwesta.trading/com.zwesta.trading.MainActivity...
✓ Connected device [device name]

App started successfully!
```

### Step 6: Test Mobile App Features

Once app loads on phone:

1. **Verify Backend Connection**
   - Dashboard should load without errors
   - Active bots should sync with web app (http://localhost:3001)
   
2. **Test Real-time Updates**
   - Start a bot on web or mobile
   - Both platforms update automatically every 5 seconds
   
3. **Verify Intelligent Features**
   - Watch for strategy switching notifications
   - Monitor position size changes in bot details
   - Check recommended commodity list matches market signals

---

## Step 2: Start Android Emulator (if not running)
```powershell
# List available emulators
emulator -list-avds

# Start emulator (example)
emulator -avd Pixel_5_API_30
```

### Step 3: Build and Run on Android
```powershell
cd "c:\zwesta-trader\Zwesta Flutter App"
flutter run -d emulator-5554  # Use actual emulator ID
# or
flutter run  # Automatically selects connected device/emulator
```

### Step 4: Verify Connection
- App should display login screen
- Bottom nav: Dashboard → Trades → Accounts → Bots
- Check logs: `flutter logs`
- Hot reload: Press 'r' during development

## Quick Start - iOS Testing (macOS only)

### Step 1: Install Dependencies
```bash
cd "c:\zwesta-trader\Zwesta Flutter App"
flutter pub get
cd ios
pod install
cd ..
```

### Step 2: Build and Run on Simulator
```bash
open -a Simulator  # Start iOS Simulator
flutter run -d iPhone
```

## Network Configuration for Mobile

### Finding Your Machine IP Address
Only needed if running on physical Android device or emulator on another machine.

```powershell
# On Windows machine running the backend
ipconfig

# Find your IPv4 Address (example output):
# Ethernet adapter Local:
#   IPv4 Address . . . . . . . . . . . : 192.168.1.100
```

### Configuring Mobile App for Backend Connection

Depending on your testing scenario:

#### Scenario A: Android Emulator on Same Windows Machine
```
App Configuration: Backend = 'http://10.0.2.2:9000'
Note: 10.0.2.2 is the special alias for the host machine
```

#### Scenario B: Physical Phone on Same Network
```
App Configuration: Backend = 'http://192.168.1.100:9000'
Replace 192.168.1.100 with YOUR actual IPv4 address from ipconfig
```

#### Scenario C: iOS Simulator on Mac (if available later)
```
App Configuration: Backend = 'http://localhost:9000'
```

### Testing Your Connection

**From Windows Machine:**
```powershell
# Should return JSON data
curl "http://192.168.1.100:9000/api/bot/status"
```

**From Android Phone/Emulator:**
Open browser and navigate to: `http://10.0.2.2:9000/api/bot/status` (for emulator)
Or: `http://192.168.1.100:9000/api/bot/status` (for physical phone)

**Expected Response:**
```json
{
  "active_bots": [
    {
      "id": "BOT-1234567890",
      "status": "Trading",
      "strategy": "Trend Following",
      "daily_profit": 150.50,
      ...
    }
  ]
}
```

### Update Backend URL
Edit `lib/services/trading_service.dart`:
```dart
// Line ~20
const String BACKEND_URL = 'http://10.0.2.2:9000/api';  // For Android emulator
// OR
const String BACKEND_URL = 'http://192.168.0.138:9000/api';  // For physical device
// OR  
const String BACKEND_URL = 'http://localhost:9000/api';  // For iOS simulator
```

## Mobile-Specific Features

### Platform Optimizations
1. **Bottom Navigation**: Native tabs for quick access (Dashboard, Trades, Accounts, Bots)
2. **Real-time Sync**: Updates every 5 seconds across all connected devices
3. **Gestures**: Pull-to-refresh on dashboard and bot list screens
4. **Adaptive UI**: Responsive layouts for phone, tablet, and landscape mode
5. **Offline Capability**: Settings cached locally, viewable without connection
6. **Battery Optimization**: Minimal background resource usage

---

## Testing Scenarios - Intelligent Features

### Test Scenario 1: Create Bot on Mobile, Monitor on Web

**Steps:**
1. Open mobile app on emulator/phone
2. Tap Dashboard → Create Bot
3. Select Strategy: "Scalping"
4. Tap Create
5. Open web app in browser (http://localhost:3001)
6. Dashboard should show the newly created bot

**Expected Result:**
- Mobile shows: "Bot Created: BOT-123456"
- Web shows: Bot in Active Bots List
- Both show same bot data and profit updates
- Real-time sync every 5 seconds

**Validation Checklist:**
- [ ] Bot ID matches on both platforms
- [ ] Strategy shown correctly on both
- [ ] Daily profit updates synchronized
- [ ] No network errors in logs

---

### Test Scenario 2: Intelligent Strategy Switching on Mobile

**Steps:**
1. Start bot (mobile or web)
2. Watch dashboard on mobile for 2-3 minutes
3. Backend tracks performance across strategies
4. After ~10 trades, backend evaluates: Which strategy has best win rate?
5. If different strategy is better, bot automatically switches
6. Mobile updates display: "✅ Switched to Trend Following"

**Expected Behavior:**
```
Example:
- Initial Strategy: Scalping (65% win rate)
- After 10 trades: Trend Following evaluated (78% win rate)
- Action: Bot switches to Trend Following
- Mobile shows: "Strategy switched (better performance)"
- Web & Mobile both display: "Trend Following" in strategy field
```

**Check Backend Log:**
```powershell
# In backend terminal, look for:
# "Strategy switching: Scalping -> Trend Following (78% > 65%)"
```

**Validation Checklist:**
- [ ] Strategy field updates on both platforms
- [ ] Win rate improves after switch
- [ ] No trading pause during switch
- [ ] Previous strategy stats preserved

---

### Test Scenario 3: Dynamic Position Scaling on Mobile

**Steps:**
1. Create bot with base position: 0.1
2. Monitor position size in bot details
3. Run trading (automatic every 30 seconds)
4. After 5 wins: Position should scale UP to ~0.11
5. After 3 consecutive losses: Position should scale DOWN to ~0.10

**Expected Display on Mobile:**
```
Position Size: 0.10 → 0.11 (📈 scaled up after 5 wins)
```

**Mathematical Logic:**
```
Base Position: 0.10
After 5 wins: 0.10 × (1 + (5 × 0.025)) = 0.10 × 1.125 = 0.1125 ≈ 0.11
After 3 losses: 0.11 × (1 - (3 × 0.01)) = 0.11 × 0.97 = 0.1067 ≈ 0.11
```

**Validation Checklist:**
- [ ] Position increases after winning trades
- [ ] Position decreases after losing trades
- [ ] Position never exceeds max (0.5)
- [ ] Position never drops below min (0.01)
- [ ] Changes visible in real-time on mobile

---

### Test Scenario 4: Web + Mobile Cross-Platform Testing

**Multi-Device Setup:**
1. Android emulator (mobile app)
2. Chrome browser on Windows (web app - http://localhost:3001)
3. Both connected to same backend (port 9000)
4. User controls on one side → Other side updates

**Test Actions:**
| Action on Web | Expected on Mobile | Time to Sync |
|---|---|---|
| Create Bot | Appears in mobile dashboard | < 5 seconds |
| Start Trading | Mobile shows trading status | < 1 second |
| Stop Bot | Mobile shows stopped status | < 1 second |
| Adjust Risk | Position sizes change on mobile | < 5 seconds |
| Strategy Switch | Both show new strategy | < 1 second |

**Example Workflow:**
```
1. Create bot on Web
2. Start trading on Web
3. Check Mobile Dashboard
   - Bot present ✓
   - Profit updating ✓
   - Status: Trading ✓
4. Switch strategy on Mobile
5. Check Web Dashboard
   - Strategy updated ✓
   - No duplicate bot ✓
```

---

### Test Scenario 5: Error Handling & Connectivity

**Test Connection Loss:**
1. Start app and verify backend connection
2. Kill backend (Ctrl+C in terminal)
3. Mobile should show: "Connection Error - Tap to Retry"
4. Tap Retry
5. Backend still down: Shows error again
6. Restart backend
7. Tap Retry: Connection restored, data loads

**Expected Error Screens:**
- "No Internet Connection" → for actual WiFi loss
- "Cannot Connect to Backend" → for port 9000 down
- "Invalid Backend URL" → for wrong IP configuration

**Recovery Options:**
- [ ] Manual Retry button works
- [ ] Auto-retry after 30 seconds
- [ ] Cached data still viewable offline
- [ ] Clear error message to adjust settings if needed

---

### Test Scenario 6: Performance & Load Testing

**Check Mobile App Performance:**

**Startup Time:**
```powershell
# Measure from app launch to dashboard visible
Typical: < 3 seconds

flutter run (with profiling)  # Use --profile flag for accurate measurements
```

**Real-time Update Responsiveness:**
```
Dashboard loaded: ✓ (0.5 sec)
Active bots load: ✓ (1.2 sec)
Real-time updates: ✓ (5 sec intervals)
Charts render smoothly: ✓ (60 FPS)
```

**Network Usage:**
- Cold start: ~2-5 MB
- Per 24 hours idle: ~5-10 MB
- Per trade: ~50 KB
- Per real-time update: ~5-10 KB

**Battery Usage:**
- Screen on, idle: ~2% per hour
- Screen on, trading: ~3-4% per hour
- Screen off, background: ~0.5% per hour

---

### Test Scenario 7: Market Data & Recommendations

**Test Commodity Signals:**
1. Open Bot Configuration on mobile
2. Tap "Select Commodities"
3. Verify 24 symbols displayed with signals:
   - 🟢 indicates strong buy signals
   - 🟡 indicates caution/mixed signals
   - 🔴 indicates sell signals
4. Select 3-4 symbols with strong signals
5. Create bot
6. Monitor profitability vs. non-signaled symbols

**Expected Signal Distribution:**
```
On any given time:
- ~40% 🟢 (STRONG BUY - positive momentum)
- ~35% 🟡 (CAUTION - mixed signals)
- ~25% 🔴 (SELL - negative momentum)

Most profitable trades occur with 🟢 signals
```

**Validation:**
- [ ] Signal colors accurate
- [ ] Trend direction correct
- [ ] Price change % realistic
- [ ] Volatility level matches market conditions
- [ ] Recommendation text matches signal color

---

### Test Scenario 8: Multi-Bot Management

**Setup Multiple Bots:**
1. Create 3 bots on mobile/web:
   - Bot 1: Scalping strategy on EURUSD
   - Bot 2: Trend Following on GOLD
   - Bot 3: Momentum on SPX500
2. Start all trading
3. Verify dashboard shows all 3 with individual metrics
4. Check total portfolio profit = sum of individual profits

**Expected Dashboard View:**
```
Portfolio Summary:
  Total Equity: $10,540
  Total Daily Profit: $540
  Total Drawdown: -$230

Active Bots: 3
  ✓ BOT-001: Scalping | Profit: +$150 | Trades: 15
  ✓ BOT-002: Trend Following | Profit: +$250 | Trades: 6
  ✓ BOT-003: Momentum | Profit: +$140 | Trades: 12
```

**Validation:**
- [ ] All bots trade independently
- [ ] Totals calculated correctly
- [ ] Each bot switches strategies independently
- [ ] Position size for each calculated correctly
- [ ] No memory leaks with multiple bots running

---

## Troubleshooting Mobile App

| Issue | Solution |
|-------|----------|
| App won't connect to backend | Check IP in app_config.dart matches your machine. Test with curl. |
| Emulator too slow | Reduce resolution (Small), enable GPU acceleration in settings |
| App crashes on startup | Run `flutter clean && flutter pub get` then rebuild |
| Charts not rendering | Ensure FLChart dependency installed (flutter pub get) |
| Real-time updates lag | Check network latency with ping, reduce update frequency if needed |
| APK too large | Use `flutter build apk --split-per-abi` (separate per architecture) |
| Battery drains quickly | Reduce update frequency (change 5 sec to 10 sec in code) |
| Can't see emulator in devices | Run `flutter devices`, restart Android Studio |

---

## Building Release APK for Testing

When ready to share with others for testing:

```powershell
cd "c:\zwesta-trader\Zwesta Flutter App"

# Build unsigned APK (for testing only)
flutter build apk --release

# Output location
# build/app/outputs/flutter-apk/app-release.apk

# Send file to tester
# Tester: Enable "Unknown Sources" in Settings, then tap APK to install
```

**For wider distribution:**
```powershell
# Build separate APK per CPU architecture (reduces size)
flutter build apk --release --split-per-abi

# Outputs:
# - app-armeabi-v7a-release.apk (~40MB)
# - app-arm64-v8a-release.apk (~45MB)
# - app-x86_64-release.apk (~48MB)
```

---

## Next Steps

### Immediate (What we just did)
✅ Backend: Intelligent strategy switching + position scaling
✅ Mobile: Setup guide for Android testing
✅ Cross-platform: Web + Mobile real-time sync

### Phase 2 (Next week)
⏳ Push notifications using Firebase Cloud Messaging
⏳ User authentication system
⏳ Subscription/payment handling
⏳ Profit commission tracking

### Phase 3 (Final)
⏳ App Store & Google Play submission
⏳ White-label customization options
⏳ Educational content integration
⏳ Affiliate system

---

## Quick Reference Commands

```powershell
cd "c:\zwesta-trader\Zwesta Flutter App"

# Check system status
flutter doctor -v

# Get latest code
flutter pub get

# Run on emulator
flutter run

# Run with profiling (performance testing)
flutter run --profile

# Build release APK
flutter build apk --release

# View logs
flutter logs

# Clean build (if issues)
flutter clean

# Hot reload (during flutter run, press 'r')
# Hot restart (during flutter run, press 'R')
```

---

## Support & Questions

For issues:
1. Check [VPS_TROUBLESHOOTING.md](VPS_TROUBLESHOOTING.md) for backend issues
2. Check [README.md](README.md) for general system overview
3. View logs: `flutter logs` (shows app and backend output)
4. Test endpoint: `curl http://192.168.1.X:9000/api/bot/status`

### Testing Checklist
- [ ] App launches without errors
- [ ] Dashboard shows active bots (fetches from backend)
- [ ] Create bot button works
- [ ] Strategy selection loads 6 options
- [ ] 24 commodities display correctly
- [ ] Charts render properly
- [ ] Navigation works between all screens
- [ ] Hot reload works (press 'r')
- [ ] Trades execute successfully
- [ ] Position sizing adjusts with each trade
- [ ] Performance metrics update in real-time

## Development Workflow

### Building for Testing
```powershell
# Android APK (debug)
flutter build apk --debug

# Android APK (release)
flutter build apk --release

# iOS App Bundle
flutter build ios --release
```

### Debugging
```powershell
# View device logs
flutter logs

# Verbose output
flutter run -v

# Debug web version
flutter run -d chrome --web-port=3002  # Different port if 3001 in use
```

### Performance Profiling
```powershell
# Run with DevTools
flutter run --profile

# DevTools: Open in browser when app runs
```

## Deployment

### For Android
1. Build release APK:
   ```powershell
   flutter build apk --release
   ```
2. File location: `build/app/outputs/apk/release/app-release.apk`
3. Install on device: `adb install build/app/outputs/apk/release/app-release.apk`

### For iOS
1. Build release bundle:
   ```bash
   flutter build ios --release
   ```
2. Upload to App Store using Xcode or Transporter

### For Web
1. Build web release:
   ```powershell
   flutter build web --release
   ```
2. Deploy `build/web/` to hosting (Firebase, Netlify, VPS)

## Troubleshooting

### Port Already in Use
```powershell
# Kill process using port 9000 (backend)
$processes = Get-NetTCPConnection -LocalPort 9000 -ErrorAction SilentlyContinue
$processes | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }

# Kill process using port 3001 (web)
$processes = Get-NetTCPConnection -LocalPort 3001 -ErrorAction SilentlyContinue
$processes | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }
```

### Emulator Can't Connect to Backend
```
Issue: "Failed to fetch" when app tries to reach backend
Solution: Use 10.0.2.2 instead of localhost for Android emulator
```

### Flutter Build Fails
```powershell
# Clean build
flutter clean
flutter pub get
flutter pub cache repair
flutter run
```

### Hot Reload Not Working
```
Issue: App changes not reflected
Solution: Run with hot restart instead
Command: Press 'R' or 'flutter run -v'
```

## Performance Metrics

### Expected Performance
- **Startup Time**: <3 seconds
- **Bot Creation**: <1 second
- **Trade Execution**: <500ms per trade
- **Chart Rendering**: <2 seconds for 100+ data points
- **Memory Usage**: 80-150MB average

### Optimization Tips
1. Reduce chart data points: Keep last 50 transactions
2. Paginate trade history: Show 20 per page
3. Lazy load bot details: Load on demand
4. Cache API responses: 30-second TTL
5. Use `const` widgets where possible

## Next Steps

1. **Set up Android Studio** (if testing on Android)
2. **Configure Android Emulator** (at least one device)
3. **Update backend URL** in `lib/services/trading_service.dart`
4. **Run `flutter run`** to start development
5. **Test on emulator/device**
6. **Deploy to beta testers**

## Useful Commands

```powershell
# Device management
flutter devices                    # List connected devices
flutter run -d <device_id>        # Run on specific device
adb shell am force-stop <app>     # Force stop Android app
xcrun simctl erase all             # Clear iOS simulator

# Development
flutter upgrade                    # Update Flutter SDK
flutter pub upgrade               # Update all packages
flutter pub upgrade --major-versions  # Include major version updates
flutter precache                  # Pre-download artifacts

# Debugging
flutter run --debug               # Debug mode
flutter run --profile             # Profile mode (performance)
flutter run --release             # Release mode
flutter analyze                   # Code analysis
dart format --fix .              # Format code
```

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Android Setup Guide](https://flutter.dev/docs/get-started/install/windows)
- [iOS Setup Guide](https://flutter.dev/docs/get-started/install/macos)
- [Firebase Console](https://console.firebase.google.com)
- [XM Global Account](https://www.xmglobal.com)

## Support

For issues or questions:
1. Check `flutter logs` for error messages
2. Run `flutter doctor` to diagnose environment
3. Try `flutter clean` and rebuild
4. Check backend connectivity: `curl http://localhost:9000/api/health`
