#!/bin/bash

# Deploy Green version to Cloud Foundry

set -e

echo "======================================"
echo "Deploying GREEN version (2.0.0)"
echo "======================================"
echo ""

# Check current version and toggle if needed
echo "Checking current configuration..."
CURRENT_VERSION=$(grep "^app.version=" src/main/resources/application.properties | cut -d'=' -f2)

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
mvn clean package -DskipTests

# Check if JAR was created
JAR_FILE=$(ls target/*.jar 2>/dev/null | grep -v original | head -1)

if [ -z "$JAR_FILE" ]; then
    echo "✗ Error: JAR file not found!"
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
echo "App name: spring-boot-db-demo-green"
echo "Version: 2.0.0"
echo "Color: green"
echo ""
echo "Check status: cf app spring-boot-db-demo-green"
echo "View logs: cf logs spring-boot-db-demo-green --recent"
