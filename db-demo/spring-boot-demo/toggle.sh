#!/bin/bash

# Toggle between version 1.0.0 (blue) and 2.0.0 (green)

set -e

CONFIG_FILE="src/main/resources/application.properties"
DOCKER_COMPOSE_FILE="docker-compose.yaml"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "✗ Error: $CONFIG_FILE not found!"
    exit 1
fi

# Check if docker-compose.yaml exists
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "✗ Error: $DOCKER_COMPOSE_FILE not found!"
    exit 1
fi

# Get current version
CURRENT_VERSION=$(grep "^app.version=" "$CONFIG_FILE" | cut -d'=' -f2)

# Determine new version and color
if [ "$CURRENT_VERSION" = "1.0.0" ]; then
    NEW_VERSION="2.0.0"
    NEW_COLOR="green"
else
    NEW_VERSION="1.0.0"
    NEW_COLOR="blue"
fi

# Update application.properties
sed -i.bak "s/^app.version=.*/app.version=$NEW_VERSION/" "$CONFIG_FILE"
sed -i.bak "s/^app.deployment.color=.*/app.deployment.color=$NEW_COLOR/" "$CONFIG_FILE"
rm -f "$CONFIG_FILE.bak"

# Update docker-compose.yaml
sed -i.bak "s/- APP_VERSION=.*/- APP_VERSION=$NEW_VERSION/" "$DOCKER_COMPOSE_FILE"
sed -i.bak "s/- APP_DEPLOYMENT_COLOR=.*/- APP_DEPLOYMENT_COLOR=$NEW_COLOR/" "$DOCKER_COMPOSE_FILE"
rm -f "$DOCKER_COMPOSE_FILE.bak"

echo "======================================"
echo "Version toggled successfully!"
echo "======================================"
echo "Previous: $CURRENT_VERSION"
echo "New: $NEW_VERSION ($NEW_COLOR)"
echo ""
echo "Updated files:"
echo "  - $CONFIG_FILE"
echo "  - $DOCKER_COMPOSE_FILE"
