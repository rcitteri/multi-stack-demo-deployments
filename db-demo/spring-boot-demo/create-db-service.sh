#!/bin/bash

# Create Cloud Foundry database service (PostgreSQL or MySQL) if it doesn't exist
# Usage: ./create-db-service.sh [postgres|mysql]
#   Default: postgres

set -e

SERVICE_NAME="my-demo-db"
DB_TYPE="${1:-postgres}"  # Default to postgres if no argument provided
SERVICE_PLAN="small"

# Validate database type
if [ "$DB_TYPE" != "postgres" ] && [ "$DB_TYPE" != "mysql" ]; then
    echo "Error: Invalid database type '$DB_TYPE'"
    echo "Usage: ./create-db-service.sh [postgres|mysql]"
    exit 1
fi

SERVICE_TYPE="$DB_TYPE"

echo "======================================"
echo "Checking for $DB_TYPE service..."
echo "======================================"

if cf service "$SERVICE_NAME" > /dev/null 2>&1; then
    echo "✓ Service '$SERVICE_NAME' already exists"
    cf service "$SERVICE_NAME"
else
    echo "Service '$SERVICE_NAME' not found. Creating..."
    echo ""

    # Create the service
    cf create-service "$SERVICE_TYPE" "$SERVICE_PLAN" "$SERVICE_NAME"

    echo ""
    echo "Waiting for service to be created..."
    echo "This may take a few minutes..."

    # Wait for service to be ready
    while true; do
        STATUS=$(cf service "$SERVICE_NAME" | grep "status:" | awk '{print $2}')

        if [ "$STATUS" = "create succeeded" ] || [ "$STATUS" = "update succeeded" ]; then
            echo ""
            echo "✓ Service '$SERVICE_NAME' is ready!"
            break
        elif [ "$STATUS" = "create failed" ]; then
            echo ""
            echo "✗ Service creation failed!"
            cf service "$SERVICE_NAME"
            exit 1
        fi

        echo -n "."
        sleep 5
    done
fi

echo ""
echo "======================================"
echo "Database service ready!"
echo "======================================"
echo ""
echo "Service name: $SERVICE_NAME"
echo "You can now deploy your application with: cf push"
