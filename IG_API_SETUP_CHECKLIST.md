# IG.com API - Quick Setup Checklist ✅

## Step 1: Backend Configuration ✅
- [x] Added IG_CONFIG to backend configuration
- [x] Integrated IGConnection with broker_manager
- [x] Created auto_connect_ig() function
- [x] Added IG API endpoints
- [x] Updated .env.example with IG credentials

## Step 2: Verify IG.com Credentials
- [x] API Key: **9bbc3ef9ad291acec96dc409d80e50c4c805161a**
- [x] Account Status: **Enabled**
- [ ] IG Username: Add to environment variables
- [ ] IG Password: Add to environment variables
- [ ] Platform: https://www.ig.com/en-ch/myig/settings/api-keys

## Step 3: Set Environment Variables (Optional but Recommended)
Create or update your `.env` file:
```bash
# Windows Command Prompt
set IG_API_KEY=9bbc3ef9ad291acec96dc409d80e50c4c805161a
set IG_USERNAME=your_username
set IG_PASSWORD=your_password
set TRADING_ENV=DEMO

# PowerShell
$env:IG_API_KEY = "9bbc3ef9ad291acec96dc409d80e50c4c805161a"
$env:IG_USERNAME = "your_username"
$env:IG_PASSWORD = "your_password"
$env:TRADING_ENV = "DEMO"
```

## Step 4: Test Backend Startup
```bash
# Run backend
cd "c:\zwesta-trader\Zwesta Flutter App"
python multi_broker_backend_updated.py
```

Expected output:
```
✅ Initializing with IG.com account
🔗 Attempting auto-connect to IG.com...
✅ Auto-connected to IG.com successfully using API key: 9bbc3ef9ad291acec96dc409d80e50c4c805161a
```

## Step 5: Test API Endpoints
### Test 1: Health Check
```bash
curl http://localhost:9000/api/health
```

### Test 2: Connect to IG.com
```bash
curl -X POST http://localhost:9000/api/ig/connect \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"YOUR_USERNAME\",\"password\":\"YOUR_PASSWORD\"}"
```

### Test 3: Get Account Info
```bash
curl http://localhost:9000/api/ig/account-info \
  -H "Content-Type: application/json"
```

## Step 6: Integrate with Flutter App

### Option A: Using the IGTradingService Class
Copy the service class from `IG_INTEGRATION_SETUP.md` to your Flutter project:
```dart
// lib/services/ig_trading_service.dart
```

### Option B: Direct HTTP Calls
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

// Connect to IG
var response = await http.post(
  Uri.parse('http://localhost:9000/api/ig/connect'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'api_key': '9bbc3ef9ad291acec96dc409d80e50c4c805161a',
    'username': 'your_username',
    'password': 'your_password',
  }),
);
```

## Step 7: Available Trading Features

### ✅ Implemented Endpoints:
1. **POST /api/ig/connect** - Connect to IG.com
2. **GET /api/ig/account-info** - Get account balance and info
3. **GET /api/ig/positions** - Get open positions
4. **GET /api/ig/trades** - Get open trades
5. **POST /api/ig/place-order** - Place new order
6. **POST /api/ig/close-position** - Close a position

### 📋 Coming Soon:
- [ ] Get market prices/quotes
- [ ] Set stop loss/take profit
- [ ] Historical prices
- [ ] Account statements
- [ ] Deposit/Withdrawal automation

## Step 8: Trading Workflow

### Demo Trading Flow:
```
Flutter App
    ↓
Backend (/api/ig/*)
    ↓
IG.com REST API
    ↓
IG Markets (Demo)
    ↓
Your Account (No Real Money)
```

### Live Trading Flow:
Set `TRADING_ENV=LIVE` and use live credentials:
```
Flutter App
    ↓
Backend (/api/ig/*)
    ↓
IG.com REST API
    ↓
IG Markets (LIVE)
    ↓
Your Account (Real Money) ⚠️
```

## Important Notes ⚠️

### Security:
- 🔐 Never commit API keys to Git
- 🔐 Use environment variables for credentials
- 🔐 Keep IG username/password secure
- 🔐 Use HTTPS in production

### Demo vs Live:
- 🎮 DEMO: Test without real money risk
- 💵 LIVE: Real trading, real money at risk

### Required Credentials:
- ✅ API Key: Already configured (9bbc3ef9ad291acec96dc409d80e50c4c805161a)
- ⚠️ Username: Needed for connection
- ⚠️ Password: Needed for connection
- ℹ️ Account ID: Optional (auto-detected)

## Troubleshooting

### Issue: "IG.com not connected" Error
**Solution:**
1. Check if backend is running
2. Verify username and password
3. Check internet connection
4. Restart backend with `TRADING_ENV=DEMO`

### Issue: Connection Timeout
**Solution:**
1. Check firewall settings
2. Ensure port 9000 is available
3. Try ports 5000 or 3000 as fallback

### Issue: Authentication Failed
**Solution:**
1. Verify API key: 9bbc3ef9ad291acec96dc409d80e50c4c805161a
2. Check IG account status at https://www.ig.com/en-ch/myig/settings/api-keys
3. Verify username/password are correct

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                       Flutter App                        │
│  - UI Components                                         │
│  - IGTradingService                                      │
│  - HTTP Clients                                          │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTP REST API
                       ↓
┌─────────────────────────────────────────────────────────┐
│          Zwesta Backend (multi_broker.py)                │
│  - Flask Server (Port 9000)                              │
│  - BrokerManager                                         │
│  - IG API Endpoints (/api/ig/*)                          │
│  - SQLite Database                                       │
└──────────────────────┬──────────────────────────────────┘
                       │ REST API (HTTPS)
                       ↓
┌─────────────────────────────────────────────────────────┐
│         IG.com REST API Gateway                          │
│  - Base URL: https://api.ig.com/gateway/deal            │
│  - Authentication: X-IG-API-KEY header                  │
│  - Credentials: Username, Password                       │
└──────────────────────┬──────────────────────────────────┘
                       │ Real-time Data
                       ↓
┌─────────────────────────────────────────────────────────┐
│         IG.com Markets Trading Platform                  │
│  - Live/Demo Accounts                                    │
│  - Real-time Prices                                      │
│  - Order Execution                                       │
└─────────────────────────────────────────────────────────┘
```

## Files Modified

### 1. multi_broker_backend_updated.py
```python
# Added:
- IG_CONFIG section with API key
- IGConnection initialization
- auto_connect_ig() function
- 6 new IG API endpoints
- Startup integration
```

### 2. .env.example
```bash
# Added:
- IG_API_KEY configuration
- IG_USERNAME field
- IG_PASSWORD field
- IG_ACCOUNT_ID field
- IG_DEMO_MODE option
```

### 3. IG_INTEGRATION_SETUP.md
```markdown
# Complete API documentation
# Flutter integration examples
# Troubleshooting guide
```

## Next Steps ✅

1. [ ] Set up environment variables (IG_USERNAME, IG_PASSWORD)
2. [ ] Run backend and verify IG connection
3. [ ] Test API endpoints with curl/Postman
4. [ ] Create IGTradingService in Flutter app
5. [ ] Test connecting from Flutter app
6. [ ] Test placing orders in demo mode
7. [ ] Switch to live trading when ready

## Support Resources

- **IG.com API Documentation**: https://labs.ig.com/
- **IG API Reference**: https://www.ig.com/en/api/
- **Backend Logs**: `multi_broker_backend.log`
- **Configuration**: See `IG_INTEGRATION_SETUP.md`

## Testing Commands

### Windows PowerShell
```powershell
# Test backend
Invoke-WebRequest http://localhost:9000/api/health -Method Get

# Test IG connection
$body = @{username="test"; password="test"} | ConvertTo-Json
Invoke-WebRequest http://localhost:9000/api/ig/connect -Method Post -Body $body -ContentType "application/json"
```

### Windows CMD
```cmd
# Test backend
curl http://localhost:9000/api/health

# Test IG connection  
curl -X POST http://localhost:9000/api/ig/connect -H "Content-Type: application/json" -d "{\"username\":\"test\",\"password\":\"test\"}"
```

---

**Setup Status**: ✅ Complete
**Backend Integration**: ✅ Complete
**API Endpoints**: ✅ Ready
**Next**: Configure credentials and test from Flutter app
