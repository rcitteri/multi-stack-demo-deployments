#!/bin/bash
set -e

echo "======================================"
echo "Starting Cloud Native Chat with Docker Compose"
echo "======================================"
echo ""

# Start services
echo "Starting MySQL, RabbitMQ, and application..."
docker-compose up -d

echo ""
echo "======================================"
echo "Services started successfully!"
echo "======================================"
echo ""
echo "Application URL:      http://localhost:8080"
echo "RabbitMQ Management:  http://localhost:15672 (guest/guest)"
echo "Actuator Chat Stats:  http://localhost:8080/actuator/chat"
echo "Actuator Health:      http://localhost:8080/actuator/health"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f app"
echo ""
echo "To stop services:"
echo "  docker-compose down"
