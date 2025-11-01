#!/bin/bash

# Deploy with default manifest to Cloud Foundry

set -e

echo "======================================"
echo "Deploying .NET Core DB Demo"
echo "======================================"
echo ""

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
cf push -f manifest.yml

echo ""
echo "======================================"
echo "Deployment complete!"
echo "======================================"
echo ""
echo "App name: dotnet-db-demo"
echo ""
echo "Check status: cf app dotnet-db-demo"
echo "View logs: cf logs dotnet-db-demo --recent"
