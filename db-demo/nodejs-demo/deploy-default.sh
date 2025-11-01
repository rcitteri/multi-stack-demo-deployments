#!/bin/bash

# Deploy with default manifest to Cloud Foundry

set -e

echo "======================================"
echo "Deploying Node.js DB Demo"
echo "======================================"
echo ""

# Install dependencies
echo "Installing dependencies..."
npm install

echo ""
echo "Deploying to Cloud Foundry..."
cf push -f manifest.yml

echo ""
echo "======================================"
echo "Deployment complete!"
echo "======================================"
echo ""
echo "App name: nodejs-db-demo"
echo ""
echo "Check status: cf app nodejs-db-demo"
echo "View logs: cf logs nodejs-db-demo --recent"
