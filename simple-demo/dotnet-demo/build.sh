#!/bin/bash

# Build script using Cloud Native Buildpacks (Paketo)

set -e

echo "Building .NET Core Demo with Paketo Buildpacks..."

# Check if pack CLI is installed
if ! command -v pack &> /dev/null; then
    echo "Error: 'pack' CLI is not installed."
    echo "Please install it from: https://buildpacks.io/docs/tools/pack/"
    echo "On macOS: brew install buildpacks/tap/pack"
    exit 1
fi

# Build the image using Paketo buildpacks
pack build dotnet-demo:latest \
    --builder paketobuildpacks/builder-jammy-base \
    --env BP_DOTNET_FRAMEWORK_VERSION=8.0 \
    --path .

echo ""
echo "Build complete!"
echo "Run with: docker-compose up"
echo "Or run with: docker run -p 5000:5000 dotnet-demo:latest"
