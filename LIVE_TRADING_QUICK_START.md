# Zwesta Trading System - Live Trading Quick Start

## 🎯 What You Now Have

Your system is **ready to execute live trades** on MetaTrader 5!

- ✅ **Flutter Web App** running at `http://localhost:8891`
- ✅ **Python Trading Backend** ready to deploy
- ✅ **MetaTrader 5 Integration** for real trade execution
- ✅ **Automatic Account Syncing** for live data

## 🚀 Getting Started in 5 Minutes

### Step 1: Install Python Backend Dependencies

```bash
cd "c:\zwesta-trader\Zwesta Flutter App"
pip install -r trading_backend_requirements.txt
```

This installs:
- **Flask** - Web API server
- **MetaTrader5** - MT5 connection library
- **Flask-CORS** - Cross-origin requests

### Step 2: Get Your MT5 Account Details

1. Open **MetaTrader 5** application
2. Login with your account
3. Note your:
   - **Account Number** (e.g., 136372035)
   - **Password** (your trading password)
   - **Server** (e.g., MetaQuotes-Demo)

Right-click account → Properties to find details.

### Step 3: Configure Backend

Open `trading_backend.py` and update lines 32-34:

```python
DEMO_ACCOUNT = YOUR_ACCOUNT_NUMBER      # e.g., 136372035
DEMO_PASSWORD = "YOUR_PASSWORD"         # Your trading password
DEMO_SERVER = "YOUR_SERVER_NAME"        # e.g., MetaQuotes-Demo
```

### Step 4: Start Trading Backend

```bash
python trading_backend.py
```

Expected output:
```
Starting Zwesta Trading Backend
MT5 Path: C:\Program Files\MetaTrader 5
MT5 initialized on startup
 * Running on http://127.0.0.1:8080
```

### Step 5: Access the Web App

Visit: **http://localhost:8891**

Your app now:
- ✅ Connects to the trading backend
- ✅ Syncs live account data
- ✅ Shows real positions
- ✅ Executes actual trades

## 📊 Using Live Trading Features

### Connect Your Trading Account

1. In the Flutter app, go to **Drawer Menu** → **Broker Integration**
2. Enter your MT5 account details
3. Click **"Connect to Broker"**
4. Your account balance and positions will load!

### Place a Live Trade

1. Go to **Dashboard** → Click **"Open Trade"**
2. Select:
   - **Symbol**: EURUSD, GBPUSD, etc.
   - **Type**: BUY or SELL
   - **Volume**: 0.01 (start small!)
   - **S/L & T/P**: Optional but recommended
3. Click **"Open Trade"**

✅ **Trade is sent to MetaTrader 5 and executed immediately!**

### View Positions

- **Dashboard**: Shows summary of open trades
- **Trades Screen**: Lists all positions with profit/loss
- **Broker Integration**: Syncs data in real-time

### Close Trades

1. Click on an open position
2. Click **"Close Trade"**
3. Position closes on broker's server immediately

## ⚙️ System Architecture

```
Your Computer
  ├─ MetaTrader 5 (Broker Connection)
  │   └─ Real market data & execution
  │
  ├─ Python Backend (Port 8080)
  │   └─ trading_backend.py
  │   └─ Connects to MT5
  │   └─ Provides REST API
  │
  └─ Flutter Web App (Port 8891)
      └─ User Interface
      └─ Sends trade requests to backend
      └─ Displays live account data
```

## 🔑 API Endpoints (Developers)

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/health` | GET | Check if backend is running |
| `/api/account/connect` | POST | Connect to MT5 account |
| `/api/account/info` | GET | Get account balance, equity, etc. |
| `/api/trade/place` | POST | Execute BUY/SELL order |
| `/api/trade/close` | POST | Close an open position |
| `/api/positions` | GET | Get all open trades |
| `/api/trades` | GET | Get trading history |
| `/api/bot/status` | GET | Get bot trading status |

## 📋 Configuration Files

**`trading_backend.py`** - Main trading server
  - Configure MT5 credentials
  - Adjust timeouts and retries
  - Custom trading logic

**`lib/utils/environment_config.dart`** - Flutter config
  - API URL: `http://127.0.0.1:8080`
  - Environment: development/staging/production
  - Offline mode toggle

**`serve.py`** - Web server
  - Serves Flutter app on port 8891
  - Handles routing for Flutter

##⚠️ Important Notes

1. **Start with Demo Account**
   - Test all features with demo money first
   - No real risk
   - Perfect for learning

2. **Start Small**
   - Use 0.01 lot size initially
   - Monitor carefully
   - Increase gradually

3. **Always Use Stop Loss**
   - Protect against sudden price moves
   - Risk management is critical

4. **Keep Backend Running**
   - Backend must be active to execute trades
   - Check `trading_backend.log` for errors
   - Restart if connection drops

5. **Network Connection**
   - Ensure internet is stable
   - Move to VPS for 24/7 trading

## 🐛 Troubleshooting

**"Cannot connect to MT5"**
```bash
# Check if MT5 is installed
ls "C:\Program Files\MetaTrader 5"

# Check account details
# Open MT5 → Right-click account → Properties
```

**"API not responding"**
```bash
# Check if backend is running
netstat -ano | findstr :8080

# Restart backend
python trading_backend.py
```

**"Trade failed: Not enough margin"**
- Reduce volume (e.g., 0.01 instead of 1.0)
- Add funds to account
- Reduce leverage requirement

**"Backend logs show errors"**
```
cat trading_backend.log  # View error details
```

## 📈 Next Steps

1. ✅ Install backend dependencies
2. ✅ Configure MT5 credentials
3. ✅ Start backend server
4. ✅ Test with demo account
5. ✅ Place your first live trade
6. ✅ Monitor positions in app
7. ⏳ Deploy to VPS for 24/7 trading (optional)
8. ⏳ Implement automated trading bots (advanced)

## 📞 Support

For issues, check:
- `trading_backend.log` - Backend errors
- Browser console (F12) - Frontend errors
- Terminal output - Connection status

## 🎓 Learning Resources

- **MetaTrader 5**: https://www.metatrader5.com/
- **MQL5 Documentation**: https://www.mql5.com/en/docs
- **Trading Risks**: https://www.investopedia.com/
- **Flask Documentation**: https://flask.palletsprojects.com/

---

## Summary

You now have a **complete live trading system** that:

✅ Connects to real MetaTrader 5 brokers
✅ Executes actual buy/sell orders
✅ Syncs account data in real-time
✅ Provides a beautiful web interface
✅ Runs on your local computer or VPS
✅ Can be extended with bot trading

**Your trading system is ready. Start trading now!** 🚀
