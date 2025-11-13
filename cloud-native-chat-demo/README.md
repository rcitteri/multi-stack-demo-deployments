# Cloud Native Chat Demo

A **12-Factor cloud-native application** demonstrating modern Spring Boot development patterns with real-time chat functionality.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Java](https://img.shields.io/badge/Java-25-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.7-brightgreen)

## Overview

This application showcases the [12-factor app methodology](https://12factor.net/) for building cloud-native applications that are:
- **Portable** across execution environments
- **Scalable** horizontally
- **Resilient** to failures
- **Observable** through metrics and health checks

### Key Features

- Real-time group chat using **WebSocket** and **RabbitMQ**
- Message persistence with **MySQL** (24-hour retention)
- Beautiful dark-themed UI built with **Thymeleaf**
- Custom **Spring Boot Actuator** endpoints for monitoring
- Horizontally scalable architecture
- Cloud Foundry ready with service binding support

## Architecture

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│   Browser   │──WS──│  Spring Boot │──────│   RabbitMQ  │
│  (Client)   │      │     App      │      │  (Message   │
└─────────────┘      │  Instance 1  │      │   Broker)   │
                     └──────────────┘      └─────────────┘
                             │                     │
                     ┌──────────────┐              │
                     │  Spring Boot │──────────────┘
                     │     App      │
                     │  Instance 2  │
                     └──────────────┘
                             │
                     ┌──────────────┐
                     │    MySQL     │
                     │  (Chat DB)   │
                     └──────────────┘
```

### Technology Stack

| Component | Technology |
|-----------|-----------|
| **Language** | Java 25 |
| **Framework** | Spring Boot 3.5.7 |
| **Template Engine** | Thymeleaf |
| **Real-time** | WebSocket (STOMP) |
| **Messaging** | RabbitMQ (AMQP) |
| **Database** | MySQL 8.0 |
| **Build Tool** | Maven |
| **Container** | Docker + Buildpacks |

## 12-Factor Principles Demonstrated

| Factor | Implementation |
|--------|---------------|
| **I. Codebase** | Single repo tracked in Git |
| **II. Dependencies** | Maven manages all dependencies |
| **III. Config** | Externalized via `application.properties` and environment variables |
| **IV. Backing Services** | MySQL and RabbitMQ as attached resources via service binding |
| **V. Build, Release, Run** | Separate build (Maven), release (Docker), and run stages |
| **VI. Processes** | Stateless app instances (chat history in MySQL, messages via RabbitMQ) |
| **VII. Port Binding** | Self-contained service exposing port 8080 |
| **VIII. Concurrency** | Horizontal scaling via multiple instances |
| **IX. Disposability** | Fast startup, graceful shutdown |
| **X. Dev/Prod Parity** | Same app runs locally (Docker) and in cloud (CF) |
| **XI. Logs** | Treated as event streams to stdout |
| **XII. Admin Processes** | **Database initializer** runs as one-off process + Actuator endpoints |

## Prerequisites

- **Java 25** ([Download](https://jdk.java.net/25/))
- **Maven 3.9+** ([Download](https://maven.apache.org/download.cgi))
- **Docker Desktop** ([Download](https://www.docker.com/products/docker-desktop))
- **Cloud Foundry CLI** (optional, for CF deployment)

## Quick Start

### 1. Run Locally with Docker Compose

```bash
# Build the application
chmod +x build.sh
./build.sh

# Start all services (MySQL + RabbitMQ + App)
chmod +x run-docker.sh
./run-docker.sh
```

Access the application:
- **Chat App**: http://localhost:8080
- **RabbitMQ Management**: http://localhost:15672 (guest/guest)
- **Actuator Chat Stats**: http://localhost:8080/actuator/chat
- **Health Check**: http://localhost:8080/actuator/health

### 2. Run App on Host Machine (Recommended for Development)

Run the Spring Boot app **on your local machine** while using Docker for infrastructure:

```bash
# Start infrastructure services only
docker-compose up -d mysql rabbitmq

# Initialize database (run once)
docker-compose up db-initializer

# Test connectivity (optional)
./test-connection.sh

# Run the application on host
mvn spring-boot:run
```

**Why this approach?**
- ✅ Fast development cycle (no Docker rebuild)
- ✅ Easy debugging from your IDE
- ✅ Live reload with Spring DevTools
- ✅ Access database with MySQL Workbench (localhost:3306)

📖 **Full Guide**: See [RUN-ON-HOST.md](RUN-ON-HOST.md) for detailed instructions and troubleshooting.

### 3. Build Container with Spring Boot Buildpacks

```bash
# Build OCI image using Cloud Native Buildpacks
mvn spring-boot:build-image

# Run the container
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://host.docker.internal:3306/chatdb \
  -e SPRING_RABBITMQ_HOST=host.docker.internal \
  cloud-native-chat:1.0.0
```

## Configuration

Configuration follows the **12-factor config principle** with externalization via environment variables.

### Application Properties

| Property | Default | Description |
|----------|---------|-------------|
| `app.version` | `1.0.0` | Application version |
| `app.deployment.color` | `blue` | Deployment color (for blue/green) |
| `server.port` | `8080` | HTTP server port |
| `spring.datasource.url` | `jdbc:mysql://localhost:3306/chatdb` | MySQL connection URL |
| `spring.rabbitmq.host` | `localhost` | RabbitMQ host |
| `chat.history.retention.hours` | `24` | Chat message retention period |

### Environment Variables for Docker/CF

```bash
SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/chatdb
SPRING_DATASOURCE_USERNAME=chatuser
SPRING_DATASOURCE_PASSWORD=chatpass
SPRING_RABBITMQ_HOST=rabbitmq
SPRING_RABBITMQ_PORT=5672
SPRING_RABBITMQ_USERNAME=guest
SPRING_RABBITMQ_PASSWORD=guest
```

## Database Initializer - 12-Factor Admin Process

This application demonstrates **Factor XII: Admin Processes** with a dedicated database initializer that runs as a **one-off process** before the main application.

### Why a Separate Initializer?

Traditional approach (anti-pattern):
- Application starts → Hibernate creates schema → App runs

**Problems:** Delayed startup, implicit changes, hard to track, no separation of concerns

12-Factor approach (best practice):
- Run db-initializer task → Schema created → Task exits
- Start application → App runs (schema ready)

**Benefits:** ✅ Explicit initialization ✅ Versionable ✅ Independent execution ✅ Clear separation

### How It Works

```
Docker Compose Startup Sequence:
1. MySQL starts ✓
2. RabbitMQ starts ✓
3. db-initializer runs → Creates schema → Exits ✓
4. Main app starts ✓
```

The initializer:
- Verifies database connection
- Creates `chat_messages` table (if not exists)
- Seeds initial welcome message
- Exits with success code

### Running Manually

```bash
# Run initializer locally
mvn spring-boot:run -Dspring-boot.run.profiles=initializer

# Run initializer in Cloud Foundry
cf run-task cloud-native-chat \
  "java -jar app.jar --spring.profiles.active=initializer" \
  --name db-initializer

# Or use the provided script
./run-db-init-task.sh
```

📖 **Full Documentation**: See [DB-INITIALIZER.md](DB-INITIALIZER.md) for complete details.

## API Endpoints

### Web Interface

| Endpoint | Description |
|----------|-------------|
| `GET /` | Entry page (username input) |
| `GET /chat` | Chat room interface |

### WebSocket

| Destination | Description |
|------------|-------------|
| `/ws-chat` | WebSocket connection endpoint |
| `/app/chat.send` | Send chat message |
| `/app/chat.join` | User joins chat |
| `/app/chat.leave` | User leaves chat |
| `/topic/messages` | Subscribe to receive messages |

### Actuator Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /actuator/health` | Application health status |
| `GET /actuator/info` | Application information |
| `GET /actuator/metrics` | Application metrics |
| `GET /actuator/chat` | **Custom endpoint**: Chat statistics |

#### Custom Chat Endpoint Response

```json
{
  "onlineUsers": 5,
  "messagesLast24Hours": 142,
  "activeUsernames": ["Alice", "Bob", "Charlie"]
}
```

## Scaling and High Availability

The application is designed to scale horizontally:

1. **Stateless Instances**: No local state (except in-memory user sessions per instance)
2. **Message Distribution**: RabbitMQ distributes messages across all instances
3. **Shared Database**: MySQL stores persistent chat history
4. **WebSocket Per Instance**: Each instance manages its own WebSocket connections

### Running Multiple Instances

```bash
# Instance 1
docker run -p 8080:8080 ... cloud-native-chat:1.0.0

# Instance 2
docker run -p 8081:8080 ... cloud-native-chat:1.0.0

# Instance 3
docker run -p 8082:8080 ... cloud-native-chat:1.0.0
```

Use a load balancer (e.g., nginx) to distribute traffic across instances.

## Cloud Foundry Deployment

### Prerequisites

1. **MySQL Service**: Create a MySQL service instance
2. **RabbitMQ Service**: Create a RabbitMQ service instance

### Automated Deployment (Recommended)

The automated deployment script handles everything including running the **database initializer task**:

```bash
# Build application
mvn clean package

# Deploy to Cloud Foundry (includes db-initializer task)
./deploy-cf.sh
```

**What it does:**
1. ✓ Creates MySQL and RabbitMQ services (if needed)
2. ✓ Pushes application (without starting)
3. ✓ Binds services
4. ✓ **Runs database initializer task** (Factor XII: Admin Process)
5. ✓ Waits for task completion
6. ✓ Starts application

### Manual Deployment Steps

```bash
# Login to Cloud Foundry
cf login -a https://api.your-cf-domain.com

# Create services
./create-services.sh

# Push application (without starting)
cf push cloud-native-chat -f manifest.yml --no-start

# Bind services (already defined in manifest.yml)

# Run database initializer task (IMPORTANT!)
cf run-task cloud-native-chat \
  "java -jar app.jar --spring.profiles.active=initializer" \
  --name db-initializer

# Wait for task to complete
cf tasks cloud-native-chat

# Start application
cf start cloud-native-chat

# Scale application
cf scale cloud-native-chat -i 3
```

### Running Database Initializer Later

```bash
# Run db-initializer anytime (idempotent)
./run-db-init-task.sh

# Or manually:
cf run-task cloud-native-chat \
  "java -jar app.jar --spring.profiles.active=initializer" \
  --name db-initializer
```

### Cloud Foundry Manifest (manifest.yml)

```yaml
applications:
  - name: cloud-native-chat
    memory: 1G
    instances: 2
    buildpacks:
      - java_buildpack
    path: target/cloud-native-chat-demo-1.0.0.jar
    env:
      APP_VERSION: "1.0.0"
      APP_DEPLOYMENT_COLOR: "blue"
    services:
      - chat-mysql
      - chat-rabbitmq
    health-check-type: http
    health-check-http-endpoint: /actuator/health
```

## Monitoring and Observability

### Health Checks

```bash
# Application health
curl http://localhost:8080/actuator/health

# Chat statistics
curl http://localhost:8080/actuator/chat
```

### Logs

```bash
# Docker Compose logs
docker-compose logs -f app

# Cloud Foundry logs
cf logs cloud-native-chat --recent
```

### RabbitMQ Management

Access RabbitMQ management UI at http://localhost:15672
- Username: `guest`
- Password: `guest`

Monitor:
- Queues and message rates
- Connections and channels
- Exchange bindings

## Development

### Project Structure

```
cloud-native-chat-demo/
├── src/
│   ├── main/
│   │   ├── java/com/example/chat/
│   │   │   ├── CloudNativeChatApplication.java
│   │   │   ├── config/
│   │   │   │   ├── RabbitMQConfig.java
│   │   │   │   └── WebSocketConfig.java
│   │   │   ├── controller/
│   │   │   │   ├── WebController.java
│   │   │   │   └── ChatController.java
│   │   │   ├── model/
│   │   │   │   ├── ChatMessage.java
│   │   │   │   └── ChatMessageDTO.java
│   │   │   ├── repository/
│   │   │   │   └── ChatMessageRepository.java
│   │   │   ├── service/
│   │   │   │   ├── ChatService.java
│   │   │   │   ├── ChatMessageListener.java
│   │   │   │   └── UserSessionService.java
│   │   │   └── actuator/
│   │   │       └── ChatStatsEndpoint.java
│   │   └── resources/
│   │       ├── application.properties
│   │       ├── templates/
│   │       │   ├── index.html
│   │       │   └── chat.html
│   │       └── static/
│   │           ├── css/style.css
│   │           └── js/chat.js
├── pom.xml
├── Dockerfile
├── docker-compose.yaml
└── README.md
```

### Running Tests

```bash
mvn test
```

### Building

```bash
# Package JAR
mvn clean package

# Build Docker image
mvn spring-boot:build-image

# Build with Dockerfile
docker build -t cloud-native-chat:1.0.0 .
```

## Troubleshooting

### Common Issues

**WebSocket connection fails**
- Ensure RabbitMQ is running and accessible
- Check firewall rules for port 5672

**Database connection error**
- Verify MySQL is running
- Check credentials in `application.properties`

**Messages not appearing across instances**
- Confirm RabbitMQ is properly configured
- Check queue bindings in RabbitMQ management UI

## License

MIT License - see LICENSE file for details

## Further Reading

- [12-Factor App Methodology](https://12factor.net/)
- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [RabbitMQ Tutorials](https://www.rabbitmq.com/getstarted.html)
- [Cloud Foundry Documentation](https://docs.cloudfoundry.org/)

---

**Built with ❤️ demonstrating cloud-native best practices**
