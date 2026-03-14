import os
from trading_ig import IGService
from flask import Blueprint, jsonify, request

ig_api = Blueprint('ig_api', __name__)

def get_ig_service():
    ig_service = IGService(
        os.environ['IG_USERNAME'],
        os.environ['IG_PASSWORD'],
        os.environ['IG_API_KEY'],
        os.environ['IG_ACCOUNT_ID'],
        acc_type='DEMO' if os.environ.get('IG_DEMO_MODE', 'true').lower() == 'true' else 'LIVE'
    )
    ig_service.create_session()
    return ig_service

def get_account_balance():
    ig = get_ig_service()
    accounts = ig.fetch_accounts()
    for acc in accounts['accounts']:
        if acc['accountId'] == os.environ['IG_ACCOUNT_ID']:
            return acc['balance']['balance']
    return None

@ig_api.route('/api/ig/balance', methods=['GET'])
def ig_balance():
    try:
        balance = get_account_balance()
        return jsonify({'success': True, 'balance': balance})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

# IG does not support direct withdrawals via API for most retail accounts.
# This endpoint is a placeholder for notification/admin/manual action.
@ig_api.route('/api/ig/withdraw', methods=['POST'])
def ig_withdraw():
    data = request.json
    amount = data.get('amount')
    # Here you would trigger a notification or admin approval for withdrawal
    return jsonify({'success': False, 'error': 'Direct withdrawal via IG API is not supported. Please process manually.'}), 400
