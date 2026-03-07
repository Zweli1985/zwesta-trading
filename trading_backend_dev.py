#!/usr/bin/env python3
"""
Zwesta Trading System - Development Backend with Mock Data
Perfect for testing without requiring MetaTrader 5 installation
"""

import os
import json
import random
from datetime import datetime, timedelta
from flask import Flask, request, jsonify
from flask_cors import CORS
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('trading_backend_dev.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Mock Account Data
MOCK_ACCOUNT = {
    "login": 104017418,
    "name": "Zweihle Mathe",
    "server": "MetaQuotes-Demo",
    "balance": 100000.0,
    "equity": 102543.50,
    "margin": 5000.0,
    "margin_free": 95000.0,
    "margin_level": 2050.87,
    "profit": 2543.50,
    "currency": "USD"
}

# Mock Trades Data
MOCK_TRADES = [
    {
        "ticket": 1001,
        "symbol": "EURUSD",
        "type": "buy",
        "volume": 1.0,
        "open_price": 1.0950,
        "current_price": 1.0975,
        "open_time": (datetime.now() - timedelta(hours=2)).isoformat(),
        "profit": 250.0,
        "status": "open"
    },
    {
        "ticket": 1002,
        "symbol": "GBPUSD",
        "type": "sell",
        "volume": 0.5,
        "open_price": 1.2700,
        "current_price": 1.2680,
        "open_time": (datetime.now() - timedelta(days=1)).isoformat(),
        "profit": 100.0,
        "status": "open"
    },
    {
        "ticket": 1003,
        "symbol": "USDJPY",
        "type": "buy",
        "volume": 2.0,
        "open_price": 145.50,
        "close_price": 145.80,
        "open_time": (datetime.now() - timedelta(days=2)).isoformat(),
        "close_time": (datetime.now() - timedelta(days=1)).isoformat(),
        "profit": 600.0,
        "status": "closed"
    },
    {
        "ticket": 1004,
        "symbol": "AUDUSD",
        "type": "buy",
        "volume": 1.5,
        "open_price": 0.6700,
        "current_price": 0.6725,
        "open_time": (datetime.now() - timedelta(hours=5)).isoformat(),
        "profit": 337.50,
        "status": "open"
    },
    {
        "ticket": 1005,
        "symbol": "NZDUSD",
        "type": "sell",
        "volume": 1.0,
        "open_price": 0.5950,
        "current_price": 0.5940,
        "open_time": (datetime.now() - timedelta(hours=8)).isoformat(),
        "profit": 100.0,
        "status": "open"
    }
]

# Mock Positions
MOCK_POSITIONS = [
    {
        "ticket": 1001,
        "symbol": "EURUSD",
        "type": "buy",
        "volume": 1.0,
        "price": 1.0975,
        "profit": 250.0,
        "time": datetime.now().isoformat()
    },
    {
        "ticket": 1002,
        "symbol": "GBPUSD",
        "type": "sell",
        "volume": 0.5,
        "price": 1.2680,
        "profit": 100.0,
        "time": datetime.now().isoformat()
    },
    {
        "ticket": 1004,
        "symbol": "AUDUSD",
        "type": "buy",
        "volume": 1.5,
        "price": 0.6725,
        "profit": 337.50,
        "time": datetime.now().isoformat()
    },
    {
        "ticket": 1005,
        "symbol": "NZDUSD",
        "type": "sell",
        "volume": 1.0,
        "price": 0.5940,
        "profit": 100.0,
        "time": datetime.now().isoformat()
    }
]

# Store for dynamic data
store = {
    'account': MOCK_ACCOUNT.copy(),
    'trades': [t.copy() for t in MOCK_TRADES],
    'positions': [p.copy() for p in MOCK_POSITIONS]
}

# ==================== ROUTES ====================

@app.route('/api/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "ok",
        "backend": "development_mock",
        "mt5": "not_required",
        "timestamp": datetime.now().isoformat()
    })

@app.route('/api/account', methods=['GET'])
def get_account():
    """Get account information"""
    logger.info("GET /api/account")
    return jsonify(store['account'])

@app.route('/api/accounts', methods=['GET'])
def get_accounts():
    """Get all accounts"""
    logger.info("GET /api/accounts")
    return jsonify([store['account']])

@app.route('/api/positions', methods=['GET'])
def get_positions():
    """Get open positions"""
    logger.info("GET /api/positions")
    return jsonify(store['positions'])

@app.route('/api/trades', methods=['GET'])
def get_trades():
    """Get all trades"""
    logger.info("GET /api/trades")
    return jsonify(store['trades'])

@app.route('/api/trades/open', methods=['GET'])
def get_open_trades():
    """Get open trades only"""
    logger.info("GET /api/trades/open")
    open_trades = [t for t in store['trades'] if t['status'] == 'open']
    return jsonify(open_trades)

@app.route('/api/trades/closed', methods=['GET'])
def get_closed_trades():
    """Get closed trades only"""
    logger.info("GET /api/trades/closed")
    closed_trades = [t for t in store['trades'] if t['status'] == 'closed']
    return jsonify(closed_trades)

@app.route('/api/symbol/quote/<symbol>', methods=['GET'])
def get_symbol_quote(symbol):
    """Get current price for symbol"""
    logger.info(f"GET /api/symbol/quote/{symbol}")
    # Return mock price
    base_prices = {
        "EURUSD": 1.0975,
        "GBPUSD": 1.2680,
        "USDJPY": 145.80,
        "AUDUSD": 0.6725,
        "NZDUSD": 0.5940,
        "USDC": 1.00,
        "BTCUSD": 95000,
        "GOLD": 2050
    }
    price = base_prices.get(symbol, 1.0)
    # Add slight random movement
    price = price * (1 + random.uniform(-0.001, 0.001))
    return jsonify({"symbol": symbol, "bid": price * 0.9999, "ask": price * 1.0001})

@app.route('/api/trade', methods=['POST'])
def open_trade():
    """Open a new trade"""
    data = request.json
    logger.info(f"POST /api/trade - {data}")
    
    ticket = max([t['ticket'] for t in store['trades']], default=1000) + 1
    trade = {
        "ticket": ticket,
        "symbol": data.get('symbol', 'EURUSD'),
        "type": data.get('type', 'buy'),
        "volume": data.get('volume', 1.0),
        "open_price": data.get('open_price', 1.0950),
        "current_price": data.get('open_price', 1.0950),
        "open_time": datetime.now().isoformat(),
        "profit": 0.0,
        "status": "open"
    }
    
    store['trades'].append(trade)
    pos = {
        "ticket": ticket,
        "symbol": trade['symbol'],
        "type": trade['type'],
        "volume": trade['volume'],
        "price": trade['open_price'],
        "profit": 0.0,
        "time": datetime.now().isoformat()
    }
    store['positions'].append(pos)
    
    # Update account equity
    store['account']['equity'] += 10.0 + random.uniform(0, 100)
    store['account']['profit'] = store['account']['equity'] - store['account']['balance']
    
    return jsonify({"status": "success", "ticket": ticket, "trade": trade}), 201

@app.route('/api/trade/<int:ticket>/close', methods=['POST'])
def close_trade(ticket):
    """Close a trade"""
    data = request.json
    logger.info(f"POST /api/trade/{ticket}/close - {data}")
    
    for trade in store['trades']:
        if trade['ticket'] == ticket:
            trade['status'] = 'closed'
            trade['close_price'] = data.get('close_price', trade['open_price'])
            trade['close_time'] = datetime.now().isoformat()
            
            # Remove from positions
            store['positions'] = [p for p in store['positions'] if p['ticket'] != ticket]
            
            # Update account
            store['account']['equity'] -= 5.0
            store['account']['profit'] = store['account']['equity'] - store['account']['balance']
            
            return jsonify({"status": "success", "trade": trade})
    
    return jsonify({"error": "Trade not found"}), 404

@app.route('/api/connect', methods=['POST'])
def connect_to_broker():
    """Connect to broker (mock)"""
    data = request.json
    logger.info(f"POST /api/connect - {data}")
    return jsonify({
        "status": "connected",
        "broker": "MetaTrader 5",
        "account": store['account']['login'],
        "message": "Connected successfully (mock data)"
    })

@app.route('/api/disconnect', methods=['POST'])
def disconnect_broker():
    """Disconnect from broker (mock)"""
    logger.info("POST /api/disconnect")
    return jsonify({"status": "disconnected"})

@app.route('/api/statement', methods=['GET'])
def get_statement():
    """Get account statement"""
    logger.info("GET /api/statement")
    open_trades = [t for t in store['trades'] if t['status'] == 'open']
    closed_trades = [t for t in store['trades'] if t['status'] == 'closed']
    
    statement = {
        "account": store['account'],
        "total_trades": len(store['trades']),
        "open_trades": len(open_trades),
        "closed_trades": len(closed_trades),
        "winning_trades": len([t for t in closed_trades if t['profit'] > 0]),
        "losing_trades": len([t for t in closed_trades if t['profit'] < 0]),
        "total_profit": sum(t['profit'] for t in closed_trades),
        "total_loss": sum(t['profit'] for t in closed_trades if t['profit'] < 0),
        "win_rate": len([t for t in closed_trades if t['profit'] > 0]) / len(closed_trades) * 100 if closed_trades else 0,
        "timestamp": datetime.now().isoformat()
    }
    return jsonify(statement)

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({"error": "Endpoint not found"}), 404

@app.errorhandler(500)
def server_error(error):
    """Handle 500 errors"""
    logger.error(f"Server error: {error}")
    return jsonify({"error": "Internal server error"}), 500

# ==================== MAIN ====================

if __name__ == '__main__':
    logger.info("=" * 60)
    logger.info("Starting Zwesta Trading Backend (Development Mode)")
    logger.info("=" * 60)
    logger.info("[OK] Mock data enabled - No MT5 required")
    logger.info(f"[ACCOUNT] {MOCK_ACCOUNT['login']} | Balance: ${MOCK_ACCOUNT['balance']:,.2f}")
    logger.info(f"[TRADES] Open Trades: {len([t for t in MOCK_TRADES if t['status'] == 'open'])}")
    logger.info("=" * 60)
    logger.info("[START] Flask server starting on http://127.0.0.1:5000")
    
    app.run(host='127.0.0.1', port=5000, debug=False, use_reloader=False)
