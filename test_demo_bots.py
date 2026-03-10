#!/usr/bin/env python3
"""Test backward compatibility with demo bots"""
import requests
import json

print("="*70)
print("Testing Backward Compatibility - Demo Bots Already Running")
print("="*70)

# Test health endpoint first
print("\n[1] Testing health endpoint...")
response = requests.get('http://localhost:9000/api/health')
print(f"✅ Health: {response.status_code}")

# Test bot status (no auth required for demo)
print("\n[2] Testing bot status endpoint...")
response = requests.get('http://localhost:9000/api/bot/status')
data = response.json()
print(f"✅ Status: {response.status_code}")
if 'activeBots' in data:
    print(f"   Active Bots: {len(data['activeBots'])}")
    for bot_id in list(data['activeBots'].keys())[:3]:
        print(f"      - {bot_id}")

# Attempt to start a demo bot WITHOUT PIN (test backward compatibility)
print("\n[3] Testing bot start WITHOUT PIN (backward compat)...")

# Get one of the demo bot IDs
if 'activeBots' in data and len(data['activeBots']) > 0:
    demo_bot_id = list(data['activeBots'].keys())[0]
    demo_user = data['activeBots'][demo_bot_id].get('user_id', 'demo_user')
    
    payload = {
        'botId': demo_bot_id,
        'user_id': demo_user
    }
    
    # No session token - test if request is rejected or allowed
    response = requests.post('http://localhost:9000/api/bot/start', json=payload)
    print(f"   Bot ID: {demo_bot_id}")
    print(f"   Status: {response.status_code}")
    data = response.json()
    
    if response.status_code == 200:
        print(f"   ✅ SUCCESS: Bot started without PIN!")
    elif response.status_code == 401:
        if 'session' in data.get('error', '').lower():
            print(f"   ⚠️  Needs session token (expected)")
        elif 'pin' in data.get('error', '').lower():
            print(f"   ❌ FAIL: Still requires PIN: {data['error']}")
        else:
            print(f"   Code: {data.get('error', 'Unknown error')}")
    else:
        print(f"   Response: {json.dumps(data, indent=2)[:200]}")

print("\n" + "="*70)
print("✅ Test complete - Check logs for 'without PIN/token' warnings")
print("="*70)
