#!/bin/bash

# Toggle script for .NET Core demo
# Toggles between version 1.0.0/blue and 2.0.0/green

set -e

CONFIG_FILE="appsettings.json"
DOCKER_COMPOSE_FILE="docker-compose.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "Error: Docker Compose file not found: $DOCKER_COMPOSE_FILE"
    exit 1
fi

# Read current version
CURRENT_VERSION=$(grep '"Version"' "$CONFIG_FILE" | sed 's/.*"Version": "\([^"]*\)".*/\1/')

# Toggle version and color
if [ "$CURRENT_VERSION" = "1.0.0" ]; then
    NEW_VERSION="2.0.0"
    NEW_COLOR="green"
    echo "Switching to version 2.0.0 (green)"
else
    NEW_VERSION="1.0.0"
    NEW_COLOR="blue"
    echo "Switching to version 1.0.0 (blue)"
fi

# Update the configuration file
sed -i.bak "s/\"Version\": \".*\"/\"Version\": \"$NEW_VERSION\"/" "$CONFIG_FILE"
sed -i.bak "s/\"DeploymentColor\": \".*\"/\"DeploymentColor\": \"$NEW_COLOR\"/" "$CONFIG_FILE"
rm -f "$CONFIG_FILE.bak"

# Update docker-compose.yaml
sed -i.bak "s/- App__Version=.*/- App__Version=$NEW_VERSION/" "$DOCKER_COMPOSE_FILE"
sed -i.bak "s/- App__DeploymentColor=.*/- App__DeploymentColor=$NEW_COLOR/" "$DOCKER_COMPOSE_FILE"
rm -f "$DOCKER_COMPOSE_FILE.bak"

echo "Configuration updated:"
echo "  Version: $NEW_VERSION"
echo "  Color: $NEW_COLOR"
echo ""
echo "Updated files:"
echo "  - $CONFIG_FILE"
echo "  - $DOCKER_COMPOSE_FILE"
echo ""
echo "Run 'docker-compose up --build' to apply changes."
