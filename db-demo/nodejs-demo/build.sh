#!/bin/bash

# Build the Node.js application

set -e

echo "======================================"
echo "Building Node.js DB Demo"
echo "======================================"
echo ""

# Install dependencies
echo "Installing dependencies..."
npm install

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "✗ Error: node_modules directory not found!"
    exit 1
fi

echo ""
echo "======================================"
echo "Build complete!"
echo "======================================"
echo ""
echo "Dependencies installed in: ./node_modules"
echo ""
echo "You can now:"
echo "  - Run locally: npm start"
echo "  - Deploy to CF: cf push"
echo "  - Deploy blue: ./deploy-blue.sh"
echo "  - Deploy green: ./deploy-green.sh"
