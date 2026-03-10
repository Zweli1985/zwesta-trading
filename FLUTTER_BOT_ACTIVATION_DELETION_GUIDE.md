# Implementation Guide - Bot Activation & Deletion Safety Features

## Backend Changes Implemented ✅

### 1. **2FA Bot Activation System**
- **New Endpoint:** `POST /api/bot/<bot_id>/request-activation`
- **Purpose:** Send 6-digit PIN to user email before bot starts trading
- **Process:**
  1. User clicks \"Start Bot\"
  2. Frontend calls `/request-activation` → gets PIN
  3. User enters PIN in app
  4. Frontend calls `/api/bot/start` with PIN
  5. Bot starts only after PIN verification

**Request:**
```json
{
  \"botId\": \"bot_12345\"
}
```

**Response:**
```json
{
  \"success\": true,
  \"message\": \"Activation PIN sent to user@email.com\",
  \"expires_in_seconds\": 600,
  \"note\": \"For testing: PIN will be printed in backend logs\"
}
```

### 2. **2-Step Bot Deletion**
- **New Endpoint:** `POST /api/bot/<bot_id>/request-deletion`
- **Purpose:** Create confirmation token before permanent deletion
- **Process:**
  1. User clicks \"Delete Bot\"
  2. Frontend shows final stats & confirmation
  3. Frontend calls `/request-deletion` → gets confirmation token
  4. User confirms deletion
  5. Frontend calls `/delete` with token
  6. Bot permanently deleted

**Request:**
```json
{
  \"botId\": \"bot_12345\"
}
```

**Response:**
```json
{
  \"success\": true,
  \"confirmation_token\": \"a1b2c3d4e5f6g7h8\",
  \"expires_in_seconds\": 300,
  \"warning\": \"This action cannot be undone. All bot data will be permanently deleted.\",
  \"bot_stats\": {
    \"totalTrades\": 150,
    \"winningTrades\": 89,
    \"totalProfit\": 5432.50,
    \"totalLosses\": 2100.00
  }
}
```

---

## Flutter UI Implementation Examples

### 1. Bot Activation Flow

```dart
// lib/services/bot_service.dart

class BotActivationService {
  
  /// Step 1: Request activation PIN
  Future<Map<String, dynamic>> requestActivationPin(String botId) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/bot/$botId/request-activation'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to request activation PIN');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  /// Step 2: Verify PIN and start bot
  Future<Map<String, dynamic>> startBotWithPin(
    String botId, 
    String activationPin
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/bot/start'),
        headers: {'Authorization': 'Bearer $authToken'},
        body: jsonEncode({
          'botId': botId,
          'activation_pin': activationPin,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']);
      }
    } catch (e) {
      throw Exception('Failed to start bot: $e');
    }
  }
}
```

**UI - Show Activation Dialog:**

```dart
// lib/screens/bot_detail_screen.dart

class BotDetailScreen extends StatefulWidget {
  final String botId;
  
  @override
  State<BotDetailScreen> createState() => _BotDetailScreenState();
}

class _BotDetailScreenState extends State<BotDetailScreen> {
  final _botService = BotActivationService();
  String? _activationPin;
  int? _pinExpiresIn;
  late Timer? _pinTimer;
  
  @override
  void initState() {
    super.initState();
    _pinTimer = null;
  }
  
  void _startBotWithConfirmation() async {
    // Step 1: Show confirmation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('🤖 Activate Trading Bot?'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will activate your bot and start live trading.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'For security, you will need to verify with a PIN sent to your email.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            onPressed: () {
              Navigator.pop(context);
              _requestActivationPin();
            },
            child: Text('Request PIN'),
          ),
        ],
      ),
    );
  }
  
  void _requestActivationPin() async {
    try {
      // Step 2: Request PIN from backend
      final result = await _botService.requestActivationPin(widget.botId);
      
      setState(() {
        _pinExpiresIn = result['expires_in_seconds'];
      });
      
      // Start countdown timer
      _pinTimer?.cancel();
      _pinTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _pinExpiresIn = (_pinExpiresIn ?? 0) - 1;
          if (_pinExpiresIn! <= 0) {
            timer.cancel();
            _activationPin = null;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PIN expired. Request a new one.')),
            );
          }
        });
      });
      
      // Step 3: Show PIN entry dialog
      if (!mounted) return;
      _showPinEntryDialog();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  void _showPinEntryDialog() {
    final pinController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('🔐 Enter Activation PIN'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A 6-digit PIN has been sent to your email.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 16),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, letterSpacing: 4),
                decoration: InputDecoration(
                  hintText: '000000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Expires in $_pinExpiresIn seconds',
                style: TextStyle(
                  fontSize: 12,
                  color: _pinExpiresIn! < 60 ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _pinTimer?.cancel();
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: pinController.text.length == 6 ? () {
              _verifyAndStartBot(pinController.text);
              Navigator.pop(context);
            } : null,
            child: Text('Verify & Start'),
          ),
        ],
      ),
    );
  }
  
  void _verifyAndStartBot(String pin) async {
    try {
      final result = await _botService.startBotWithPin(widget.botId, pin);
      
      _pinTimer?.cancel();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Bot activated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh bot status
      _refreshBotStatus();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }
  
  void _refreshBotStatus() {
    // Reload bot data
    setState(() {});
  }
  
  @override
  void dispose() {
    _pinTimer?.cancel();
    super.dispose();
  }
}

// ============ BUILD METHOD ============
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Bot Details')),
    body: SingleChildScrollView(
      child: Column(
        children: [
          // Bot info here
          SizedBox(height: 20),
          
          // Start Bot Button
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _startBotWithConfirmation,
              icon: Icon(Icons.play_arrow),
              label: Text('Start Trading'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

### 2. Bot Deletion Flow

```dart
// lib/services/bot_service.dart

class BotDeletionService {
  
  /// Step 1: Request deletion confirmation
  Future<Map<String, dynamic>> requestDeletionConfirmation(String botId) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/bot/$botId/request-deletion'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to request deletion');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  /// Step 2: Permanently delete bot
  Future<Map<String, dynamic>> confirmAndDeleteBot(
    String botId,
    String confirmationToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/bot/delete/$botId'),
        headers: {'Authorization': 'Bearer $authToken'},
        body: jsonEncode({
          'confirmation_token': confirmationToken,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']);
      }
    } catch (e) {
      throw Exception('Failed to delete bot: $e');
    }
  }
}
```

**UI - Show Deletion Dialog:**

```dart
// lib/screens/bot_list_screen.dart

void _deleteBotWithConfirmation(String botId, String botName) async {
  final deletionService = BotDeletionService();
  
  // Step 1: Show warning dialog with final stats
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('⚠️ Delete Bot Permanently?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. All bot data will be permanently deleted.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16),
            
            // Show stats before deletion
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Final Statistics:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  _buildStatRow('Total Trades:', '150'),
                  _buildStatRow('Winning Trades:', '89'),
                  _buildStatRow('Total Profit:', '\$5,432.50'),
                  _buildStatRow('Total Losses:', '\$2,100.00'),
                ],
              ),
            ),
            
            SizedBox(height: 12),
            Text(
              'Deletion requires email verification for security.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Keep Bot'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _requestDeletionConfirmation(botId);
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: Text('Delete'),
        ),
      ],
    ),
  );
}

Widget _buildStatRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

void _requestDeletionConfirmation(String botId) async {
  try {
    final deletionService = BotDeletionService();
    
    // Step 2: Request deletion token from backend
    final result = await deletionService.requestDeletionConfirmation(botId);
    final confirmationToken = result['confirmation_token'];
    
    // Step 3: Show final confirmation dialog
    if (!mounted) return;
    _showFinalDeletionConfirmation(botId, confirmationToken);
    
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Error: $e')),
    );
  }
}

void _showFinalDeletionConfirmation(String botId, String token) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('🗑️ Confirm Permanent Deletion'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you absolutely sure? Type \"DELETE\" to confirm.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (value){},
              decoration: InputDecoration(
                hintText: 'Type DELETE',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This will remove all trading history and statistics.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _confirmDeletion(botId, token);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: Text('Permanently Delete'),
        ),
      ],
    ),
  );
}

void _confirmDeletion(String botId, String token) async {
  try {
    final deletionService = BotDeletionService();
    
    // Step 4: Send final deletion request with token
    final result = await deletionService.confirmAndDeleteBot(botId, token);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Bot deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Refresh list or navigate back
    if (mounted) {
      Navigator.pop(context);
    }
    
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Error: $e')),
    );
  }
}
```

---

## API Endpoints Summary

| Operation | Endpoint | Method | Purpose |
|-----------|----------|--------|---------|
| Request Activation PIN | `/api/bot/<bot_id>/request-activation` | POST | Get 6-digit PIN for bot activation |
| Start Bot (with PIN) | `/api/bot/start` | POST | Activate bot (requires PIN) |
| Stop Bot | `/api/bot/stop/<bot_id>` | POST | Pause bot (can restart later) |
| Request Deletion | `/api/bot/<bot_id>/request-deletion` | POST | Get confirmation token |
| Delete Bot | `/api/bot/delete/<bot_id>` | DELETE/POST | Permanently delete (requires token) |
| Auto-Withdrawal | `/api/bot/<bot_id>/auto-withdrawal` | POST | Set profit target for auto-withdrawal |
| Manual Withdrawal | `/api/withdrawal/request` | POST | Request commission withdrawal |

---

## Testing

For testing activation:
1. Run backend: `python multi_broker_backend_updated.py`
2. In logs, you'll see the PIN printed (since email is not configured)
3. Copy PIN and enter in app when prompted

Example log output:
```
==================================================
🔐 BOT ACTIVATION PIN SENT
--------------------------------------------------
User: John Doe (john@example.com)
Bot ID: bot_12345
PIN: 482931
Valid for: 10 minutes
==================================================
```

