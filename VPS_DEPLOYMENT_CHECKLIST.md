# VPS Deployment Checklist

## Pre-Deployment Phase

### System Preparation
- [ ] VPS instance provisioned (2+ CPU, 4GB+ RAM recommended)
- [ ] Ubuntu 20.04 LTS or later installed
- [ ] SSH access configured with key-based authentication
- [ ] Firewall rules configured (ports 22, 80, 443 open)
- [ ] System packages updated (`apt update && apt upgrade`)

### Development Preparation
- [ ] Flutter SDK installed locally for testing
- [ ] Git repository initialized with .gitignore
- [ ] All dependencies in pubspec.yaml updated
- [ ] Local testing completed successfully
- [ ] Code committed to main branch

### Documentation Review
- [ ] VPS_DEPLOYMENT_GUIDE.md reviewed
- [ ] ENHANCED_FEATURES.md understood
- [ ] IMPLEMENTATION_SUMMARY.md reviewed
- [ ] Environment configuration understood

---

## Environment Setup Phase

### Install Required Tools
- [ ] Git installed on VPS
- [ ] Curl, unzip, and other utilities installed
- [ ] Flutter SDK downloaded and extracted to /opt/flutter
- [ ] Flutter PATH configured in ~/.bashrc
- [ ] `flutter doctor` ran successfully

### Database Setup
- [ ] PostgreSQL installed
- [ ] Database 'zwesta' created
- [ ] User 'zwesta_user' created with password
- [ ] Permissions granted to user on database
- [ ] Database connectivity tested
- [ ] Backup scripts configured

### Web Server Setup
- [ ] Nginx installed
- [ ] Nginx configuration file created
- [ ] Nginx status verified (`nginx -t`)
- [ ] Nginx service started and enabled
- [ ] Web root directory configured (/var/www/zwesta-trading)

---

## Security Phase

### SSL/TLS Certificate
- [ ] Domain name registered and DNS configured
- [ ] Let's Encrypt certbot installed
- [ ] SSL certificate obtained
  ```bash
  sudo certbot certonly --nginx -d api.zwesta.com
  ```
- [ ] Certificate auto-renewal configured
- [ ] SSL certificate path added to Nginx config

### Server Security
- [ ] SSH key-based authentication enabled
- [ ] Password authentication disabled in SSH config
- [ ] Firewall rules configured with UFW
  ```bash
  sudo ufw allow 22/tcp
  sudo ufw allow 80/tcp
  sudo ufw allow 443/tcp
  sudo ufw enable
  ```
- [ ] Fail2ban installed and configured (optional)
- [ ] SELinux or AppArmor configured (if applicable)

### Application Security
- [ ] Environment variables set for production
  ```bash
  export ZWESTA_ENV=production
  export DATABASE_URL=postgresql://...
  export API_KEY=your_secure_key
  ```
- [ ] API keys stored securely (not in code)
- [ ] Database credentials secured (not in code)
- [ ] CORS headers properly configured
- [ ] Rate limiting enabled on API endpoints

---

## Deployment Phase

### Application Setup
- [ ] Repository cloned to /var/www/zwesta-trading
- [ ] Ownership set correctly: `sudo chown -R www-data:www-data /var/www/zwesta-trading`
- [ ] `flutter pub get` executed
- [ ] Application compiled successfully
  ```bash
  flutter build web --release --dart-define=ZWESTA_ENV=production
  ```

### Build Artifacts
- [ ] Build output verified in build/web directory
- [ ] Static files served by Nginx configured
- [ ] Service worker configured for offline support
- [ ] Assets properly loaded and accessible

### Service Configuration
- [ ] Systemd service file created
- [ ] Service enabled for auto-start
  ```bash
  sudo systemctl enable zwesta-trading
  sudo systemctl start zwesta-trading
  ```
- [ ] Service status verified
  ```bash
  sudo systemctl status zwesta-trading
  ```
- [ ] Service auto-restarts on failure configured

### Nginx Configuration
- [ ] Nginx config includes SSL redirects
- [ ] Proxy pass configured correctly
- [ ] Gzip compression enabled
- [ ] Cache headers configured
- [ ] Security headers added
  ```
  add_header X-Frame-Options "SAMEORIGIN";
  add_header X-Content-Type-Options "nosniff";
  ```
- [ ] Nginx reloaded and verified

---

## Monitoring & Logging Phase

### Logging Setup
- [ ] Application logs directory created: `/var/log/zwesta-trading/`
- [ ] Log rotation configured with logrotate
- [ ] Log file permissions set correctly
- [ ] Application logging to correct file verified

### Monitoring Tools
- [ ] Monitoring tool installed (PM2, Datadog, New Relic, etc.)
- [ ] Performance metrics being collected
- [ ] Error tracking enabled
- [ ] Health check endpoint available
- [ ] Monitoring dashboard accessible

### Backup Configuration
- [ ] Database backup script created
- [ ] Backup schedule configured with cron
  ```bash
  0 2 * * * /usr/local/bin/backup-zwesta.sh
  ```
- [ ] Backup directory with sufficient space
- [ ] Backup restoration tested
- [ ] Backup files encrypted (optional)

### Updates Configuration
- [ ] Automatic security updates configured (optional)
- [ ] Flutter upgrade plan established
- [ ] Dependency update schedule defined
- [ ] Rollback procedure documented

---

## Testing Phase

### Functionality Testing
- [ ] Application loads at domain URL
- [ ] Login/authentication works
- [ ] Dashboard displays correctly
- [ ] Trade functionality operates
- [ ] Account management accessible
- [ ] Statement generation tested
- [ ] PDF export tested and downloads correctly

### Performance Testing
- [ ] Page load times acceptable (< 3 seconds)
- [ ] API response times acceptable (< 1 second)
- [ ] Database queries optimized
- [ ] No memory leaks detected
- [ ] CPU usage normal under load
- [ ] Connection pool working properly

### Security Testing
- [ ] HTTPS enforced on all pages
- [ ] SSL certificate valid (check with SSL Labs)
- [ ] API authentication working
- [ ] CORS properly restricted
- [ ] Rate limiting functional
- [ ] SQL injection prevention tested
- [ ] XSS protection verified

### Cross-Browser Testing
- [ ] Chrome/Chromium tested
- [ ] Firefox tested
- [ ] Safari tested (if applicable)
- [ ] Mobile browsers tested
- [ ] Responsive design verified

---

## Production Verification Phase

### Domain & Connectivity
- [ ] Domain resolves correctly
- [ ] IP address correct in DNS
- [ ] SSL certificate displays correctly
- [ ] Both HTTP and HTTPS load-tested
- [ ] Redirects working (HTTP to HTTPS)

### Database Connectivity
- [ ] Database connection pool working
- [ ] Data persistence verified
- [ ] Backups being created
- [ ] Query performance acceptable

### API Endpoints
- [ ] All endpoints operational
- [ ] Error responses formatted correctly
- [ ] Authentication tokens working
- [ ] API documentation updated

### User Features
- [ ] User registration functional
- [ ] User login successful
- [ ] Session management working
- [ ] Logout clears session
- [ ] Password reset works
- [ ] Profile updates persist

---

## Post-Deployment Phase

### Documentation Updates
- [ ] Deployment documentation updated
- [ ] API documentation current
- [ ] Architecture documentation created
- [ ] Runbook created for operations team
- [ ] Troubleshooting guide created

### Team Communication
- [ ] Team notified of deployment
- [ ] Release notes distributed
- [ ] Known issues documented
- [ ] Support contacts updated

### Monitoring & Maintenance
- [ ] Monitoring alerts tested
- [ ] Team trained on monitoring dashboard
- [ ] Escalation procedures defined
- [ ] On-call rotation established
- [ ] Incident response procedures created

### Future Planning
- [ ] Scaling strategy documented
- [ ] Disaster recovery plan created
- [ ] Growth projections analyzed
- [ ] Backup VPS strategy defined
- [ ] CDN implementation planned

---

## Rollback Contingency

### Preparation
- [ ] Previous version backed up
- [ ] Rollback procedure documented
- [ ] Database snapshot available
- [ ] Configuration rollback tested
- [ ] Time estimate for rollback: _____ minutes

### Rollback Triggers
- [ ] Critical bug affecting users defined
- [ ] Performance degradation threshold set
- [ ] Security vulnerability procedure defined
- [ ] Availability SLA threshold defined

### Rollback Execution
- [ ] Rollback command/script prepared
- [ ] Team trained on rollback
- [ ] Communication template ready
- [ ] Rollback success verification plan

---

## Sign-Off

- **Deployed By**: ____________________
- **Date**: ____________________
- **Time**: ____________________
- **Approved By**: ____________________
- **Production Environment**: ☐ Development  ☐ Staging  ☐ Production
- **Notes**: 
  ```
  
  
  
  ```

---

## Quick Reference

### Emergency Commands

```bash
# Check application status
sudo systemctl status zwesta-trading

# View application logs
sudo tail -f /var/log/zwesta-trading/app.log

# Restart application
sudo systemctl restart zwesta-trading

# Stop application
sudo systemctl stop zwesta-trading

# View Nginx status
sudo systemctl status nginx

# Test Nginx config
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Check database
psql -U zwesta_user -d zwesta

# Database backup
pg_dump -U zwesta_user zwesta > backup.sql
```

### Contact Information

- **DevOps Lead**: ____________________
- **Database Admin**: ____________________
- **Security Officer**: ____________________
- **Product Manager**: ____________________

---

**Version**: 1.0  
**Last Updated**: March 2026  
**Document Owner**: DevOps/Admin Team
