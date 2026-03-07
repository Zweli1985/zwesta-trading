# Zwesta Trading System - VPS Deployment Guide

## Overview
This guide provides comprehensive instructions for deploying the Zwesta Trading System Flutter application to a VPS (Virtual Private Server) environment.

## Prerequisites

### System Requirements
- **VPS Specifications**: Recommended 2+ CPU cores, 4GB+ RAM
- **Operating System**: Linux (Ubuntu 20.04 LTS or later)
- **Storage**: Minimum 20GB free space
- **Network**: Stable internet connection with port forwarding capabilities

### Required Software
- Flutter SDK 3.0.0 or later
- Dart SDK (bundled with Flutter)
- Docker (optional, for containerization)
- Nginx (for reverse proxy)
- PostgreSQL or MySQL (for database)
- Redis (for caching, optional)

## Installation Steps

### 1. Install Flutter on VPS

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Flutter dependencies
sudo apt install -y git curl unzip xz-utils zip libglu1-mesa

# Download Flutter SDK
cd /opt
sudo wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.x.x-stable.tar.xz
sudo tar xf flutter_linux_3.x.x-stable.tar.xz

# Add Flutter to PATH
export PATH="$PATH:/opt/flutter/bin"
echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
flutter --version
```

### 2. Clone the Project

```bash
cd /var/www
git clone <repository-url> zwesta-trading
cd zwesta-trading
```

### 3. Configure Environment

Set environment variables for VPS deployment:

```bash
# Create .env file
cat > .env << EOF
ZWESTA_ENV=production
API_URL=https://api.zwesta.com
SECURE_TOKEN=your_secure_token_here
DATABASE_URL=postgresql://user:password@localhost/zwesta
EOF
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Build for Production (Web)

```bash
# Build web version for VPS
flutter build web --release --dart-define=ZWESTA_ENV=production

# Output directory: /workspace/build/web
```

### 6. Setup Nginx Reverse Proxy

```bash
# Install Nginx
sudo apt install -y nginx

# Create Nginx config
sudo cat > /etc/nginx/sites-available/zwesta << 'EOF'
server {
    listen 443 ssl http2;
    server_name api.zwesta.com;

    ssl_certificate /etc/ssl/certs/your_cert.crt;
    ssl_certificate_key /etc/ssl/private/your_key.key;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name api.zwesta.com;
    return 301 https://$server_name$request_uri;
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/zwesta /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 7. Setup Database

```bash
# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Create database
sudo -u postgres createdb zwesta
sudo -u postgres createuser zwesta_user
sudo -u postgres psql -c "ALTER USER zwesta_user WITH PASSWORD 'secure_password';"
```

### 8. Configure SSL Certificate

```bash
# Using Let's Encrypt
sudo apt install -y certbot python3-certbot-nginx
sudo certbot certonly --nginx -d api.zwesta.com
```

## Docker Deployment (Alternative)

### Create Dockerfile

```dockerfile
FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    git curl unzip xz-utils zip libglu1-mesa \
    postgresql-client

WORKDIR /app
COPY . .

RUN git clone https://github.com/flutter/flutter.git /flutter && \
    export PATH="/flutter/bin:$PATH" && \
    flutter pub get && \
    flutter build web --release --dart-define=ZWESTA_ENV=production

EXPOSE 8080

CMD ["flutter", "run", "-d", "web", "--web-port=8080", "--web-hostname=0.0.0.0"]
```

### Build and Run Docker Container

```bash
# Build image
docker build -t zwesta-trading:latest .

# Run container
docker run -d \
  --name zwesta-trading \
  -p 8080:8080 \
  -e ZWESTA_ENV=production \
  -e DATABASE_URL=postgresql://user:password@db:5432/zwesta \
  zwesta-trading:latest
```

## Environment Configuration

The application uses environment-based configuration. Set the `ZWESTA_ENV` variable:

```bash
# Development
export ZWESTA_ENV=development

# Staging
export ZWESTA_ENV=staging

# Production
export ZWESTA_ENV=production
```

### Configuration Levels

- **Development**: Debug mode enabled, local API endpoints, verbose logging
- **Staging**: Limited debug features, staging API endpoints, info-level logging
- **Production**: Full optimizations, production API endpoints, error-only logging

## Security Best Practices

### 1. API Security
- Use HTTPS/TLS for all connections
- Implement rate limiting
- Use API keys and token-based authentication
- Enable CORS headers properly

### 2. Database Security
- Use strong passwords
- Implement database backups
- Use connection pooling
- Encrypt sensitive data at rest

### 3. Application Security
- Regular dependency updates
- Vulnerability scanning
- Input validation
- Output encoding
- CSRF protection

### 4. Server Security
- Firewall rules
- SSH key-based authentication
- Regular security updates
- Monitoring and logging

## Monitoring and Maintenance

### Setup Monitoring

```bash
# Install monitoring tools
sudo apt install -y htop iotop nethogs

# Monitor application logs
tail -f /var/log/zwesta-trading/app.log
```

### Database Backups

```bash
# Create backup script
cat > /usr/local/bin/backup-zwesta.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backups/zwesta"
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump zwesta > $BACKUP_DIR/zwesta_$DATE.sql
gzip $BACKUP_DIR/zwesta_$DATE.sql
EOF

chmod +x /usr/local/bin/backup-zwesta.sh

# Schedule daily backup with cron
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-zwesta.sh") | crontab -
```

## Performance Optimization

### 1. Enable Caching
- Implement Redis for session caching
- Use CDN for static assets
- Enable HTTP caching headers

### 2. Database Optimization
- Create proper indexes
- Use connection pooling
- Implement query optimization

### 3. Application Optimization
- Enable minification and obfuscation
- Implement lazy loading
- Use service workers for offline support

## Troubleshooting

### Common Issues

**Issue**: Application not starting
```bash
# Check logs
journalctl -u zwesta-trading -n 50

# Verify Flutter installation
flutter doctor
```

**Issue**: Database connection errors
```bash
# Test database connection
psql -U zwesta_user -d zwesta -h localhost
```

**Issue**: SSL certificate issues
```bash
# Renew certificate
sudo certbot renew --dry-run
```

## Support and Maintenance

- Regular security updates: `flutter upgrade`
- Dependency updates: `flutter pub upgrade`
- Database maintenance: Regular backups and optimization
- Log rotation: Configure logrotate for application logs

## Deployment Checklist

- [ ] VPS provisioned and secured
- [ ] Flutter and dependencies installed
- [ ] Project cloned and dependencies installed
- [ ] Environment variables configured
- [ ] Database created and configured
- [ ] SSL certificate installed
- [ ] Nginx configured and running
- [ ] Application built for production
- [ ] Monitoring and backups configured
- [ ] Security hardening completed
- [ ] DNS records updated
- [ ] Load testing completed
- [ ] Documentation updated
