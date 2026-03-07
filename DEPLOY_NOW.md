# 3-Minute Deployment

## Windows (One Command)

```bash
cd "C:\zwesta-trader\Zwesta Flutter App"
.\deploy-to-vps.bat 38.247.146.198 root
```

## Any OS (Copy-Paste)

```bash
# Copy all files
scp -r build/web/* root@38.247.146.198:/var/www/zwesta-trading/

# Fix permissions  
ssh root@38.247.146.198 'sudo chown -R www-data:www-data /var/www/zwesta-trading'

# Reload web server
ssh root@38.247.146.198 'sudo systemctl reload nginx'
```

## Verify It Works

Open in browser:
- **Health Check**: http://38.247.146.198/health-check.html
- **Main App**: http://38.247.146.198/

Should see dashboard with mock data loading.

---

## Troubleshooting

Still blank? 

```bash
# Check VPS has your files
ssh root@38.247.146.198 'ls /var/www/zwesta-trading/index.html'

# Check Nginx errors
ssh root@38.247.146.198 'sudo tail -20 /var/log/nginx/zwesta-error.log'

# Check Nginx is running
ssh root@38.247.146.198 'sudo systemctl status nginx'
```

See an error in browser console (F12)? Paste it here and I'll help debug.

---

## File That Changed

- **index.html** - Added better error handling + loading UI
- **favicon.ico** - Created to fix 404 error
- **main.dart** - Safer environment variable parsing
- **health-check.html** - NEW diagnostic page
