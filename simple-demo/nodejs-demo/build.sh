#!/bin/bash

# Build script using Cloud Native Buildpacks (Paketo)

set -e

echo "Building Node.js Demo with Paketo Buildpacks..."

# Check if pack CLI is installed
if ! command -v pack &> /dev/null; then
    echo "Error: 'pack' CLI is not installed."
    echo "Please install it from: https://buildpacks.io/docs/tools/pack/"
    echo "On macOS: brew install buildpacks/tap/pack"
    exit 1
fi

# Build the image using Paketo buildpacks
pack build nodejs-demo:latest \
    --builder paketobuildpacks/builder-jammy-base \
    --env BP_NODE_VERSION=18 \
    --path .

echo ""
echo "Build complete!"
echo "Run with: docker-compose up"
echo "Or run with: docker run -p 8082:8082 nodejs-demo:latest"
