import requests
import sqlite3

# CONFIGURATION
API_URL = 'http://localhost:9000/api/bot/status'  # Update if backend runs elsewhere
DELETE_URL = 'http://localhost:9000/api/bot/delete/{}'
SESSION_TOKEN = 'YOUR_SESSION_TOKEN_HERE'  # <-- Replace with your valid session token

# 1. Get all bots for the user
headers = {
    'Content-Type': 'application/json',
    'X-Session-Token': SESSION_TOKEN,
}

resp = requests.get(API_URL, headers=headers)
if resp.status_code != 200:
    print('Failed to fetch bots:', resp.text)
    exit(1)

data = resp.json()
bots = data.get('bots', [])

if not bots:
    print('No bots found.')
    exit(0)

print(f'Found {len(bots)} bots. Deleting...')

# 2. Delete each bot via API
for bot in bots:
    bot_id = bot.get('botId') or bot.get('id')
    if not bot_id:
        print('Bot missing id:', bot)
        continue
    del_url = DELETE_URL.format(bot_id)
    del_resp = requests.delete(del_url, headers=headers)
    if del_resp.status_code == 200:
        print(f'Bot {bot_id} deleted.')
    else:
        print(f'Failed to delete {bot_id}:', del_resp.text)

print('All bots processed.')
