#!/bin/bash
set -e

echo "======================================"
echo "Building Cloud Native Chat Application"
echo "======================================"
echo ""

# Build with Maven
echo "Building application with Maven..."
mvn clean package -DskipTests

# Build Docker image using Spring Boot buildpacks
echo ""
echo "Building Docker image with Spring Boot buildpacks..."
mvn spring-boot:build-image

echo ""
echo "======================================"
echo "Build completed successfully!"
echo "======================================"
echo ""
echo "Docker image: cloud-native-chat:1.0.0"
echo ""
echo "To run locally with Docker Compose:"
echo "  ./run-docker.sh"
echo ""
echo "To run with just Maven:"
echo "  mvn spring-boot:run"
