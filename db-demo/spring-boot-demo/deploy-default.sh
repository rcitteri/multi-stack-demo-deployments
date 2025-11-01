#!/bin/bash

# Deploy with default manifest to Cloud Foundry

set -e

echo "======================================"
echo "Deploying Spring Boot DB Demo"
echo "======================================"
echo ""

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
cf push -f manifest.yml

echo ""
echo "======================================"
echo "Deployment complete!"
echo "======================================"
echo ""
echo "App name: spring-boot-db-demo"
echo ""
echo "Check status: cf app spring-boot-db-demo"
echo "View logs: cf logs spring-boot-db-demo --recent"
