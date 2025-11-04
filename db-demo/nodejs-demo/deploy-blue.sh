#!/bin/bash

# Deploy blue version (1.0.0) to Cloud Foundry

set -e

echo "======================================"
echo "Deploying Blue Version (1.0.0)"
echo "======================================"
echo ""

# Check current version
CURRENT_VERSION=$(grep "^APP_VERSION=" .env | cut -d'=' -f2)

if [ "$CURRENT_VERSION" != "1.0.0" ]; then
    echo "Current version is $CURRENT_VERSION, toggling to 1.0.0 (blue)..."
    ./toggle.sh
    echo ""
fi

# Create offline cache for Cloud Foundry (official method)
echo "Creating npm-packages-offline-cache for air-gapped deployment..."
./create-offline-cache.sh
echo ""

echo "Pushing to Cloud Foundry..."
cf push -f manifest-blue.yml

echo ""
echo "======================================"
echo "Blue deployment complete!"
echo "======================================"
echo ""
echo "App name: nodejs-db-demo-blue"
echo "Version: 1.0.0"
echo "Color: blue"
echo ""
echo "Check status with: cf apps"
echo "View logs with: cf logs nodejs-db-demo-blue --recent"
