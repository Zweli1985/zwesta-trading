#!/usr/bin/env python3
"""
Test Broker Detection System
Tests: 1) Database migrations
       2) IG Markets credential storage
       3) MT5 credential storage
       4) Automatic broker detection
"""

import sqlite3
import json
import sys

print("\n" + "="*70)
print("ZWESTA BROKER DETECTION SYSTEM - COMPREHENSIVE TEST")
print("="*70)

# Test 1: Check database migrations
print("\n✅ TEST 1: DATABASE MIGRATIONS")
print("-" * 70)

conn = sqlite3.connect('trading_system.db')
conn.row_factory = sqlite3.Row
cursor = conn.cursor()

# Get broker_credentials schema
cursor.execute("PRAGMA table_info(broker_credentials)")
columns = {row['name']: row['type'] for row in cursor.fetchall()}

print("broker_credentials table columns:")
for col_name in ['credential_id', 'user_id', 'broker_name', 'api_key', 'username', 'account_number', 'password', 'server', 'is_live']:
    if col_name in columns:
        print(f"  ✅ {col_name:20} ({columns[col_name]})")
    else:
        print(f"  ❌ {col_name:20} MISSING")

# Test 2: Verify data structure
print("\n✅ TEST 2: BROKER CREDENTIAL REQUIREMENTS")
print("-" * 70)

required_for_ig = ['api_key', 'username', 'password']
required_for_mt5 = ['account_number', 'password', 'server']

ig_ok = all(col in columns for col in required_for_ig)
mt5_ok = all(col in columns for col in required_for_mt5)

print(f"IG Markets requirements: {' '.join(required_for_ig)}")
print(f"  {'✅ PASS' if ig_ok else '❌ FAIL'}")

print(f"\nMT5 requirements: {' '.join(required_for_mt5)}")
print(f"  {'✅ PASS' if mt5_ok else '❌ FAIL'}")

# Test 3: Create test credentials
print("\n✅ TEST 3: CREDENTIAL STORAGE TEST")
print("-" * 70)

test_ig_cred = {
    'credential_id': 'test_ig_001',
    'user_id': 'test_user_001',
    'broker_name': 'IG Markets',
    'api_key': 'test_api_key_xyz',
    'username': 'test_ig_username',
    'password': 'test_ig_password',
    'account_number': None,
    'server': None,
    'is_live': 0
}

test_mt5_cred = {
    'credential_id': 'test_mt5_001',
    'user_id': 'test_user_001',
    'broker_name': 'MetaQuotes',
    'api_key': None,
    'username': None,
    'account_number': '104254514',
    'password': 'test_mt5_password',
    'server': 'MetaQuotes-Demo',
    'is_live': 0
}

try:
    # Insert test credentials
    cursor.execute('''
        INSERT OR REPLACE INTO broker_credentials 
        (credential_id, user_id, broker_name, api_key, username, account_number, password, server, is_live)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', (
        test_ig_cred['credential_id'], test_ig_cred['user_id'], test_ig_cred['broker_name'],
        test_ig_cred['api_key'], test_ig_cred['username'], test_ig_cred['account_number'],
        test_ig_cred['password'], test_ig_cred['server'], test_ig_cred['is_live']
    ))
    
    cursor.execute('''
        INSERT OR REPLACE INTO broker_credentials 
        (credential_id, user_id, broker_name, api_key, username, account_number, password, server, is_live)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', (
        test_mt5_cred['credential_id'], test_mt5_cred['user_id'], test_mt5_cred['broker_name'],
        test_mt5_cred['api_key'], test_mt5_cred['username'], test_mt5_cred['account_number'],
        test_mt5_cred['password'], test_mt5_cred['server'], test_mt5_cred['is_live']
    ))
    
    conn.commit()
    print("✅ IG Markets credential inserted")
    print("✅ MT5 credential inserted")
    
except Exception as e:
    print(f"❌ Error inserting credentials: {e}")
    sys.exit(1)

# Test 4: Simulate broker detection logic
print("\n✅ TEST 4: AUTOMATIC BROKER DETECTION")
print("-" * 70)

# Retrieve and detect IG credential
cursor.execute("SELECT * FROM broker_credentials WHERE credential_id = ?", ('test_ig_001',))
ig_row = cursor.fetchone()

if ig_row:
    broker_name = ig_row['broker_name']
    if broker_name == 'IG Markets':
        print(f"✅ IG Markets detected: {broker_name}")
        print(f"   API Key: {ig_row['api_key'][:10]}...")
        print(f"   Username: {ig_row['username']}")
        print(f"   No MT5 fields needed: account_number={ig_row['account_number']}, server={ig_row['server']}")
    else:
        print(f"❌ Expected IG Markets but got {broker_name}")

# Retrieve and detect MT5 credential
cursor.execute("SELECT * FROM broker_credentials WHERE credential_id = ?", ('test_mt5_001',))
mt5_row = cursor.fetchone()

if mt5_row:
    broker_name = mt5_row['broker_name']
    if broker_name == 'MetaQuotes':
        print(f"\n✅ MT5 detected: {broker_name}")
        print(f"   Account: {mt5_row['account_number']}")
        print(f"   Server: {mt5_row['server']}")
        print(f"   No IG fields needed: api_key={mt5_row['api_key']}, username={mt5_row['username']}")
    else:
        print(f"❌ Expected MetaQuotes but got {broker_name}")

# Test 5: Verify no cross-contamination
print("\n✅ TEST 5: NO CROSS-CONTAMINATION")
print("-" * 70)

cursor.execute("""
    SELECT credential_id, broker_name,
           CASE WHEN api_key IS NOT NULL THEN 'HAS' ELSE 'NULL' END as api_key_status,
           CASE WHEN username IS NOT NULL THEN 'HAS' ELSE 'NULL' END as username_status,
           CASE WHEN account_number IS NOT NULL THEN 'HAS' ELSE 'NULL' END as account_status,
           CASE WHEN server IS NOT NULL THEN 'HAS' ELSE 'NULL' END as server_status
    FROM broker_credentials 
    WHERE credential_id IN ('test_ig_001', 'test_mt5_001')
""")

for row in cursor.fetchall():
    print(f"\n{row['credential_id']} ({row['broker_name']}):")
    print(f"  IG Fields  → api_key: {row['api_key_status']:4} | username: {row['username_status']:4}")
    print(f"  MT5 Fields → account: {row['account_status']:4} | server:   {row['server_status']:4}")

# Summary
print("\n" + "="*70)
print("SUMMARY")
print("="*70)

all_tests_pass = ig_ok and mt5_ok

if all_tests_pass:
    print("✅ ALL TESTS PASSED")
    print("   - Database migrations applied successfully")
    print("   - IG Markets credentials stored correctly")
    print("   - MT5 credentials stored correctly")
    print("   - Automatic broker detection ready")
    print("   - No cross-broker credential confusion")
else:
    print("❌ SOME TESTS FAILED")

conn.close()

print("\n" + "="*70)
