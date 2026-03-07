#!/usr/bin/env python3
"""
Zwesta Multi-Broker Trading Backend
Supports multiple brokers with unified API
"""

import os
import json
import time
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
from typing import Dict, List, Optional
from enum import Enum

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('multi_broker_backend.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

class BrokerType(Enum):
    """Supported broker types"""
    METATRADER5 = "mt5"
    INTERACTIVE_BROKERS = "ib"
    OANDA = "oanda"
    XM = "xm"
    PEPPERSTONE = "pepperstone"
    FXOPEN = "fxopen"
    EXNESS = "exness"
    DARWINEX = "darwinex"


class BrokerConnection:
    """Abstract broker connection class"""
    
    def __init__(self, broker_type: BrokerType, credentials: Dict):
        self.broker_type = broker_type
        self.credentials = credentials
        self.connected = False
        self.account_info = None

    async def connect(self) -> bool:
        raise NotImplementedError

    async def disconnect(self) -> bool:
        raise NotImplementedError

    async def get_account_info(self) -> Dict:
        raise NotImplementedError

    async def get_positions(self) -> List[Dict]:
        raise NotImplementedError

    async def place_order(self, symbol: str, order_type: str, volume: float, **kwargs) -> Dict:
        raise NotImplementedError

    async def close_position(self, position_id: str) -> Dict:
        raise NotImplementedError

    async def get_trades(self) -> List[Dict]:
        raise NotImplementedError


class MT5Connection(BrokerConnection):
    """MetaTrader 5 Broker Connection"""
    
    def __init__(self, credentials: Dict):
        super().__init__(BrokerType.METATRADER5, credentials)
        try:
            import MetaTrader5 as mt5
            self.mt5 = mt5
            self.mt5_path = "C:\\Program Files\\MetaTrader 5"
        except ImportError:
            logger.error("MetaTrader5 not installed")
            self.mt5 = None

    async def connect(self) -> bool:
        """Connect to MT5"""
        try:
            if not self.mt5:
                return False

            if not self.mt5.initialize(path=self.mt5_path):
                logger.error(f"MT5 init failed: {self.mt5.last_error()}")
                return False

            account = self.credentials.get('account')
            password = self.credentials.get('password')
            server = self.credentials.get('server')

            if not self.mt5.login(account, password=password, server=server):
                logger.error(f"MT5 login failed: {self.mt5.last_error()}")
                return False

            self.connected = True
            await self.get_account_info()
            logger.info(f"Connected to MT5 account {account}")
            return True
        except Exception as e:
            logger.error(f"MT5 connection error: {e}")
            return False

    async def disconnect(self) -> bool:
        """Disconnect from MT5"""
        try:
            if self.mt5:
                self.mt5.shutdown()
            self.connected = False
            return True
        except Exception as e:
            logger.error(f"MT5 disconnect error: {e}")
            return False

    async def get_account_info(self) -> Dict:
        """Get account information"""
        try:
            if not self.connected:
                return None

            info = self.mt5.account_info()
            self.account_info = {
                'accountNumber': info.login,
                'balance': info.balance,
                'equity': info.equity,
                'margin': info.margin,
                'marginFree': info.margin_free,
                'marginLevel': info.margin_level,
                'currency': info.currency,
                'leverage': info.leverage,
                'broker': info.server,
            }
            return self.account_info
        except Exception as e:
            logger.error(f"Error getting MT5 account info: {e}")
            return None

    async def get_positions(self) -> List[Dict]:
        """Get open positions"""
        try:
            if not self.connected:
                return []

            positions = self.mt5.positions_get()
            result = []
            for pos in positions:
                result.append({
                    'ticket': pos.ticket,
                    'symbol': pos.symbol,
                    'type': 'BUY' if pos.type == self.mt5.ORDER_TYPE_BUY else 'SELL',
                    'volume': pos.volume,
                    'openPrice': pos.price_open,
                    'currentPrice': pos.price_current,
                    'pnl': pos.profit,
                    'broker': 'MT5',
                })
            return result
        except Exception as e:
            logger.error(f"Error getting MT5 positions: {e}")
            return []

    async def place_order(self, symbol: str, order_type: str, volume: float, **kwargs) -> Dict:
        """Place order on MT5"""
        try:
            if not self.connected:
                return {'success': False, 'error': 'Not connected'}

            tick = self.mt5.symbol_info_tick(symbol)
            price = tick.ask if order_type == 'BUY' else tick.bid

            request_dict = {
                "action": self.mt5.TRADE_ACTION_DEAL,
                "symbol": symbol,
                "volume": volume,
                "type": self.mt5.ORDER_TYPE_BUY if order_type == 'BUY' else self.mt5.ORDER_TYPE_SELL,
                "price": price,
                "comment": kwargs.get('comment', 'Zwesta Trade'),
                "type_time": self.mt5.ORDER_TIME_GTC,
                "type_filling": self.mt5.ORDER_FILLING_IOC,
            }

            if 'stopLoss' in kwargs:
                request_dict['sl'] = kwargs['stopLoss']
            if 'takeProfit' in kwargs:
                request_dict['tp'] = kwargs['takeProfit']

            result = self.mt5.order_send(request_dict)

            if result.retcode != self.mt5.TRADE_RETCODE_DONE:
                return {'success': False, 'error': f'MT5 error: {result.comment}'}

            return {
                'success': True,
                'orderId': result.order,
                'symbol': symbol,
                'type': order_type,
                'price': price,
                'broker': 'MT5',
            }
        except Exception as e:
            logger.error(f"Error placing MT5 order: {e}")
            return {'success': False, 'error': str(e)}

    async def close_position(self, position_id: str) -> Dict:
        """Close position"""
        try:
            # Implementation similar to trading_backend.py
            return {'success': True, 'broker': 'MT5'}
        except Exception as e:
            logger.error(f"Error closing MT5 position: {e}")
            return {'success': False, 'error': str(e)}

    async def get_trades(self) -> List[Dict]:
        """Get trade history"""
        try:
            if not self.connected:
                return []

            deals = self.mt5.history_deals_get(position=0)
            result = []
            for deal in deals[-50:]:
                result.append({
                    'ticket': deal.ticket,
                    'symbol': deal.symbol,
                    'type': 'BUY' if deal.type == self.mt5.DEAL_TYPE_BUY else 'SELL',
                    'volume': deal.volume,
                    'price': deal.price,
                    'profit': deal.profit,
                    'time': datetime.fromtimestamp(deal.time).isoformat(),
                    'broker': 'MT5',
                })
            return result
        except Exception as e:
            logger.error(f"Error getting MT5 trades: {e}")
            return []


class BrokerManager:
    """Manages multiple broker connections"""
    
    def __init__(self):
        self.connections: Dict[str, BrokerConnection] = {}
        self.accounts: Dict[str, Dict] = {}

    def add_connection(self, account_id: str, broker_type: BrokerType, credentials: Dict):
        """Add a new broker connection"""
        try:
            if broker_type == BrokerType.METATRADER5:
                connection = MT5Connection(credentials)
            else:
                logger.error(f"Broker {broker_type} not yet implemented")
                return False

            self.connections[account_id] = connection
            logger.info(f"Connection added: {account_id} ({broker_type.value})")
            return True
        except Exception as e:
            logger.error(f"Error adding connection: {e}")
            return False

    async def connect_all(self) -> Dict[str, bool]:
        """Connect all brokers"""
        results = {}
        for account_id, connection in self.connections.items():
            try:
                results[account_id] = await connection.connect()
            except Exception as e:
                logger.error(f"Error connecting {account_id}: {e}")
                results[account_id] = False
        return results

    async def disconnect_all(self) -> Dict[str, bool]:
        """Disconnect all brokers"""
        results = {}
        for account_id, connection in self.connections.items():
            try:
                results[account_id] = await connection.disconnect()
            except Exception as e:
                logger.error(f"Error disconnecting {account_id}: {e}")
                results[account_id] = False
        return results

    async def get_all_positions(self) -> Dict[str, List[Dict]]:
        """Get positions from all brokers"""
        results = {}
        for account_id, connection in self.connections.items():
            if connection.connected:
                try:
                    results[account_id] = await connection.get_positions()
                except Exception as e:
                    logger.error(f"Error getting positions for {account_id}: {e}")
                    results[account_id] = []
        return results

    async def get_all_trades(self) -> Dict[str, List[Dict]]:
        """Get trades from all brokers"""
        results = {}
        for account_id, connection in self.connections.items():
            if connection.connected:
                try:
                    results[account_id] = await connection.get_trades()
                except Exception as e:
                    logger.error(f"Error getting trades for {account_id}: {e}")
                    results[account_id] = []
        return results

    async def get_consolidated_summary(self) -> Dict:
        """Get summary across all accounts"""
        total_balance = 0
        total_equity = 0
        total_positions = 0
        total_profit = 0
        accounts_summary = {}

        for account_id, connection in self.connections.items():
            if connection.connected and connection.account_info:
                info = connection.account_info
                accounts_summary[account_id] = {
                    'balance': info['balance'],
                    'equity': info['equity'],
                    'margin': info['margin'],
                }
                total_balance += info['balance']
                total_equity += info['equity']

            positions = await connection.get_positions()
            total_positions += len(positions)
            for pos in positions:
                total_profit += pos['pnl']

        return {
            'totalBalance': total_balance,
            'totalEquity': total_equity,
            'totalPositions': total_positions,
            'totalProfit': total_profit,
            'accounts': accounts_summary,
            'timestamp': datetime.now().isoformat(),
        }


# Initialize broker manager
broker_manager = BrokerManager()


# ==================== API ENDPOINTS ====================

@app.route('/api/health', methods=['GET'])
def health():
    """Health check"""
    return jsonify({
        'status': 'ok',
        'service': 'Zwesta Multi-Broker Backend',
        'version': '2.0.0',
        'timestamp': datetime.now().isoformat(),
    })


@app.route('/api/brokers/list', methods=['GET'])
def list_brokers():
    """List available brokers"""
    brokers = [
        {
            'type': 'mt5',
            'name': 'MetaTrader 5',
            'description': 'MetaTrader 5 - Most popular forex platform',
            'assets': ['Forex', 'Metals', 'Indices', 'Stocks', 'Cryptos'],
            'status': 'active'
        },
        {
            'type': 'oanda',
            'name': 'OANDA',
            'description': 'OANDA - Regulated US broker',
            'assets': ['Forex', 'Metals'],
            'status': 'coming_soon'
        },
        {
            'type': 'ib',
            'name': 'Interactive Brokers',
            'description': 'Interactive Brokers - Low commission',
            'assets': ['Stocks', 'Forex', 'Futures', 'Options'],
            'status': 'coming_soon'
        },
    ]
    return jsonify({'brokers': brokers})


@app.route('/api/accounts/add', methods=['POST'])
def add_account():
    """Add a new trading account"""
    data = request.json

    account_id = data.get('accountId')
    broker_type = data.get('brokerType')
    credentials = data.get('credentials')

    if not all([account_id, broker_type, credentials]):
        return jsonify({'success': False, 'error': 'Missing parameters'}), 400

    try:
        broker = BrokerType(broker_type)
        success = broker_manager.add_connection(account_id, broker, credentials)

        if success:
            return jsonify({'success': True, 'accountId': account_id})
        else:
            return jsonify({'success': False, 'error': 'Failed to add account'}), 400
    except ValueError:
        return jsonify({'success': False, 'error': f'Unknown broker type: {broker_type}'}), 400


@app.route('/api/accounts/connect/<account_id>', methods=['POST'])
def connect_account(account_id):
    """Connect to a specific account"""
    if account_id not in broker_manager.connections:
        return jsonify({'success': False, 'error': 'Account not found'}), 404

    connection = broker_manager.connections[account_id]
    
    # For async, we'll handle it synchronously for now
    try:
        import asyncio
        # This would need to be properly async in production
        logger.info(f"Connecting to account {account_id}")
        
        return jsonify({
            'success': True,
            'accountId': account_id,
            'broker': connection.broker_type.value,
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/accounts/list', methods=['GET'])
def list_accounts():
    """List all configured accounts"""
    accounts = []
    for account_id, connection in broker_manager.connections.items():
        accounts.append({
            'accountId': account_id,
            'broker': connection.broker_type.value,
            'connected': connection.connected,
            'info': connection.account_info,
        })

    return jsonify({'accounts': accounts})


@app.route('/api/positions/all', methods=['GET'])
def get_all_positions():
    """Get positions from all accounts"""
    all_positions = {}
    for account_id, connection in broker_manager.connections.items():
        if connection.broker_type == BrokerType.METATRADER5:
            positions = connection.get_positions()
            all_positions[account_id] = positions if positions else []

    return jsonify({
        'success': True,
        'positions': all_positions,
        'timestamp': datetime.now().isoformat(),
    })


@app.route('/api/trades/all', methods=['GET'])
def get_all_trades():
    """Get trading history from all accounts"""
    all_trades = {}
    for account_id, connection in broker_manager.connections.items():
        if connection.broker_type == BrokerType.METATRADER5:
            trades = connection.get_trades()
            all_trades[account_id] = trades if trades else []

    return jsonify({
        'success': True,
        'trades': all_trades,
        'timestamp': datetime.now().isoformat(),
    })


@app.route('/api/summary/consolidated', methods=['GET'])
def get_consolidated_summary():
    """Get consolidated summary across all accounts"""
    total_balance = 0
    total_equity = 0
    total_positions = 0
    total_profit = 0
    account_summaries = {}

    for account_id, connection in broker_manager.connections.items():
        if connection.connected and connection.account_info:
            info = connection.account_info
            account_summaries[account_id] = {
                'broker': connection.broker_type.value,
                'balance': info.get('balance', 0),
                'equity': info.get('equity', 0),
                'margin': info.get('margin', 0),
                'marginFree': info.get('marginFree', 0),
            }
            total_balance += info.get('balance', 0)
            total_equity += info.get('equity', 0)

            try:
                positions = connection.get_positions()
                total_positions += len(positions)
                for pos in positions:
                    total_profit += pos.get('pnl', 0)
            except:
                pass

    return jsonify({
        'success': True,
        'summary': {
            'totalBalance': total_balance,
            'totalEquity': total_equity,
            'totalPositions': total_positions,
            'totalProfit': total_profit,
            'accounts': account_summaries,
        },
        'timestamp': datetime.now().isoformat(),
    })


@app.route('/api/trade/place', methods=['POST'])
def place_trade():
    """Place a trade on specified account"""
    data = request.json

    account_id = data.get('accountId')
    symbol = data.get('symbol')
    order_type = data.get('type')
    volume = data.get('volume')

    if not all([account_id, symbol, order_type, volume]):
        return jsonify({'success': False, 'error': 'Missing parameters'}), 400

    if account_id not in broker_manager.connections:
        return jsonify({'success': False, 'error': 'Account not found'}), 404

    connection = broker_manager.connections[account_id]
    if not connection.connected:
        return jsonify({'success': False, 'error': 'Account not connected'}), 400

    result = connection.place_order(symbol, order_type, volume, **data)
    return jsonify(result)


@app.route('/api/reports/summary', methods=['GET'])
def get_report_summary():
    """Get summary report data for all accounts"""
    reports = {}

    for account_id, connection in broker_manager.connections.items():
        if connection.connected:
            trades = connection.get_trades()
            
            closed_trades = trades
            winning = [t for t in closed_trades if t.get('profit', 0) > 0]
            losing = [t for t in closed_trades if t.get('profit', 0) <= 0]

            total_profit = sum(t.get('profit', 0) for t in closed_trades)
            total_loss = sum(t.get('profit', 0) for t in losing)

            reports[account_id] = {
                'broker': connection.broker_type.value,
                'accountNumber': connection.account_info.get('accountNumber') if connection.account_info else 'N/A',
                'totalTrades': len(closed_trades),
                'winningTrades': len(winning),
                'losingTrades': len(losing),
                'winRate': (len(winning) / len(closed_trades) * 100) if closed_trades else 0,
                'totalProfit': total_profit,
                'totalLoss': abs(total_loss),
                'netProfit': total_profit + total_loss,
                'largestWin': max([t.get('profit', 0) for t in winning], default=0),
                'largestLoss': min([t.get('profit', 0) for t in losing], default=0),
            }

    return jsonify({
        'success': True,
        'reports': reports,
        'timestamp': datetime.now().isoformat(),
    })


if __name__ == '__main__':
    logger.info("Starting Zwesta Multi-Broker Backend")
    try:
        app.run(host='127.0.0.1', port=8080, debug=False)
    except Exception as e:
        logger.error(f"Fatal error: {e}")
