#!/bin/bash
set -e

echo "======================================"
echo "Creating Cloud Foundry Services"
echo "======================================"
echo ""

# MySQL Service
MYSQL_SERVICE_NAME="demodb"
echo "Checking MySQL service: $MYSQL_SERVICE_NAME"
if cf service "$MYSQL_SERVICE_NAME" > /dev/null 2>&1; then
    echo "✓ MySQL service '$MYSQL_SERVICE_NAME' already exists"
else
    echo "Creating MySQL service..."
    cf create-service p.mysql small "$MYSQL_SERVICE_NAME"
    echo "Waiting for MySQL service to be ready..."
    while true; do
        STATUS=$(cf service "$MYSQL_SERVICE_NAME" | grep "status:" | awk '{print $2}')
        if [ "$STATUS" = "create succeeded" ] || [ "$STATUS" = "update succeeded" ]; then
            echo "✓ MySQL service is ready"
            break
        fi
        echo "  Status: $STATUS - waiting..."
        sleep 10
    done
fi

echo ""

# RabbitMQ Service
RABBITMQ_SERVICE_NAME="chatqueue"
echo "Checking RabbitMQ service: $RABBITMQ_SERVICE_NAME"
if cf service "$RABBITMQ_SERVICE_NAME" > /dev/null 2>&1; then
    echo "✓ RabbitMQ service '$RABBITMQ_SERVICE_NAME' already exists"
else
    echo "Creating RabbitMQ service..."
    cf create-service rabbitmq small "$RABBITMQ_SERVICE_NAME"
    echo "Waiting for RabbitMQ service to be ready..."
    while true; do
        STATUS=$(cf service "$RABBITMQ_SERVICE_NAME" | grep "status:" | awk '{print $2}')
        if [ "$STATUS" = "create succeeded" ] || [ "$STATUS" = "update succeeded" ]; then
            echo "✓ RabbitMQ service is ready"
            break
        fi
        echo "  Status: $STATUS - waiting..."
        sleep 10
    done
fi

echo ""
echo "======================================"
echo "All services are ready!"
echo "======================================"
