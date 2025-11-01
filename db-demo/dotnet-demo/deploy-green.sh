#!/bin/bash

# Deploy Green version to Cloud Foundry

set -e

echo "======================================"
echo "Deploying GREEN version (2.0.0)"
echo "======================================"
echo ""

# Check current version and toggle if needed
echo "Checking current configuration..."
CURRENT_VERSION=$(grep '"Version":' appsettings.json | sed 's/.*"Version": "\(.*\)".*/\1/')

if [ "$CURRENT_VERSION" != "2.0.0" ]; then
    echo "Current version is $CURRENT_VERSION, toggling to 2.0.0 (green)..."
    ./toggle.sh
    echo ""
else
    echo "Already configured for version 2.0.0 (green)"
    echo ""
fi

# Build the application
echo "Building application..."
dotnet publish --configuration Release --output ./publish

# Check if publish was successful
if [ ! -d "./publish" ]; then
    echo "✗ Error: Publish directory not found!"
    exit 1
fi

echo ""
echo "Deploying to Cloud Foundry..."
cf push -f manifest-green.yml

echo ""
echo "======================================"
echo "Green deployment complete!"
echo "======================================"
echo ""
echo "App name: dotnet-db-demo-green"
echo "Version: 2.0.0"
echo "Color: green"
echo ""
echo "Check status: cf app dotnet-db-demo-green"
echo "View logs: cf logs dotnet-db-demo-green --recent"
