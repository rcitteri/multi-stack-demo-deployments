#!/bin/bash

# Deploy default (blue) version to Cloud Foundry

set -e

echo "======================================"
echo "Deploying DEFAULT version"
echo "======================================"

# Check current version and toggle if needed
echo "Checking current configuration..."
CURRENT_VERSION=$(grep "^APP_VERSION=" .env | cut -d'=' -f2)

if [ "$CURRENT_VERSION" != "1.0.0" ]; then
    echo "Current version is $CURRENT_VERSION, toggling to 1.0.0 (blue)..."
    ./toggle.sh
    echo ""
else
    echo "Already configured for version 1.0.0 (blue)"
    echo ""
fi

# Create offline cache for Cloud Foundry (official method)
echo "Creating npm-packages-offline-cache for air-gapped deployment..."
./create-offline-cache.sh

echo ""
echo "Deploying to Cloud Foundry using default manifest..."
cf push -f manifest.yml

echo ""
echo "======================================"
echo "Default deployment complete!"
echo "======================================"
echo ""
echo "App name: nodejs-demo"
echo "Version: 1.0.0"
echo "Color: blue"
echo ""
echo "Check status: cf app nodejs-demo"
echo "View logs: cf logs nodejs-demo --recent"
