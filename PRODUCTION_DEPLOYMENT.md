# Zwesta Trading System - Production Deployment Guide

## Quick Start Deployment

### Prerequisites
- Docker & Docker Compose installed
- SSL certificates (for HTTPS)
- AWS/VPS credentials (if deploying to cloud)

### Option 1: Docker Compose Deployment (Recommended)

```bash
# 1. Clone repository
git clone <your-repo>
cd "Zwesta Flutter App"

# 2. Build Flutter web
flutter build web --release --dart-define=ZWESTA_ENV=production

# 3. Setup environment
cp .env.production.example .env.production
# Edit .env.production with your production values

# 4. Create directories
mkdir -p logs data certs

# 5. Setup SSL certificates (use Let's Encrypt)
# If using Certbot:
docker run -it --rm --name certbot -v "./certs:/etc/letsencrypt" certbot/certbot certonly --standalone

# 6. Deploy with Docker Compose
docker-compose up -d

# 7. Verify deployment
curl https://localhost/api/health
```

### Option 2: Kubernetes Deployment

```bash
# Build and push Docker image to registry
docker build -t your-registry/zwesta-trading:latest .
docker push your-registry/zwesta-trading:latest

# Deploy to Kubernetes
kubectl apply -f k8s-deployment.yaml
kubectl apply -f k8s-service.yaml
kubectl apply -f k8s-ingress.yaml

# View logs
kubectl logs -f deployment/zwesta-trading
```

### Option 3: Traditional Server Deployment (Linux)

```bash
# 1. Install dependencies
sudo apt update
sudo apt install -y python3 python3-pip nginx supervisor ufw

# 2. Clone and setup
cd /opt
sudo git clone <your-repo> zwesta-trading
cd zwesta-trading
sudo pip3 install -r trading_backend_requirements.txt
sudo pip3 install gunicorn

# 3. Create systemd service
sudo cp systemd/zwesta-trading.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable zwesta-trading
sudo systemctl start zwesta-trading

# 4. Setup Nginx
sudo cp nginx-prod.conf /etc/nginx/sites-available/zwesta
sudo ln -s /etc/nginx/sites-available/zwesta /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 5. Setup firewall
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

## Performance Optimization

### Caching Strategy
```python
# Redis caching enabled
REDIS_ENABLED=true
CACHE_TTL=3600  # 1 hour
```

### Load Balancing
- Gunicorn workers: 4-8 (adjust based on CPU cores)
- Nginx load balancing: least_conn algorithm
- Connection pooling: 32 persistent connections

### Database Optimization
- Use indexed queries
- Implement query pagination
- Cache frequently accessed data

## Monitoring & Logging

### Log Files
- Application: `/app/logs/trading_backend.log`
- Nginx: `/var/log/nginx/error.log`
- Docker: `docker logs zwesta-trading-backend`

### Health Checks
```bash
# Check API health
curl https://your-domain/api/health

# Check system status
curl https://your-domain/api/accounts/list
curl https://your-domain/api/positions/all
```

### Metrics & Monitoring
```bash
# Enable Sentry monitoring (optional)
SENTRY_ENABLED=true
SENTRY_DSN=https://your-sentry-dsn
```

## Backup & Recovery

### Automated Backups
```bash
# Backup configuration
BACKUP_ENABLED=true
BACKUP_INTERVAL=86400  # Daily
BACKUP_PATH=/app/backups
```

### Manual Backup
```bash
docker exec zwesta-trading-backend tar -czf /app/backups/backup-$(date +%Y%m%d).tar.gz /app/data
```

## Security Best Practices

1. **SSL/TLS**: Use Let's Encrypt certificates (auto-renewal)
2. **Secrets Management**: Use environment variables or secret managers
3. **Rate Limiting**: Enable API rate limiting
4. **CORS**: Configure allowed origins
5. **Authentication**: Implement JWT tokens
6. **Firewall**: Restrict access to known IPs
7. **Updates**: Regular security updates for dependencies

## Troubleshooting

### Service won't start
```bash
# Check logs
docker-compose logs trading-backend

# Check port availability
sudo lsof -i :9000
```

### High memory usage
```bash
# Increase Gunicorn workers limit
# Edit docker-compose.yml
GUNICORN_WORKERS=2  # Reduce from 4
```

### SSL certificate errors
```bash
# Renew certificates
docker run --rm -v "./certs:/etc/letsencrypt" certbot/certbot renew
```

## Scaling for Production

1. **Horizontal Scaling**: Use Kubernetes or load balancer
2. **Vertical Scaling**: Increase server resources
3. **Database Scaling**: Implement read replicas
4. **Caching**: Use Redis for session and data caching
5. **CDN**: Use CloudFront or similar for static assets

## Update & Rollback

```bash
# Update application
docker-compose pull
docker-compose up -d --build

# Rollback to previous version
docker-compose down
docker image ls  # Find previous version
docker tag old-image:tag zwesta-trading:latest
docker-compose up -d
```

## Support & Documentation

- API Documentation: `/api/docs`
- GitHub Issues: https://github.com/your-repo/issues
- Community: https://your-community-forum.com
