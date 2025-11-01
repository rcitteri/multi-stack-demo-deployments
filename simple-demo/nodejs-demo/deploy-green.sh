#!/bin/bash

# Deploy Green version to Cloud Foundry

set -e

echo "======================================"
echo "Deploying GREEN version (2.0.0)"
echo "======================================"

# Check current version and toggle if needed
echo "Checking current configuration..."
CURRENT_VERSION=$(grep "^APP_VERSION=" .env | cut -d'=' -f2)

if [ "$CURRENT_VERSION" != "2.0.0" ]; then
    echo "Current version is $CURRENT_VERSION, toggling to 2.0.0 (green)..."
    ./toggle.sh
    echo ""
else
    echo "Already configured for version 2.0.0 (green)"
    echo ""
fi

# Install dependencies
echo "Installing dependencies..."
npm install --production

echo ""
echo "Deploying to Cloud Foundry..."
cf push -f manifest-green.yml

echo ""
echo "======================================"
echo "Green deployment complete!"
echo "======================================"
echo ""
echo "App name: nodejs-demo-green"
echo "Version: 2.0.0"
echo "Color: green"
echo ""
echo "Check status: cf app nodejs-demo-green"
echo "View logs: cf logs nodejs-demo-green --recent"
