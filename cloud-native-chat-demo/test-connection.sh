#!/bin/bash

echo "======================================"
echo "Testing MySQL & RabbitMQ Connectivity"
echo "======================================"
echo ""

# Test MySQL connection
echo "Testing MySQL connection (localhost:3306)..."
if command -v mysql &> /dev/null; then
    mysql -h 127.0.0.1 -P 3306 -u chatuser -pchatpass -e "SELECT 1 as test; SHOW DATABASES;" 2>&1
    if [ $? -eq 0 ]; then
        echo "✓ MySQL connection successful"
    else
        echo "✗ MySQL connection failed"
        echo ""
        echo "Troubleshooting:"
        echo "1. Check if MySQL container is running: docker ps | grep chat-mysql"
        echo "2. Check MySQL logs: docker logs chat-mysql"
        echo "3. Restart containers: docker-compose down && docker-compose up -d mysql"
    fi
else
    echo "MySQL client not installed. Using Docker to test..."
    docker exec chat-mysql mysql -uchatuser -pchatpass -e "SELECT 1 as test; SHOW DATABASES;" 2>&1
    if [ $? -eq 0 ]; then
        echo "✓ MySQL is running and accessible from Docker"
        echo ""
        echo "To test from host, install MySQL client:"
        echo "  brew install mysql-client  # macOS"
    fi
fi

echo ""
echo "--------------------------------------"
echo ""

# Test RabbitMQ connection
echo "Testing RabbitMQ connection (localhost:5672)..."
if command -v nc &> /dev/null; then
    nc -zv 127.0.0.1 5672 2>&1 | grep -q succeeded
    if [ $? -eq 0 ]; then
        echo "✓ RabbitMQ AMQP port (5672) is accessible"
    else
        echo "✗ RabbitMQ AMQP port (5672) is not accessible"
        echo ""
        echo "Troubleshooting:"
        echo "1. Check if RabbitMQ container is running: docker ps | grep chat-rabbitmq"
        echo "2. Check RabbitMQ logs: docker logs chat-rabbitmq"
        echo "3. Restart containers: docker-compose down && docker-compose up -d rabbitmq"
    fi

    nc -zv 127.0.0.1 15672 2>&1 | grep -q succeeded
    if [ $? -eq 0 ]; then
        echo "✓ RabbitMQ Management UI (15672) is accessible"
        echo "  Access at: http://localhost:15672 (guest/guest)"
    else
        echo "✗ RabbitMQ Management UI (15672) is not accessible"
    fi
else
    echo "netcat (nc) not available. Checking with curl..."
    curl -s http://localhost:15672 > /dev/null
    if [ $? -eq 0 ]; then
        echo "✓ RabbitMQ Management UI is accessible"
    else
        echo "✗ RabbitMQ Management UI is not accessible"
    fi
fi

# Check RabbitMQ guest user configuration
echo ""
echo "Checking RabbitMQ guest user configuration..."
docker exec chat-rabbitmq rabbitmqctl list_users 2>&1 | grep -q guest
if [ $? -eq 0 ]; then
    echo "✓ Guest user exists"

    # Check loopback_users configuration
    docker exec chat-rabbitmq cat /etc/rabbitmq/rabbitmq.conf 2>&1 | grep -q "loopback_users = none"
    if [ $? -eq 0 ]; then
        echo "✓ Guest user allowed from any host (loopback_users = none)"
    else
        echo "✗ Guest user might be restricted to localhost only"
        echo ""
        echo "To fix: Ensure rabbitmq.conf contains 'loopback_users = none'"
    fi
else
    echo "✗ Guest user not found"
fi

echo ""
echo "======================================"
echo "Connection Test Complete"
echo "======================================"
echo ""
echo "If all tests passed, you can run the app locally:"
echo "  mvn spring-boot:run"
