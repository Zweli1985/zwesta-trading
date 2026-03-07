# VPS Configuration Guide - Zwesta Trading System

## Environment Variables for Web Deployment

The Zwesta Trading System supports environment variable configuration for flexible VPS deployment without rebuilding the application.

### Building with Environment Variables

#### 1. **Production Build with Custom API URL**

```bash
cd "c:\zwesta-trader\Zwesta Flutter App"
flutter build web --release \
  --dart-define=ZWESTA_ENV=production \
  --dart-define=API_URL=https://your-vps-domain.com/api \
  --dart-define=API_KEY=your_production_api_key
```

#### 2. **Staging Build with Custom Settings**

```bash
flutter build web --release \
  --dart-define=ZWESTA_ENV=staging \
  --dart-define=API_URL=https://staging-api.your-domain.com \
  --dart-define=API_KEY=your_staging_api_key
```

#### 3. **Development Build with Local API**

```bash
flutter build web --release \
  --dart-define=ZWESTA_ENV=development \
  --dart-define=API_URL=http://localhost:8080
```

#### 4. **Testing Build with Offline Mode (Mock Data)**

```bash
flutter build web --release \
  --dart-define=ZWESTA_ENV=production \
  --dart-define=OFFLINE_MODE=true
```

### Configuration Options

#### Available Environment Variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `ZWESTA_ENV` | `production` | Environment: `development`, `staging`, or `production` |
| `API_URL` | Environment-specific | Full API endpoint URL (e.g., `https://api.zwesta.com`) |
| `API_KEY` | Environment-specific | API authentication key |
| `OFFLINE_MODE` | `false` | Enable offline mode with mock data: `true` or `false` |

### Deployment Configurations

#### Configuration A: Production with Real API

```bash
flutter build web --release \
  --dart-define=ZWESTA_ENV=production \
  --dart-define=API_URL=https://api.zwesta.com \
  --dart-define=API_KEY=prod_key_xyz123
```

**Use Case**: Production deployment with live backend API

---

#### Configuration B: Testing/Demo Mode

```bash
flutter build web --release \
  --dart-define=ZWESTA_ENV=production \
  --dart-define=OFFLINE_MODE=true
```

**Use Case**: Testing the UI without backend API running
- Dashboard shows mock trading data
- All screens fully functional
- Perfect for UAT and demonstrations
- No API calls made

---

#### Configuration C: Custom VPS with HTTPS

```bash
flutter build web --release \
  --dart-define=ZWESTA_ENV=production \
  --dart-define=API_URL=https://38.247.146.198:8443/api \
  --dart-define=API_KEY=vps_secure_key
```

**Use Case**: Deployment on custom VPS with SSL/TLS

---

#### Configuration D: Development/Local Testing

```bash
flutter build web --release \
  --dart-define=ZWESTA_ENV=development \
  --dart-define=API_URL=http://localhost:3000
```

**Use Case**: Local development environment

---

## Deploying to VPS

### Step 1: Build with Environment Variables

```bash
# Choose your configuration above and build
flutter build web --release --dart-define=ZWESTA_ENV=production --dart-define=API_URL=https://your-api.com
```

### Step 2: Upload to VPS

```bash
# Copy all web files to VPS
scp -r build/web/* user@your-vps:/var/www/zwesta-trading/
```

### Step 3: Configure Web Server

**Nginx Configuration** (`/etc/nginx/sites-available/zwesta-trading`):

```nginx
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    root /var/www/zwesta-trading;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.dart\.js$ {
        expires 1d;
        add_header Cache-Control "public, immutable";
    }

    location ~* \.js$ {
        expires 1h;
    }

    location ~* \.css$ {
        expires 1h;
    }

    location ~* \.(jpg|jpeg|png|gif|ico|svg)$ {
        expires 30d;
    }
}
```

### Step 4: Enable Site and Reload Nginx

```bash
sudo ln -s /etc/nginx/sites-available/zwesta-trading /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Offline Mode (Testing)

When deployed with `--dart-define=OFFLINE_MODE=true`:

### Dashboard Features (All Functional):
- ✅ Portfolio Overview with mock data
- ✅ Trade Results Distribution chart
- ✅ Active positions and open trades
- ✅ Win rate calculations
- ✅ Historical trade data

### Mock Data Includes:
- 5 sample trades (mixed wins/losses)
- Multiple account examples
- Realistic trading metrics
- Sample financial data

### Perfect For:
- UAT testing without backend
- Feature demonstrations
- Mobile/tablet testing
- Training and onboarding
- Performance testing

## Runtime Configuration

You can also set configuration at runtime in your Dart code:

```dart
import 'package:zwesta_trading/utils/environment_config.dart';

// Set custom API URL at runtime
EnvironmentConfig.setApiUrl('https://your-new-api.com');

// Enable offline mode at runtime
EnvironmentConfig.setOfflineMode(true);

// Get current configuration
String config = EnvironmentConfig.getConfigSummary();
print(config);
```

## Troubleshooting

### Issue: "Service Worker API unavailable"
**Solution**: Ensure HTTPS is properly configured on VPS

### Issue: "API requests failing with 404"
**Solution**: Verify API_URL is correct:
```bash
flutter build web --release --dart-define=API_URL=https://correct-url.com
```

### Issue: "App shows blank screen"
**Solution**: Enable offline mode for testing:
```bash
flutter build web --release --dart-define=OFFLINE_MODE=true
```

### Issue: "API Key authentication failing"
**Solution**: Update API_KEY in build command:
```bash
flutter build web --release --dart-define=API_KEY=your_actual_key
```

## Monitoring & Logging

The app logs configuration info on startup (when in debug mode):

```
=== Zwesta Trading System Configuration ===
Environment: Production
API URL: https://api.zwesta.com
Offline Mode: false
Debug Mode: false
Log Level: ERROR
App Version: 1.0.0
==========================================
```

## Security Best Practices

1. **Never commit API keys** - Use environment variables
2. **Always use HTTPS** in production - Install SSL certificates
3. **Rotate API keys** regularly
4. **Use strong passwords** for VPS access
5. **Enable firewalls** - Restrict API access to known IPs
6. **Monitor logs** - Check Nginx error logs regularly

```bash
# View Nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

## Production Checklist

- [ ] HTTPS/SSL certificates installed
- [ ] Correct API_URL configured
- [ ] API_KEY set to production value
- [ ] OFFLINE_MODE set to false
- [ ] Database backups configured
- [ ] Log monitoring setup
- [ ] Firewall rules configured
- [ ] Health check endpoint tested
- [ ] CDN configured for static assets (optional)
- [ ] Load balancer setup (for high traffic)
