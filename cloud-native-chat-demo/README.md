# Cloud Native Chat Demo

A **12-Factor cloud-native application** demonstrating modern Spring Boot development patterns with real-time chat functionality.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Java](https://img.shields.io/badge/Java-21-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.7-brightgreen)

## 🎯 The 12-Factor App Methodology

This application is a **complete implementation** of the [12-Factor App methodology](https://12factor.net/), demonstrating all principles for building cloud-native applications. Each factor is explicitly demonstrated in this codebase:

### Factor I: Codebase
**One codebase tracked in revision control, many deploys**

✅ **Implementation**:
- Single Git repository contains all application code
- Same codebase deploys to local, Docker, and Cloud Foundry
- Version control enables rollbacks and audit trails
- Branch strategy supports multiple environments

📂 **Code**: Entire project in one repo with clear structure

### Factor II: Dependencies
**Explicitly declare and isolate dependencies**

✅ **Implementation**:
- Maven (`pom.xml`) explicitly declares all dependencies with versions
- No system-level dependencies assumed - everything bundled
- Spring Boot manages transitive dependencies
- Dependency isolation through Maven dependency management

📂 **Code**: `pom.xml` (main app), `initializer/pom.xml` (db-initializer)

### Factor III: Config
**Store config in the environment**

✅ **Implementation**:
- Configuration externalized via `application.properties`
- Environment variables override config (e.g., `SPRING_DATASOURCE_URL`)
- No hardcoded credentials or environment-specific values
- Cloud Foundry binds services via `VCAP_SERVICES`
- `java-cfenv-boot` automatically reads Cloud Foundry environment

📂 **Code**: `src/main/resources/application.properties`, manifest files

### Factor IV: Backing Services
**Treat backing services as attached resources**

✅ **Implementation**:
- **MySQL**: Attached via JDBC URL (local or Cloud Foundry service)
- **RabbitMQ**: Attached via connection config (local or CF service)
- Service URLs provided via environment - no code changes needed
- Services can be swapped without code modifications
- CF service binding automatically configures connections

📂 **Code**: `RabbitMQConfig.java`, `application.properties`, `manifest.yml`

### Factor V: Build, Release, Run
**Strictly separate build and run stages**

✅ **Implementation**:
- **Build**: `mvn clean package` creates executable JAR
- **Release**: Docker image tags or CF push creates versioned release
- **Run**: `java -jar` executes the release artifact
- Artifacts are immutable - built once, deployed many times
- No code changes after build stage

📂 **Code**: `pom.xml`, `Dockerfile`, `build.sh`, `deploy-cf.sh`

### Factor VI: Processes
**Execute the app as one or more stateless processes**

✅ **Implementation**:
- Application is completely stateless
- No local session storage (WebSocket sessions are ephemeral)
- Chat history stored in MySQL (shared across instances)
- Messages distributed via RabbitMQ (external broker)
- Any instance can be killed and replaced without data loss
- Horizontal scaling works because no local state

📂 **Code**: All service classes use external storage/messaging

### Factor VII: Port Binding
**Export services via port binding**

✅ **Implementation**:
- Embedded Tomcat server (self-contained)
- Exports HTTP service on port 8080
- No external web server (Apache/nginx) required
- WebSocket also served via embedded server
- Application is completely self-contained

📂 **Code**: Spring Boot embedded container, `server.port=8080`

### Factor VIII: Concurrency
**Scale out via the process model**

✅ **Implementation**:
- Horizontal scaling: Run multiple instances
- Each instance is identical and stateless (Factor VI)
- RabbitMQ distributes messages across instances
- Load balancer (nginx/CF router) distributes HTTP traffic
- Tested with multiple Docker containers and CF instances
- No coordination needed between instances

📂 **Code**: RabbitMQ message distribution, stateless design

```bash
# Scale in Cloud Foundry
cf scale cloud-native-chat -i 5

# Scale in Docker
docker run -p 8080:8080 cloud-native-chat:1.0.0  # Instance 1
docker run -p 8081:8080 cloud-native-chat:1.0.0  # Instance 2
docker run -p 8082:8080 cloud-native-chat:1.0.0  # Instance 3
```

### Factor IX: Disposability
**Maximize robustness with fast startup and graceful shutdown**

✅ **Implementation**:
- **Fast startup**: Application starts in ~10-15 seconds
- **Graceful shutdown**: n/a, use Spring Boot shutdown hooks to manage shutdown
- WebSocket connections closed gracefully
- RabbitMQ connections closed properly
- Can be started/stopped without data loss
- Suitable for frequent deploys and autoscaling

📂 **Code**: Spring Boot lifecycle management, graceful shutdown

### Factor X: Dev/Prod Parity
**Keep development, staging, and production as similar as possible**

✅ **Implementation**:
- **Same code**: Identical codebase across all environments
- **Same backing services**: MySQL and RabbitMQ in all envs
- **Same containers**: Docker Compose (dev) = Docker (prod)
- **Same deployment**: Cloud Foundry mirrors local Docker setup
- **Time gap**: CI/CD enables hours between dev and prod
- **Personnel gap**: Developers can deploy to production
- **Tools gap**: Same database (MySQL) and message broker (RabbitMQ)

📂 **Code**: `docker-compose.yaml`, `manifest.yml`, same services everywhere

### Factor XI: Logs
**Treat logs as event streams**

✅ **Implementation**:
- All logs written to stdout/stderr (no log files)
- Structured logging with SLF4J and Logback
- No log rotation or management in application code
- Platform captures logs (Docker logs, CF logs)
- Logs are time-ordered event streams
- External tools aggregate and analyze logs

📂 **Code**: `@Slf4j` annotations, no file appenders

```bash
# View logs in Docker
docker-compose logs -f app

# View logs in Cloud Foundry
cf logs cloud-native-chat --recent
cf logs cloud-native-chat  # Follow in real-time
```

### Factor XII: Admin Processes
**Run admin/management tasks as one-off processes**

✅ **Implementation**: **STAR FEATURE** of this demo!
- **Database Initializer**: Separate Spring Boot application in `initializer/` folder
- Runs as one-off process before main app starts
- Creates schema, seeds data, then exits
- Idempotent - safe to run multiple times
- Cloud Foundry: Runs as `cf task`
- Docker: Runs as separate container that exits
- Zero parameters needed - uses same environment bindings

📂 **Code**: `initializer/` folder (complete separate Spring Boot app)

```bash
# Docker Compose
docker-compose up db-initializer  # Runs once, exits with code 0

# Cloud Foundry
cf run-task cloud-native-chat-initializer \
  --command 'java -jar app.jar' \ # This is a shortcut command to demonstrate how it works refer to `deploy-cf.sh`
  --name db-initializer

# Local
cd initializer && mvn spring-boot:run
```

**Additional Admin Endpoints:**
- `GET /actuator/chat` - Custom endpoint for chat statistics
- `GET /actuator/health` - Health checks for observability
- `GET /actuator/metrics` - Application metrics

📖 **Full Documentation**: [DB-INITIALIZER.md](DB-INITIALIZER.md)

---

## 💬 About the Chat Application

This is a **real-time group chat application** that demonstrates cloud-native patterns through practical implementation. Users can join chat rooms, exchange messages instantly via WebSocket, and see their conversation history persisted in MySQL.

### User Experience

<table>
<tr>
<td width="50%">
<strong>Login Page</strong><br/>
Users enter their name to join the chat room
<br/><br/>
<img src="assets/screen-01.png" alt="Login Page" width="100%"/>
</td>
<td width="50%">
<strong>Chat Interface</strong><br/>
Real-time messaging with a clean, dark-themed UI
<br/><br/>
<img src="assets/screen-02.png" alt="Chat View" width="100%"/>
</td>
</tr>
</table>

**Features:**
- ✅ Real-time message delivery across all connected users
- ✅ Persistent chat history (messages stored in MySQL)
- ✅ System notifications for user join/leave events
- ✅ Support for multiple simultaneous chat sessions
- ✅ Horizontal scaling with RabbitMQ message distribution

---

## Overview

This application showcases all 12 factors for building cloud-native applications that are:
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

| Component | Technology          |
|-----------|---------------------|
| **Language** | Java 21+            |
| **Framework** | Spring Boot 3.5.7   |
| **Template Engine** | Thymeleaf           |
| **Real-time** | WebSocket (STOMP)   |
| **Messaging** | RabbitMQ (AMQP)     |
| **Database** | MySQL 8.0           |
| **Build Tool** | Maven               |
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

- **Java 21+** ([Download](https://jdk.java.net/21/))
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

This application demonstrates **Factor XII: Admin Processes** with a **completely separate Spring Boot application** in the `initializer/` folder that runs as a **one-off process** before the main application.

### Why a Separate Application?

Traditional approach (anti-pattern):
- Application starts → Hibernate creates schema → App runs

**Problems:** Delayed startup, implicit changes, hard to track, no separation of concerns

12-Factor approach (best practice):
- Build & run separate `db-initializer` app → Schema created → Exits
- Start main application → App runs (schema ready)

**Benefits:** ✅ Explicit initialization ✅ Completely independent ✅ Zero coupling ✅ Clear separation

### Two Separate Spring Boot Applications

This project contains **two completely independent applications**:

```
cloud-native-chat-demo/           # Main chat application
├── src/                          # Main app source code
├── pom.xml                       # Main app dependencies
└── target/
    └── cloud-native-chat-demo-1.0.0.jar

initializer/                      # Database initializer (separate app)
├── src/                          # Initializer source code
├── pom.xml                       # Minimal dependencies (no RabbitMQ/WebSocket)
└── target/
    └── cloud-native-chat-initializer-1.0.0.jar
```

### How It Works

```
Docker Compose Startup Sequence:
1. MySQL starts ✓
2. RabbitMQ starts ✓
3. db-initializer builds & runs → Creates schema → Exits ✓
4. Main app builds & starts ✓
```

The initializer:
- Verifies database connection
- Creates `chat_messages` table (if not exists)
- Seeds initial welcome message and conversation
- Exits with success code (0 = success, non-zero = failure)

### Running Manually

```bash
# Run initializer locally
cd initializer
mvn spring-boot:run

# Run initializer in Cloud Foundry
cf run-task cloud-native-chat-initializer \
  --command 'java -jar app.jar' \
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

# Build both applications
mvn clean package -DskipTests
cd initializer && mvn clean package -DskipTests && cd ..
cp initializer/target/cloud-native-chat-initializer-1.0.0.jar target/

# Push initializer application (no-route, won't start)
cf push cloud-native-chat-initializer -f manifest-initializer.yml

# Run database initializer task (IMPORTANT!)
cf run-task cloud-native-chat-initializer \
  --command 'java -jar app.jar' \
  --name db-initializer

# Wait for task to complete
cf tasks cloud-native-chat-initializer

# Push and start main application
cf push cloud-native-chat -f manifest.yml

# Scale application
cf scale cloud-native-chat -i 3
```

### Running Database Initializer Later

```bash
# Run db-initializer anytime (idempotent)
./run-db-init-task.sh

# Or manually:
cf run-task cloud-native-chat-initializer \
  --command 'JAVA_OPTS="-agentpath:$PWD/.java-buildpack/open_jdk_jre/bin/jvmkill-1.17.0_RELEASE=printHeapHistogram=1 -Djava.io.tmpdir=$TMPDIR -Djava.ext.dirs=  -Djava.security.properties=$PWD/.java-buildpack/java_security/java.security $JAVA_OPTS" && CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-3.13.0_RELEASE -totMemory=$MEMORY_LIMIT -loadedClasses=27736 -poolType=metaspace -stackThreads=250 -vmOptions="$JAVA_OPTS") && echo JVM Memory Configuration: $CALCULATED_MEMORY && JAVA_OPTS="$JAVA_OPTS $CALCULATED_MEMORY" && MALLOC_ARENA_MAX=2 SERVER_PORT=$PORT eval exec $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/.:$PWD/.java-buildpack/container_security_provider/container_security_provider-1.20.0_RELEASE.jar org.springframework.boot.loader.launch.JarLauncher'
```

### Cloud Foundry Manifest (manifest.yml)

```yaml
applications:
  - name: cloud-native-chat
    memory: 1G
    instances: 2
    buildpacks:
      - java_buildpack_offline
    path: target/cloud-native-chat-demo-1.0.0.jar
    env:
      JBP_CONFIG_OPEN_JDK_JRE: '{ jre: { version: 21.+ } }'
      APP_VERSION: "1.0.0"
      APP_DEPLOYMENT_COLOR: "blue"
    services:
      - demodb
      - chatqueue
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
├── src/                          # Main Application Source Code
│   ├── main/
│   │   ├── java/com/example/chat/
│   │   │   ├── CloudNativeChatApplication.java  # Main entry point
│   │   │   ├── config/
│   │   │   │   ├── RabbitMQConfig.java         # Message broker config
│   │   │   │   └── WebSocketConfig.java        # WebSocket/STOMP config
│   │   │   ├── controller/
│   │   │   │   ├── WebController.java          # Web UI endpoints
│   │   │   │   └── ChatController.java         # WebSocket message handlers
│   │   │   ├── model/
│   │   │   │   ├── ChatMessage.java            # JPA entity
│   │   │   │   └── ChatMessageDTO.java         # Data transfer object
│   │   │   ├── repository/
│   │   │   │   └── ChatMessageRepository.java  # Spring Data JPA
│   │   │   ├── service/
│   │   │   │   ├── ChatService.java            # Business logic
│   │   │   │   ├── ChatMessageListener.java    # RabbitMQ consumer
│   │   │   │   └── UserSessionService.java     # WebSocket session tracking
│   │   │   └── actuator/
│   │   │       └── ChatStatsEndpoint.java      # Custom metrics
│   │   └── resources/
│   │       ├── application.properties           # Main app configuration
│   │       ├── templates/
│   │       │   ├── index.html                  # Entry page (Thymeleaf)
│   │       │   └── chat.html                   # Chat room (Thymeleaf)
│   │       └── static/
│   │           ├── css/style.css               # Dark theme styles
│   │           └── js/chat.js                  # WebSocket client
├── initializer/                  # DATABASE INITIALIZER (Separate App!)
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/example/chat/
│   │   │   │   ├── DbInitializerApplication.java      # Initializer entry point
│   │   │   │   └── DatabaseInitializerService.java    # Schema creation logic
│   │   │   └── resources/
│   │   │       └── application.properties              # Initializer config (minimal)
│   ├── pom.xml                   # Minimal dependencies (JDBC only, no RabbitMQ)
│   └── target/
│       └── cloud-native-chat-initializer-1.0.0.jar
├── pom.xml                       # Main app dependencies
├── Dockerfile                    # Multi-stage build (app + initializer)
├── docker-compose.yaml           # Local dev infrastructure
├── docker-compose-all.yaml       # Full stack (MySQL + RabbitMQ + App)
├── manifest.yml                  # Cloud Foundry main app manifest
├── manifest-initializer.yml      # Cloud Foundry initializer manifest
├── build.sh                      # Build script
├── run-docker.sh                 # Run with Docker Compose
├── deploy-cf.sh                  # Deploy to Cloud Foundry
├── run-db-init-task.sh           # Run initializer task in CF
└── README.md                     # This file
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

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

This is a demonstration project specifically designed for **educational purposes**. Feel free to use, modify, and share for learning and teaching.


## Further Reading

- [12-Factor App Methodology](https://12factor.net/)
- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [RabbitMQ Tutorials](https://www.rabbitmq.com/getstarted.html)
- [Cloud Foundry Documentation](https://docs.cloudfoundry.org/)

---

**Built with ❤️ demonstrating cloud-native best practices**
