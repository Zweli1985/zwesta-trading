#!/usr/bin/env python3
"""Test backward compatibility - bot start without PIN"""
import requests
import json

print("="*70)
print("✅ BACKWARD COMPATIBILITY TEST - Bot Start Without PIN")
print("="*70)

# Get active bots
try:
    r = requests.get('http://localhost:9000/api/bot/status')
    data = r.json()
    bots = data.get('bots', [])

    if not bots:
        print("❌ No bots found")
        exit(1)

    demo_bot = bots[0]
    bot_id = demo_bot['botId']
    user_id = demo_bot.get('user_id', 'demo_user')

    print(f"\n[1] Getting test bot...")
    print(f"    Bot ID: {bot_id}")
    print(f"    User ID: {user_id}")

    print(f"\n[2] Testing bot start WITHOUT activation_pin...")
    print(f"    (This should work now with backward compatibility)")

    # This should work now WITHOUT activation_pin (backward compatible)
    payload = {
        'botId': bot_id,
        'user_id': user_id
        # NOTE: No activation_pin provided!
    }

    response = requests.post('http://localhost:9000/api/bot/start', json=payload)
    print(f"\n    Response Status: {response.status_code}")

    resp_data = response.json()
    if 'error' in resp_data:
        error = resp_data['error']
        if 'session' in error.lower():
            print(f"    ⚠️  (Expected) Needs session token: {error[:60]}")
        elif 'pin' in error.lower():
            print(f"    ❌ FAIL: Still requires PIN!")
            print(f"       Error: {error}")
        else:
            print(f"    Info: {error[:70]}")
    elif resp_data.get('success') == True:
        print(f"    ✅ SUCCESS: Bot started without PIN!")
    else:
        print(f"    Response: {json.dumps(resp_data, indent=2)[:200]}")

    print("\n" + "="*70)
    print("SUMMARY:")
    print("  - If status=401 with 'session' error: PIN is optional ✅")
    print("  - If status=401 with 'PIN required' error: PIN is mandatory ❌")
    print("\nCheck backend logs for warnings:")
    print("  'WITHOUT 2FA PIN' = backward compatible ✅")
    print("="*70)

except Exception as e:
    print(f"Error: {e}")
    exit(1)
