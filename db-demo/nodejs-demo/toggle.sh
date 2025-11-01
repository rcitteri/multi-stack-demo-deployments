#!/bin/bash

# Toggle between version 1.0.0 (blue) and 2.0.0 (green)

set -e

ENV_FILE=".env"
DOCKER_COMPOSE_FILE="docker-compose.yaml"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "✗ Error: $ENV_FILE not found!"
    exit 1
fi

# Check if docker-compose.yaml exists
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "✗ Error: $DOCKER_COMPOSE_FILE not found!"
    exit 1
fi

# Get current version
CURRENT_VERSION=$(grep "^APP_VERSION=" "$ENV_FILE" | cut -d'=' -f2)

# Determine new version and color
if [ "$CURRENT_VERSION" = "1.0.0" ]; then
    NEW_VERSION="2.0.0"
    NEW_COLOR="green"
else
    NEW_VERSION="1.0.0"
    NEW_COLOR="blue"
fi

# Update .env file
sed -i.bak "s/^APP_VERSION=.*/APP_VERSION=$NEW_VERSION/" "$ENV_FILE"
sed -i.bak "s/^APP_COLOR=.*/APP_COLOR=$NEW_COLOR/" "$ENV_FILE"
rm -f "$ENV_FILE.bak"

# Update docker-compose.yaml
sed -i.bak "s/- APP_VERSION=.*/- APP_VERSION=$NEW_VERSION/" "$DOCKER_COMPOSE_FILE"
sed -i.bak "s/- APP_COLOR=.*/- APP_COLOR=$NEW_COLOR/" "$DOCKER_COMPOSE_FILE"
rm -f "$DOCKER_COMPOSE_FILE.bak"

echo "======================================"
echo "Version toggled successfully!"
echo "======================================"
echo "Previous: $CURRENT_VERSION"
echo "New: $NEW_VERSION ($NEW_COLOR)"
echo ""
echo "Updated files:"
echo "  - $ENV_FILE"
echo "  - $DOCKER_COMPOSE_FILE"
