#!/usr/bin/env python3
"""Test backward compatibility - bot start without PIN"""
import requests
import json

print("="*60)
print("Testing Backend Backward Compatibility")
print("="*60)

# Step 1: Login
print("\n[1] Logging in...")
login_payload = {'email': 'zwexman@gmail.com'}
login_response = requests.post('http://localhost:9000/api/user/login', json=login_payload)

if login_response.status_code != 200:
    print(f"❌ Login failed: {login_response.json()}")
    exit(1)

login_data = login_response.json()
session_token = login_data.get('session_token')
user_id = login_data.get('user_id')

print(f"✅ Login successful")
print(f"   User: {login_data.get('name')} ({user_id})")

# Step 2: Test bot start WITHOUT PIN
print("\n[2] Testing bot start WITHOUT PIN...")
headers = {'X-Session-Token': session_token}
payload = {
    'botId': 'bot_1773159895420',
    'user_id': user_id
}

response = requests.post('http://localhost:9000/api/bot/start', json=payload, headers=headers)
data = response.json()

print(f"Status: {response.status_code}")
if response.status_code == 200:
    print(f"✅ SUCCESS: Bot started WITHOUT PIN (backward compatible)")
    print(f"   Message: {data.get('message', 'Bot started')}")
else:
    print(f"Response: {json.dumps(data, indent=2)}")
    if 'error' in data:
        print(f"Error: {data['error']}")

# Step 3: Test bot deletion WITHOUT token
print("\n[3] Testing bot deletion WITHOUT token...")
headers = {'X-Session-Token': session_token}
payload = {
    'user_id': user_id
}

response = requests.post(f'http://localhost:9000/api/bot/delete/bot_1773159895420', json=payload, headers=headers)
data = response.json()

print(f"Status: {response.status_code}")
if response.status_code == 200:
    print(f"✅ SUCCESS: Bot deleted WITHOUT token (backward compatible)")
    print(f"   Message: {data.get('message', 'Bot deleted')}")
else:
    print(f"Response: {json.dumps(data, indent=2)[:200]}")
    if 'error' in data:
        print(f"Error: {data['error'][:100]}")

print("\n" + "="*60)
print("✅ Backward compatibility test complete!")
print("="*60)
