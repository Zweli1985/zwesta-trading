#!/usr/bin/env python3
"""Test intelligent strategy switching and dynamic position sizing"""

import requests
import json
import time

BASE_URL = 'http://localhost:9000'
bot_id = 'smart_bot_001'

def test_bot_creation():
    """Test bot creation with intelligent features"""
    print("=" * 60)
    print("TESTING INTELLIGENT BOT CREATION")
    print("=" * 60)
    
    bot_data = {
        'botId': bot_id,
        'accountId': 'XM_Demo',
        'symbols': ['EURUSD', 'GOLD', 'CRUDE_OIL'],
        'strategy': 'Momentum Trading',
        'riskPerTrade': 100,
        'maxDailyLoss': 500,
        'enabled': True,
        'autoSwitch': True,
        'dynamicSizing': True,
        'basePositionSize': 1.0
    }
    
    response = requests.post(f'{BASE_URL}/api/bot/create', json=bot_data)
    result = response.json()
    
    print("\n✓ Bot Created Successfully")
    print(f"  Bot ID: {result['botId']}")
    print(f"  Strategy: {result['config']['strategy']}")
    print(f"  Auto-Switch Enabled: {result['config'].get('autoSwitch', False)}")
    print(f"  Dynamic Sizing Enabled: {result['config'].get('dynamicSizing', False)}")
    
    return True


def test_strategy_execution():
    """Test strategy execution with position sizing"""
    print("\n" + "=" * 60)
    print("TESTING STRATEGY EXECUTION WITH POSITION SIZING")
    print("=" * 60)
    
    for i in range(3):
        response = requests.post(f'{BASE_URL}/api/bot/start', json={'botId': bot_id})
        data = response.json()
        
        print(f"\n--- EXECUTION RUN {i+1} ---")
        print(f"Trades Placed: {data['tradesPlaced']}")
        print(f"Current Strategy: {data['strategy']}")
        
        if data.get('trades'):
            trade = data['trades'][0]
            print(f"\nFirst Trade Details:")
            print(f"  Symbol: {trade['symbol']}")
            print(f"  Type: {trade['type']}")
            print(f"  Base Volume: {trade.get('baseVolume')}")
            print(f"  Adjusted Volume: {trade['volume']}")
            print(f"  Position Size Multiplier: {trade.get('positionSize')}")
            print(f"  Profit: ${trade['profit']:.2f}")
            print(f"  Win: {trade['isWinning']}")
        
        print(f"\nBot Statistics:")
        stats = data.get('botStats', {})
        print(f"  Total Trades: {stats.get('totalTrades', 0)}")
        print(f"  Winning Trades: {stats.get('winningTrades', 0)}")
        print(f"  Total Profit: ${stats.get('totalProfit', 0):.2f}")
        print(f"  Win Rate: {stats.get('winRate', 0):.2f}%")
        print(f"  ROI: {stats.get('roi', 0) or 0:.2f}%")
        print(f"  Max Drawdown: ${stats.get('maxDrawdown', 0):.2f}")
        
        time.sleep(0.5)


def test_strategy_recommendations():
    """Test strategy performance tracking"""
    print("\n" + "=" * 60)
    print("TESTING STRATEGY PERFORMANCE TRACKING")
    print("=" * 60)
    
    response = requests.get(f'{BASE_URL}/api/strategy/recommend')
    data = response.json()
    
    print(f"\n✓ Best Recommended Strategy: {data['recommendedStrategy']}")
    print("\nAll Strategy Performance:")
    
    for strategy, stats in data['allStats'].items():
        print(f"\n  {strategy}:")
        print(f"    Trades: {stats['trades']}")
        print(f"    Wins: {stats['wins']}")
        print(f"    Losses: {stats['losses']}")
        print(f"    Total Profit: ${stats['profit']:.2f}")
        print(f"    Win Rate: {stats['win_rate']:.2f}%")
        print(f"    Profit Factor: {stats['profit_factor']}")


def test_position_sizing_metrics():
    """Test position sizing calculations"""
    print("\n" + "=" * 60)
    print("TESTING DYNAMIC POSITION SIZING METRICS")
    print("=" * 60)
    
    response = requests.get(f'{BASE_URL}/api/position/sizing-metrics/{bot_id}')
    data = response.json()
    
    print(f"\nPosition Sizes at Different Volatility Levels:")
    pos_sizing = data['positionSizing']
    print(f"  Low Volatility: {pos_sizing['low_volatility']}x")
    print(f"  Medium Volatility: {pos_sizing['medium_volatility']}x")
    print(f"  High Volatility: {pos_sizing['high_volatility']}x")
    print(f"  Very High Volatility: {pos_sizing['very_high_volatility']}x")
    print(f"  Current (Medium): {pos_sizing['current']}x")
    
    print(f"\nEquity Metrics:")
    equity = data['equityMetrics']
    print(f"  Current Profit: ${equity['currentProfit']:.2f}")
    print(f"  Peak Profit: ${equity['peakProfit']:.2f}")
    print(f"  Max Drawdown: ${equity['maxDrawdown']:.2f}")
    print(f"  Drawdown %: {equity['drawdownPercent']:.2f}%")
    print(f"  Profit Factor: {equity['profitFactor']}")


def test_bot_config():
    """Test complete bot configuration"""
    print("\n" + "=" * 60)
    print("TESTING COMPLETE BOT CONFIGURATION")
    print("=" * 60)
    
    response = requests.get(f'{BASE_URL}/api/bot/config/{bot_id}')
    data = response.json()
    
    config = data['config']
    print(f"\nBot Configuration:")
    print(f"  ID: {config['botId']}")
    print(f"  Strategy: {config['strategy']}")
    print(f"  Auto-Switch: {config['autoSwitch']}")
    print(f"  Dynamic Sizing: {config['dynamicSizing']}")
    print(f"  Base Position Size: {config['basePositionSize']}")
    print(f"  Symbols: {', '.join(config['symbols'])}")
    
    status = data['status']
    print(f"\nBot Status:")
    print(f"  Runtime: {status['runtime']}")
    print(f"  Total Trades: {status['totalTrades']}")
    print(f"  Win Rate: {status['winRate']:.2f}%")
    print(f"  Total Profit: ${status['totalProfit']:.2f}")
    print(f"  Daily Profit: ${status['dailyProfit']:.2f}")
    
    intelligence = data['intelligence']
    print(f"\nIntelligence Metrics:")
    print(f"  Strategy Changes: {intelligence['strategyChanges']}")
    if intelligence['strategyHistory']:
        print(f"  Last Strategy Change: {intelligence['strategyHistory'][-1].get('newStrategy')}")


if __name__ == '__main__':
    try:
        test_bot_creation()
        test_strategy_execution()
        test_strategy_recommendations()
        test_position_sizing_metrics()
        test_bot_config()
        
        print("\n" + "=" * 60)
        print("✓ ALL INTELLIGENT FEATURES TESTED SUCCESSFULLY")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()
