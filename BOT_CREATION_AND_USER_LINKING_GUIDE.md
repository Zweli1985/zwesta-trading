# Bot Creation Flow & User Linking Guide

## 📍 Bot Creation Location

**File:** `multi_broker_backend_updated.py`  
**Endpoint:** `/api/bot/create` (Line 1999-2080)  
**Location:** `C:\backend\multi_broker_backend_updated.py` (on your VPS)

---

## 🔄 Complete Bot Creation Flow

### **Step 1: User Logs In**
```
Flutter App
├─ Call: POST /api/user/login
│  └─ Email: user@example.com
│
Backend (multi_broker_backend_updated.py)
├─ Find user in database
├─ Generate session token (real, not fake)
├─ Store in user_sessions table
└─ Return: { session_token: "abc123...", user_id: "uuid-xyz" }

Flutter App stores:
├─ auth_token = "abc123..." (session_token)
└─ user_id = "uuid-xyz"
```

### **Step 2: User Creates Bot**
```
Flutter App (bot_service.dart)
├─ Call: POST /api/bot/create
├─ Headers: X-Session-Token: "abc123..."
├─ Body:
│  ├─ user_id: "uuid-xyz"
│  ├─ botId: "MyTradingBot"
│  ├─ strategy: "Trend Following"
│  └─ symbols: ["EURUSD", "GBPUSD"]
│
Backend (multi_broker_backend_updated.py - Line 1999)
├─ Check: @require_session (needs valid token)
├─ Extract: user_id from request
├─ Verify: User exists in users table
├─ Store in user_bots table:
│  ├─ bot_id
│  ├─ user_id ← LINKED TO THIS USER
│  ├─ strategy
│  └─ created_at
├─ Store in active_bots dictionary:
│  ├─ botId
│  ├─ user_id ← LINKED TO THIS USER
│  └─ strategy
└─ Return: { success: true, botId: "..." }
```

---

## 🔐 How Bots Are Linked to Users

### **Database Level** (SQLite - zwesta_trading.db)

```sql
-- users table
CREATE TABLE users (
  user_id TEXT PRIMARY KEY,
  email TEXT UNIQUE,
  name TEXT,
  referral_code TEXT,
  created_at TEXT
)

-- user_bots table (stores all bots created by users)
CREATE TABLE user_bots (
  bot_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,  ← FOREIGN KEY - Links to users.user_id
  name TEXT,
  strategy TEXT,
  status TEXT,
  enabled INTEGER,
  created_at TEXT,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
)

-- user_sessions table (tracks login sessions)
CREATE TABLE user_sessions (
  session_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,  ← Which user is logged in
  token TEXT UNIQUE,
  created_at TEXT,
  expires_at TEXT,
  is_active INTEGER,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
)
```

### **Backend Memory Level** (active_bots dictionary)

```python
active_bots = {
    'bot_abc123': {
        'botId': 'bot_abc123',
        'user_id': 'user_xyz789',   ← LINKED TO USER
        'strategy': 'Trend Following',
        'enabled': True,
        'symbols': ['EURUSD'],
        # ... other bot properties
    },
    'bot_def456': {
        'botId': 'bot_def456',
        'user_id': 'user_111222',   ← DIFFERENT USER
        'strategy': 'Mean Reversion',
        'enabled': True,
        # ...
    }
}
```

---

## 🚀 Complete Bot Interaction Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER APP                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ lib/services/bot_service.dart                        │   │
│  │                                                       │   │
│  │ createBotOnBackend() {                               │   │
│  │   sessionToken = await prefs.getString('auth_token') │   │
│  │   userId = await prefs.getString('user_id')          │   │
│  │                                                       │   │
│  │   POST /api/bot/create                               │   │
│  │   Headers: X-Session-Token: sessionToken             │   │
│  │   Body: { user_id, botId, strategy, ... }            │   │
│  │ }                                                     │   │
│  └────────────────┬──────────────────────────────────────┘   │
└─────────────────┼────────────────────────────────────────────┘
                  │ HTTP POST
                  │
┌─────────────────┼────────────────────────────────────────────┐
│                 ▼                                              │
│           BACKEND (PORT 9000)                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ multi_broker_backend_updated.py                      │   │
│  │                                                       │   │
│  │ @app.route('/api/bot/create')                        │   │
│  │ @require_session  ← Validates X-Session-Token        │   │
│  │ def create_bot():                                    │   │
│  │   user_id = request.user_id  ← From session          │   │
│  │                                                       │   │
│  │   # Check: User exists?                              │   │
│  │   SELECT FROM users WHERE user_id = ?                │   │
│  │   If not found → 404 error                           │   │
│  │                                                       │   │
│  │   # Create bot linked to user                        │   │
│  │   INSERT INTO user_bots (bot_id, user_id, ...)       │   │
│  │   ↓                                                   │   │
│  │   user_bots table {                                  │   │
│  │     bot_id: "bot_12345",                             │   │
│  │     user_id: "uuid-xyz",  ← LINKAGE                  │   │
│  │     strategy: "Trend Following",                     │   │
│  │     created_at: "2026-03-09..."                      │   │
│  │   }                                                   │   │
│  │                                                       │   │
│  │   # Also store in memory for fast access             │   │
│  │   active_bots['bot_12345'] = {                       │   │
│  │     'user_id': 'uuid-xyz',  ← LINKAGE                │   │
│  │     'strategy': 'Trend Following',                   │   │
│  │     'enabled': True,                                 │   │
│  │     ...                                              │   │
│  │   }                                                   │   │
│  │                                                       │   │
│  │   return { success: true, botId: "bot_12345" }       │   │
│  │ }                                                     │   │
│  └────────────────┬──────────────────────────────────────┘   │
│                   │                                           │
│         ┌─────────┴─────────┐                                │
│         │                   │                                │
│   ┌─────▼────────┐  ┌──────▼────────┐                        │
│   │ SQLite DB    │  │ Memory Cache  │                        │
│   │ zwesta_      │  │ active_bots   │                        │
│   │ trading.db   │  │ dictionary    │                        │
│   └──────────────┘  └───────────────┘                        │
│                                                               │
│   Both have: user_id linking bot to profile                 │
└─────────────────────────────────────────────────────────────┘
```

---

## ❌ Why You Get "Failed to Create Bot 401"

### **Scenario 1: Backend Not Running**
```
Flutter: POST /api/bot/create with X-Session-Token
  ↓
Backend: Not listening on port 9000
  ↓
Connection refused
  ↓
Flutter shows: "Failed to create bot 401"
```

**Fix:** Start backend first
```bash
python C:\backend\multi_broker_backend_updated.py
```

### **Scenario 2: Invalid Session Token**
```
Flutter: POST /api/bot/create with X-Session-Token: "fake_token"
  ↓
Backend: @require_session decorator checks token
  ↓
user_sessions table: No match found
  ↓
Returns: 401 Unauthorized
  ↓
Flutter shows: "Failed to create bot 401"
```

**Fix:** Login first (with backend running) to get real token
```
1. Register email: user@example.com
2. Login: POST /api/user/login with email
3. Backend: Validate user, create real session token
4. Flutter: Store session_token in SharedPreferences
5. Then create bot with valid token
```

### **Scenario 3: No User ID**
```
Flutter: POST /api/bot/create without user_id
  ↓
Backend: user_id = data.get('user_id') or request.user_id
  ↓
If both are None:
  ↓
Returns: 400 Bad Request (error: 'user_id required')
```

**Fix:** Flutter bot_service.dart passes user_id:
```dart
final userId = prefs.getString('user_id');
body: jsonEncode({
  'user_id': userId,  ← Must not be null
  'botId': botId,
  ...
})
```

---

## 🔍 How to Debug Bot Creation Issues

### **1. Backend Logs**
When you create a bot, you should see:
```
2026-03-09 16:30:50,134 - __main__ - INFO - Created bot bot_12345 for user uuid-xyz: Trend Following
```

If you don't see this line → Bot wasn't created on backend

### **2. Check Database**
```bash
sqlite3 C:\backend\zwesta_trading.db
sqlite> SELECT * FROM user_bots;

bot_id          user_id         strategy            created_at
bot_12345       uuid-xyz        Trend Following     2026-03-09T16:30:50...
bot_67890       uuid-abc        Mean Reversion      2026-03-09T16:31:20...
```

Each bot should have a `user_id` linking it to a user.

### **3. Check User Sessions**
```bash
sqlite3 C:\backend\zwesta_trading.db
sqlite> SELECT * FROM user_sessions WHERE is_active = 1;

user_id    token                             expires_at           is_active
uuid-xyz   abc123def456...                   2026-04-08...        1
uuid-abc   xyz789abc123...                   2026-04-08...        1
```

If your user_id isn't here → Session expired or login failed

---

## ✅ Correct Workflow (Step by Step)

### **Step 1: Ensure Backend is Running**
```bash
C:\backend> python multi_broker_backend_updated.py
Running on http://0.0.0.0:9000  ← MUST SEE THIS
```

### **Step 2: App Registration**
```
Flutter App
├─ Register: Name, Email, Username, Password
└─ Backend: Creates user in database, generates referral code
```

Check database:
```bash
sqlite> SELECT user_id, email, referral_code FROM users;
uuid-xyz  user@example.com  A1B2C3D4
```

### **Step 3: App Login**
```
Flutter App
├─ Login: Email only
│
Backend
├─ Find user by email
├─ Create session token
├─ Store in user_sessions table
└─ Return: { session_token: "real_token", user_id: "uuid-xyz" }

Flutter App
├─ Save auth_token = "real_token"
├─ Save user_id = "uuid-xyz"
└─ Now authenticated ✅
```

Check database:
```bash
sqlite> SELECT user_id, token, is_active FROM user_sessions;
uuid-xyz  real_token_hash...  1
```

### **Step 4: Create Bot**
```
Flutter App
├─ bot_service.dartcreateBot()
├─ Get: auth_token = "real_token", user_id = "uuid-xyz"
├─ POST /api/bot/create
├─ Headers: X-Session-Token: "real_token"
├─ Body: { user_id: "uuid-xyz", botId: "Bot1", ... }
│
Backend
├─ Validate session token ✅
├─ Extract user_id from session ✅
├─ Verify user exists ✅
├─ Create bot linked to user_id ✅
└─ Return: { success: true }
```

Check database:
```bash
sqlite> SELECT bot_id, user_id, strategy FROM user_bots;
bot_abc   uuid-xyz  Trend Following
```

Check active bots in memory:
```python
print(active_bots)
# {
#   'bot_abc': {
#     'botId': 'bot_abc',
#     'user_id': 'uuid-xyz',  ← LINKED
#     'strategy': 'Trend Following',
#     ...
#   }
# }
```

---

## 📊 User Data Isolation (Multi-Tenant)

Each user sees ONLY their own bots:

**User 1 (uuid-xyz):**
```bash
GET /api/user/uuid-xyz/bots
Headers: X-Session-Token: token-user1

Backend filters:
SELECT * FROM user_bots WHERE user_id = 'uuid-xyz'

Returns: Only bots owned by User 1
[
  { botId: 'bot_abc', strategy: 'Trend Following', user_id: 'uuid-xyz' }
]
```

**User 2 (uuid-abc):**
```bash
GET /api/user/uuid-abc/bots
Headers: X-Session-Token: token-user2

Backend filters:
SELECT * FROM user_bots WHERE user_id = 'uuid-abc'

Returns: Only bots owned by User 2
[
  { botId: 'bot_xyz', strategy: 'Mean Reversion', user_id: 'uuid-abc' }
]
```

**User 1 tries to access User 2's bots:**
```bash
GET /api/user/uuid-abc/bots
Headers: X-Session-Token: token-user1

Backend checks:
request.user_id (from token) = 'uuid-xyz'
requested user_id parameter = 'uuid-abc'

if request.user_id != user_id:
    return 403 Forbidden ✅
```

---

## Summary Table

| Component | File | Purpose | Links Bots to Users |
|-----------|------|---------|---------------------|
| Flutter | `lib/services/bot_service.dart` | Sends bot creation request | Includes session token + user_id |
| Backend | `multi_broker_backend_updated.py` | Processes bot creation | Validates token, stores user_id with bot |
| Database | `user_bots` table | Persistent storage | Foreign key: `user_id` |
| Memory | `active_bots` dict | Real-time access | Dictionary key includes bot_id, value includes user_id |
| Auth | `user_sessions` table | Session management | Maps token to user_id |

---

## 🎯 To Fix Your "Failed to Create Bot 401"

**Checklist:**
- [ ] Backend running on port 9000?
- [ ] User registered in database?
- [ ] User logged in?
- [ ] Session token stored in SharedPreferences?
- [ ] user_id stored in SharedPreferences?
- [ ] X-Session-Token header sent with bot request?
- [ ] Session token hasn't expired (< 30 days)?

Check backend logs for exact error message and solve accordingly!
