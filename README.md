# Multi-Stack Demo Applications

**🌐 Language / Sprache:** **English** | [Deutsch](README_DE.md)

---

## Overview
This repository contains demo applications built with different technology stacks to showcase cloud-native development patterns and deployment strategies. The project includes two types of demos, each implemented in three different technology stacks (Spring Boot/Java, .NET Core/C#, Node.js).

## Purpose
The goal of this demo is to:
- **Compare Tech Stacks**: See how the same application is implemented in Spring Boot (Java), .NET Core, and Node.js
- **Cloud Native Patterns**: Demonstrate containerization, external configuration, stateless and stateful designs
- **Database Integration**: Show cloud-native database patterns with PostgreSQL and MySQL
- **Deployment Flexibility**: Show multiple deployment options (local, Docker, Cloud Foundry)
- **Blue/Green Deployments**: Visualize deployment strategies with version and color coding
- **Multi-Instance Awareness**: Use UUIDs to identify different instances in load-balanced scenarios
- **Service Binding**: Demonstrate Cloud Foundry service binding with VCAP_SERVICES

## Demo Applications

### Simple-Demo (Stateless Applications)
Basic stateless applications showcasing fundamental cloud-native patterns.

![Simple Demo Screenshot](assets/simple-demo.png)

#### 1. Spring Boot Demo (`simple-demo/spring-boot-demo`)
- **Framework**: Spring Boot 3.5.7
- **Language**: Java 21
- **Port**: 8080 (configurable via PORT env var)

#### 2. .NET Core Demo (`simple-demo/dotnet-demo`)
- **Framework**: .NET 8.0
- **Language**: C#
- **Port**: 8081 (configurable via PORT env var)

#### 3. Node.js Demo (`simple-demo/nodejs-demo`)
- **Backend**: Express.js
- **Frontend**: HTML
- **Port**: 8082 (configurable via PORT env var)
- **Offline Deployment**: Supports Cloud Foundry offline/air-gapped deployments via `npm-packages-offline-cache`

### DB-Demo (Database-Backed Applications)
Applications with PostgreSQL database integration demonstrating cloud-native data patterns.

![DB Demo Screenshot](assets/db-demo.png)

#### 1. Spring Boot DB Demo (`db-demo/spring-boot-demo`)
- **Framework**: Spring Boot 3.5.7 + Spring Data JPA
- **Language**: Java 21
- **Database**: PostgreSQL 17
- **Port**: 8080 (configurable via PORT env var)

#### 2. .NET Core DB Demo (`db-demo/dotnet-demo`)
- **Framework**: .NET 8.0 + Entity Framework Core
- **Language**: C#
- **Database**: PostgreSQL 17
- **Port**: 8081 (configurable via PORT env var)

#### 3. Node.js DB Demo (`db-demo/nodejs-demo`)
- **Backend**: Express.js + pg (node-postgres) + mysql2
- **Database**: PostgreSQL 17 or MySQL 8 (auto-detected)
- **Port**: 8082 (configurable via PORT env var)
- **Offline Deployment**: Supports Cloud Foundry offline/air-gapped deployments via `npm-packages-offline-cache`


### Cloud Native Chat Demo

[Cloud Native Demo Documentation](cloud-native-chat-demo/README.md)

A **12-Factor cloud-native application** demonstrating modern Spring Boot development patterns with real-time chat functionality.

### User Experience

<table>
<tr>
<td width="50%">
<strong>Login Page</strong><br/>
Users enter their name to join the chat room
<br/><br/>
<img src="cloud-native-chat-demo/assets/screen-01.png" alt="Login Page" width="100%"/>
</td>
<td width="50%">
<strong>Chat Interface</strong><br/>
Real-time messaging with a clean, dark-themed UI
<br/><br/>
<img src="cloud-native-chat-demo/assets/screen-02.png" alt="Chat View" width="100%"/>
</td>
</tr>
</table>

**Features:**
- ✅ Real-time message delivery across all connected users
- ✅ Persistent chat history (messages stored in MySQL)
- ✅ System notifications for user join/leave events
- ✅ Support for multiple simultaneous chat sessions
- ✅ Horizontal scaling with RabbitMQ message distribution



### Overview

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


---

## Features Simple & DB Demo

### Simple-Demo Features

#### Web Interface
- **Instance UUID**: Displayed in the header to identify individual instances
- **Tech Stack Info**: Framework, language version, runtime details
- **Version Badge**: Configurable version number with color coding for deployment visualization

#### REST API
- **Endpoint**: `GET /api/infos`
- **Returns**: JSON with tech stack information and instance details

![API Infos Response](assets/api-infos.png)

### DB-Demo Features

#### Web Interface
- **Instance UUID**: Displayed in the header to identify individual instances
- **Tech Stack Info**: Framework, language version, runtime details
- **Version Badge**: Configurable version number with color coding for deployment visualization
- **Pets Table**: Database-backed table showing 8 sample pet entries (race, gender, name, age, description)

#### REST API
- **Endpoint**: `GET /api/infos` - Tech stack information
- **Endpoint**: `GET /api/pets` - List all pets from PostgreSQL database

![API Pets Response](assets/api-pets.png)

#### Database Integration
- **PostgreSQL 17 or MySQL 8**: Dual database support with automatic detection
- **Sample Data**: 8 pre-populated pet entries
- **Auto-initialization**: Creates table and data on first run
- **Docker Compose**: Includes PostgreSQL and pgAdmin 4 for local development
- **Cloud Foundry**: Auto-detects MySQL or PostgreSQL via VCAP_SERVICES (my-demo-db)
- **Flexible Deployment**: Choose between PostgreSQL or MySQL when deploying to Cloud Foundry

## Deployment Options

### Simple-Demo: Local Development
Each application can be run directly on your machine:
```bash
# Spring Boot
cd simple-demo/spring-boot-demo
./mvnw spring-boot:run

# .NET Core
cd simple-demo/dotnet-demo
dotnet run

# Node.js
cd simple-demo/nodejs-demo
npm install
npm start

# Note: For Cloud Foundry offline/air-gapped environments,
# see "Offline Deployment" section below
```

### DB-Demo: Local Development with Docker Compose
The db-demo apps require PostgreSQL, provided via Docker Compose:
```bash
# Spring Boot
cd db-demo/spring-boot-demo
docker-compose up

# .NET Core
cd db-demo/dotnet-demo
docker-compose up

# Node.js
cd db-demo/nodejs-demo
docker-compose up
```

This starts:
- The application (Spring Boot/8080, .NET/8081, Node.js/8082)
- PostgreSQL 17 database (internal network only)
- pgAdmin 4 at http://localhost:5050 (admin@demo.com / admin)

### Docker with Cloud Native Buildpacks
Build and run using Paketo buildpacks:
```bash
cd simple-demo/<app-name>
./build.sh
docker-compose up
```

### Cloud Foundry Deployment

#### Simple-Demo
```bash
cd simple-demo/<app-name>
cf push
```

**For Node.js apps in offline/air-gapped Cloud Foundry environments:**
```bash
cd simple-demo/nodejs-demo
./create-offline-cache.sh  # Create npm-packages-offline-cache
cf push
```

#### DB-Demo (with Database Service)

**Option 1: PostgreSQL (default)**
```bash
cd db-demo/<app-name>
# Create PostgreSQL service if it doesn't exist
./create-db-service.sh
# or explicitly:
./create-db-service.sh postgres
# Deploy application
cf push
```

**Option 2: MySQL**
```bash
cd db-demo/<app-name>
# Create MySQL service if it doesn't exist
./create-db-service.sh mysql
# Deploy application
cf push
```

The db-demo applications automatically detect and bind to either MySQL or PostgreSQL service (`my-demo-db`) in Cloud Foundry via VCAP_SERVICES. The application will configure itself accordingly based on the detected database type.

**For Node.js apps in offline/air-gapped Cloud Foundry environments:**
```bash
cd db-demo/nodejs-demo
./create-offline-cache.sh        # Create npm-packages-offline-cache
./create-db-service.sh postgres  # Create database service (if needed)
cf push
```

## Configuration
Each application uses its native configuration format to set:
- **Version Number**: For blue/green deployment identification
- **Deployment Color**: Visual indicator (blue, green, etc.)

Configuration files:
- Spring Boot: `application.properties`
- .NET Core: `appsettings.json`
- Node.js: `.env` or `config.json`

## Blue/Green Deployment Demo
1. Deploy version 1.0.0 with color "blue"
2. Access the application and note the UUID and color
3. Deploy version 2.0.0 with color "green"
4. Toggle traffic between versions to demonstrate zero-downtime deployment
5. Use the UUID to track which instance is handling requests

## Offline/Air-Gapped Cloud Foundry Deployment

The **Node.js demos** support deployment to Cloud Foundry environments that **cannot access external npm registries** during buildpack execution (air-gapped or restricted networks).

### Official Cloud Foundry Method: npm-packages-offline-cache

Both Node.js demos use the **official Cloud Foundry offline deployment method** as documented in the [CF Node.js Buildpack documentation](https://docs.cloudfoundry.org/buildpacks/node/index.html#vendoring).

#### How It Works
1. **Create offline cache**: Run `./create-offline-cache.sh` to create `npm-packages-offline-cache/` directory with all dependencies
2. **Upload to CF**: The cache, `.yarnrc`, and `yarn.lock` files are uploaded with your app
3. **Buildpack detection**: CF buildpack detects the offline cache and runs Yarn in offline mode
4. **No external access needed**: All dependencies are provided from the cache

#### Quick Start
```bash
# Simple demo
cd simple-demo/nodejs-demo
./create-offline-cache.sh
cf push

# DB demo
cd db-demo/nodejs-demo
./create-offline-cache.sh
./create-db-service.sh postgres  # if needed
cf push
```

#### Files Created
- `npm-packages-offline-cache/` - Contains all dependencies as .tgz archives
- `.yarnrc` - Yarn offline configuration
- `yarn.lock` - Dependency lock file

#### Buildpack Output
When deploying, you'll see:
```
-----> Detected npm-packages-offline-cache directory
-----> Running yarn in offline mode
```

### Documentation
- **Complete Guide**: [`OFFLINE-CACHE-GUIDE.md`](OFFLINE-CACHE-GUIDE.md)
- **Overview & Comparison**: [`NODEJS-OFFLINE-DEPLOYMENT-README.md`](NODEJS-OFFLINE-DEPLOYMENT-README.md)

---

## Cloud Native Patterns Demonstrated

### Simple-Demo Patterns
- ✅ **Stateless Design**: No shared state between instances
- ✅ **External Configuration**: Version and color from config files
- ✅ **Containerization**: Cloud Native Buildpacks for security and consistency
- ✅ **API-First**: REST endpoints alongside web UI
- ✅ **Health Monitoring**: Each app exposes health information
- ✅ **Platform Portability**: Runs on local, Docker, Cloud Foundry
- ✅ **Offline Deployment** (Node.js): Air-gapped Cloud Foundry support via npm-packages-offline-cache

#### Health Check Endpoints
All applications provide health check endpoints for monitoring and orchestration:

![Spring Boot Actuator Health](assets/actuator-health.png)

- **Spring Boot**: `/actuator/health` - Actuator health endpoint
- **.NET Core**: `/health` - ASP.NET Core health check
- **Node.js**: `/health` - Custom health endpoint

### DB-Demo Patterns (Additional)
- ✅ **External Service Dependency**: Database as a separate, managed service
- ✅ **Service Binding**: Cloud Foundry VCAP_SERVICES for database credentials
- ✅ **Multi-Database Support**: Automatic detection and configuration for MySQL or PostgreSQL
- ✅ **Loose Coupling**: Application doesn't manage database lifecycle
- ✅ **Environment-Based Configuration**: Database connection from environment variables
- ✅ **Service Discovery**: Platform provides database location and credentials
- ✅ **Database Initialization**: Automatic schema creation on first run
- ✅ **Docker Compose for Dev**: Local development with PostgreSQL and pgAdmin
- ✅ **Offline Deployment** (Node.js): Air-gapped Cloud Foundry support with database drivers in offline cache

## Architecture
```
┌─────────────────────────────────────────┐
│          Load Balancer                  │
└─────────────────────────────────────────┘
         │              │
         ▼              ▼
    ┌─────────┐    ┌─────────┐
    │ App v1  │    │ App v2  │
    │ (Blue)  │    │ (Green) │
    │ UUID: A │    │ UUID: B │
    └─────────┘    └─────────┘
```

## Getting Started
1. Clone this repository
2. Navigate to the demo of your choice in `simple-demo/`
3. Follow the README in each subdirectory for specific setup instructions
4. Start the application using your preferred method (local, Docker, or CF)
5. Access the web UI or call the `/api/infos` endpoint

## Project Structure
```
demo/
├── README.md (this file - English)
├── README_DE.md (this file - German)
├── CLAUDE.md (planning document)
├── LICENSE (MIT License)
├── .gitignore
├── OFFLINE-CACHE-GUIDE.md (Node.js offline deployment guide)
├── NODEJS-OFFLINE-DEPLOYMENT-README.md (Overview & comparison)
├── assets/ (screenshots)
├── simple-demo/
│   ├── spring-boot-demo/
│   ├── dotnet-demo/
│   └── nodejs-demo/
│       └── create-offline-cache.sh (offline cache creation)
└── db-demo/
    ├── spring-boot-demo/
    ├── dotnet-demo/
    └── nodejs-demo/
        └── create-offline-cache.sh (offline cache creation)
```

## Documentation
- **Planning & Architecture**: [`CLAUDE.md`](CLAUDE.md) - Detailed planning and architectural decisions
- **Application-Specific**: Each subdirectory contains its own README with specific instructions
- **Node.js Offline Deployment**:
  - [`OFFLINE-CACHE-GUIDE.md`](OFFLINE-CACHE-GUIDE.md) - Complete guide for npm-packages-offline-cache method
  - [`NODEJS-OFFLINE-DEPLOYMENT-README.md`](NODEJS-OFFLINE-DEPLOYMENT-README.md) - Overview and method comparison

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

This is a demonstration project specifically designed for **educational purposes**. Feel free to use, modify, and share for learning and teaching.

## Happy Coding
### 11/2025 - Andreas Lange