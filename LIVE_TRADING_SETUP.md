# Zwesta Trading System - Live Trading Setup Guide

## Overview

The Zwesta Trading System is now configured to execute **live trades** on MetaTrader 5. This guide walks you through setup and deployment.

## Architecture

```
MetaTrader 5 (Broker)
        ↓
Python Backend (trading_backend.py) - Flask API on port 8080
        ↓
Flutter Web App (localhost:8891)
```

## Prerequisites

1. **MetaTrader 5 Installation**
   - Download: https://www.metatrader5.com/en/download
   - Ensure MT5 is installed at: `C:\Program Files\MetaTrader 5`

2. **Python 3.8 or higher**
   - Download: https://www.python.org/downloads/
   - Add to PATH during installation

3. **Broker Account** (demo or live)
   - Demo accounts are free and perfect for testing
   - Get demo: Signup in MT5 app

## Installation & Setup

### Step 1: Install Backend Dependencies

```bash
cd "c:\zwesta-trader\Zwesta Flutter App"
pip install -r trading_backend_requirements.txt
```

This installs:
- Flask (web server)
- MetaTrader5 (MT5 connection library)
- Flask-CORS (allows Flutter app to connect)

### Step 2: Configure MT5 Credentials

Edit `trading_backend.py` and update these lines:

```python
DEMO_ACCOUNT = 136372035      # Your MT5 account number
DEMO_PASSWORD = "demo1234"     # Your MT5 password
DEMO_SERVER = "MetaQuotes-Demo"  # Your broker server
```

To find your credentials:
1. Open MetaTrader 5
2. Login with your account
3. Right-click on account → Properties
4. Copy Account Number and Server name

### Step 3: Start the Trading Backend

```bash
cd "c:\zwesta-trader\Zwesta Flutter App"
python trading_backend.py
```

Expected output:
```
Starting Zwesta Trading Backend
MT5 Path: C:\Program Files\MetaTrader 5
MT5 initialized on startup
 * Running on http://127.0.0.1:8080
```

### Step 4: Update Flutter Configuration

Open `lib/utils/environment_config.dart` and set:

```dart
static const bool _prodOfflineMode = false;  // Enable API
```

Or use environment variable:
```bash
OFFLINE_MODE=false
```

### Step 5: Build and Deploy Flutter App

```bash
cd "c:\zwesta-trader\Zwesta Flutter App"
flutter build web --release
python serve.py
```

Access at: **http://localhost:8891**

## API Endpoints Reference

### Account Management

**Connect to MT5 Account**
```
POST /api/account/connect
{
  "account": 136372035,
  "password": "demo1234",
  "server": "MetaQuotes-Demo"
}
```

**Get Account Info**
```
GET /api/account/info
Returns: balance, equity, margin, leverage, etc.
```

### Trading Operations

**Place Trade**
```
POST /api/trade/place
{
  "symbol": "EURUSD",
  "type": "BUY",
  "volume": 0.1,
  "stopLoss": 1.0850,
  "takeProfit": 1.1050
}
```

**Close Trade**
```
POST /api/trade/close
{
  "ticket": 12345678
}
```

**Get Open Positions**
```
GET /api/positions
Returns: array of active trades with profit/loss
```

**Get Trade History**
```
GET /api/trades
Returns: last 20 closed trades
```

### Bot Management

**Get Bot Status**
```
GET /api/bot/status
Returns: running status, balance, equity, active positions
```

## Using Live Trading in Flutter App

### 1. Connect Account Screen

In your app:
1. Go to **Broker Integration** (drawer menu)
2. Enter MT5 Account Number
3. Enter Password
4. Select Server: "MetaQuotes-Demo" (or your broker's server)
5. Click "Connect to Broker"

The app will:
- Connect to MT5 via backend
- Sync account balance and positions
- Load trading history
- Start live data updates

### 2. Place Live Trades

On **Dashboard** or **Trades Screen**:
1. Click "Open Trade"
2. Select Symbol (EURUSD, GBPUSD, etc.)
3. Choose BUY or SELL
4. Set Volume (e.g., 0.1 lot)
5. Set Stop Loss and Take Profit (optional)
6. Click "Open Trade"

**The order is sent directly to MetaTrader 5 and executed on the broker's market!**

### 3. Close Live Trades

1. View open positions
2. Click on a position
3. Click "Close Trade"
4. Confirm close price

**Your position will be instantly closed on the broker's server.**

## Monitoring & Logs

### Backend Logs
```
trading_backend.log  - All API requests and trade executions
```

### Console Output
```
Python console shows:
- MT5 connection status
- Each trade placed/closed
- API errors
```

### Browser Console
Press F12 in browser to see:
- API requests to /api endpoints
- Network errors
- Trade confirmations

## Troubleshooting

### "Cannot connect to MT5"
- Ensure MetaTrader 5 is open
- Check MT5 is installed at `C:\Program Files\MetaTrader 5`
- Verify account credentials in backend

### "API not responding"
```bash
# Check if backend is running
netstat -ano | findstr :8080
```
- Restart backend: `python trading_backend.py`
- Check firewall isn't blocking port 8080

### "Trade failed: Not enough margin"
- Account balance too low for selected volume
- Reduce volume or add funds to account

### "Symbol not found"
- Ensure symbol is tradeable on your broker
- Try: EURUSD, GBPUSD, USDJPY, AUDUSD
- Some brokers have different symbol names

## Security Notes

⚠️ **Important for Production:**

1. **Never share your password** in config files
2. **Use environment variables** for credentials:
   ```bash
   set MT5_ACCOUNT=136372035
   set MT5_PASSWORD=your_password
   set MT5_SERVER=MetaQuotes-Demo
   python trading_backend.py
   ```

3. **Change default API key** in `trading_backend.py`:
   ```python
   API_KEY = "change_this_to_secure_key"
   ```

4. **Use HTTPS** when deploying to VPS:
   - Install SSL certificate
   - Use `https://your-domain.com`

5. **Enable auth** in production:
   ```python
   # Add to all API endpoints
   if request.headers.get('Authorization') != f'Bearer {API_KEY}':
       return {'error': 'Unauthorized'}, 401
   ```

## Performance Tips

1. **Reduce refresh rate** to save bandwidth:
   - Edit `dashboard_screen.dart`
   - Change refresh interval to 5-10 seconds

2. **Use demo account first** to test
3. **Start with small volumes** (0.01 lot)
4. **Monitor backend logs** for errors

## Deployment to VPS (38.247.146.198)

### 1. SSH into VPS
```bash
ssh user@38.247.146.198
```

### 2. Install Python & Dependencies
```bash
sudo apt update
sudo apt install python3 python3-pip
cd /var/www/zwesta
pip3 install -r trading_backend_requirements.txt
```

### 3. Install MetaTrader5 Alternative (Linux)
For Linux VPS, use Wine to run MT5:
```bash
sudo apt install wine wine32
wine /path/to/metatrader5.exe
```

Or use a dedicated MT5 bridge service (recommended).

### 4. Run Backend
```bash
python3 trading_backend.py
# Or use supervisor for auto-restart
sudo systemctl start trading-backend
```

### 5. Deploy Flutter Web
```bash
flutter build web --release
sudo cp -r build/web/* /var/www/html/zwesta/
```

### 6. Configure Nginx
```nginx
server {
    listen 80;
    server_name 38.247.146.198;

    location / {
        root /var/www/html/zwesta;
        try_files $uri /index.html;
    }

    location /api {
        proxy_pass http://127.0.0.1:8080;
    }
}
```

## Next Steps

1. ✅ Install backend dependencies
2. ✅ Configure MT5 credentials
3. ✅ Start backend server
4. ✅ Build Flutter app
5. ✅ Connect to trading account
6. ✅ Place first live trade
7. ✅ Monitor positions in real-time
8. ✅ Deploy to VPS when ready

## Support

For issues:
1. Check `trading_backend.log`
2. Verify backend is running: `curl http://localhost:8080/api/health`
3. Check MT5 is connected in app console
4. Review error messages in Flutter app

---

**System Ready for Live Trading! 🚀**
