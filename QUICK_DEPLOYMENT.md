# Quick VPS Deployment Guide

## 🚀 Three Ways to Deploy

### 1. **Testing/Demo Mode** (Current Build - Offline Mode)
```bash
# Already built - ready to deploy!
# Location: build/web/
# Features: All features work with mock data
```
- ✅ Perfect for testing on VPS without backend
- ✅ Dashboard shows realistic trading data
- ✅ All screens fully functional
- ✅ No API dependency

**Deploy to VPS:**
```bash
scp -r build/web/* user@38.247.146.198:/var/www/zwesta-trading/
```

---

### 2. **Production Mode** (Real API)
```bash
flutter build web --release \
  --dart-define=ZWESTA_ENV=production \
  --dart-define=API_URL=https://your-api-domain.com \
  --dart-define=API_KEY=your_production_key
```
- ✅ Uses live backend API
- ✅ Real trading data
- ✅ Production configuration

---

### 3. **Custom Configuration** (Using deploy.bat)
```bash
# Windows:
deploy.bat -e production -a https://your-api.com -k your_key -o

# Linux/Mac:
./deploy.sh -e production -a https://your-api.com -k your_key -o
```

---

## 📦 Current Build Status

**Build Type:** Offline Mode (Demo)  
**Build Date:** 2026-03-06  
**Environment:** Production  
**Location:** `build/web/`  
**Size:** ~5-10 MB  
**Status:** ✅ Ready for deployment  

---

## 🔧 Dashboard Container Sizing

The dashboard automatically resizes containers to fit the screen:

```
┌─────────────────────────────────────┐
│     Portfolio Overview              │
├──────────────────┬──────────────────┤
│   Balance        │   Total Profit   │
│   $75,000.00     │   $250.00        │
├──────────────────┼──────────────────┤
│   Open Trades    │   Win Rate       │
│   3              │   50.0% (1W/2T)  │
└──────────────────┴──────────────────┘
```

**Features:**
- 2x2 grid layout (responsive)
- Auto-sizing based on screen width
- Perfect fit on mobile, tablet, and desktop
- Compact card design
- Color-coded metrics

---

## 📋 VPS Deployment Checklist

- [ ] **HTTPS Setup**
  ```bash
  # Install SSL certificate (Let's Encrypt)
  sudo apt-get install certbot python3-certbot-nginx
  sudo certbot certonly --nginx -d your-domain.com
  ```

- [ ] **Nginx Configuration**
  ```bash
  sudo cp nginx.conf /etc/nginx/sites-available/zwesta-trading
  sudo ln -s /etc/nginx/sites-available/zwesta-trading /etc/nginx/sites-enabled/
  sudo nginx -t
  sudo systemctl reload nginx
  ```

- [ ] **Upload Web Build**
  ```bash
  scp -r build/web/* user@your-vps:/var/www/zwesta-trading/
  ```

- [ ] **Set Permissions**
  ```bash
  sudo chown -R www-data:www-data /var/www/zwesta-trading
  sudo chmod -R 755 /var/www/zwesta-trading
  ```

- [ ] **Test Access**
  ```
  Visit: https://your-domain.com
  or http://38.247.146.198
  ```

- [ ] **Monitor Logs**
  ```bash
  sudo tail -f /var/log/nginx/access.log
  sudo tail -f /var/log/nginx/error.log
  ```

---

## 🧪 Testing Locally First (Recommended)

Before deploying to VPS, test locally:

```bash
cd build/web
python3 -m http.server 8000
```

Then visit: `http://localhost:8000`

**Test the following:**
- ✓ Dashboard loads with mock data
- ✓ Trades screen shows sample trades
- ✓ Financial analytics calculate correctly
- ✓ Statements can be generated
- ✓ PDF export works
- ✓ All navigation works

---

## 🚨 Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Blank page | Service Worker error | Add HTTPS with valid cert |
| API fails | Wrong API_URL | Rebuild with correct URL |
| CSS/JS not loading | MIME type issues | Check Nginx config |
| High latency | Large JS bundle | Enable gzip compression |

**Enable Gzip Compression in Nginx:**
```nginx
gzip on;
gzip_vary on;
gzip_types text/plain text/css text/javascript application/javascript;
gzip_comp_level 6;
```

---

## 📊 Mock Data Included

When running in **Offline Mode**, the app includes:

**Accounts:**
- ZWS-2024-001: $75,000 balance
- ZWS-2024-002: $50,000 balance  
- ZWS-2024-003: $25,000 balance

**Sample Trades:**
- 2 Winning trades (EUR/USD, GBP/USD)
- 1 Losing trade (USD/JPY)
- 2 Open trades (AUD/USD, NZD/USD)
- Mixed profit/loss scenarios

**Financial Data:**
- Realistic profit margins
- Win rate calculations
- Cash flow analysis
- Investment tracking

---

## 🔐 Security Recommendations

1. **Update Nginx**
   ```bash
   sudo apt-get update && sudo apt-get upgrade nginx
   ```

2. **Add Security Headers**
   ```nginx
   add_header X-Frame-Options "SAMEORIGIN" always;
   add_header X-Content-Type-Options "nosniff" always;
   add_header X-XSS-Protection "1; mode=block" always;
   ```

3. **Enable HTTP/2**
   ```nginx
   listen 443 ssl http2;
   ```

4. **Regular Backups**
   ```bash
   tar -czf zwesta-backup-$(date +%Y%m%d).tar.gz /var/www/zwesta-trading/
   ```

---

## 📞 Support

For issues or questions:
1. Check `VPS_CONFIGURATION_GUIDE.md` for detailed configuration
2. Review Nginx error logs: `/var/log/nginx/error.log`
3. Check browser console (F12) for JavaScript errors
4. Verify SSL certificate: `sudo certbot certificates`

---

**Ready to deploy? Copy all files from `build/web/` to your VPS!** 🚀
