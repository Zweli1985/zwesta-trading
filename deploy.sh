#!/bin/bash

# Zwesta Trading System - VPS Deployment Script
# This script builds and deploys the application with specified configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Zwesta Trading System - Deployment${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter is not installed${NC}"
    exit 1
fi

# Default values
ENVIRONMENT="production"
API_URL=""
API_KEY=""
OFFLINE_MODE="false"
OUTPUT_DIR="build/web"
VPS_HOST=""
VPS_USER=""
VPS_PATH="/var/www/zwesta-trading"

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -e, --env ENV              Environment: production, staging, development (default: production)
    -a, --api-url URL          API URL (required for production)
    -k, --api-key KEY          API Key (required for production)
    -o, --offline              Enable offline mode (uses mock data)
    -h, --host HOST            VPS hostname/IP for SCP deployment
    -u, --user USER            VPS SSH username
    -p, --path PATH            VPS deployment path (default: /var/www/zwesta-trading)
    --help                     Display this help message

Examples:
    # Production with API
    $0 -e production -a https://api.zwesta.com -k prod_key_xyz

    # Testing with offline mode
    $0 -e production --offline

    # Deploy to VPS
    $0 -e production -a https://api.zwesta.com -h 38.247.146.198 -u deploy

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -a|--api-url)
            API_URL="$2"
            shift 2
            ;;
        -k|--api-key)
            API_KEY="$2"
            shift 2
            ;;
        -o|--offline)
            OFFLINE_MODE="true"
            shift
            ;;
        -h|--host)
            VPS_HOST="$2"
            shift 2
            ;;
        -u|--user)
            VPS_USER="$2"
            shift 2
            ;;
        -p|--path)
            VPS_PATH="$2"
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Validation
if [[ "$OFFLINE_MODE" != "true" && -z "$API_URL" ]]; then
    echo -e "${YELLOW}Warning: No API_URL provided. Using development defaults.${NC}"
fi

# Print configuration
echo -e "\n${BLUE}Configuration:${NC}"
echo "  Environment: $ENVIRONMENT"
echo "  API URL: ${API_URL:-'(default)'}"
echo "  Offline Mode: $OFFLINE_MODE"
if [[ -n "$VPS_HOST" ]]; then
    echo "  VPS Deployment: $VPS_HOST:$VPS_PATH"
fi

# Clean and get dependencies
echo -e "\n${BLUE}Step 1: Preparing project...${NC}"
flutter clean > /dev/null 2>&1
flutter pub get > /dev/null 2>&1

# Build web application
echo -e "\n${BLUE}Step 2: Building web application...${NC}"

BUILD_ARGS="--release"
BUILD_ARGS="$BUILD_ARGS --dart-define=ZWESTA_ENV=$ENVIRONMENT"

if [[ -n "$API_URL" ]]; then
    BUILD_ARGS="$BUILD_ARGS --dart-define=API_URL=$API_URL"
fi

if [[ -n "$API_KEY" ]]; then
    BUILD_ARGS="$BUILD_ARGS --dart-define=API_KEY=$API_KEY"
fi

if [[ "$OFFLINE_MODE" == "true" ]]; then
    BUILD_ARGS="$BUILD_ARGS --dart-define=OFFLINE_MODE=true"
fi

flutter build web $BUILD_ARGS

# Check build success
if [[ ! -f "$OUTPUT_DIR/index.html" ]]; then
    echo -e "${RED}Build failed: index.html not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Build successful${NC}"

# Deploy to VPS if specified
if [[ -n "$VPS_HOST" && -n "$VPS_USER" ]]; then
    echo -e "\n${BLUE}Step 3: Deploying to VPS...${NC}"
    
    # Create deployment package
    echo "Creating deployment package..."
    tar -czf zwesta-build.tar.gz -C "$OUTPUT_DIR" . || true
    
    # Upload to VPS
    echo "Uploading to $VPS_HOST..."
    scp -rC "$OUTPUT_DIR"/* "$VPS_USER@$VPS_HOST:$VPS_PATH/" || {
        echo -e "${RED}SCP failed. Make sure SSH keys are configured.${NC}"
        echo "Manual deployment command:"
        echo "  scp -r $OUTPUT_DIR/* $VPS_USER@$VPS_HOST:$VPS_PATH/"
    }
    
    echo -e "${GREEN}✓ Deployment complete${NC}"
else
    echo -e "\n${YELLOW}No VPS deployment specified. Build files available at: $OUTPUT_DIR${NC}"
    echo "To deploy manually:"
    echo "  scp -r $OUTPUT_DIR/* user@your-vps:/var/www/zwesta-trading/"
fi

# Summary
echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}Deployment Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo "Environment: $ENVIRONMENT"
echo "Build Directory: $OUTPUT_DIR"
echo "Build Size: $(du -sh $OUTPUT_DIR | cut -f1)"
echo "Files Count: $(find $OUTPUT_DIR -type f | wc -l)"
if [[ -n "$VPS_HOST" ]]; then
    echo "Deployed to: https://$VPS_HOST"
fi
echo -e "${BLUE}========================================${NC}"

echo -e "\n${GREEN}✓ Build and deployment complete!${NC}"
