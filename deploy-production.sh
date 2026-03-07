#!/bin/bash

# Zwesta Trading System - Production Deployment Script
# Usage: ./deploy-production.sh <app|infrastructure|all>

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOYMENT_ENV=${DEPLOYMENT_ENV:-"production"}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-"docker.io"}
IMAGE_NAME=${IMAGE_NAME:-"zwesta-trading"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local required_tools=("docker" "docker-compose" "git")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "$tool is not installed"
            exit 1
        fi
    done
    
    log_success "All prerequisites met"
}

# Setup environment
setup_environment() {
    log_info "Setting up environment..."
    
    # Copy example env if it doesn't exist
    if [ ! -f "$PROJECT_DIR/.env.production" ]; then
        cp "$PROJECT_DIR/.env.production.example" "$PROJECT_DIR/.env.production"
        log_warn ".env.production created from example. Please update with your values!"
    fi
    
    # Create necessary directories
    mkdir -p "$PROJECT_DIR/logs"
    mkdir -p "$PROJECT_DIR/data"
    mkdir -p "$PROJECT_DIR/certs"
    
    log_success "Environment setup completed"
}

# Setup SSL certificates
setup_ssl() {
    log_info "Setting up SSL certificates..."
    
    if [ ! -f "$PROJECT_DIR/certs/fullchain.pem" ]; then
        log_warn "SSL certificates not found. Using self-signed certificates..."
        
        mkdir -p "$PROJECT_DIR/certs"
        openssl req -x509 -newkey rsa:4096 -keyout "$PROJECT_DIR/certs/privkey.pem" \
            -out "$PROJECT_DIR/certs/fullchain.pem" -days 365 -nodes \
            -subj "/CN=localhost"
        
        log_warn "Self-signed certificate created. Replace with proper certificate for production!"
    else
        log_success "SSL certificates found"
    fi
}

# Deploy with Docker Compose
deploy_docker() {
    log_info "Deploying application with Docker Compose..."
    
    cd "$PROJECT_DIR"
    
    # Pull latest images
    docker-compose pull || true
    
    # Start services
    docker-compose up -d
    
    # Wait for services to be ready
    log_info "Waiting for services to be ready..."
    sleep 10
    
    # Check health
    if docker exec zwesta-trading-backend curl -f http://localhost:9000/api/health > /dev/null 2>&1; then
        log_success "Backend is healthy"
    else
        log_error "Backend health check failed"
        docker-compose logs trading-backend
        exit 1
    fi
    
    log_success "Deployment completed successfully"
}

# Verify deployment
verify_deployment() {
    log_info "Verifying deployment..."
    
    # Check if services are running
    if docker-compose ps | grep -q "Up" 2>/dev/null; then
        log_success "Docker services are running"
    fi
    
    # Check API health
    if curl -f http://localhost:9000/api/health > /dev/null 2>&1; then
        log_success "API is responding"
    fi
    
    log_success "Deployment verification completed"
}

# Show logs
show_logs() {
    log_info "Showing application logs..."
    docker-compose logs -f --tail=50 trading-backend
}

# Main deployment flow
main() {
    local deployment_type=${1:-"all"}
    
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║   Zwesta Trading System - Production Deployment        ║"
    echo "║   Environment: $DEPLOYMENT_ENV"
    echo "╚════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    check_prerequisites
    
    case "$deployment_type" in
        "all")
            log_info "Full deployment starting..."
            setup_environment
            setup_ssl
            deploy_docker
            verify_deployment
            ;;
        "logs")
            show_logs
            ;;
        *)
            log_error "Unknown deployment type: $deployment_type"
            echo "Usage: $0 {all|logs}"
            exit 1
            ;;
    esac
    
    echo ""
    log_success "Deployment process completed!"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Access the application: http://localhost:9000"
    echo "2. Monitor logs: docker-compose logs -f"
    echo "3. Configure your brokers via API"
    echo ""
}

# Run main function
main "$@"
