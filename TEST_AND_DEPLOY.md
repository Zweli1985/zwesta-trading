# Zwesta Trading - Intelligent System Testing & Deployment Guide

**Status**: Ready for XM Global Live Testing  
**Date**: March 7, 2026  
**Features**: Strategy Switching, Position Scaling, Multi-Platform Testing

---

## Executive Summary

Your trading system now has:
✅ **Intelligent Backend** - Automatically switches strategies and scales positions based on performance  
✅ **Web Platform** - Real-time dashboard at http://localhost:3001  
✅ **Mobile Platform** - Android app for on-the-go monitoring  
✅ **Cross-Platform Sync** - All devices show unified data in real-time  
✅ **XM Global Ready** - Configured for demo and live trading

---

## Quick Start (5 minutes)

### Option A: Windows (Web + Mobile Emulator)

```powershell
# Terminal 1: Start everything
cd "c:\zwesta-trader\Zwesta Flutter App"
START_DEVELOPMENT.bat

# This starts:
# - Backend on port 9000
# - Web on port 3001
# - Opens new terminal windows

# Wait 10 seconds, then open browser:
http://localhost:3001
```

### Option B: Just Web (No Mobile)

```powershell
# Terminal 1: Backend
cd "c:\zwesta-trader\Zwesta Flutter App"
python multi_broker_backend_updated.py

# Terminal 2: Web Frontend
cd "c:\zwesta-trader\Zwesta Flutter App"
flutter run -d chrome --web-port=3001

# Browser opens automatically
```

### Option C: Just Backend (For API Testing)

```powershell
cd "c:\zwesta-trader\Zwesta Flutter App"
python multi_broker_backend_updated.py

# Test in PowerShell:
curl http://localhost:9000/api/bot/status | ConvertFrom-Json
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     XM Global MT5                            │
│          (Receives trades from backend)                      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ Real trades executed
                     │
┌────────────────────▼────────────────────────────────────────┐
│            INTELLIGENT BACKEND                              │
│            (Port 9000 - Multi-Broker)                        │
│                                                               │
│  ✓ Strategy Switching                                       │
│  ✓ Position Scaling                                         │
│  ✓ Market Data (24 commodities)                            │
│  ✓ Bot Management                                           │
│  ✓ Trade Tracking                                           │
└────────────┬──────────────────────────────┬─────────────────┘
             │                              │
        ┌────▼───────┐              ┌──────▼────────┐
        │ WEB CLIENT │              │ MOBILE CLIENT │
        │ Port 3001  │              │  Android/iOS  │
        │ Chrome     │              │  Emulator     │
        └────────────┘              └───────────────┘
```

---

## Test Phase 1: Backend Validation

### Test 1.1: Backend Health Check

```powershell
# Check if backend is responding
curl http://localhost:9000/api/bot/status

# Expected output (JSON):
# {
#   "active_bots": [],
#   "total_profit": 0,
#   "market_status": "ready"
# }
```

✅ **Pass**: Returns JSON data  
❌ **Fail**: Connection refused → Backend not running

### Test 1.2: Create Test Bot via API

```powershell
# Create a bot using API
$headers = @{ 'Content-Type' = 'application/json' }
$body = @{
    strategy = 'Trend Following'
    initial_balance = 1000
    risk_per_trade = 0.01
    daily_loss_limit = 50
    symbols = @('EURUSD', 'GOLD', 'OIL')
} | ConvertTo-Json

curl -Method POST `
  -Headers $headers `
  -Body $body `
  http://localhost:9000/api/bot/create

# Expected: Returns bot ID like "BOT-1709873400"
```

✅ **Pass**: Bot ID returned, can be used for testing  
❌ **Fail**: Error message or empty response

### Test 1.3: Check Market Data (24 Commodities)

```powershell
curl http://localhost:9000/api/market/commodities

# Expected output includes 24 symbols:
# {
#   "commodities": [
#     {
#       "symbol": "EURUSD",
#       "signal": "🟢",
#       "trend": "UP",
#       "change": "+0.45%",
#       ...
#     }
#   ]
# }
```

✅ **Pass**: All 24 symbols with signals  
❌ **Fail**: Empty list or missing signals

---

## Test Phase 2: Web Platform Validation

### Test 2.1: Dashboard Loading

1. Open http://localhost:3001 in Chrome
2. Verify sections load:
   - Portfolio Summary (Total Profit, Equity, Drawdown)
   - Active Bots List (should be empty initially)
   - Market Summary Cards
   - Create Bot Button

✅ **Pass**: All sections visible, no errors  
❌ **Fail**: Blank screen or connection errors

### Test 2.2: Create Bot from Web

1. Click "Create Bot" button
2. Fill in: Strategy = "Scalping", Risk = 0.01, Daily Loss = 50
3. Select 3 commodities (prefer ones with 🟢 signals)
4. Click Create

**Expected**: 
- Success message appears
- Auto-navigates to Dashboard
- New bot appears in Active Bots list

✅ **Pass**: Bot created and visible  
❌ **Fail**: Error message or doesn't appear

### Test 2.3: Real-time Update Sync

1. Create bot from web
2. Wait 30 seconds for trading to occur
3. Observe profit changing every ~5 seconds
4. Watch for position size updates
5. Monitor for strategy switching notification

✅ **Pass**: Numbers changing, responsive UI  
❌ **Fail**: Frozen display or no updates

### Test 2.4: Chart Rendering

1. Click any bot's "View Analytics" button
2. Verify 3 charts display:
   - Profit over time (line chart)
   - Trade count growth (bar chart)
   - Profit distribution (pie chart)
3. Colors should be visible and readable

✅ **Pass**: All charts load with data  
❌ **Fail**: Blank charts or rendering errors

---

## Test Phase 3: Intelligent Features Testing

### Test 3.1: Strategy Intelligent Switching

**Setup**: Create bot and let it trade for 2-3 minutes

**What to Watch**:
- Initial strategy performance (win rate %)
- Auto-evaluation after ~10 trades
- If another strategy performs better:
  - Backend switches automatically
  - Web/mobile both show new strategy
  - Trading continues without interruption

**Check Backend Log** for confirmation:
```
Strategy switching: Scalping (65%) -> Trend Following (78%)
Improvement: +13% win rate
```

✅ **Pass**: Strategy changes, performance improves  
❌ **Fail**: No switching or same strategy every time

### Test 3.2: Dynamic Position Scaling

**Setup**: Let bot trade multiple rounds (5+ minutes)

**Expected Pattern**:
```
Starting Position: 0.10
After 5 wins:     0.11 (scaled up)
After 3 losses:   0.10 (scaled down)
After streak:     Position adjusts based on momentum
```

**Verification**:
1. Check bot details on web/mobile
2. Compare position sizes over time
3. Verify position stays within limits (0.01 - 0.50)

✅ **Pass**: Position changes match trade outcomes  
❌ **Fail**: Static position, no scaling

### Test 3.3: Market Sentimen Integration

**Check**: When bot switches strategies

1. View new strategy's recommended commodities
2. Compare against market signals (🟢🟡🔴)
3. Verify bot focuses on high-signal commodities

✅ **Pass**: Strategy aligns with best-signal commodities  
❌ **Fail**: Ignores market signals

---

## Test Phase 4: Mobile Platform Testing

### Prerequisites

```powershell
# 1. Check Android setup
flutter doctor -v

# 2. Start Android emulator (choose one):
# Option A: Command line
emulator -avd Pixel_6_API_33

# Option B: Android Studio
# Tools > Device Manager > Launch Pixel_6

# 3. Wait 15 seconds for emulator to boot
```

### Test 4.1: Mobile App Launch

```powershell
cd "c:\zwesta-trader\Zwesta Flutter App"
flutter run
```

**Expected**:
- App builds (first time ~3 min, later ~30 sec)
- Emulator shows app interface
- Dashboard loads within 2 seconds

✅ **Pass**: App running, dashboard visible  
❌ **Fail**: Build error or blank screen

### Test 4.2: Mobile Dashboard Sync

1. On web: Create a new bot
2. On mobile: Wait 5 seconds, open Dashboard
3. New bot should appear in Active Bots list

✅ **Pass**: Bot synced to mobile in <5 sec  
❌ **Fail**: Mobile doesn't show new bot

### Test 4.3: Create Bot from Mobile

1. Tap "Create Bot" on mobile dashboard
2. Fill configuration (same as web)
3. Tap Create

✅ **Pass**: Bot created on mobile  
❌ **Fail**: Error or doesn't appear on web

---

## Test Phase 5: Cross-Platform Testing

### Test 5.1: Web ↔ Mobile Sync

| Action | Performed On | Expected on Other |
|--------|--------------|-------------------|
| Create Bot | Web | Appears on Mobile (5 sec) |
| Start Trading | Mobile | Shows active on Web (1 sec) |
| Stop Bot | Web | Updates on Mobile (1 sec) |
| Switch Strategy | Mobile | Changes visible on Web (1 sec) |
| Adjust Risk | Web | Reflected on Mobile (5 sec) |

### Test 5.2: Data Consistency

```
On Web Dashboard:
- Bot ID: BOT-12345
- Strategy: Trend Following
- Daily P&L: +$150.25
- Trades: 8

On Mobile Dashboard (should match exactly):
- Bot ID: BOT-12345
- Strategy: Trend Following
- Daily P&L: +$150.25
- Trades: 8
```

✅ **Pass**: All numbers match between platforms  
❌ **Fail**: Discrepancies or different data

---

## Performance Benchmarks

Expected performance metrics:

| Metric | Target | Actual |
|--------|--------|--------|
| Backend startup | < 5 sec | ___ sec |
| Web load | < 3 sec | ___ sec |
| Mobile load | < 3 sec | ___ sec |
| Bot creation | < 2 sec | ___ sec |
| Real-time update delay | < 5 sec | ___ sec |
| Strategy switch time | < 1 sec | ___ sec |
| Cross-platform sync | < 2 sec | ___ sec |

---

## Error Handling Tests

### Test 6.1: Backend Connection Loss

1. Stop backend (Ctrl+C)
2. Try to load web/mobile dashboard
3. Should show "Connection Error - Retry Button"
4. Restart backend
5. Click Retry
6. Should recover

✅ **Pass**: Graceful error handling, recovery works  
❌ **Fail**: App crashes or freezes

### Test 6.2: Invalid Configuration

1. Manually set wrong backend IP in code
2. App should show helpful error message
3. Allow user to retry or reconfigure

✅ **Pass**: Clear error message  
❌ **Fail**: Cryptic error or no message

---

## XM Global Live Trading Setup

Ready to move from testing to live trading?

### Prerequisites

1. **XM Global Account**: [Open Account](https://www.xmglobal.com)
   - Minimum deposit: $5 (or as per XM terms)
   - Preferred: Demo account first to test

2. **MT5 Platform**: [Download](https://www.xmglobal.com/trading/tools/metatrader5)
   - Login with XM credentials
   - Verify connection

3. **Update Backend Configuration**

Edit [multi_broker_backend_updated.py](multi_broker_backend_updated.py), find XM Global config:

```python
# Lines ~200-210
BROKER_CONFIGS = {
    'xm_global': {
        'server': 'XMGlobal-Demo',  # Change to 'XMGlobal-Real' for live
        'account': 'YOUR_ACCOUNT_NUMBER',
        'password': 'YOUR_PASSWORD',
        'broker': 'MetaQuotes',
    }
}
```

4. **Test with Small Amount First**
   - Start with demo account ($50,000 virtual)
   - Run bot for 24 hours
   - Verify profit generation
   - Check position scaling works

5. **Go Live**
   - Switch config to real account
   - Start with small position (0.01 lot)
   - Monitor every 2 hours
   - Increase position size after 20 profitable trades

---

## Monitoring Checklist

### Daily Monitoring (While Trading Live)

```
Morning Check:
[ ] Backend running with no errors
[ ] Dashboard loads within 2 seconds
[ ] Active bots show realistic equity balance
[ ] No unusual drawdown (should stay < 5%)

Check Every 4 Hours:
[ ] Profit trajectory is positive
[ ] Win rate improving (or strategy switched)
[ ] No error messages
[ ] Position sizes adjusting correctly

Daily Summary:
[ ] Total profit recorded
[ ] Strategy performance tracked
[ ] No API errors or timeouts
[ ] All 3 bots (if running) performing
```

---

## Troubleshooting Reference

| Problem | Solution |
|---------|----------|
| Backend won't start | Check Python 3.9+, install requirements.txt |
| Web doesn't load | Check port 3001 available, run `flutter run` again |
| Mobile won't connect | Verify IP in app_config.dart, check firewall |
| Bots disappear | Restart backend, check database connection |
| No real-time updates | Check network latency, reload dashboard |
| Position scaling wrong | Review position_scaling.py logic, check trade history |

See full troubleshooting: [VPS_TROUBLESHOOTING.md](VPS_TROUBLESHOOTING.md)

---

## Success Metrics

Your system is ready for live trading when:

✅ Web dashboard loads in < 3 sec  
✅ Mobile app syncs within 5 sec  
✅ Bot creates successfully 100% of time  
✅ Strategy switching occurs (checked in logs)  
✅ Position scaling matches trade outcomes  
✅ No connection errors over 1 hour test run  
✅ Profit tracking accurate vs MT5  
✅ All 24 commodities available in selector  
✅ Dashboard handles multiple bots (3+)  
✅ Real-time updates never lag > 5 sec  

---

## Next Steps

1. ✅ **Complete Testing** - Run through all 6 phases above
2. ✅ **Get XM Global Account** - Sign up if not already done
3. ✅ **Configure Live Credentials** - Update backend config
4. ✅ **Demo Trading** - Trade with virtual money 24 hours
5. ✅ **Go Live** - Start with $100-500 real money
6. 🔜 **Scale Up** - Increase position sizes after 100 trades
7. 🔜 **Add Mobile Features** - Push notifications, biometric auth
8. 🔜 **App Store Release** - Submit to Google Play

---

## Support & Debugging

**Quick Commands**:
```powershell
# Check backend health
curl http://localhost:9000/api/bot/status

# View backend logs (terminal where python is running)
# Scroll up to see strategy switching messages

# Check app logs
flutter logs

# Restart everything
taskkill /F /IM python.exe
taskkill /F /IM dart.exe
taskkill /F /IM chrome.exe
START_DEVELOPMENT.bat
```

**Files Reference**:
- Backend: [multi_broker_backend_updated.py](multi_broker_backend_updated.py)
- Web UI: [lib/screens/dashboard_screen.dart](lib/screens/dashboard_screen.dart)
- Mobile Setup: [MOBILE_APP_SETUP.md](MOBILE_APP_SETUP.md)
- Config: [lib/config/app_config.dart](lib/config/app_config.dart)

---

## Timeline Expectation

| Task | Duration | Status |
|------|----------|--------|
| Test Phase 1-5 | 1-2 hours | ⏳ Pending |
| Setup XM Global | 15 minutes | ⏳ Todo |
| Demo trading test | 24 hours | ⏳ Todo |
| Go live | Immediate | ⏳ Todo |
| Monitor first week | 1 hour/day | ⏳ Todo |
| Scale operations | Week 2+ | ⏳ Future |

---

**Good luck with your testing! Let me know results from each phase.** 🚀
