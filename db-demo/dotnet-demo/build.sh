#!/bin/bash

# Build the .NET Core application

set -e

echo "======================================"
echo "Building .NET Core DB Demo"
echo "======================================"
echo ""

# Build with dotnet
echo "Running dotnet build..."
dotnet build --configuration Release

echo ""
echo "Publishing application..."
dotnet publish --configuration Release --output ./publish

# Check if publish was successful
if [ ! -d "./publish" ]; then
    echo "✗ Error: Publish directory not found!"
    exit 1
fi

echo ""
echo "======================================"
echo "Build complete!"
echo "======================================"
echo ""
echo "Published to: ./publish"
echo "Size: $(du -sh ./publish | cut -f1)"
echo ""
echo "You can now:"
echo "  - Run locally: dotnet ./publish/dotnet-demo.dll"
echo "  - Deploy to CF: cf push"
echo "  - Deploy blue: ./deploy-blue.sh"
echo "  - Deploy green: ./deploy-green.sh"
