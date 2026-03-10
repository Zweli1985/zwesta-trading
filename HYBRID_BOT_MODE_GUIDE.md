# Hybrid Bot Trading Mode Guide

## Overview

Zwesta Trading System supports **HYBRID BOT MODE** - allowing users to choose between:
- **DEMO Mode**: Free to use, trades on shared demo MT5 account
- **LIVE Mode**: User provides their own MT5 credentials, trades on their real account

## Mode Comparison

| Feature | DEMO | LIVE |
|---------|------|------|
| MT5 Credentials Required | ❌ No | ✅ Yes |
| Trading Account | Shared Demo | Your Account |
| Data Isolation | Multi-tenant | Personal |
| Profits Attribution | Shared | 100% Yours |
| Referral Earnings | Yes | Yes |
| Cost | FREE | FREE |

## Creating a Bot - DEMO Mode (Recommended for Testing)

**Default behavior** - no MT5 credentials needed:

```dart
// In bot_service.dart - createBotOnBackend()
final response = await http.post(
  Uri.parse('$_apiUrl/api/bot/create'),
  headers: {
    'Content-Type': 'application/json',
    'X-Session-Token': sessionToken,
  },
  body: jsonEncode({
    'user_id': userId,
    'botId': botId,
    'symbols': ['EURUSD', 'XAUUSD'],        // Your trading symbols
    'strategy': 'Trend Following',           // Your strategy
    'riskPerTrade': 100,                     // Risk per trade
    'maxDailyLoss': 500,
    // Optional:
    'mode': 'demo',  // Explicit, but this is the default
    // NO mt5_credentials needed for demo
  }),
);
```

**Backend Response (DEMO Mode):**
```json
{
  "success": true,
  "botId": "bot_uuid_123",
  "mode": "demo",
  "accountId": "Demo MT5 - XM Global",
  "credentialId": null,
  "message": "Bot created successfully in DEMO mode",
  "config": {
    "botId": "bot_uuid_123",
    "mode": "demo",
    "accountId": "Demo MT5 - XM Global",
    "symbols": ["EURUSD", "XAUUSD"],
    "strategy": "Trend Following"
  }
}
```

## Creating a Bot - LIVE Mode (Real Trading)

**Requires MT5 credentials:**

1. **First, save user's MT5 credentials:**

```dart
// In auth_service.dart or settings_screen.dart
Future<bool> addMT5Credentials({
  required String accountNumber,
  required String password,
  required String server,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final authToken = prefs.getString('auth_token');
  final userId = prefs.getString('user_id');
  
  final response = await http.post(
    Uri.parse('$_apiUrl/api/user/$userId/broker-credentials'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $API_KEY',  // Admin key for storage
    },
    body: jsonEncode({
      'broker_name': 'MT5',
      'account_number': accountNumber,
      'password': password,
      'server': server,
      'is_live': true,
    }),
  );
  
  if (response.statusCode == 200) {
    print('✅ MT5 Credentials saved');
    return true;
  }
  return false;
}
```

2. **Then create bot in LIVE mode with credentials:**

```dart
// In bot_service.dart - createBotOnBackend()
final response = await http.post(
  Uri.parse('$_apiUrl/api/bot/create'),
  headers: {
    'Content-Type': 'application/json',
    'X-Session-Token': sessionToken,
  },
  body: jsonEncode({
    'user_id': userId,
    'botId': botId,
    'symbols': ['EURUSD', 'XAGUSD'],
    'strategy': 'Scalping',
    'riskPerTrade': 150,
    'maxDailyLoss': 750,
    // LIVE MODE with credentials:
    'mode': 'live',
    'mt5_credentials': {
      'account_number': '104017418',  // Your MT5 account number
      'password': '*6RjhRvH',           // Your MT5 password
      'server': 'MetaQuotes-Demo',      // Your MT5 server
    }
  }),
);
```

**Backend Response (LIVE Mode):**
```json
{
  "success": true,
  "botId": "bot_uuid_456",
  "mode": "live",
  "accountId": "User_uuid_104017418",
  "credentialId": "credential_id_789",
  "message": "Bot created successfully in LIVE mode",
  "config": {
    "botId": "bot_uuid_456",
    "mode": "live",
    "accountId": "User_uuid_104017418",
    "symbols": ["EURUSD", "XAGUSD"],
    "strategy": "Scalping"
  }
}
```

## Bot Data Persistence & Isolation

### DEMO Mode Bots
- Trades stored in shared demo trades storage
- Profits tracked per bot
- Database: `user_bots` table with `broker_account_id = "Demo MT5 - XM Global"`

### LIVE Mode Bots
- Trades stored per user's MT5 account
- Credentials encrypted in `broker_credentials` table
- Database: `user_bots` table with `broker_account_id = "User_{user_id}_{account_number}"`
- Multiple users = completely isolated data

## Switching Between Modes

### Option 1: Delete DEMO Bot + Create LIVE Bot
```dart
// Delete demo bot
await http.delete(
  Uri.parse('$_apiUrl/api/bot/delete/$demoBotId'),
  headers: {'X-Session-Token': sessionToken},
);

// Create live bot (see above)
```

### Option 2: Create Multiple Bots (Run Both)
```dart
// Keep running DEMO bot
// Add new LIVE bot
// Both will trade simultaneously on their respective accounts
```

## Admin: Viewing User's Bots

```dart
// GET /api/user/{user_id}/bots
final response = await http.get(
  Uri.parse('$_apiUrl/api/user/$userId/bots'),
  headers: {'X-Session-Token': sessionToken},
);

// Response shows all user's bots with their modes:
{
  "success": true,
  "bots": [
    {
      "bot_id": "demo_bot_1",
      "name": "My Demo Bot",
      "strategy": "Trend Following",
      "broker_account_id": "Demo MT5 - XM Global",  // ← DEMO
      "status": "active",
      "enabled": true
    },
    {
      "bot_id": "live_bot_1",
      "name": "My Live Bot",
      "strategy": "Scalping",
      "broker_account_id": "User_abc_104017418",    // ← LIVE
      "status": "active",
      "enabled": true
    }
  ]
}
```

## Viewing Credentials

```dart
// GET /api/user/{user_id}/broker-credentials
final response = await http.get(
  Uri.parse('$_apiUrl/api/user/$userId/broker-credentials'),
  headers: {'X-Session-Token': sessionToken},
);

// Response:
{
  "success": true,
  "credentials": [
    {
      "credential_id": "cred_123",
      "broker_name": "MT5",
      "account_number": "104017418",  // Last 9 digits visible
      "server": "MetaQuotes-Demo",
      "is_live": true,
      "is_active": true,
      "created_at": "2026-03-10T19:20:00"
    }
  ]
}
```

## Security Notes

✅ **Best Practices:**
- Passwords stored encrypted in database
- Only transmitted via HTTPS
- Credentials never logged or exposed
- User can delete credentials anytime
- Each credential tied to specific user_id

❌ **Never:**
- Store credentials in SharedPreferences (use backend)
- Log full account numbers or passwords
- Send credentials in GET requests
- Hardcode credentials in app

## Error Cases

### Creating LIVE Bot Without Credentials:
```json
{
  "success": false,
  "error": "Live mode requires mt5_credentials"
}
```

### Getting 401 When Starting Bot:
- Session expired → Login again
- Bot belongs to different user → Use correct user_id
- Check browser's X-Session-Token header

### Credentials Deactivated:
```json
{
  "success": false,
  "error": "MT5 credentials not found or inactive"
}
```
User should add new credentials via `/api/user/{user_id}/broker-credentials`

## Referral Earnings in Hybrid Mode

✅ **DEMO Bots** - Earn referral commissions:
- Referrer gets 5% of profits from referred users' demo bots

✅ **LIVE Bots** - Earn referral commissions:
- Referrer gets 5% of profits from referred users' live bots
- Profits from users' real accounts

**No difference** - Both modes contribute to referral earnings equally.

## Intelligent Features Work in Both Modes

- ✅ Dynamic Position Sizing
- ✅ Auto-Strategy Switching
- ✅ Auto-Withdrawal (when profit target reached)
- ✅ Performance Tracking
- ✅ Risk Management
- ✅ Multi-Broker Support (future)

## Migration Path

**Recommended workflow:**

1. **Phase 1 - Testing** (Week 1)
   - Create DEMO bot
   - Test strategy without risk
   - Monitor performance
   - Earn referral commissions already

2. **Phase 2 - Live Trading** (When confident)
   - Add MT5 credentials
   - Create LIVE bot with same strategy
   - Trade with real capital
   - Still earn referral commissions

3. **Phase 3 - Scale** (Ongoing)
   - Run multiple LIVE bots with different strategies
   - Optimize which ones are most profitable
   - Delete underperforming bots

## FAQ

**Q: Can I have both DEMO and LIVE bots at same time?**
A: Yes! They run independently on different accounts.

**Q: Will my DEMO bot earnings count?**
A: Yes, even demo profit generates referral commissions if you're a referrer.

**Q: Can I change my MT5 account after creating LIVE bot?**
A: Create new LIVE bot with new credentials, delete old one.

**Q: How are profits calculated for referral earnings?**
A: Same way for both modes - 5% of bot's total profit goes to referrer.

**Q: What if MT5 credentials are wrong?**
A: Bot will fail to connect when started. Error in logs will show which field is wrong.

---

**Support:** If you encounter issues with hybrid mode, check:
1. Session token is fresh (login again if needed)
2. MT5 credentials are correct (test in MT5 app first)
3. Server name matches exactly (e.g., "MetaQuotes-Demo" vs "XM Global")
4. Account number is valid (9-10 digits)
5. Database has `broker_credentials` and `user_sessions` tables
