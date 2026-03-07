#!/usr/bin/env python3
"""
Intelligent Trading Backend with Strategy Switching & Dynamic Position Sizing
Zwesta - Advanced Bot Platform
"""

import os
import json
import time
from datetime import datetime, timedelta
from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
from typing import Dict, List, Optional, Tuple
from enum import Enum
import random
import math

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('intelligent_trading_backend.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# ==================== XM GLOBAL CONFIGURATION ====================
# MT5 Demo Account (Testing)
MT5_DEMO_CONFIG = {
    'account': 104017418,
    'password': '*6RjhRvH',
    'server': 'MetaQuotes-Demo',
    'path': 'C:\\Program Files\\XM Global MT5',
    'mode': 'demo',
    'accountType': 'XM Global Demo',
    'leverage': 1000,
    'initialBalance': 10000.0,
}

# MT5 Live Account (Production)
# User should update these with their real credentials
MT5_LIVE_CONFIG = {
    'account': None,  # User provides their live account
    'password': None,  # User provides their password
    'server': 'XMGlobal-Real',
    'path': 'C:\\Program Files\\XM Global MT5',
    'mode': 'live',
    'accountType': 'XM Global Live',
    'leverage': 1000,
    'initialBalance': 0,  # Will fetch from MT5
}

# Current configuration (can be toggled between demo and live)
CURRENT_CONFIG = MT5_DEMO_CONFIG.copy()


# ==================== STRATEGY PERFORMANCE TRACKING ====================
class StrategyStats:
    """Tracks performance metrics for each strategy"""
    
    def __init__(self, name: str):
        self.name = name
        self.total_trades = 0
        self.winning_trades = 0
        self.losing_trades = 0
        self.gross_profit = 0.0
        self.gross_loss = 0.0
        self.peak_profit = 0.0
        self.peak_equity = 10000.0  # Starting equity
        self.max_drawdown = 0.0
        self.trades_24h = 0  # Trades in last 24 hours
        self.profit_24h = 0.0
        self.win_streak = 0
        self.loss_streak = 0
        self.consecutive_losses = 0
        self.last_trade_time = None
        self.trade_history = []
        
    def add_trade(self, profit: float, timestamp: datetime = None):
        """Record a trade"""
        if timestamp is None:
            timestamp = datetime.now()
            
        self.total_trades += 1
        
        if profit > 0:
            self.winning_trades += 1
            self.gross_profit += profit
            self.win_streak += 1
            self.loss_streak = 0
            self.consecutive_losses = 0
        else:
            self.losing_trades += 1
            self.gross_loss += abs(profit)
            self.loss_streak += 1
            self.win_streak = 0
            self.consecutive_losses += 1
        
        # Update peak and drawdown
        equity = self.gross_profit - self.gross_loss
        if equity > self.peak_equity:
            self.peak_equity = equity
        
        drawdown = self.peak_equity - equity
        if drawdown > self.max_drawdown:
            self.max_drawdown = drawdown
        
        # Track 24h
        if (datetime.now() - timestamp).total_seconds() < 86400:
            self.trades_24h += 1
            self.profit_24h += profit
        
        self.last_trade_time = timestamp
        self.trade_history.append({'timestamp': timestamp, 'profit': profit})
    
    def get_win_rate(self) -> float:
        """Calculate win rate percentage"""
        if self.total_trades == 0:
            return 0.0
        return (self.winning_trades / self.total_trades) * 100
    
    def get_profit_factor(self) -> float:
        """Calculate profit factor"""
        if self.gross_loss == 0:
            return 99.99 if self.gross_profit > 0 else 0
        return min(self.gross_profit / self.gross_loss, 99.99)
    
    def get_expectancy(self) -> float:
        """Calculate average profit per trade"""
        if self.total_trades == 0:
            return 0.0
        net_profit = self.gross_profit - self.gross_loss
        return net_profit / self.total_trades
    
    def get_sharpe_ratio(self) -> float:
        """Approximate Sharpe ratio (trades must have volatility)"""
        if len(self.trade_history) < 2:
            return 0.0
        
        returns = [t['profit'] for t in self.trade_history]
        avg_return = sum(returns) / len(returns)
        
        if avg_return == 0:
            return 0.0
        
        variance = sum((r - avg_return) ** 2 for r in returns) / len(returns)
        std_dev = math.sqrt(variance)
        
        if std_dev == 0:
            return 0.0
        
        return avg_return / std_dev
    
    def to_dict(self) -> Dict:
        """Convert stats to dictionary"""
        return {
            'name': self.name,
            'totalTrades': self.total_trades,
            'winningTrades': self.winning_trades,
            'losingTrades': self.losing_trades,
            'grossProfit': round(self.gross_profit, 2),
            'grossLoss': round(self.gross_loss, 2),
            'netProfit': round(self.gross_profit - self.gross_loss, 2),
            'winRate': round(self.get_win_rate(), 2),
            'profitFactor': round(self.get_profit_factor(), 2),
            'expectancy': round(self.get_expectancy(), 2),
            'sharpeRatio': round(self.get_sharpe_ratio(), 2),
            'maxDrawdown': round(self.max_drawdown, 2),
            'trades24h': self.trades_24h,
            'profit24h': round(self.profit_24h, 2),
            'winStreak': self.win_streak,
            'lossStreak': self.loss_streak,
            'lastTradeTime': self.last_trade_time.isoformat() if self.last_trade_time else None,
        }


# ==================== DYNAMIC POSITION SIZING ====================
class PositionSizer:
    """Calculates optimal position size based on multiple factors"""
    
    def __init__(self, account_equity: float, risk_per_trade: float = 100):
        self.account_equity = account_equity
        self.risk_per_trade = risk_per_trade
        self.base_size = 0.1  # Base lot size
        self.min_size = 0.01
        self.max_size = 10.0
        
    def calculate_size(self, 
                      equity_change: float = 1.0,  # Current equity / initial equity
                      win_streak: int = 0,
                      loss_streak: int = 0,
                      volatility_factor: float = 1.0,  # market volatility multiplier
                      consecutive_losses: int = 0,
                      profit_factor: float = 1.0) -> float:
        """
        Calculate optimal position size
        
        Args:
            equity_change: Ratio of current equity to initial equity
            win_streak: Current winning trades in a row
            loss_streak: Current losing trades in a row
            volatility_factor: 1.0 = normal, >1.0 = high volatility, <1.0 = low
            consecutive_losses: Number of consecutive losing trades
            profit_factor: Strategy's profit factor (gross_profit / gross_loss)
        
        Returns:
            Position size in lots
        """
        size = self.base_size
        
        # 1. Scale by account equity growth/loss (most important)
        size *= equity_change
        
        # 2. Reduce size if consecutive losses
        if consecutive_losses >= 3:
            loss_reduction = 0.5 ** (consecutive_losses - 2)  # 0.5, 0.25, 0.125...
            size *= loss_reduction
        elif win_streak > 0:
            # Increase by 5% per win (but capped)
            size *= (1.0 + (win_streak * 0.05))
        
        # 3. Reduce in high volatility
        size *= (2.0 - volatility_factor)  # If volatility=2.0, size *= 0.0; if volatility=1.0, size *= 1.0
        
        # 4. Adjust based on profit factor
        # If strategy is losing money, reduce size
        if profit_factor < 1.0:
            size *= (0.5 + (profit_factor * 0.5))  # 0.5 when PF=0, 1.0 when PF=1.0
        
        # 5. Enforce limits
        size = max(self.min_size, min(size, self.max_size))
        
        return round(size, 2)


# ==================== INTELLIGENT STRATEGY SWITCHING ====================
class IntelligentStrategyManager:
    """Manages multiple strategies and switches between them"""
    
    def __init__(self):
        self.strategies = {}
        self.strategy_stats = {}
        self.current_strategy = 'trend_following'
        self.switch_history = []
        self.last_switch_time = None
        self.min_switch_interval = 300  # 5 minutes between switches
        
    def register_strategy(self, name: str):
        """Register a strategy for tracking"""
        self.strategy_stats[name] = StrategyStats(name)
        self.strategies[name] = True
        logger.info(f"Registered strategy: {name}")
    
    def record_trade(self, strategy_name: str, profit: float):
        """Record a trade result for a strategy"""
        if strategy_name in self.strategy_stats:
            self.strategy_stats[strategy_name].add_trade(profit)
    
    def get_best_strategy(self) -> Tuple[str, Dict]:
        """
        Determine best performing strategy
        Uses weighted scoring: profit_factor (40%) + win_rate (30%) + sharpe_ratio (30%)
        """
        if not self.strategy_stats:
            return self.current_strategy, {}
        
        best_strategy = None
        best_score = -float('inf')
        
        for name, stats in self.strategy_stats.items():
            # Calculate weighted score
            pf_score = min(stats.get_profit_factor(), 5) / 5 * 40  # Cap at 5.0 PF
            wr_score = stats.get_win_rate() / 100 * 30
            sharpe_score = min(stats.get_sharpe_ratio(), 2) / 2 * 30  # Cap at 2.0 Sharpe
            
            total_score = pf_score + wr_score + sharpe_score
            
            logger.info(f"Strategy {name}: PF={stats.get_profit_factor():.2f}, "
                       f"WR={stats.get_win_rate():.2f}%, Sharpe={stats.get_sharpe_ratio():.2f}, "
                       f"Score={total_score:.2f}")
            
            if total_score > best_score:
                best_score = total_score
                best_strategy = name
        
        return best_strategy or self.current_strategy, self.strategy_stats.get(best_strategy, {})
    
    def try_switch_strategy(self, bot_id: str) -> Tuple[bool, str, str]:
        """
        Attempt to switch to best performing strategy
        
        Returns:
            (switched: bool, old_strategy: str, new_strategy: str)
        """
        # Check minimum interval between switches
        if self.last_switch_time:
            elapsed = (datetime.now() - self.last_switch_time).total_seconds()
            if elapsed < self.min_switch_interval:
                return False, self.current_strategy, self.current_strategy
        
        best_strategy, stats = self.get_best_strategy()
        
        if best_strategy != self.current_strategy:
            old_strategy = self.current_strategy
            self.current_strategy = best_strategy
            self.last_switch_time = datetime.now()
            
            self.switch_history.append({
                'timestamp': datetime.now().isoformat(),
                'botId': bot_id,
                'from': old_strategy,
                'to': best_strategy,
                'reason': f"Better performance (Profit Factor: {stats.get('profitFactor', 0):.2f})"
            })
            
            logger.info(f"Bot {bot_id}: Switched from {old_strategy} to {best_strategy}")
            return True, old_strategy, best_strategy
        
        return False, self.current_strategy, self.current_strategy


# ==================== STRATEGY IMPLEMENTATIONS ====================

strategy_manager = IntelligentStrategyManager()

def trend_following_strategy(symbol: str, account_id: str, risk: float = 100) -> Dict:
    """Trend following strategy"""
    is_winning = random.random() > 0.45
    profit = random.uniform(50, 300) if is_winning else -random.uniform(30, 150)
    return {
        'symbol': symbol,
        'type': 'BUY' if random.random() > 0.5 else 'SELL',
        'volume': 0.1,
        'profit': profit,
        'strategy': 'trend_following',
    }

def scalping_strategy(symbol: str, account_id: str, risk: float = 100) -> Dict:
    """Scalping strategy - quick small profits"""
    is_winning = random.random() > 0.55  # Higher win rate but smaller profits
    profit = random.uniform(10, 100) if is_winning else -random.uniform(15, 80)
    return {
        'symbol': symbol,
        'type': 'BUY' if random.random() > 0.5 else 'SELL',
        'volume': 0.5,
        'profit': profit,
        'strategy': 'scalping',
    }

def momentum_strategy(symbol: str, account_id: str, risk: float = 100) -> Dict:
    """Momentum strategy"""
    is_winning = random.random() > 0.48
    profit = random.uniform(100, 400) if is_winning else -random.uniform(50, 200)
    return {
        'symbol': symbol,
        'type': 'BUY' if random.random() > 0.5 else 'SELL',
        'volume': 0.15,
        'profit': profit,
        'strategy': 'momentum',
    }

def mean_reversion_strategy(symbol: str, account_id: str, risk: float = 100) -> Dict:
    """Mean reversion strategy"""
    is_winning = random.random() > 0.50
    profit = random.uniform(75, 250) if is_winning else -random.uniform(40, 180)
    return {
        'symbol': symbol,
        'type': 'BUY' if random.random() > 0.5 else 'SELL',
        'volume': 0.12,
        'profit': profit,
        'strategy': 'mean_reversion',
    }

def range_trading_strategy(symbol: str, account_id: str, risk: float = 100) -> Dict:
    """Range trading strategy"""
    is_winning = random.random() > 0.52
    profit = random.uniform(30, 150) if is_winning else -random.uniform(20, 100)
    return {
        'symbol': symbol,
        'type': 'BUY' if random.random() > 0.5 else 'SELL',
        'volume': 0.2,
        'profit': profit,
        'strategy': 'range_trading',
    }

def breakout_strategy(symbol: str, account_id: str, risk: float = 100) -> Dict:
    """Breakout strategy"""
    is_winning = random.random() > 0.46
    profit = random.uniform(150, 500) if is_winning else -random.uniform(75, 250)
    return {
        'symbol': symbol,
        'type': 'BUY' if random.random() > 0.5 else 'SELL',
        'volume': 0.08,
        'profit': profit,
        'strategy': 'breakout',
    }

STRATEGY_FUNCTIONS = {
    'trend_following': trend_following_strategy,
    'scalping': scalping_strategy,
    'momentum': momentum_strategy,
    'mean_reversion': mean_reversion_strategy,
    'range_trading': range_trading_strategy,
    'breakout': breakout_strategy,
}

# Register all strategies
for strategy_name in STRATEGY_FUNCTIONS.keys():
    strategy_manager.register_strategy(strategy_name)


# ==================== DEMO DATA ====================
commodity_market_data = [
    # Forex Pairs
    {'symbol': 'EURUSD', 'category': 'Forex', 'signal': '🟢', 'trend': '↑', 'change': '+0.45%', 'volatility': 'Low', 'recommendation': 'STRONG BUY'},
    {'symbol': 'GBPUSD', 'category': 'Forex', 'signal': '🟡', 'trend': '→', 'change': '-0.12%', 'volatility': 'Medium', 'recommendation': 'HOLD'},
    {'symbol': 'USDJPY', 'category': 'Forex', 'signal': '🔴', 'trend': '↓', 'change': '-0.89%', 'volatility': 'High', 'recommendation': 'SELL'},
    {'symbol': 'AUDUSD', 'category': 'Forex', 'signal': '🟢', 'trend': '↑', 'change': '+0.67%', 'volatility': 'Medium', 'recommendation': 'BUY'},
    {'symbol': 'USDCAD', 'category': 'Forex', 'signal': '🟡', 'trend': '→', 'change': '+0.23%', 'volatility': 'Low', 'recommendation': 'CAUTION'},
    
    # Precious Metals
    {'symbol': 'XAUUSD', 'category': 'Metals', 'signal': '🟢', 'trend': '↑', 'change': '+1.23%', 'volatility': 'High', 'recommendation': 'STRONG BUY'},
    {'symbol': 'XAGUSD', 'category': 'Metals', 'signal': '🟡', 'trend': '→', 'change': '-0.34%', 'volatility': 'Medium', 'recommendation': 'HOLD'},
    {'symbol': 'XPDUSD', 'category': 'Metals', 'signal': '🔴', 'trend': '↓', 'change': '-2.11%', 'volatility': 'High', 'recommendation': 'SELL'},
    
    # Energy
    {'symbol': 'WTIUSD', 'category': 'Energy', 'signal': '🟢', 'trend': '↑', 'change': '+2.45%', 'volatility': 'High', 'recommendation': 'BUY'},
    {'symbol': 'BRNUSD', 'category': 'Energy', 'signal': '🟡', 'trend': '→', 'change': '+0.12%', 'volatility': 'Medium', 'recommendation': 'HOLD'},
    
    # Agricultural Commodities
    {'symbol': 'WHUSD', 'category': 'Agriculture', 'signal': '🔴', 'trend': '↓', 'change': '-1.56%', 'volatility': 'Medium', 'recommendation': 'SELL'},
    {'symbol': 'CORNUSD', 'category': 'Agriculture', 'signal': '🟡', 'trend': '→', 'change': '+0.08%', 'volatility': 'Low', 'recommendation': 'HOLD'},
    {'symbol': 'SOYUSD', 'category': 'Agriculture', 'signal': '🟢', 'trend': '↑', 'change': '+0.94%', 'volatility': 'Low', 'recommendation': 'BUY'},
    
    # Stock Indices
    {'symbol': 'US30', 'category': 'Indices', 'signal': '🟢', 'trend': '↑', 'change': '+1.12%', 'volatility': 'Medium', 'recommendation': 'BUY'},
    {'symbol': 'DE40', 'category': 'Indices', 'signal': '🟡', 'trend': '→', 'change': '-0.45%', 'volatility': 'Low', 'recommendation': 'HOLD'},
    {'symbol': 'UK100', 'category': 'Indices', 'signal': '🟢', 'trend': '↑', 'change': '+0.78%', 'volatility': 'Low', 'recommendation': 'BUY'},
    {'symbol': 'JP225', 'category': 'Indices', 'signal': '🟡', 'trend': '→', 'change': '+0.23%', 'volatility': 'Medium', 'recommendation': 'CAUTION'},
    {'symbol': 'HK50', 'category': 'Indices', 'signal': '🟢', 'trend': '↑', 'change': '+1.34%', 'volatility': 'High', 'recommendation': 'STRONG BUY'},
    
    # Cryptocurrencies
    {'symbol': 'BTC', 'category': 'Crypto', 'signal': '🟢', 'trend': '↑', 'change': '+3.45%', 'volatility': 'Very High', 'recommendation': 'STRONG BUY'},
    {'symbol': 'ETH', 'category': 'Crypto', 'signal': '🟢', 'trend': '↑', 'change': '+2.89%', 'volatility': 'Very High', 'recommendation': 'BUY'},
    {'symbol': 'XRP', 'category': 'Crypto', 'signal': '🟡', 'trend': '→', 'change': '+1.23%', 'volatility': 'Very High', 'recommendation': 'CAUTION'},
]


# Store active bots
active_bots = {}
demo_trades_storage = {}


# ==================== FLASK ENDPOINTS ====================

@app.route('/api/config/active', methods=['GET'])
def get_active_config():
    """Get current broker configuration (demo or live)"""
    config = CURRENT_CONFIG.copy()
    config.pop('password')  # Don't expose password
    return jsonify({
        'success': True,
        'config': config,
        'availableModes': ['demo', 'live'],
    }), 200


@app.route('/api/config/switch', methods=['POST'])
def switch_broker_config():
    """Switch between demo and live broker configurations"""
    try:
        global CURRENT_CONFIG
        data = request.json
        mode = data.get('mode', 'demo')
        
        if mode == 'demo':
            CURRENT_CONFIG = MT5_DEMO_CONFIG.copy()
            message = "Switched to XM Global DEMO account"
        elif mode == 'live':
            # User must provide live credentials
            account = data.get('account')
            password = data.get('password')
            
            if not account or not password:
                return jsonify({'success': False, 'error': 'Live account requires account number and password'}), 400
            
            CURRENT_CONFIG = MT5_LIVE_CONFIG.copy()
            CURRENT_CONFIG['account'] = account
            CURRENT_CONFIG['password'] = password
            CURRENT_CONFIG['initialBalance'] = data.get('initialBalance', 1000.0)
            message = f"Switched to XM Global LIVE account {account}"
        else:
            return jsonify({'success': False, 'error': f'Invalid mode: {mode}'}), 400
        
        logger.info(message)
        return jsonify({
            'success': True,
            'message': message,
            'mode': mode,
        }), 200
    
    except Exception as e:
        logger.error(f"Error switching config: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/bot/create', methods=['POST'])
def create_bot():
    """Create and start a new trading bot"""
    try:
        data = request.json
        bot_id = data.get('botId') or f"bot_{datetime.now().timestamp()}"
        symbols = data.get('symbols', ['EURUSD'])
        strategy = data.get('strategy', 'trend_following')
        risk_per_trade = float(data.get('riskPerTrade', 100))
        max_daily_loss = float(data.get('maxDailyLoss', 500))
        
        now = datetime.now()
        active_bots[bot_id] = {
            'botId': bot_id,
            'symbols': symbols,
            'strategy': strategy,
            'currentStrategy': strategy,
            'riskPerTrade': risk_per_trade,
            'maxDailyLoss': max_daily_loss,
            'enabled': True,
            'mode': CURRENT_CONFIG.get('mode', 'demo'),
            'accountId': CURRENT_CONFIG.get('account'),
            
            # Performance tracking
            'totalTrades': 0,
            'winningTrades': 0,
            'totalProfit': 0.0,
            'totalLosses': 0.0,
            'totalInvestment': 0.0,
            'maxDrawdown': 0.0,
            'peakProfit': 0.0,
            
            # Equity tracking
            'initialEquity': CURRENT_CONFIG.get('initialBalance', 10000.0),
            'currentEquity': CURRENT_CONFIG.get('initialBalance', 10000.0),
            'dailyProfits': {},
            'profitHistory': [],
            'tradeHistory': [],
            
            # Intelligent features
            'strategyStats': {name: {} for name in STRATEGY_FUNCTIONS.keys()},
            'switchHistory': [],
            'positionSizingEnabled': True,
            'strategyRotationEnabled': True,
            'lastStrategySwitch': None,
            
            # Metadata
            'createdAt': now.isoformat(),
            'startTime': now.isoformat(),
        }
        
        logger.info(f"Created bot {bot_id}: {strategy} on symbols {symbols} (Mode: {CURRENT_CONFIG.get('mode')})")
        
        return jsonify({
            'success': True,
            'botId': bot_id,
            'message': f'Bot created in {CURRENT_CONFIG.get("mode").upper()} mode',
            'config': active_bots[bot_id],
        }), 200
    
    except Exception as e:
        logger.error(f"Error creating bot: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/bot/start', methods=['POST'])
def start_bot():
    """Start automatic trading for a bot with intelligent strategy switching"""
    try:
        data = request.json
        bot_id = data.get('botId')
        
        if bot_id not in active_bots:
            return jsonify({'success': False, 'error': f'Bot {bot_id} not found'}), 404
        
        bot = active_bots[bot_id]
        
        # Try strategy switch if enabled
        switched = False
        old_strategy = bot['currentStrategy']
        if bot['strategyRotationEnabled']:
            switched, old_strat, new_strat = strategy_manager.try_switch_strategy(bot_id)
            if switched:
                bot['currentStrategy'] = new_strat
                bot['lastStrategySwitch'] = datetime.now().isoformat()
                bot['switchHistory'].append({
                    'timestamp': bot['lastStrategySwitch'],
                    'from': old_strat,
                    'to': new_strat,
                })
        
        # Get strategy function
        strategy_func = STRATEGY_FUNCTIONS.get(bot['currentStrategy'], trend_following_strategy)
        
        # Calculate position size with dynamic sizing
        equity_ratio = bot['currentEquity'] / bot['initialEquity']
        consecutive_losses = 0
        if bot['totalTrades'] > 0:
            recent_trades = bot['tradeHistory'][-5:]
            for trade in reversed(recent_trades):
                if trade['profit'] < 0:
                    consecutive_losses += 1
                else:
                    break
        
        win_streak = sum(1 for t in bot['tradeHistory'][-5:] if t.get('profit', 0) > 0)
        loss_streak = sum(1 for t in bot['tradeHistory'][-5:] if t.get('profit', 0) < 0)
        
        sizer = PositionSizer(bot['currentEquity'], bot['riskPerTrade'])
        position_size = sizer.calculate_size(
            equity_change=equity_ratio,
            win_streak=win_streak,
            loss_streak=loss_streak,
            volatility_factor=1.0,
            consecutive_losses=consecutive_losses,
            profit_factor=min(bot['totalProfit'] / max(bot['totalLosses'], 1), 5.0) if bot['totalLosses'] > 0 else 1.0
        )
        
        # Place trades
        trades_placed = []
        for symbol in bot['symbols'][:3]:
            trade_params = strategy_func(symbol, str(bot['accountId']), bot['riskPerTrade'])
            
            # Apply position sizing
            trade_params['volume'] = position_size
            
            trade = {
                'ticket': random.randint(1000000, 9999999),
                'symbol': trade_params['symbol'],
                'type': trade_params['type'],
                'volume': trade_params['volume'],
                'profit': trade_params['profit'],
                'timestamp': int(datetime.now().timestamp() * 1000),
                'time': datetime.now().isoformat(),
                'botId': bot_id,
                'strategy': bot['currentStrategy'],
                'isWinning': trade_params['profit'] > 0,
            }
            
            # Update bot stats
            bot['totalTrades'] += 1
            if trade['profit'] > 0:
                bot['winningTrades'] += 1
            
            bot['totalProfit'] += trade['profit']
            if trade['profit'] < 0:
                bot['totalLosses'] += abs(trade['profit'])
            
            # Update equity
            bot['currentEquity'] += trade['profit']
            
            # Track peak and drawdown
            if bot['currentEquity'] > bot['initialEquity']:
                bot['peakProfit'] = bot['currentEquity'] - bot['initialEquity']
            
            drawdown = max(0, (bot['initialEquity'] + bot['peakProfit']) - bot['currentEquity'])
            if drawdown > bot['maxDrawdown']:
                bot['maxDrawdown'] = drawdown
            
            # Record in strategy stats
            strategy_manager.record_trade(bot['currentStrategy'], trade['profit'])
            
            # Store trade
            bot['tradeHistory'].append(trade)
            bot['profitHistory'].append({
                'timestamp': trade['timestamp'],
                'profit': round(bot['totalProfit'], 2),
                'equity': round(bot['currentEquity'], 2),
                'trades': bot['totalTrades'],
            })
            
            # Track daily profit
            today = datetime.now().strftime('%Y-%m-%d')
            if today not in bot['dailyProfits']:
                bot['dailyProfits'][today] = 0
            bot['dailyProfits'][today] += trade['profit']
            
            trades_placed.append(trade)
        
        # Response data
        today = datetime.now().strftime('%Y-%m-%d')
        daily_profit = bot['dailyProfits'].get(today, 0)
        
        return jsonify({
            'success': True,
            'botId': bot_id,
            'strategy': bot['currentStrategy'],
            'strategySwitched': switched,
            'previousStrategy': old_strategy if switched else None,
            'tradesPlaced': len(trades_placed),
            'trades': trades_placed,
            'positionSize': position_size,
            'botStats': {
                'totalTrades': bot['totalTrades'],
                'winningTrades': bot['winningTrades'],
                'totalProfit': round(bot['totalProfit'], 2),
                'totalLosses': round(bot['totalLosses'], 2),
                'currentEquity': round(bot['currentEquity'], 2),
                'initialEquity': round(bot['initialEquity'], 2),
                'equityChange': round((bot['currentEquity'] - bot['initialEquity']), 2),
                'winRate': round((bot['winningTrades'] / bot['totalTrades'] * 100) if bot['totalTrades'] > 0 else 0, 2),
                'maxDrawdown': round(bot['maxDrawdown'], 2),
                'profitFactor': round((bot['totalProfit'] / max(bot['totalLosses'], 1)), 2) if bot['totalLosses'] > 0 else 99.99,
                'dailyProfit': round(daily_profit, 2),
            }
        }), 200
    
    except Exception as e:
        logger.error(f"Error starting bot: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/bot/strategy-stats', methods=['GET'])
def get_strategy_stats():
    """Get performance statistics for all strategies"""
    try:
        stats = {}
        for name, stat_obj in strategy_manager.strategy_stats.items():
            stats[name] = stat_obj.to_dict()
        
        return jsonify({
            'success': True,
            'strategies': stats,
            'timestamp': datetime.now().isoformat(),
        }), 200
    
    except Exception as e:
        logger.error(f"Error getting strategy stats: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/bot/status', methods=['GET'])
def bot_status():
    """Get status of all active bots with intelligent metrics"""
    try:
        bots_list = []
        for bot in active_bots.values():
            created = datetime.fromisoformat(bot['createdAt'])
            runtime_seconds = (datetime.now() - created).total_seconds()
            runtime_hours = runtime_seconds / 3600
            runtime_minutes = (runtime_seconds % 3600) / 60
            
            today = datetime.now().strftime('%Y-%m-%d')
            daily_profit = bot['dailyProfits'].get(today, 0)
            
            investment = bot['totalInvestment']
            roi = (bot['totalProfit'] / max(investment, 1)) * 100 if investment > 0 else 0
            
            profit_factor = (bot['totalProfit'] / max(bot['totalLosses'], 1)) if bot['totalLosses'] > 0 else 99.99
            profit_factor = min(profit_factor, 99.99)
            
            enhanced_bot = bot.copy()
            enhanced_bot.update({
                'runtimeHours': round(runtime_hours, 2),
                'runtimeMinutes': int(runtime_minutes),
                'runtimeFormatted': f"{int(runtime_hours)}h {int(runtime_minutes)}m",
                'dailyProfit': round(daily_profit, 2),
                'profitFactor': round(profit_factor, 2),
                'roi': round(roi, 2),
                'avgProfitPerTrade': round(bot['totalProfit'] / max(bot['totalTrades'], 1), 2),
                'status': 'Active' if bot['enabled'] else 'Inactive',
                'equityPercentageChange': round(((bot['currentEquity'] - bot['initialEquity']) / bot['initialEquity']) * 100, 2),
                'lastTradeTime': bot['tradeHistory'][-1]['time'] if bot['tradeHistory'] else bot['createdAt'],
            })
            bots_list.append(enhanced_bot)
        
        return jsonify({
            'success': True,
            'activeBots': len([b for b in bots_list if b['enabled']]),
            'bots': bots_list,
            'timestamp': datetime.now().isoformat(),
        }), 200
    
    except Exception as e:
        logger.error(f"Error getting bot status: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/bot/stop/<bot_id>', methods=['POST'])
def stop_bot(bot_id):
    """Stop a trading bot"""
    try:
        if bot_id not in active_bots:
            return jsonify({'success': False, 'error': f'Bot {bot_id} not found'}), 404
        
        bot = active_bots[bot_id]
        bot['enabled'] = False
        
        logger.info(f"Bot {bot_id} stopped")
        
        return jsonify({
            'success': True,
            'message': f'Bot {bot_id} stopped',
            'finalStats': {
                'totalTrades': bot['totalTrades'],
                'totalProfit': round(bot['totalProfit'], 2),
                'finalEquity': round(bot['currentEquity'], 2),
                'profitFactor': round((bot['totalProfit'] / max(bot['totalLosses'], 1)), 2) if bot['totalLosses'] > 0 else 99.99,
            }
        }), 200
    
    except Exception as e:
        logger.error(f"Error stopping bot: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/market/commodities', methods=['GET'])
def get_commodity_market_data():
    """Get market data for all trading commodities"""
    try:
        return jsonify({
            'success': True,
            'commodities': commodity_market_data,
            'timestamp': datetime.now().isoformat(),
        }), 200
    
    except Exception as e:
        logger.error(f"Error getting market data: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'currentMode': CURRENT_CONFIG.get('mode', 'demo'),
        'activeBots': len([b for b in active_bots.values() if b['enabled']]),
    }), 200


if __name__ == '__main__':
    logger.info("=" * 60)
    logger.info("Zwesta Intelligent Trading Backend Started")
    logger.info(f"Mode: {CURRENT_CONFIG.get('mode').upper()}")
    logger.info(f"Account: {CURRENT_CONFIG.get('account')}")
    logger.info(f"Server: {CURRENT_CONFIG.get('server')}")
    logger.info("=" * 60)
    
    app.run(host='0.0.0.0', port=9000, debug=False)
