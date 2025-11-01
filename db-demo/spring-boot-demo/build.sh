#!/bin/bash

# Build the Spring Boot application

set -e

echo "======================================"
echo "Building Spring Boot DB Demo"
echo "======================================"
echo ""

# Build with Maven
echo "Running Maven build..."
mvn clean package -DskipTests

# Check if JAR was created
JAR_FILE=$(ls target/*.jar 2>/dev/null | grep -v original | head -1)

if [ -z "$JAR_FILE" ]; then
    echo "✗ Error: JAR file not found!"
    exit 1
fi

echo ""
echo "======================================"
echo "Build complete!"
echo "======================================"
echo ""
echo "JAR file: $JAR_FILE"
echo "Size: $(du -h "$JAR_FILE" | cut -f1)"
echo ""
echo "You can now:"
echo "  - Run locally: java -jar $JAR_FILE"
echo "  - Deploy to CF: cf push"
echo "  - Deploy blue: ./deploy-blue.sh"
echo "  - Deploy green: ./deploy-green.sh"
