# Spring Boot Demo Application

A cloud-native demo application built with Spring Boot 3.5.6 and Java 25.

## Features
- Web interface showing tech stack information
- Instance UUID for multi-instance identification
- Configurable version and deployment color for blue/green deployments
- REST API endpoint for programmatic access
- Health check endpoints via Spring Boot Actuator

## Prerequisites

### For Local Development
- Java 25 or later
- Maven 3.8+ (or use included Maven Wrapper)

### For Docker Build
- Docker
- Pack CLI (Buildpacks): `brew install buildpacks/tap/pack`

### For Cloud Foundry
- CF CLI
- Access to a Cloud Foundry environment

## Running Locally

### Using Maven Wrapper
```bash
./mvnw spring-boot:run
```

### Using Maven
```bash
mvn spring-boot:run
```

The application will start on `http://localhost:8080`

## Building and Running with Docker

### Build with Cloud Native Buildpacks
```bash
chmod +x build.sh
./build.sh
```

### Run with Docker Compose
```bash
docker-compose up
```

### Run with Docker directly
```bash
docker run -p 8080:8080 spring-boot-demo:latest
```

## Deploying to Cloud Foundry

### Quick Deploy (Default)

Deploy the default blue version:
```bash
./deploy-default.sh
```

This deploys a single app instance named `spring-boot-demo` with version 1.0.0 (blue).

### Blue/Green Deployment Strategy

This application includes scripts for zero-downtime blue/green deployments on Cloud Foundry.

#### Deploy Blue Version
```bash
./deploy-blue.sh
```
- App name: `spring-boot-demo-blue`
- Version: 1.0.0
- Color: Blue
- Instances: 2

#### Deploy Green Version
```bash
./deploy-green.sh
```
- App name: `spring-boot-demo-green`
- Version: 2.0.0
- Color: Green
- Instances: 2

### Step-by-Step Blue/Green Cutover

This demonstrates a zero-downtime deployment with gradual traffic shifting:

**Step 1: Initial State - Blue is live (100% traffic)**
```bash
./deploy-blue.sh
cf map-route spring-boot-demo-blue apps.example.com --hostname spring-boot-demo
```
State: Blue (2 instances) → 100% traffic

**Step 2: Deploy Green (0% traffic)**
```bash
./deploy-green.sh
cf scale spring-boot-demo-green -i 0
```
State: Blue (2 instances) → 100% traffic, Green (0 instances) → 0% traffic

**Step 3: Start Green instances and add to routing (50/50 split)**
```bash
cf scale spring-boot-demo-green -i 2
cf map-route spring-boot-demo-green apps.example.com --hostname spring-boot-demo
```
State: Blue (2 instances) → 50% traffic, Green (2 instances) → 50% traffic

**Step 4: Monitor and verify Green is healthy**
```bash
cf app spring-boot-demo-green
cf logs spring-boot-demo-green --recent
# Test the endpoint and check UUIDs to verify both versions
curl https://spring-boot-demo.apps.example.com/api/infos
```

**Step 5: Gradual cutover - Scale down Blue, keep Green (25/75 split)**
```bash
cf scale spring-boot-demo-blue -i 1
```
State: Blue (1 instance) → 25% traffic, Green (2 instances) → 75% traffic

**Step 6: Complete cutover - Remove Blue (0/100 split)**
```bash
cf unmap-route spring-boot-demo-blue apps.example.com --hostname spring-boot-demo
cf scale spring-boot-demo-blue -i 0
# Or delete the blue app entirely
cf delete spring-boot-demo-blue
```
State: Blue (0 instances) → 0% traffic, Green (2 instances) → 100% traffic

**Step 7: Rollback (if needed)**

If issues are detected, instantly rollback:
```bash
cf scale spring-boot-demo-blue -i 2
cf map-route spring-boot-demo-blue apps.example.com --hostname spring-boot-demo
cf unmap-route spring-boot-demo-green apps.example.com --hostname spring-boot-demo
```

### Manual Deployment

If you prefer manual deployment:
```bash
# Build the JAR
./mvnw clean package -DskipTests

# Deploy using specific manifest
cf push -f manifest-blue.yml
# or
cf push -f manifest-green.yml
# or default
cf push -f manifest.yml
```

## Configuration

### Port Configuration

The application uses port 8080 by default, but can be customized via the `PORT` environment variable:

```bash
# Run on default port 8080
./mvnw spring-boot:run

# Run on custom port
PORT=9000 ./mvnw spring-boot:run
```

In `application.properties`, the port is configured as:
```properties
server.port=${PORT:8080}
```

### Version and Color Configuration

Edit `src/main/resources/application.properties` to change:

```properties
# Version and color for blue/green deployments
app.version=1.0.0
app.deployment.color=blue
```

Available colors: `blue`, `green`, `red`, `yellow`

### Quick Toggle Script

Use the `toggle.sh` script to quickly switch between version 1.0.0 (blue) and version 2.0.0 (green):

```bash
./toggle.sh
```

Each time you run the script, it toggles between:
- Version 1.0.0 with blue color
- Version 2.0.0 with green color

**Note**: You must restart the application after running `toggle.sh` for changes to take effect.

## API Endpoints

### Web Interface
- `GET /` - HTML page with tech stack information

### REST API
- `GET /api/infos` - JSON response with tech stack details

### Health Checks
- `GET /actuator/health` - Application health status
- `GET /actuator/info` - Application information

## Example API Response

```json
{
  "uuid": "550e8400-e29b-41d4-a716-446655440000",
  "version": "1.0.0",
  "deploymentColor": "blue",
  "techStack": {
    "framework": "Spring Boot",
    "version": "3.5.6",
    "language": "Java",
    "languageVersion": "25",
    "runtime": "JVM"
  }
}
```

## Blue/Green Deployment Example

1. Deploy version 1.0.0 with blue color
2. Verify application is running
3. Change configuration to version 2.0.0 with green color
4. Deploy new version
5. Route traffic between versions as needed

## Project Structure
```
spring-boot-demo/
├── src/
│   └── main/
│       ├── java/com/example/demo/
│       │   ├── DemoApplication.java
│       │   ├── config/
│       │   │   └── AppConfig.java
│       │   ├── controller/
│       │   │   ├── InfoController.java
│       │   │   └── WebController.java
│       │   └── model/
│       │       ├── TechStack.java
│       │       └── TechStackInfo.java
│       └── resources/
│           ├── application.properties
│           └── templates/
│               └── index.html
├── pom.xml
├── Dockerfile
├── build.sh
├── toggle.sh
├── docker-compose.yaml
├── manifest.yml
├── manifest-blue.yml
├── manifest-green.yml
├── deploy-default.sh
├── deploy-blue.sh
└── deploy-green.sh
```

## Technology Stack
- **Framework**: Spring Boot 3.5.6
- **Language**: Java 25
- **Build Tool**: Maven
- **Template Engine**: Thymeleaf
- **Containerization**: Paketo Buildpacks
