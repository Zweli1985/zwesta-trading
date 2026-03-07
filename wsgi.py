#!/usr/bin/env python3
"""
WSGI entry point for production deployment
Use with Gunicorn, uWSGI, or other WSGI servers
"""

import os
import sys

# Add project root to path
project_root = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, project_root)

# Import and configure the Flask app
from multi_broker_backend_updated import app

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=9000)
