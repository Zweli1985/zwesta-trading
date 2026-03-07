# Zwesta VPS HTTP Deployment - Troubleshooting Guide

## Quick Status Check

After reloading http://38.247.146.198, you should see:
- ✅ Loading spinner with "Loading Zwesta Trading System..." text
- ✅ Dashboard with mock data (Balance, Total Profit, Open Trades, Win Rate)
- ⚠️ Service Worker errors may still appear in console (harmless on HTTP)

## If You Still See a Blank Page

### Step 1: Check Browser Console (F12)

Open DevTools (F12) and check Console tab for errors. Common issues:

#### Issue A: "Cannot find /assets/..." or "Cannot find /canvaskit/..."
**Cause**: Flutter assets aren't being served
**Fix**: 
```bash
# SSH to VPS
ssh root@38.247.146.198

# Check if assets are in web root
ls -la /var/www/zwesta-trading/assets/
ls -la /var/www/zwesta-trading/canvaskit/

# If empty, copy the build
cp -r ~/build/web/* /var/www/zwesta-trading/
chmod -R 755 /var/www/zwesta-trading/
```

#### Issue B: "main.dart.js not found" or "404 on /main.dart.js"
**Cause**: Flutter app script not served
**Fix**:
```bash
# Check if main.dart.js exists
ls -la /var/www/zwesta-trading/main.dart.js

# If missing, rebuild and copy:
flutter clean
flutter build web --release --dart-define=ZWESTA_ENV=production --dart-define=OFFLINE_MODE=true
scp -r build/web/* root@38.247.146.198:/var/www/zwesta-trading/
```

#### Issue C: "Service Worker API unavailable"
**Cause**: Service Worker doesn't work on HTTP (this is expected)
**Status**: ✅ Fixed - We suppressed these errors in index.html
**Action Required**: None - app should work despite this warning

### Step 2: Check Nginx Configuration

```bash
# SSH to VPS
ssh root@38.247.146.198

# Test Nginx config
sudo nginx -t
# Should show: "syntax is ok" and "test is successful"

# View current config
sudo cat /etc/nginx/sites-enabled/zwesta-trading

# Reload Nginx with new config
sudo systemctl reload nginx

# Check Nginx status
sudo systemctl status nginx
```

### Step 3: Check Nginx Logs

```bash
# See last 50 lines of error log
sudo tail -50 /var/log/nginx/zwesta-error.log

# See real-time errors (Ctrl+C to exit)
sudo tail -f /var/log/nginx/zwesta-error.log

# See access log
sudo tail -50 /var/log/nginx/zwesta-access.log
```

### Step 4: Verify File Permissions

```bash
# Check permissions
ls -la /var/www/zwesta-trading/

# Fix permissions if needed
sudo chmod -R 755 /var/www/zwesta-trading/
sudo chown -R www-data:www-data /var/www/zwesta-trading/
```

## If App Shows but with Errors

### JavaScript Runtime Errors

If you see JavaScript errors like `RangeError: Invalid value`, this might be:
1. Old browser cache - Hard reload with Ctrl+Shift+R
2. Source map issues (non-critical) - App still works
3. Bootstrap timing issue - Reload page once more

**Fix**:
```bash
# Clear browser cache or use incognito mode
# Hard reload: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
```

### Missing Icons/Favicon

Manifest shows 404s for icons. This is expected and fixed.

**Check**:
```bash
# Icons are optional - app should work without them
# If you want them later, re-add to manifest.json
```

## Complete Reset Steps

If nothing works, do a complete reset:

```bash
# 1. SSH to VPS
ssh root@38.247.146.198

# 2. Stop Nginx
sudo systemctl stop nginx

# 3. Clear web directory
sudo rm -rf /var/www/zwesta-trading/*

# 4. Rebuild locally (on your machine)
cd ~/Zwesta\ Flutter\ App/
flutter clean
flutter build web --release --dart-define=ZWESTA_ENV=production --dart-define=OFFLINE_MODE=true

# 5. Copy fresh build
scp -r build/web/* root@38.247.146.198:/var/www/zwesta-trading/

# 6. Fix permissions
ssh root@38.247.146.198 'sudo chmod -R 755 /var/www/zwesta-trading && sudo chown -R www-data:www-data /var/www/zwesta-trading'

# 7. Copy new Nginx config (if you haven't already)
scp nginx-http.conf root@38.247.146.198:/etc/nginx/sites-available/zwesta-trading

# 8. Re-enable and reload Nginx
ssh root@38.247.146.198 'sudo systemctl start nginx && sudo systemctl reload nginx'

# 9. Test
# Open in browser: http://38.247.146.198
```

## Expected Behavior

### On Page Load (First 2-3 seconds)
1. See "Loading Zwesta Trading System..." with spinner
2. Browser console: Service Worker API message (harmless)
3. No fatal JavaScript errors

### After App Loads
1. Dashboard displays with:
   - Balance card
   - Total Profit card
   - Open Trades card
   - Win Rate card
2. All cards show mock data:
   - Balance: $45,250.00
   - Total Profit: +$4,250.00 (green)
   - Open Trades: 2
   - Win Rate: 66.67%
3. FinTA tab (Financials) accessible with financial breakdown
4. Navigation works between all tabs

## Manual Nginx Configuration

If you need to configure Nginx manually:

```bash
# 1. SSH to VPS
ssh root@38.247.146.198

# 2. Create config directory if needed
sudo mkdir -p /etc/nginx/sites-available
sudo mkdir -p /etc/nginx/sites-enabled

# 3. Create basic HTTP config
sudo cat > /etc/nginx/sites-available/zwesta-trading << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/zwesta-trading;
    index index.html;
    
    access_log /var/log/nginx/zwesta-access.log;
    error_log /var/log/nginx/zwesta-error.log;
    
    # Gzip compression
    gzip on;
    gzip_types text/plain text/css text/javascript application/json;
    
    # Cache headers for static files
    location ~* \.(js|css|png|jpg|svg|woff2)$ {
        expires 30d;
    }
    
    # Main SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }
}
EOF

# 4. Enable the site
sudo ln -sf /etc/nginx/sites-available/zwesta-trading /etc/nginx/sites-enabled/

# 5. Test and reload
sudo nginx -t
sudo systemctl reload nginx

# 6. Verify
sudo systemctl status nginx
```

## For HTTPS (Production)

Once HTTP is working and app displays correctly:

```bash
# 1. Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# 2. Get certificate (replace your-domain.com)
sudo certbot certonly --nginx -d your-domain.com

# 3. Update Nginx config with SSL settings

# 4. Reload
sudo systemctl reload nginx
```

## Quick Health Check Commands

```bash
# Check if Nginx is running
sudo systemctl status nginx

# Check if port 80 is listening
sudo lsof -i :80

# Check web root exists and has files
ls -la /var/www/zwesta-trading/

# Test main.dart.js loads
curl -I http://38.247.146.198/main.dart.js

# Test index.html loads
curl -I http://38.247.146.198/

# Check current load time
curl -w "Time: %{time_total}s\n" -o /dev/null -s http://38.247.146.198/
```

## Next: Test Now

**Action Required**: 
1. Reload http://38.247.146.198 in your browser
2. Press Shift+Ctrl+R for hard refresh (clears cache)
3. Check browser console (F12 > Console tab)
4. Report any errors you see

**Expected Result**: 
- Loading spinner shows
- Dashboard loads with mock data
- No critical JavaScript errors
