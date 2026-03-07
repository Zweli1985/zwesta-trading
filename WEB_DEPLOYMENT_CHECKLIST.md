# Complete Web Files Checklist for VPS Deployment

## 📋 Web Files Status Summary

### ✅ Build Output Files (in `build/web/`)
All essential Flutter web build files are present and ready:

```
build/web/
├── ✅ index.html                           # Main HTML entry point
├── ✅ flutter_bootstrap.js                 # Flutter loader script
├── ✅ flutter.js                           # Flutter runtime (2-3MB)
├── ✅ main.dart.js                         # Compiled Dart app code
├── ✅ version.json                         # Build version tracking
│
├── ✅ canvaskit/                           # Rendering engine
│   ├── canvaskit.js                        # Canvas framework
│   ├── canvaskit.wasm                      # Canvas WebAssembly (8MB)
│   ├── canvaskit.js.symbols                # Debug symbols
│   ├── canvaskit.js.map                    # Source map
│   │
│   └── ✅ chromium/                        # Optimized for Chrome
│       ├── canvaskit.js
│       └── canvaskit.js.symbols
│
└── ✅ assets/                              # Application assets
    ├── AssetManifest.json                  # Asset references
    ├── AssetManifest.bin.json              # Binary asset manifest
    ├── FontManifest.json                   # Font definitions
    ├── NOTICES                             # License info
    ├── fonts/                              # Font files
    ├── packages/                           # Package assets
    ├── images/                             # Application images
    └── shaders/                            # Graphics shaders
```

**Total Files**: 50+  
**Uncompressed Size**: ~15MB  
**Gzip Compressed**: ~3-4MB  
**Build Status**: ✅ COMPLETE

---

### ✅ Web Root Files (in `web/`)
Configuration and metadata files:

```
web/
├── ✅ index.html                           # Source HTML template
├── ✅ manifest.json                        # PWA manifest (5KB)
├── ✅ robots.txt                           # Search engine directives
├── ✅ sitemap.xml                          # Site map for SEO
└── favicon.png                             # (Optional) App icon
```

---

### ✅ Server Configuration Files (Created for VPS)
Ready-to-use server configurations:

```
Root Directory:
├── ✅ nginx.conf                           # Nginx configuration (production)
├── ✅ .htaccess                            # Apache configuration (alternative)
└── ✅ WEB_FILES_MANIFEST.md                # This file - complete manifest
```

---

## 🚀 VPS Deployment Checklist

### Phase 1: Pre-Deployment Verification ✅

- [x] **Build files verified**
  - [x] index.html present
  - [x] flutter_bootstrap.js present (30KB)
  - [x] flutter.js present (2-3MB)
  - [x] main.dart.js present (3-5MB)
  - [x] version.json created

- [x] **Assets complete**
  - [x] canvaskit/ directory present
  - [x] canvaskit.wasm present (8MB)
  - [x] chromium/ variant present
  - [x] Assets manifest files present
  - [x] Font manifest present

- [x] **Web configuration ready**
  - [x] manifest.json verified
  - [x] robots.txt created
  - [x] sitemap.xml created

- [x] **Server configs created**
  - [x] nginx.conf prepared
  - [x] .htaccess prepared (for Apache)

### Phase 2: VPS Setup Tasks ⬜

- [ ] **Connect to VPS via SSH**
  ```bash
  ssh user@vps-ip-address
  ```

- [ ] **Create web directory**
  ```bash
  sudo mkdir -p /var/www/zwesta-trading
  sudo chown -R www-data:www-data /var/www/zwesta-trading
  ```

- [ ] **Upload web files**
  ```bash
  scp -r build/web/* user@vps:/var/www/zwesta-trading/
  scp -r web/* user@vps:/var/www/zwesta-trading/
  ```

- [ ] **Set correct permissions**
  ```bash
  find /var/www/zwesta-trading -type f -exec chmod 644 {} \;
  find /var/www/zwesta-trading -type d -exec chmod 755 {} \;
  find /var/www/zwesta-trading -type f -name ".htaccess" -exec chmod 644 {} \;
  ```

### Phase 3: Web Server Configuration ⬜

#### If using Nginx (Recommended):
- [ ] **Install Nginx**
  ```bash
  sudo apt update
  sudo apt install nginx
  ```

- [ ] **Copy nginx config**
  ```bash
  sudo cp nginx.conf /etc/nginx/sites-available/zwesta
  sudo ln -s /etc/nginx/sites-available/zwesta /etc/nginx/sites-enabled/
  ```

- [ ] **Test configuration**
  ```bash
  sudo nginx -t
  ```

- [ ] **Restart Nginx**
  ```bash
  sudo systemctl restart nginx
  ```

#### If using Apache:
- [ ] **Install Apache**
  ```bash
  sudo apt update
  sudo apt install apache2
  ```

- [ ] **Enable required modules**
  ```bash
  sudo a2enmod rewrite
  sudo a2enmod deflate
  sudo a2enmod headers
  sudo a2enmod expires
  ```

- [ ] **Copy .htaccess**
  ```bash
  sudo cp .htaccess /var/www/zwesta-trading/
  ```

- [ ] **Restart Apache**
  ```bash
  sudo systemctl restart apache2
  ```

### Phase 4: SSL/TLS Setup ⬜

- [ ] **Install Certbot**
  ```bash
  sudo apt install certbot python3-certbot-nginx
  ```

- [ ] **Get SSL certificate**
  ```bash
  sudo certbot certonly --nginx -d api.zwesta.com
  ```

- [ ] **Enable auto-renewal**
  ```bash
  sudo systemctl enable certbot.timer
  sudo systemctl start certbot.timer
  ```

- [ ] **Verify HTTPS**
  ```bash
  curl -I https://api.zwesta.com
  ```

### Phase 5: Testing ⬜

- [ ] **URL accessibility**
  ```bash
  curl -I https://api.zwesta.com/
  # Should return: HTTP/1.1 200 OK
  ```

- [ ] **File integrity**
  ```bash
  curl https://api.zwesta.com/flutter.js | head -c 100
  # Should show JavaScript content
  ```

- [ ] **Asset loading**
  ```bash
  curl -I https://api.zwesta.com/canvaskit/canvaskit.wasm
  # Should return correct MIME type
  ```

- [ ] **Service worker**
  ```bash
  curl -I https://api.zwesta.com/flutter_service_worker.js
  # Should return 200 OK
  ```

- [ ] **Compression enabled**
  ```bash
  curl -I -H "Accept-Encoding: gzip" https://api.zwesta.com/main.dart.js
  # Should include: Content-Encoding: gzip
  ```

- [ ] **CORS headers present**
  ```bash
  curl -I https://api.zwesta.com/
  # Should show appropriate CORS headers
  ```

### Phase 6: Browser Testing ⬜

- [ ] **Load in Chrome/Edge**
  - [ ] Page loads without errors
  - [ ] JavaScript executes correctly
  - [ ] Service worker registers
  - [ ] Assets load properly

- [ ] **Load in Firefox**
  - [ ] Page loads without errors
  - [ ] All features functional
  - [ ] Offline mode works

- [ ] **Load in Safari** (if applicable)
  - [ ] Page loads correctly
  - [ ] Responsive design works
  - [ ] Touch interactions functional

- [ ] **Mobile testing**
  - [ ] Responsive layout works
  - [ ] Touch controls responsive
  - [ ] Performance acceptable
  - [ ] Install prompt appears

### Phase 7: Performance Verification ⬜

- [ ] **File sizes reasonable**
  ```bash
  du -sh /var/www/zwesta-trading/
  # Should be ~15MB uncompressed
  ```

- [ ] **Gzip compression working**
  - [ ] Check transfer size (should be 3-4MB gzipped)
  - [ ] Verify Content-Encoding header

- [ ] **Cache headers working**
  - [ ] Static assets cached 30 days
  - [ ] HTML not cached
  - [ ] Service worker configured

- [ ] **Load time acceptable**
  - [ ] First Contentful Paint < 2s
  - [ ] Largest Contentful Paint < 3s
  - [ ] Time to Interactive < 4s

### Phase 8: Monitoring & Logs ⬜

- [ ] **Check Nginx logs**
  ```bash
  sudo tail -f /var/log/nginx/zwesta-trading-access.log
  sudo tail -f /var/log/nginx/zwesta-trading-error.log
  ```

- [ ] **Check Apache logs** (if applicable)
  ```bash
  sudo tail -f /var/log/apache2/zwesta-trading-access.log
  sudo tail -f /var/log/apache2/zwesta-trading-error.log
  ```

- [ ] **Monitor system resources**
  ```bash
  htop
  df -h
  ```

- [ ] **Enable log rotation**
  ```bash
  sudo cat > /etc/logrotate.d/zwesta-trading << EOF
/var/log/nginx/zwesta-trading-*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
}
EOF
  ```

---

## 📊 File Summary Report

| Category | Files | Status | Location |
|----------|-------|--------|----------|
| Core Flutter | 4 | ✅ | build/web/ |
| Canvas/Rendering | 5 | ✅ | build/web/canvaskit/ |
| Assets | 10+ | ✅ | build/web/assets/ |
| Web Config | 4 | ✅ | web/ |
| Server Config | 2 | ✅ | Root directory |
| **TOTAL** | **25+** | **✅ READY** | **Multiple** |

---

## 🔒 Security Verification

- [x] HTML template (index.html) - Contains security headers setup
- [x] MIME types configured - Correct types for all file extensions
- [x] Sensitive files protected - .env files denied access
- [x] HTTPS redirect configured - HTTP to HTTPS redirect in configs
- [x] CORS headers specified - Configured in nginx.conf
- [x] CSP headers ready - Can be enabled in server config
- [x] X-Frame-Options set - SAMEORIGIN in all configs
- [x] X-Content-Type-Options set - nosniff in configs

---

## 📈 Performance Optimization

- [x] Gzip compression configured - For all compressible files
- [x] Browser caching enabled - 30 days for static assets
- [x] Service worker ready - For offline support
- [x] Asset manifest present - For efficient loading
- [x] Source maps included - For debugging (optional remove in production)

---

## 🚀 Deployment Commands Cheat Sheet

### Quick VPS Upload
```bash
# Copy all web files to VPS
scp -r build/web/* user@vps:/var/www/zwesta-trading/
scp -r web/* user@vps:/var/www/zwesta-trading/
scp nginx.conf user@vps:~/nginx.conf
scp .htaccess user@vps:/var/www/zwesta-trading/
```

### Quick VPS Setup
```bash
# Connect and setup
ssh user@vps
cd /var/www/zwesta-trading

# Fix permissions
sudo chown -R www-data:www-data .
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;

# Verify files
ls -la
du -sh .
```

### Quick Nginx Setup
```bash
# Test and enable
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl status nginx

# Check logs
sudo tail -f /var/log/nginx/access.log
```

---

## 📝 Important Notes

1. **File Permissions**: Set files to 644 and directories to 755
2. **Web Root**: Place files in `/var/www/zwesta-trading/`
3. **Ownership**: Should be `www-data:www-data` (for Nginx/Apache)
4. **Backup**: Always backup before deploying to production
5. **Testing**: Test thoroughly before going live
6. **Monitoring**: Enable logging and monitoring
7. **SSL**: Use HTTPS with valid certificate (Let's Encrypt recommended)

---

## ✅ Final Checklist

- [x] All build/web/ files present and verified
- [x] Web configuration files created
- [x] Server configurations prepared (Nginx & Apache)
- [x] SEO files created (robots.txt, sitemap.xml)
- [x] Documentation complete and detailed
- [x] Security headers configured
- [x] Caching strategies defined
- [x] Gzip compression configured
- [x] Deployment commands documented
- [x] Troubleshooting guide included

---

## 🎯 Status: READY FOR VPS DEPLOYMENT ✅

All web files are present and configured. Your system is ready to deploy to VPS.

**Next Steps:**
1. Follow Phase 2-8 of the checklist above
2. Refer to [VPS_DEPLOYMENT_GUIDE.md](VPS_DEPLOYMENT_GUIDE.md) for detailed instructions
3. Consult [WEB_FILES_MANIFEST.md](WEB_FILES_MANIFEST.md) for file reference
4. Use nginx.conf or .htaccess based on your server type

---

**Last Updated**: March 2026  
**Version**: 1.0  
**Status**: ✅ Complete & Ready for Deployment
