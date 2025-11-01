# Spring Boot DB Demo Application

A cloud-native demo application with PostgreSQL database integration, built with Spring Boot 3.5.7, Spring Data JPA, and Java 25.

## Features
- Web interface showing tech stack information
- Database-backed pets table with 8 sample entries
- Instance UUID for multi-instance identification
- Configurable version and deployment color for blue/green deployments
- REST API endpoints for programmatic access
- Automatic database initialization
- PostgreSQL 17 database integration
- Cloud Foundry service binding via VCAP_SERVICES

## Prerequisites

### For Local Development
- Java 25 or later
- Maven 3.8+ (or use included Maven Wrapper)
- Docker and Docker Compose (for database)

### For Cloud Foundry
- CF CLI
- Access to a Cloud Foundry environment with PostgreSQL service

## Running Locally with Docker Compose

The easiest way to run locally is using Docker Compose, which includes PostgreSQL and pgAdmin:

```bash
docker-compose up
```

This starts:
- **Application**: http://localhost:8080
- **PostgreSQL 17**: Internal database (no external port)
- **pgAdmin 4**: http://localhost:5050 (admin@demo.com / admin)

To stop:
```bash
docker-compose down
```

To remove volumes (reset database):
```bash
docker-compose down -v
```

## Running Locally (Native)

If you want to run the app natively, you'll need PostgreSQL running separately.

### 1. Start PostgreSQL
```bash
docker run -d \
  --name postgres-demo \
  -e POSTGRES_DB=demodb \
  -e POSTGRES_USER=demouser \
  -e POSTGRES_PASSWORD=demopass \
  -p 5432:5432 \
  postgres:17
```

### 2. Run the Application
```bash
./mvnw spring-boot:run
```

The application will connect to PostgreSQL at `localhost:5432`.

## Deploying to Cloud Foundry

### 1. Create Database Service

Run the provided script to create the PostgreSQL service:
```bash
./create-db-service.sh
```

This creates a service named `my-demo-db` if it doesn't exist.

### 2. Build the Application
```bash
./mvnw clean package -DskipTests
```

### 3. Deploy
```bash
cf push
```

The application will automatically bind to `my-demo-db` and read credentials from `VCAP_SERVICES`.

## Database Configuration

### Local Development
Database connection is configured in `application.properties`:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/demodb
spring.datasource.username=demouser
spring.datasource.password=demopass
```

These can be overridden with environment variables:
- `DATABASE_URL`
- `DATABASE_USER`
- `DATABASE_PASSWORD`

### Cloud Foundry
In Cloud Foundry, Spring Boot automatically detects the bound PostgreSQL service from `VCAP_SERVICES` and configures the datasource. **No code changes needed!**

The `VCAP_SERVICES` environment variable contains:
```json
{
  "postgres": [{
    "name": "my-demo-db",
    "credentials": {
      "uri": "postgres://user:pass@host:5432/dbname",
      "username": "user",
      "password": "pass",
      "host": "hostname",
      "port": 5432,
      "database": "dbname"
    }
  }]
}
```

Spring Cloud Connectors or Spring Boot's auto-configuration handles this automatically.

## Database Schema

The `pets` table is automatically created on first run:

```sql
CREATE TABLE pets (
    id SERIAL PRIMARY KEY,
    race VARCHAR(50) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    name VARCHAR(50) NOT NULL,
    age INTEGER NOT NULL,
    description TEXT
);
```

### Sample Data
8 pet entries are inserted on first startup:
1. Golden Retriever, Male, "Max", Age 5
2. Persian Cat, Female, "Luna", Age 3
3. German Shepherd, Male, "Rocky", Age 7
4. Siamese Cat, Female, "Bella", Age 2
5. Labrador, Male, "Charlie", Age 4
6. Maine Coon, Female, "Daisy", Age 6
7. Border Collie, Female, "Molly", Age 3
8. Bengal Cat, Male, "Oliver", Age 4

## API Endpoints

### Web Interface
- `GET /` - HTML page with tech stack info and pets table

### REST API
- `GET /api/infos` - Tech stack information (JSON)
- `GET /api/pets` - List all pets from database (JSON)

### Health Checks
- `GET /actuator/health` - Application health status
- `GET /actuator/info` - Application information

## Configuration

### Port Configuration
The application uses port 8080 by default, but can be customized via the `PORT` environment variable:

```bash
# Run on default port 8080
./mvnw spring-boot:run

# Run on custom port
PORT=9000 ./mvnw spring-boot:run
```

### Version and Color Configuration
Edit `src/main/resources/application.properties`:

```properties
# Version and color for blue/green deployments
app.version=1.0.0
app.deployment.color=blue
```

Available colors: `blue`, `green`, `red`, `yellow`

## pgAdmin Setup

When using Docker Compose, pgAdmin is available at http://localhost:5050.

**Login:**
- Email: `admin@demo.com`
- Password: `admin`

**Add Server Connection:**
1. Right-click "Servers" → "Register" → "Server"
2. General tab:
   - Name: `Demo DB`
3. Connection tab:
   - Host: `postgres`
   - Port: `5432`
   - Database: `demodb`
   - Username: `demouser`
   - Password: `demopass`

## Cloud Native Patterns Demonstrated

### External Service Dependency
The database is a separate, managed service:
- **Local**: PostgreSQL container via Docker Compose
- **Cloud Foundry**: Managed PostgreSQL service (`my-demo-db`)

### Service Binding
In Cloud Foundry, the application doesn't hardcode database credentials. Instead:
- Service credentials come from `VCAP_SERVICES`
- Spring Boot auto-configures the datasource
- Loose coupling between app and database

### Database Initialization
- Automatic schema creation via JPA/Hibernate (`ddl-auto=update`)
- Idempotent data seeding (only inserts if table is empty)
- Safe to restart multiple times

### Stateless Application
- Database holds all persistent state
- Application instances are stateless and horizontally scalable
- Any instance can serve any request

## Technology Stack
- **Framework**: Spring Boot 3.5.7
- **ORM**: Spring Data JPA / Hibernate
- **Language**: Java 25
- **Build Tool**: Maven
- **Database**: PostgreSQL 17
- **JDBC Driver**: PostgreSQL JDBC Driver
- **Template Engine**: Thymeleaf
- **Containerization**: Docker Compose
