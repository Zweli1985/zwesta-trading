# Web Deployment Package Manifest
# All files required for production VPS deployment

## Essential Core Files ✅
- build/web/index.html                      # Main entry point
- build/web/flutter_bootstrap.js            # Flutter loader and initialization
- build/web/flutter.js                      # Flutter framework runtime
- build/web/main.dart.js                    # Compiled Dart application code

## Canvas & Rendering ✅
- build/web/canvaskit/canvaskit.js         # Canvas rendering library
- build/web/canvaskit/canvaskit.wasm       # Canvas WebAssembly binary
- build/web/canvaskit/canvaskit.js.symbols # Debug symbols for Canvas Kit
- build/web/canvaskit/chromium/canvaskit.js           # Optimized for Chromium
- build/web/canvaskit/chromium/canvaskit.js.symbols   # Chromium symbols

## Service Worker & Offline Support ✅
- build/web/flutter_service_worker.js      # Service worker for offline/caching
- build/web/manifest.json                  # Progressive Web App manifest

## Assets & Resources ✅
- build/web/assets/AssetManifest.json      # Asset manifest
- build/web/assets/AssetManifest.bin.json  # Binary asset manifest
- build/web/assets/FontManifest.json       # Font definitions
- build/web/assets/NOTICES                 # License information
- build/web/assets/fonts/                  # Font files
- build/web/assets/packages/               # Package assets
- build/web/assets/images/                 # Application images
- build/web/assets/shaders/                # Shader files

## Optional Debug Files (Remove for Production)
- build/web/.last_build_id                 # Build ID for tracking

## Configuration Files (Not in build/, place manually)
- .htaccess                                [TO CREATE] Apache web server config
- nginx.conf                               [TO CREATE] Nginx web server config
- robots.txt                               [TO CREATE] Search engine directives
- sitemap.xml                              [TO CREATE] Site map for SEO

## Security Files (Manual setup)
- ssl.crt                                  [EXTERNAL] SSL certificate
- ssl.key                                  [EXTERNAL] SSL private key

## Deployment Files
- package-lock.json                        [OPTIONAL] Dependencies lock
- .env.production                          [EXTERNAL] Production environment config

---

## File Size Reference (Approximate)

| File | Size | Purpose |
|------|------|---------|
| flutter_bootstrap.js | ~30KB | Loader |
| flutter.js | ~2MB | Runtime |
| main.dart.js | ~3-5MB | Application code |
| canvaskit.wasm | ~8MB | Rendering engine |
| Total (uncompressed) | ~15MB | Full application |
| Total (gzip compressed) | ~3-4MB | Network transfer |

---

## Deployment Checklist

### Files Present ✅
- [x] index.html - Main HTML entry point
- [x] flutter_bootstrap.js - Flutter loader
- [x] flutter.js - Flutter runtime
- [x] canvaskit/ - Complete rendering engine

### Files Missing ⚠️ (TO CREATE)
- [ ] robots.txt - search engine directives
- [ ] .htaccess - Apache configuration (if using Apache)
- [ ] nginx.conf - Nginx configuration (if using Nginx)
- [ ] sitemap.xml - SEO site map
- [ ] .env.production - Production environment variables

### Verification Steps

1. **Check Build Output:**
   ```bash
   ls -la build/web/
   ls -la build/web/canvaskit/
   ls -la build/web/assets/
   ```

2. **Verify File Integrity:**
   ```bash
   du -sh build/web/              # Total size
   find build/web -type f | wc -l # File count
   ```

3. **Test Locally:**
   ```bash
   cd build/web
   python3 -m http.server 8000
   # Visit http://localhost:8000
   ```

4. **Deploy to VPS:**
   ```bash
   scp -r build/web/* user@vps:/var/www/zwesta-trading/
   ```

---

## VPS Web Server Configuration

### For Nginx (Recommended)
See nginx.conf in root directory for complete configuration

### For Apache
See .htaccess in root directory for complete configuration

### For Node.js/Express
Use appropriate middleware for static file serving

---

## Service Worker & Offline Support

The flutter_service_worker.js provides:
- Asset caching for offline access
- Version management
- Automatic updates
- Network fallback

Version in manifest: auto-generated based on assets

---

## Asset Management

### Image Assets
Located in: build/web/assets/images/
- Compressed for web delivery
- Multiple resolution support

### Fonts
Located in: build/web/assets/fonts/
- Preloaded for performance
- Web-optimized formats

### Icons & Metadata
- AppIcon references from manifest.json
- Favicon in web/favicon.png
- Apple touch icon for iOS

---

## Size Optimization Tips

1. **Enable Gzip Compression** (on web server)
   - Reduces transfer size by 75-85%
   - Configure server to compress .js, .wasm, .json

2. **Set Cache Headers**
   - Browser cache for static assets
   - Service worker for offline support

3. **Content Delivery Network (Optional)**
   - Use CDN for canvaskit/ directory
   - Distribute load across regions

4. **Remove Debug Symbols (Optional)**
   - Build with `--dart-define=DART_OBFUSCATION=true`
   - Reduces canvaskit.js.symbols size

---

## Environment Configuration

### Production Environment Setup
```bash
export ZWESTA_ENV=production
export FLUTTER_WEB_PORT=8080
export FLUTTER_WEB_HOSTNAME=0.0.0.0
```

### Build Command
```bash
flutter build web --release --dart-define=ZWESTA_ENV=production
```

---

## Monitoring & Health Checks

### Health Check Endpoint
```
GET / -> Returns index.html (200 OK)
GET /manifest.json -> Returns manifest (200 OK)
GET /assets/* -> Returns assets (200 OK)
```

### Performance Metrics
- First Contentful Paint (FCP): < 2s
- Largest Contentful Paint (LCP): < 3s
- Cumulative Layout Shift (CLS): < 0.1

---

## Troubleshooting

### Issue: Files not found (404)
- Verify correct relative paths
- Check web server configuration
- Ensure assets folder structure matches

### Issue: Service Worker errors
- Clear browser cache and service workers
- Reset: DevTools → Application → Clear storage
- Check browser console for errors

### Issue: WASM loading issues
- Verify MIME types configured on server
- Check CORS headers if loading from CDN
- Ensure .wasm files have correct permissions

### Issue: Slow loading
- Enable gzip compression
- Use service workers for caching
- Consider CDN for static assets
- Verify assets are minified

---

## Production Deployment Checklist

- [ ] All files in build/web/ verified
- [ ] File permissions set correctly (644 for files, 755 for directories)
- [ ] Web server configured (Nginx/Apache)
- [ ] SSL certificate installed
- [ ] HTTPS redirect configured
- [ ] Gzip compression enabled
- [ ] Cache headers configured
- [ ] Service worker test completed
- [ ] MIME types configured
- [ ] CORS headers set
- [ ] Monitoring enabled
- [ ] Backup configured
- [ ] Health checks passing
- [ ] Load testing completed

---

## Next Steps

1. Review [VPS_DEPLOYMENT_GUIDE.md](VPS_DEPLOYMENT_GUIDE.md)
2. Create missing configuration files below
3. Deploy build/web/ contents to VPS
4. Configure web server
5. Test application
6. Enable monitoring

---

**Version**: 1.0  
**Last Updated**: March 2026  
**Status**: Ready for VPS Deployment ✅
