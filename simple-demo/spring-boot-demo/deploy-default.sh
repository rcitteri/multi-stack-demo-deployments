#!/bin/bash

# Deploy default (blue) version to Cloud Foundry

set -e

echo "======================================"
echo "Deploying DEFAULT version"
echo "======================================"

# Check current version and toggle if needed
echo "Checking current configuration..."
CURRENT_VERSION=$(grep "^app.version=" src/main/resources/application.properties | cut -d'=' -f2)

if [ "$CURRENT_VERSION" != "1.0.0" ]; then
    echo "Current version is $CURRENT_VERSION, toggling to 1.0.0 (blue)..."
    ./toggle.sh
    echo ""
else
    echo "Already configured for version 1.0.0 (blue)"
    echo ""
fi

# Build the application
echo "Building application..."
mvn clean package -DskipTests

# Check if JAR was created
if [ ! -f "target/spring-boot-demo-1.0.0.jar" ]; then
    echo "Error: JAR file not found!"
    exit 1
fi

echo ""
echo "Deploying to Cloud Foundry using default manifest..."
cf push -f manifest.yml

echo ""
echo "======================================"
echo "Default deployment complete!"
echo "======================================"
echo ""
echo "App name: spring-boot-demo"
echo "Version: 1.0.0"
echo "Color: blue"
echo ""
echo "Check status: cf app spring-boot-demo"
echo "View logs: cf logs spring-boot-demo --recent"
