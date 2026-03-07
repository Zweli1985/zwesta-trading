#!/usr/bin/env python3
"""
Zwesta Trading System - MetaTrader 5 Backend
Handles live trading execution, account management, and bot strategies
"""

import os
import json
import time
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
import MetaTrader5 as mt5
from typing import Dict, List, Optional
import threading
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('trading_backend.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Configuration
MT5_PATH = "C:\\Program Files\\XM Global MT5"
API_KEY = "your_api_key_here"
DEMO_ACCOUNT = 104017418
DEMO_PASSWORD = "*6RjhRvH"
DEMO_SERVER = "MetaQuotes-Demo"

class MT5Manager:
    """Manages MetaTrader 5 connection and trading operations"""
    
    def __init__(self):
        self.connected = False
        self.connected_account = None
        self.trades = []
        self.positions = []
        self.accounts_cache = {}
        
    def initialize(self):
        """Initialize MetaTrader 5"""
        try:
            if not mt5.initialize(path=MT5_PATH):
                logger.error(f"MT5 initialization failed: {mt5.last_error()}")
                return False
            logger.info("MT5 initialized successfully")
            self.connected = True
            return True
        except Exception as e:
            logger.error(f"MT5 initialization error: {e}")
            return False
    
    def connect_account(self, account: int, password: str, server: str) -> Dict:
        """Connect to MT5 account"""
        try:
            if not self.connected:
                if not self.initialize():
                    return {
                        'success': False,
                        'message': 'Failed to initialize MT5',
                        'error': 'INIT_FAILED'
                    }
            
            # Connect to account
            if not mt5.login(account, password=password, server=server):
                error = mt5.last_error()
                logger.error(f"Login failed for account {account}: {error}")
                return {
                    'success': False,
                    'message': f'Login failed: {error}',
                    'error': 'AUTH_FAILED'
                }
            
            self.connected_account = account
            
            # Get account info
            account_info = mt5.account_info()
            if not account_info:
                return {
                    'success': False,
                    'message': 'Failed to get account info',
                    'error': 'ACCOUNT_INFO_FAILED'
                }
            
            logger.info(f"Connected to MT5 account {account}")
            
            return {
                'success': True,
                'account': {
                    'accountNumber': account_info.login,
                    'balance': account_info.balance,
                    'equity': account_info.equity,
                    'margin': account_info.margin,
                    'marginFree': account_info.margin_free,
                    'marginLevel': account_info.margin_level,
                    'marginUsed': account_info.margin_used,
                    'currency': account_info.currency,
                    'leverage': account_info.leverage,
                    'broker': account_info.server,
                    'isDemo': account_info.trade_mode == mt5.ACCOUNT_TRADE_MODE_DEMO,
                }
            }
        except Exception as e:
            logger.error(f"Connection error: {e}")
            return {
                'success': False,
                'message': str(e),
                'error': 'EXCEPTION'
            }
    
    def get_account_info(self) -> Optional[Dict]:
        """Get current account information"""
        try:
            if not self.connected_account:
                return None
            
            account_info = mt5.account_info()
            if not account_info:
                return None
            
            return {
                'accountNumber': account_info.login,
                'balance': account_info.balance,
                'equity': account_info.equity,
                'margin': account_info.margin,
                'marginFree': account_info.margin_free,
                'marginLevel': account_info.margin_level,
                'marginUsed': account_info.margin_used,
                'currency': account_info.currency,
                'leverage': account_info.leverage,
                'broker': account_info.server,
                'isDemo': account_info.trade_mode == mt5.ACCOUNT_TRADE_MODE_DEMO,
                'timestamp': datetime.now().isoformat(),
            }
        except Exception as e:
            logger.error(f"Error getting account info: {e}")
            return None
    
    def get_positions(self) -> List[Dict]:
        """Get all open positions"""
        try:
            if not self.connected_account:
                return []
            
            positions = mt5.positions_get()
            if not positions:
                return []
            
            result = []
            for pos in positions:
                result.append({
                    'ticket': pos.ticket,
                    'symbol': pos.symbol,
                    'type': 'BUY' if pos.type == mt5.ORDER_TYPE_BUY else 'SELL',
                    'volume': pos.volume,
                    'openPrice': pos.price_open,
                    'currentPrice': pos.price_current,
                    'pnl': pos.profit,
                    'openTime': datetime.fromtimestamp(pos.time).isoformat(),
                    'comment': pos.comment,
                })
            return result
        except Exception as e:
            logger.error(f"Error getting positions: {e}")
            return []
    
    def place_trade(self, symbol: str, order_type: str, volume: float, 
                   price: Optional[float] = None, sl: Optional[float] = None,
                   tp: Optional[float] = None, comment: str = "") -> Dict:
        """Place a trade order"""
        try:
            if not self.connected_account:
                return {
                    'success': False,
                    'message': 'Not connected to trading account',
                    'error': 'NOT_CONNECTED'
                }
            
            # Get current price
            tick = mt5.symbol_info_tick(symbol)
            if not tick:
                return {
                    'success': False,
                    'message': f'Could not get price for {symbol}',
                    'error': 'SYMBOL_NOT_FOUND'
                }
            
            # Prepare order
            order_type_mt5 = mt5.ORDER_TYPE_BUY if order_type.upper() == 'BUY' else mt5.ORDER_TYPE_SELL
            price = tick.ask if order_type.upper() == 'BUY' else tick.bid
            
            request_dict = {
                "action": mt5.TRADE_ACTION_DEAL,
                "symbol": symbol,
                "volume": volume,
                "type": order_type_mt5,
                "price": price,
                "comment": comment,
                "type_time": mt5.ORDER_TIME_GTC,
                "type_filling": mt5.ORDER_FILLING_IOC,
            }
            
            if sl:
                request_dict["sl"] = sl
            if tp:
                request_dict["tp"] = tp
            
            # Send order
            result = mt5.order_send(request_dict)
            
            if result.retcode != mt5.TRADE_RETCODE_DONE:
                return {
                    'success': False,
                    'message': f'Order failed: {result.comment}',
                    'error': f'MT5_ERROR_{result.retcode}',
                    'retcode': result.retcode,
                }
            
            logger.info(f"Trade placed: {order_type} {volume} {symbol} @ {price}")
            
            return {
                'success': True,
                'orderId': result.order,
                'ticket': result.order,
                'symbol': symbol,
                'type': order_type,
                'volume': volume,
                'price': price,
                'timestamp': datetime.now().isoformat(),
            }
        except Exception as e:
            logger.error(f"Error placing trade: {e}")
            return {
                'success': False,
                'message': str(e),
                'error': 'EXCEPTION'
            }
    
    def close_position(self, ticket: int) -> Dict:
        """Close an open position"""
        try:
            if not self.connected_account:
                return {
                    'success': False,
                    'message': 'Not connected to trading account',
                    'error': 'NOT_CONNECTED'
                }
            
            # Get position
            position = None
            positions = mt5.positions_get(ticket=ticket)
            if positions:
                position = positions[0]
            else:
                return {
                    'success': False,
                    'message': f'Position {ticket} not found',
                    'error': 'POSITION_NOT_FOUND'
                }
            
            # Create close order
            order_type = mt5.ORDER_TYPE_SELL if position.type == mt5.ORDER_TYPE_BUY else mt5.ORDER_TYPE_BUY
            
            tick = mt5.symbol_info_tick(position.symbol)
            price = tick.bid if position.type == mt5.ORDER_TYPE_BUY else tick.ask
            
            request_dict = {
                "action": mt5.TRADE_ACTION_DEAL,
                "symbol": position.symbol,
                "volume": position.volume,
                "type": order_type,
                "price": price,
                "position": ticket,
                "comment": f"Close position {ticket}",
                "type_time": mt5.ORDER_TIME_GTC,
                "type_filling": mt5.ORDER_FILLING_IOC,
            }
            
            result = mt5.order_send(request_dict)
            
            if result.retcode != mt5.TRADE_RETCODE_DONE:
                return {
                    'success': False,
                    'message': f'Close failed: {result.comment}',
                    'error': f'MT5_ERROR_{result.retcode}'
                }
            
            logger.info(f"Position closed: {ticket}")
            
            return {
                'success': True,
                'ticket': ticket,
                'closePrice': price,
                'timestamp': datetime.now().isoformat(),
            }
        except Exception as e:
            logger.error(f"Error closing position: {e}")
            return {
                'success': False,
                'message': str(e),
                'error': 'EXCEPTION'
            }
    
    def get_trades(self) -> List[Dict]:
        """Get trading history"""
        try:
            if not self.connected_account:
                return []
            
            deals = mt5.history_deals_get(position=0)
            if not deals:
                return []
            
            result = []
            for deal in deals[-20:]:  # Last 20 deals
                result.append({
                    'ticket': deal.ticket,
                    'symbol': deal.symbol,
                    'type': 'BUY' if deal.type == mt5.DEAL_TYPE_BUY else 'SELL',
                    'volume': deal.volume,
                    'price': deal.price,
                    'commission': deal.commission,
                    'profit': deal.profit,
                    'time': datetime.fromtimestamp(deal.time).isoformat(),
                    'comment': deal.comment,
                })
            return result
        except Exception as e:
            logger.error(f"Error getting trades: {e}")
            return []
    
    def shutdown(self):
        """Shutdown MT5"""
        try:
            mt5.shutdown()
            self.connected = False
            logger.info("MT5 shutdown")
        except Exception as e:
            logger.error(f"Error shutting down MT5: {e}")


# Initialize MT5 Manager
mt5_manager = MT5Manager()


# ==================== API ENDPOINTS ====================

@app.route('/api/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'service': 'Zwesta Trading Backend',
        'version': '1.0.0',
        'timestamp': datetime.now().isoformat(),
    })


@app.route('/api/account/connect', methods=['POST'])
def connect_account():
    """Connect to MT5 trading account"""
    data = request.json
    
    account = data.get('account', DEMO_ACCOUNT)
    password = data.get('password', DEMO_PASSWORD)
    server = data.get('server', DEMO_SERVER)
    
    result = mt5_manager.connect_account(account, password, server)
    return jsonify(result)


@app.route('/api/account/info', methods=['GET'])
def get_account_info():
    """Get current account information"""
    info = mt5_manager.get_account_info()
    
    if not info:
        return jsonify({
            'success': False,
            'message': 'Not connected to account',
            'error': 'NOT_CONNECTED'
        }), 400
    
    return jsonify({
        'success': True,
        'account': info
    })


@app.route('/api/positions', methods=['GET'])
def get_positions():
    """Get all open positions"""
    positions = mt5_manager.get_positions()
    
    return jsonify({
        'success': True,
        'positions': positions,
        'count': len(positions),
        'timestamp': datetime.now().isoformat(),
    })


@app.route('/api/trades', methods=['GET'])
def get_trades():
    """Get trading history"""
    trades = mt5_manager.get_trades()
    
    return jsonify({
        'success': True,
        'trades': trades,
        'count': len(trades),
        'timestamp': datetime.now().isoformat(),
    })


@app.route('/api/trade/place', methods=['POST'])
def place_trade():
    """Place a new trade order"""
    data = request.json
    
    symbol = data.get('symbol', 'EURUSD')
    order_type = data.get('type', 'BUY')
    volume = data.get('volume', 0.1)
    sl = data.get('stopLoss')
    tp = data.get('takeProfit')
    comment = data.get('comment', 'Zwesta Trade')
    
    result = mt5_manager.place_trade(symbol, order_type, volume, sl=sl, tp=tp, comment=comment)
    return jsonify(result)


@app.route('/api/trade/close', methods=['POST'])
def close_trade():
    """Close an open position"""
    data = request.json
    ticket = data.get('ticket')
    
    if not ticket:
        return jsonify({
            'success': False,
            'message': 'Ticket ID required',
            'error': 'MISSING_PARAM'
        }), 400
    
    result = mt5_manager.close_position(ticket)
    return jsonify(result)


@app.route('/api/bot/status', methods=['GET'])
def bot_status():
    """Get bot trading status"""
    account_info = mt5_manager.get_account_info()
    positions = mt5_manager.get_positions()
    
    if not account_info:
        return jsonify({
            'success': False,
            'message': 'Not connected',
            'error': 'NOT_CONNECTED'
        }), 400
    
    return jsonify({
        'success': True,
        'status': 'running' if mt5_manager.connected else 'stopped',
        'account': account_info['accountNumber'],
        'balance': account_info['balance'],
        'equity': account_info['equity'],
        'activePositions': len(positions),
        'marginLevel': account_info['marginLevel'],
        'timestamp': datetime.now().isoformat(),
    })


@app.route('/api/symbols', methods=['GET'])
def get_symbols():
    """Get available trading symbols"""
    try:
        symbols = mt5.symbols_get()
        if not symbols:
            return jsonify({
                'success': True,
                'symbols': [
                    'EURUSD', 'GBPUSD', 'USDJPY', 'AUDUSD', 'NZDUSD',
                    'USDCAD', 'USDHKD', 'USDSGD', 'USDCHF', 'EURGBP'
                ]
            })
        
        symbol_list = [s.name for s in symbols[:50]]
        return jsonify({
            'success': True,
            'symbols': symbol_list
        })
    except Exception as e:
        return jsonify({
            'success': True,
            'symbols': [
                'EURUSD', 'GBPUSD', 'USDJPY', 'AUDUSD', 'NZDUSD',
                'USDCAD', 'USDHKD', 'USDSGD', 'USDCHF', 'EURGBP'
            ]
        })


if __name__ == '__main__':
    logger.info("Starting Zwesta Trading Backend")
    logger.info(f"MT5 Path: {MT5_PATH}")
    
    try:
        # Initialize MT5 on startup
        if mt5_manager.initialize():
            logger.info("MT5 initialized on startup")
        
        # Start Flask app
        app.run(host='127.0.0.1', port=8080, debug=False)
    except Exception as e:
        logger.error(f"Fatal error: {e}")
    finally:
        mt5_manager.shutdown()
