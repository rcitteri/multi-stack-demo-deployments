#!/bin/bash

# Deploy green version (2.0.0) to Cloud Foundry

set -e

echo "======================================"
echo "Deploying Green Version (2.0.0)"
echo "======================================"
echo ""

# Check current version
CURRENT_VERSION=$(grep "^APP_VERSION=" .env | cut -d'=' -f2)

if [ "$CURRENT_VERSION" != "2.0.0" ]; then
    echo "Current version is $CURRENT_VERSION, toggling to 2.0.0 (green)..."
    ./toggle.sh
    echo ""
fi

echo "Building application..."
npm install
echo ""

echo "Pushing to Cloud Foundry..."
cf push -f manifest-green.yml

echo ""
echo "======================================"
echo "Green deployment complete!"
echo "======================================"
echo ""
echo "App name: nodejs-db-demo-green"
echo "Version: 2.0.0"
echo "Color: green"
echo ""
echo "Check status with: cf apps"
echo "View logs with: cf logs nodejs-db-demo-green --recent"
