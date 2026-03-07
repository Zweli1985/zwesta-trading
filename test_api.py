#!/usr/bin/env python3
"""
Local Testing Suite for Zwesta Trading System
Tests all API endpoints in local environment
"""

import requests
import json
import time
from typing import Dict, Any
from datetime import datetime

BASE_URL = "http://localhost:9000"

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'

class TestResults:
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.tests = []
    
    def add(self, name: str, success: bool, response: Dict[str, Any] = None, error: str = None):
        self.tests.append({
            'name': name,
            'success': success,
            'response': response,
            'error': error,
            'time': datetime.now().isoformat()
        })
        if success:
            self.passed += 1
        else:
            self.failed += 1
    
    def print_summary(self):
        print(f"\n{Colors.BLUE}{'='*60}")
        print(f"TEST RESULTS SUMMARY")
        print(f"{'='*60}{Colors.RESET}")
        print(f"{Colors.GREEN}✓ Passed: {self.passed}{Colors.RESET}")
        print(f"{Colors.RED}✗ Failed: {self.failed}{Colors.RESET}")
        print(f"Total: {self.passed + self.failed}")
        print(f"{Colors.BLUE}{'='*60}{Colors.RESET}\n")

results = TestResults()

def print_test(name: str, method: str, endpoint: str):
    print(f"\n{Colors.BLUE}Testing: {Colors.RESET}{method} {endpoint}")
    print(f"{Colors.YELLOW}→ {name}{Colors.RESET}")

def test_health():
    """Test health check endpoint"""
    print_test("Health Check", "GET", "/api/health")
    try:
        response = requests.get(f"{BASE_URL}/api/health", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"{Colors.GREEN}✓ Health check passed{Colors.RESET}")
            results.add("Health Check", True, data)
            return True
        else:
            print(f"{Colors.RED}✗ Health check failed: {response.status_code}{Colors.RESET}")
            results.add("Health Check", False, None, f"Status: {response.status_code}")
            return False
    except Exception as e:
        print(f"{Colors.RED}✗ Error: {str(e)}{Colors.RESET}")
        results.add("Health Check", False, None, str(e))
        return False

def test_account_info():
    """Test account info endpoint"""
    print_test("Account Info", "GET", "/api/account/info")
    try:
        response = requests.get(f"{BASE_URL}/api/account/info", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print(f"  Account ID: {data['account']['accountId']}")
            print(f"  Broker: {data['account']['broker']}")
            print(f"{Colors.GREEN}✓ Account info retrieved{Colors.RESET}")
            results.add("Account Info", True, data)
            return True
        else:
            print(f"{Colors.RED}✗ Failed: {response.status_code}{Colors.RESET}")
            results.add("Account Info", False, None, f"Status: {response.status_code}")
            return False
    except Exception as e:
        print(f"{Colors.RED}✗ Error: {str(e)}{Colors.RESET}")
        results.add("Account Info", False, None, str(e))
        return False

def test_trades():
    """Test trades endpoint"""
    print_test("Get Trades", "GET", "/api/trades")
    try:
        response = requests.get(f"{BASE_URL}/api/trades", timeout=5)
        if response.status_code == 200:
            data = response.json()
            trade_count = len(data.get('trades', []))
            print(f"  Trades found: {trade_count}")
            if trade_count == 0:
                print(f"  {Colors.YELLOW}(Demo account - no trades yet){Colors.RESET}")
            print(f"{Colors.GREEN}✓ Trades endpoint working{Colors.RESET}")
            results.add("Get Trades", True, data)
            return True
        else:
            print(f"{Colors.RED}✗ Failed: {response.status_code}{Colors.RESET}")
            results.add("Get Trades", False, None, f"Status: {response.status_code}")
            return False
    except Exception as e:
        print(f"{Colors.RED}✗ Error: {str(e)}{Colors.RESET}")
        results.add("Get Trades", False, None, str(e))
        return False

def test_positions():
    """Test positions endpoint"""
    print_test("Get Positions", "GET", "/api/positions/all")
    try:
        response = requests.get(f"{BASE_URL}/api/positions/all", timeout=5)
        if response.status_code == 200:
            data = response.json()
            position_count = data.get('count', 0)
            print(f"  Positions found: {position_count}")
            print(f"{Colors.GREEN}✓ Positions endpoint working{Colors.RESET}")
            results.add("Get Positions", True, data)
            return True
        else:
            print(f"{Colors.RED}✗ Failed: {response.status_code}{Colors.RESET}")
            results.add("Get Positions", False, None, f"Status: {response.status_code}")
            return False
    except Exception as e:
        print(f"{Colors.RED}✗ Error: {str(e)}{Colors.RESET}")
        results.add("Get Positions", False, None, str(e))
        return False

def test_account_equity():
    """Test account equity endpoint"""
    print_test("Account Equity", "GET", "/api/account/equity")
    try:
        response = requests.get(f"{BASE_URL}/api/account/equity", timeout=5)
        if response.status_code == 200:
            data = response.json()
            for account in data.get('accounts', []):
                print(f"  Account: {account['accountId']}")
                print(f"    Balance: ${account['balance']:.2f}")
                print(f"    Equity: ${account['equity']:.2f}")
                print(f"    Margin Level: {account['marginLevel']:.2f}%")
            print(f"{Colors.GREEN}✓ Equity data retrieved{Colors.RESET}")
            results.add("Account Equity", True, data)
            return True
        else:
            print(f"{Colors.RED}✗ Failed: {response.status_code}{Colors.RESET}")
            results.add("Account Equity", False, None, f"Status: {response.status_code}")
            return False
    except Exception as e:
        print(f"{Colors.RED}✗ Error: {str(e)}{Colors.RESET}")
        results.add("Account Equity", False, None, str(e))
        return False

def test_demo_trades():
    """Test demo trade generation"""
    print_test("Generate Demo Trades", "POST", "/api/demo/generate-trades")
    try:
        payload = {"count": 3}
        response = requests.post(
            f"{BASE_URL}/api/demo/generate-trades",
            json=payload,
            timeout=5
        )
        if response.status_code == 200:
            data = response.json()
            trade_count = len(data.get('trades', []))
            print(f"  Generated trades: {trade_count}")
            for trade in data.get('trades', [])[:2]:
                print(f"    {trade['symbol']}: {trade['type']} {trade['volume']} lots")
            print(f"{Colors.GREEN}✓ Demo trades generated{Colors.RESET}")
            results.add("Generate Demo Trades", True, data)
            return True
        else:
            print(f"{Colors.RED}✗ Failed: {response.status_code}{Colors.RESET}")
            results.add("Generate Demo Trades", False, None, f"Status: {response.status_code}")
            return False
    except Exception as e:
        print(f"{Colors.RED}✗ Error: {str(e)}{Colors.RESET}")
        results.add("Generate Demo Trades", False, None, str(e))
        return False

def test_accounts_list():
    """Test accounts list endpoint"""
    print_test("List Accounts", "GET", "/api/accounts/list")
    try:
        response = requests.get(f"{BASE_URL}/api/accounts/list", timeout=5)
        if response.status_code == 200:
            data = response.json()
            accounts = data.get('accounts', [])
            print(f"  Total accounts: {len(accounts)}")
            for account in accounts:
                status = "✓ Connected" if account['connected'] else "✗ Not connected"
                print(f"    {account['accountId']}: {status}")
            print(f"{Colors.GREEN}✓ Accounts list retrieved{Colors.RESET}")
            results.add("List Accounts", True, data)
            return True
        else:
            print(f"{Colors.RED}✗ Failed: {response.status_code}{Colors.RESET}")
            results.add("List Accounts", False, None, f"Status: {response.status_code}")
            return False
    except Exception as e:
        print(f"{Colors.RED}✗ Error: {str(e)}{Colors.RESET}")
        results.add("List Accounts", False, None, str(e))
        return False

def test_brokers_list():
    """Test brokers list endpoint"""
    print_test("List Brokers", "GET", "/api/brokers/list")
    try:
        response = requests.get(f"{BASE_URL}/api/brokers/list", timeout=5)
        if response.status_code == 200:
            data = response.json()
            brokers = data.get('brokers', [])
            print(f"  Available brokers: {len(brokers)}")
            for broker in brokers[:5]:
                print(f"    - {broker}")
            print(f"{Colors.GREEN}✓ Brokers list retrieved{Colors.RESET}")
            results.add("List Brokers", True, data)
            return True
        else:
            print(f"{Colors.RED}✗ Failed: {response.status_code}{Colors.RESET}")
            results.add("List Brokers", False, None, f"Status: {response.status_code}")
            return False
    except Exception as e:
        print(f"{Colors.RED}✗ Error: {str(e)}{Colors.RESET}")
        results.add("List Brokers", False, None, str(e))
        return False

def test_report_summary():
    """Test report summary endpoint"""
    print_test("Report Summary", "GET", "/api/reports/summary")
    try:
        response = requests.get(f"{BASE_URL}/api/reports/summary", timeout=5)
        if response.status_code == 200:
            data = response.json()
            reports = data.get('reports', {})
            print(f"  Accounts with reports: {len(reports)}")
            for account_id, report in reports.items():
                print(f"    {account_id}:")
                print(f"      Win Rate: {report['winRate']:.1f}%")
                print(f"      Total Trades: {report['totalTrades']}")
                print(f"      Net Profit: ${report['netProfit']:.2f}")
            print(f"{Colors.GREEN}✓ Report summary retrieved{Colors.RESET}")
            results.add("Report Summary", True, data)
            return True
        else:
            print(f"{Colors.RED}✗ Failed: {response.status_code}{Colors.RESET}")
            results.add("Report Summary", False, None, f"Status: {response.status_code}")
            return False
    except Exception as e:
        print(f"{Colors.RED}✗ Error: {str(e)}{Colors.RESET}")
        results.add("Report Summary", False, None, str(e))
        return False

def main():
    print(f"\n{Colors.BLUE}")
    print("╔════════════════════════════════════════════════════════╗")
    print("║   Zwesta Trading System - Local API Test Suite         ║")
    print(f"║   Target: {BASE_URL:<40}║")
    print("╚════════════════════════════════════════════════════════╝")
    print(f"{Colors.RESET}")
    
    # Check if server is running
    try:
        requests.get(f"{BASE_URL}/api/health", timeout=2)
    except:
        print(f"{Colors.RED}✗ ERROR: Server not responding at {BASE_URL}")
        print(f"   Make sure backend is running: python multi_broker_backend_updated.py{Colors.RESET}\n")
        return
    
    print(f"{Colors.GREEN}✓ Server is running!{Colors.RESET}\n")
    print(f"Starting tests at {datetime.now().strftime('%H:%M:%S')}...\n")
    
    # Run all tests
    test_health()
    time.sleep(0.5)
    
    test_account_info()
    time.sleep(0.5)
    
    test_accounts_list()
    time.sleep(0.5)
    
    test_brokers_list()
    time.sleep(0.5)
    
    test_trades()
    time.sleep(0.5)
    
    test_positions()
    time.sleep(0.5)
    
    test_account_equity()
    time.sleep(0.5)
    
    test_demo_trades()
    time.sleep(0.5)
    
    test_report_summary()
    
    # Print summary
    results.print_summary()
    
    if results.failed == 0:
        print(f"{Colors.GREEN}🎉 All tests passed! System is ready.{Colors.RESET}\n")
    else:
        print(f"{Colors.RED}⚠ Some tests failed. Review output above.{Colors.RESET}\n")

if __name__ == "__main__":
    main()
