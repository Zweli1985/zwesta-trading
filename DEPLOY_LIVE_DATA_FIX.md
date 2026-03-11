# 🚀 Live Data Feed Fix - Quick Deploy Guide

## VPS Deployment (Run These Commands)

### 1. Pull Latest Code from GitHub
```bash
cd C:\zwesta-trader\Zwesta Flutter App
git pull origin main
```

### 2. Run Database Migration (CRITICAL - Must be done first!)
```bash
cd C:\backend
python "C:\zwesta-trader\Zwesta Flutter App\migrate_db.py"
```

**Wait for this output before proceeding:**
```
✅ Migration complete! Added 1 columns to user_bots table
```

### 3. Stop Current Backend (if running)
```bash
taskkill /IM python.exe /F
```

### 4. Start the Fixed Backend
```bash
cd C:\backend
python "C:\zwesta-trader\Zwesta Flutter App\multi_broker_backend_updated.py"
```

**Watch for these success messages in the logs:**
```
✅ Live market data updater thread started
✅ Connected to MT5 account 104254514
Running on http://0.0.0.0:9000
```

---

## What Was Fixed ✅

| Issue | Status | Solution |
|-------|--------|----------|
| Bot creation fails with "no column named symbols" | ❌→✅ | Database migration adds symbols column |
| No live price feed - showing static data | ❌→✅ | Live MT5 price updater thread (every 3 sec) |
| Can't see commodity performance in app | ❌→✅ | API returns real MT5 prices + signals |
| Robot can't trade with live data | ❌→✅ | Real-time data from MetaTerminal 5 |

---

## Verify the Fix Works ✅

### Check 1: Create a bot (should NOT error anymore)
```bash
# In Flutter app or API test:
PUT /api/bot/create
{
  "name": "Live Test Bot",
  "strategy": "Trend Following", 
  "symbols": ["EURUSD", "XPTUSD", "OILK"],
  "enabled": true,
  "brokerId": "YOUR_BROKER_ID"
}
```
✅ **Expected: Success response, no database error**

### Check 2: Get live prices
```bash
# In browser or curl:
GET http://127.0.0.1:9000/api/market/commodities
```
✅ **Expected: Real MT5 prices, changes every 3 seconds, signals like 🟢 BUY / 🔴 SELL**

### Check 3: Watch the logs
```bash
# In the running terminal with backend, you should see:
✅ Updated 19 live prices from MT5
✅ Updated 19 live prices from MT5
✅ Updated 19 live prices from MT5
# ...repeats every 3 seconds
```

---

## Files Changed

### 1. `multi_broker_backend_updated.py` 
- Added `live_market_data_updater()` background thread
- Fetches real prices from MT5 using `symbol_info_tick()`
- Updates `/api/market/commodities` with live data
- Thread-safe with locks for concurrent access

### 2. `migrate_db.py`
- Added migration to add `symbols` column to `user_bots` table
- Fixes "table user_bots has no column named symbols" error
- Backward compatible with existing databases

### 3. `LIVE_DATA_FEED_FIX.md` (Documentation)
- Complete fix explanation and testing procedures

---

## Troubleshooting

### Problem: Still getting database error
**Solution:** 
```bash
python migrate_db.py
# Then delete old database (backup first!)
del zwesta_trading.db
# Restart backend - will recreate with new schema
```

### Problem: Prices not updating
**Solution:**
1. Make sure MT5 terminal is running
2. Check for `✅ Live market data updater thread started` in logs
3. Verify MT5 is connected: `✅ Connected to MT5 account` in logs

### Problem: "Running on http://0.0.0.0:9000" shows but prices still static
**Solution:**
1. Go to `http://38.247.146.198:9000/api/market/commodities` (your VPS URL)
2. Refresh the page - should see different prices
3. Prices should continue changing as you refresh

---

## Expected Behavior After Fix ✅

Your trading robot will now:
- ✅ **Create bots successfully** without database errors
- ✅ **See live commodity/forex prices** updated every 3 seconds
- ✅ **Get real trading signals** based on actual MT5 data (🟢 BUY, 🔴 SELL, 🟡 HOLD)
- ✅ **Trade with current market prices** not outdated hardcoded values
- ✅ **Monitor real-time performance** as trades open and close

---

## Need More Details?

Read the full documentation: `/LIVE_DATA_FEED_FIX.md`
