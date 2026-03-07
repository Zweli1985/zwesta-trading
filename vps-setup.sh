#!/bin/bash
# Zwesta Trading System - VPS Setup and Deployment Script
# Usage: bash vps-setup.sh

set -e

echo "=================================================="
echo "Zwesta Trading System - VPS Setup"
echo "=================================================="
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use: sudo bash vps-setup.sh)"
   exit 1
fi

# Variables
DOMAIN=${1:-localhost}
WEB_ROOT="/var/www/zwesta-trading"
NGINX_AVAIL="/etc/nginx/sites-available/zwesta-trading"

echo "[1/5] Creating web root directory..."
mkdir -p $WEB_ROOT
echo "✓ Directory created: $WEB_ROOT"
echo ""

echo "[2/5] Installing/updating Nginx..."
apt-get update > /dev/null 2>&1
apt-get install -y nginx > /dev/null 2>&1
echo "✓ Nginx installed"
echo ""

echo "[3/5] Copying Nginx configuration..."
if [ -f "nginx-http.conf" ]; then
    cp nginx-http.conf "$NGINX_AVAIL"
    echo "✓ Nginx config copied to $NGINX_AVAIL"
else
    echo "✗ Error: nginx-http.conf not found in current directory"
    exit 1
fi
echo ""

echo "[4/5] Enabling Nginx site..."
rm -f /etc/nginx/sites-enabled/default
ln -sf "$NGINX_AVAIL" /etc/nginx/sites-enabled/zwesta-trading
echo "✓ Site enabled"
echo ""

echo "[5/5] Testing and reloading Nginx..."
if nginx -t > /dev/null 2>&1; then
    systemctl reload nginx
    echo "✓ Nginx configuration valid and reloaded"
else
    echo "✗ Nginx configuration test failed!"
    nginx -t
    exit 1
fi
echo ""

echo "=================================================="
echo "✓ VPS Setup Complete!"
echo "=================================================="
echo ""
echo "Next steps:"
echo "1. Copy your Flutter web build to: $WEB_ROOT"
echo "   Example: cp -r build/web/* $WEB_ROOT/"
echo ""
echo "2. Verify the site is running:"
echo "   - Open http://$(hostname -I | awk '{print $1}') in browser"
echo "   - Check logs: tail -f /var/log/nginx/zwesta-error.log"
echo ""
echo "3. For HTTPS (recommended for production):"
echo "   - Edit $NGINX_AVAIL"
echo "   - Uncomment SSL sections"
echo "   - Get certificate: sudo certbot certonly --nginx -d your-domain.com"
echo "   - Reload: sudo systemctl reload nginx"
echo ""
echo "4. Monitor the app:"
echo "   Access logs: tail -f /var/log/nginx/zwesta-access.log"
echo "   Error logs:  tail -f /var/log/nginx/zwesta-error.log"
echo ""
