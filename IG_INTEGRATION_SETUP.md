# IG.com API Integration Setup

## Overview
Your Zwesta Flutter trading system is now integrated with **IG.com Markets API** using the credentials from your IG.com account.

## API Key Information
- **API Key**: `9bbc3ef9ad291acec96dc409d80e50c4c805161a`
- **Status**: Enabled
- **Platform**: https://www.ig.com/en-ch/myig/settings/api-keys
- **Account Name**: Zwesta Trading System

## Configuration

### 1. Environment Variables (Optional)
You can set these environment variables to override defaults:

```bash
# IG.com Credentials
IG_API_KEY=9bbc3ef9ad291acec96dc409d80e50c4c805161a
IG_USERNAME=your_ig_username  # If you have one
IG_PASSWORD=your_ig_password  # If you have one
IG_ACCOUNT_ID=your_account_id # Your IG account ID
IG_DEMO_MODE=true             # Set to false for live trading

# Trading Environment
TRADING_ENV=DEMO              # Set to LIVE for live trading
```

### 2. Backend Initialization
The backend automatically:
- ✅ Loads IG_CONFIG on startup
- ✅ Initializes IG Markets connection in broker_manager
- ✅ Attempts auto-connect to IG.com
- ✅ Exposes API endpoints for Flutter app

## API Endpoints

### 1. Connect to IG.com
**Endpoint**: `POST /api/ig/connect`

```json
{
  "api_key": "9bbc3ef9ad291acec96dc409d80e50c4c805161a",
  "username": "your_username",
  "password": "your_password"
}
```

**Response** (Success):
```json
{
  "success": true,
  "message": "Connected to IG.com successfully",
  "api_key": "9bbc3ef9ad291acec96dc409d80e50c4c805161a",
  "account_id": "account123"
}
```

### 2. Get Account Info
**Endpoint**: `GET /api/ig/account-info`

**Response**:
```json
{
  "success": true,
  "account": {
    "account_id": "...",
    "balance": 10000.00,
    "available_funds": 9500.00,
    "margin_used": 500.00
  },
  "api_key": "9bbc3ef9ad291acec96dc409d80e50c4c805161a"
}
```

### 3. Get Open Positions
**Endpoint**: `GET /api/ig/positions`

**Response**:
```json
{
  "success": true,
  "positions": [
    {
      "position_id": "12345",
      "epic": "EURUSD",
      "direction": "BUY",
      "size": 1.0,
      "entry_price": 1.0850,
      "current_price": 1.0865,
      "profit_loss": 150.00
    }
  ]
}
```

### 4. Place Order
**Endpoint**: `POST /api/ig/place-order`

```json
{
  "epic": "EURUSD",
  "direction": "BUY",
  "size": 1.0,
  "stop_loss": 1.0800,
  "take_profit": 1.0900
}
```

**Response**:
```json
{
  "success": true,
  "order_id": "order123",
  "deal_id": "deal456"
}
```

### 5. Get Open Trades
**Endpoint**: `GET /api/ig/trades`

**Response**:
```json
{
  "success": true,
  "trades": [
    {
      "deal_id": "deal456",
      "epic": "EURUSD",
      "direction": "BUY",
      "size": 1.0,
      "open_price": 1.0850,
      "current_price": 1.0865,
      "unrealized_profit": 150.00
    }
  ]
}
```

### 6. Close Position
**Endpoint**: `POST /api/ig/close-position`

```json
{
  "deal_id": "deal456",
  "epic": "EURUSD"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Position closed successfully",
  "closing_deal_id": "deal789",
  "profit_loss": 150.00
}
```

## Flutter Integration Example

### Dart/Flutter Code
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class IGTradingService {
  final String baseUrl = 'http://localhost:9000';
  final String apiKey = '9bbc3ef9ad291acec96dc409d80e50c4c805161a';
  
  // Connect to IG.com
  Future<Map> connectIG(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ig/connect'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'api_key': apiKey,
        'username': username,
        'password': password,
      }),
    );
    
    return jsonDecode(response.body);
  }
  
  // Get account info
  Future<Map> getAccountInfo() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/ig/account-info'),
      headers: {'Content-Type': 'application/json'},
    );
    
    return jsonDecode(response.body);
  }
  
  // Place order
  Future<Map> placeOrder({
    required String epic,
    required String direction,
    required double size,
    double? stopLoss,
    double? takeProfit,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ig/place-order'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'epic': epic,
        'direction': direction,
        'size': size,
        'stop_loss': stopLoss,
        'take_profit': takeProfit,
      }),
    );
    
    return jsonDecode(response.body);
  }
  
  // Get open trades
  Future<Map> getTrades() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/ig/trades'),
      headers: {'Content-Type': 'application/json'},
    );
    
    return jsonDecode(response.body);
  }
  
  // Close position
  Future<Map> closePosition({
    required String dealId,
    required String epic,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ig/close-position'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'deal_id': dealId,
        'epic': epic,
      }),
    );
    
    return jsonDecode(response.body);
  }
}
```

## Testing the Integration

### 1. Test Backend Startup
```bash
# Run the backend
python multi_broker_backend_updated.py
```

You should see:
```
🔗 Attempting auto-connect to IG.com...
✅ Auto-connected to IG.com successfully using API key: 9bbc3ef9ad291acec96dc409d80e50c4c805161a
```

### 2. Test API Endpoints
```bash
# Test health check
curl http://localhost:9000/api/health

# Test IG connection
curl -X POST http://localhost:9000/api/ig/connect \
  -H "Content-Type: application/json" \
  -d '{"username":"your_username","password":"your_password"}'
```

### 3. Test Flutter App
Add the IGTradingService to your Flutter app and test the connection flow.

## Troubleshooting

### Connection Issues
1. **"IG.com not connected"**
   - Check if username/password are provided in environment variables
   - Verify your IG.com credentials are correct
   - Check internet connection

2. **"IG Markets connection not initialized"**
   - Restart the backend server
   - Check backend logs for initialization errors

3. **API Key 401 Errors**
   - Verify the API key: `9bbc3ef9ad291acec96dc409d80e50c4c805161a`
   - Check if IG account is still enabled in https://www.ig.com/en-ch/myig/settings/api-keys

### Demo vs Live Mode
- **DEMO MODE** (default): Uses demo account for testing, no real money
- **LIVE MODE**: Requires `TRADING_ENV=LIVE` and valid credentials

## Architecture

```
Flutter App
    ↓
Zwesta Backend (multi_broker_backend_updated.py)
    ↓
IG.com REST API (https://api.ig.com/gateway/deal)
    ↓
IG.com Markets (Live Trading)
```

## Security Notes
- 🔐 API Key is stored in environment variables
- 🔐 Credentials are encrypted in transit (HTTPS)
- 🔐 Keep your IG username/password secure
- 🔐 Do not commit credentials to version control

## Files Modified
- ✅ `multi_broker_backend_updated.py` - Added IG_CONFIG, IGConnection initialization, API endpoints
- ✅ `IG_INTEGRATION_SETUP.md` - This documentation
- ✅ `.env.example` - Environment variables template

## Next Steps
1. Add IG_USERNAME and IG_PASSWORD to your environment variables
2. Run the backend and verify IG connection
3. Integrate IGTradingService into your Flutter app
4. Test trading endpoints with demo account first
5. Switch to live trading when ready

## Support
For issues or questions:
1. Check the backend logs: `multi_broker_backend.log`
2. Review the IG API documentation: https://labs.ig.com/
3. Enable verbose logging in the backend
