#!/bin/bash

# Build script using Cloud Native Buildpacks (Paketo)

set -e

echo "Building Spring Boot Demo with Paketo Buildpacks..."

# Check if pack CLI is installed
if ! command -v pack &> /dev/null; then
    echo "Error: 'pack' CLI is not installed."
    echo "Please install it from: https://buildpacks.io/docs/tools/pack/"
    echo "On macOS: brew install buildpacks/tap/pack"
    exit 1
fi

# Build the image using Paketo buildpacks
pack build spring-boot-demo:latest \
    --builder paketobuildpacks/builder-jammy-base \
    --env BP_JVM_VERSION=25 \
    --env BP_MAVEN_BUILD_ARGUMENTS="-Dmaven.test.skip=true package" \
    --path .

echo ""
echo "Build complete!"
echo "Run with: docker-compose up"
echo "Or run with: docker run -p 8080:8080 spring-boot-demo:latest"
