# Backend 24/7 Setup with MT5 Integration

## Overview
Run your Flask trading backend continuously with MetaTrader 5 (MT5) integration so the app stays connected 24/7 while it's trading.

---

## Option 1: Windows Service (Recommended for Local Machine)

### Setup as Windows Service

1. **Install NSSM (Non-Sucking Service Manager):**
   ```powershell
   # Download from: https://nssm.cc/download
   # Extract to C:\nssm\
   
   # Add to PATH
   setx PATH "%PATH%;C:\nssm\win64"
   ```

2. **Create a batch file** `C:\zwesta-trader\start-backend.bat`:
   ```batch
   @echo off
   cd C:\zwesta-trader\Zwesta Flutter App
   python trading_backend.py
   ```

3. **Install as service:**
   ```powershell
   nssm install ZwestaBackend "C:\zwesta-trader\start-backend.bat"
   nssm set ZwestaBackend AppDirectory "C:\zwesta-trader\Zwesta Flutter App"
   nssm set ZwestaBackend AppStdout "C:\zwesta-trader\backend-logs.txt"
   nssm set ZwestaBackend AppStderr "C:\zwesta-trader\backend-errors.txt"
   ```

4. **Start the service:**
   ```powershell
   net start ZwestaBackend
   ```

5. **Verify it's running:**
   ```powershell
   nssm status ZwestaBackend
   ```

---

## Option 2: Python Virtual Environment with Scheduled Task

1. **Create a Python script** `C:\zwesta-trader\run_backend_forever.py`:
   ```python
   import subprocess
   import time
   import logging
   from datetime import datetime
   
   logging.basicConfig(
       filename='C:\\zwesta-trader\\backend-service.log',
       level=logging.INFO,
       format='%(asctime)s - %(levelname)s - %(message)s'
   )
   
   def run_backend():
       while True:
           try:
               logging.info("Starting backend server...")
               process = subprocess.Popen([
                   'python',
                   'C:\\zwesta-trader\\Zwesta Flutter App\\trading_backend.py'
               ])
               process.wait()
               logging.error("Backend crashed, restarting in 5 seconds...")
               time.sleep(5)
           except Exception as e:
               logging.error(f"Error: {e}, retrying in 10 seconds...")
               time.sleep(10)
   
   if __name__ == "__main__":
       run_backend()
   ```

2. **Create scheduled task to run on startup:**
   ```powershell
   $trigger = New-ScheduledTaskTrigger -AtStartup
   $principal = New-ScheduledTaskPrincipal -UserID "SYSTEM" -RunLevel Highest
   $action = New-ScheduledTaskAction -Execute powershell.exe -Argument "-NoProfile -WindowStyle Hidden -File C:\zwesta-trader\start-backend.ps1"
   $task = Register-ScheduledTask -TaskName "ZwestaBackend" -Trigger $trigger -Principal $principal -Action $action
   ```

---

## Option 3: VPS Deployment (Best for 24/7)

### Deploy to Windows VPS or Cloud

1. **Use Azure, AWS, or DigitalOcean:**
   - Rent a Windows Server 2022 instance
   - Install Python 3.10+
   - Install MT5 API client

2. **SSH into server and clone project:**
   ```bash
   git clone https://github.com/Zweli1985/zwesta-trading.git
   cd zwesta-trading
   pip install -r trading_backend_requirements.txt
   ```

3. **Run with `nohup` (Linux/Unix):**
   ```bash
   nohup python trading_backend.py > backend.log 2>&1 &
   ```

4. **Or use `screen` for persistent sessions:**
   ```bash
   screen -S zwesta-backend
   python trading_backend.py
   # Press Ctrl+A then D to detach
   ```

5. **Keep alive with systemd service** (Linux):
   ```bash
   sudo nano /etc/systemd/system/zwesta-trading.service
   ```
   
   Add:
   ```ini
   [Unit]
   Description=Zwesta Trading Backend
   After=network.target
   
   [Service]
   Type=simple
   User=ubuntu
   WorkingDirectory=/home/ubuntu/zwesta-trading
   ExecStart=/usr/bin/python3 trading_backend.py
   Restart=always
   RestartSec=10
   
   [Install]
   WantedBy=multi-user.target
   ```
   
   Then:
   ```bash
   sudo systemctl enable zwesta-trading
   sudo systemctl start zwesta-trading
   ```

---

## MT5 Integration Setup

### 1. Install MT5 Python Client

```bash
pip install MetaTrader5
```

### 2. Update `trading_backend.py` to connect MT5:

```python
import MetaTrader5 as mt5

class MT5Manager:
    def __init__(self):
        if not mt5.initialize():
            print(f"initialize() failed, error code = {mt5.last_error()}")
            quit()
    
    def get_account_info(self):
        account_info = mt5.account_info()
        if account_info is None:
            return None
        return {
            'balance': account_info.balance,
            'equity': account_info.equity,
            'profit': account_info.profit,
            'margin': account_info.margin,
            'margin_free': account_info.margin_free,
        }
    
    def get_positions(self):
        positions = mt5.positions_get()
        return [
            {
                'ticket': pos.ticket,
                'symbol': pos.symbol,
                'type': 'BUY' if pos.type == 0 else 'SELL',
                'volume': pos.volume,
                'price_open': pos.price_open,
                'price_current': pos.price_current,
                'profit': pos.profit,
            }
            for pos in positions
        ]
    
    def get_trades_history(self, limit=100):
        deals = mt5.history_deals_get(-1, limit=limit)
        return [
            {
                'ticket': deal.ticket,
                'symbol': deal.symbol,
                'type': 'BUY' if deal.type == 0 else 'SELL',
                'volume': deal.volume,
                'price': deal.price,
                'profit': deal.profit,
                'time': deal.time,
            }
            for deal in deals
        ]
    
    def shutdown(self):
        mt5.shutdown()

# Use in your Flask routes
mt5_manager = MT5Manager()

@app.route('/api/account', methods=['GET'])
def get_account():
    return mt5_manager.get_account_info()

@app.route('/api/positions', methods=['GET'])
def get_positions():
    return mt5_manager.get_positions()

@app.route('/api/trades', methods=['GET'])
def get_trades():
    return mt5_manager.get_trades_history()
```

### 3. MT5 Connection Details

- **Account Number**: Your MT5 Account ID
- **Server**: Your broker's MT5 server (e.g., "ICMarkets-Demo")
- **Password**: Your MT5 account password

Set these in `.env`:
```
MT5_ACCOUNT=1234567
MT5_SERVER=ICMarkets-Demo
MT5_PASSWORD=your_password
```

### 4. Handle MT5 in Backend

Modify `trading_backend.py`:
```python
import os
from dotenv import load_dotenv

load_dotenv()

mt5_account = int(os.getenv('MT5_ACCOUNT'))
mt5_server = os.getenv('MT5_SERVER')
mt5_password = os.getenv('MT5_PASSWORD')

if not mt5.login(mt5_account, mt5_password, mt5_server):
    print(f"Login failed: {mt5.last_error()}")
```

---

## Monitoring 24/7

### 1. Add Health Check Endpoint:

```python
@app.route('/api/health', methods=['GET'])
def health():
    return {
        'status': 'OK',
        'time': datetime.now().isoformat(),
        'mt5_connected': mt5.connected(),
        'backend_version': '1.0'
    }
```

### 2. Check from Flutter App periodically:

```dart
// In trading_service.dart
Future<void> _healthCheck() async {
  try {
    final response = await http.get(
      Uri.parse('${EnvironmentConfig.apiBaseUrl}/api/health'),
    );
    if (response.statusCode != 200) {
      print('Backend health check failed');
      _notifyError('Backend offline');
    }
  } catch (e) {
    print('Health check error: $e');
  }
}

// Call periodically (every 30 seconds)
Timer.periodic(Duration(seconds: 30), (_) async {
  await _healthCheck();
});
```

---

## Recommended Setup for 24/7

**Best Practice:**
1. Run backend on **Windows VPS** (Azure, AWS, DigitalOcean)
2. Use **systemd service** or **Windows Service** for auto-restart
3. Add **health checks** in your app
4. Enable **logging** for debugging
5. Set up **email alerts** if service crashes

---

## Frequently Debugged Issues

| Issue | Solution |
|-------|----------|
| Port already in use | Change port in `trading_backend.py` + update app |
| MT5 timeout | Increase `LOGIN_TIMEOUT` in MT5 settings |
| Memory leak | Monitor logs for memory growth, restart daily |
| SSL/TLS errors | Update certificates yearly |
| CORS blocked | Add your app domain to Flask CORS config |

---

## Cost Estimates (Monthly)

- **Local Machine**: $0 (electricity only)
- **Small VPS**: $5-15 (DigitalOcean, Linode)
- **Medium VPS**: $20-40 (handle more users)
- **Azure/AWS**: Pay-as-you-go, ~$30-80

---

## Next Steps

1. Choose your deployment option
2. Test backend locally: `python trading_backend.py`
3. Deploy to VPS or set up Windows Service
4. Update app's `environment_config.dart` with backend URL
5. Test from Flutter app
6. Monitor logs continuously

Questions? Check backend logs!
