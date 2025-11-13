# Database Initializer - 12-Factor Admin Process

## Overview

The database initializer demonstrates **Factor XII** of the [12-Factor App methodology](https://12factor.net/admin-processes):

> **Run admin/management tasks as one-off processes**

This is a separate Spring Boot application that:
- Runs **before** the main application starts
- Initializes the database schema
- Seeds initial data if needed
- Exits upon completion
- Can be run multiple times safely (idempotent)

## Why Separate Initialization?

### Traditional Approach (Anti-Pattern)
```
Application starts → Hibernate auto-creates schema → Application runs
```

**Problems:**
- Application startup is delayed
- Database changes happen implicitly
- Hard to track what changes were made
- Difficult to run migrations separately
- No clear separation of concerns

### 12-Factor Approach (Best Practice)
```
1. Run db-initializer task → Schema created → Task exits
2. Start application → Application runs (schema already exists)
```

**Benefits:**
- ✅ Explicit database initialization
- ✅ Can be versioned and tracked
- ✅ Can run independently of the app
- ✅ Clear separation of concerns
- ✅ Supports migration strategies
- ✅ Idempotent and safe to re-run

## How It Works

### Application Architecture

```
┌─────────────────────────────────────┐
│  DbInitializerApplication.java      │
│  - Runs with 'initializer' profile  │
│  - CommandLineRunner executes init  │
│  - Exits with status code           │
└─────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────┐
│  DatabaseInitializerService.java    │
│  1. Verify database connection      │
│  2. Create tables (if not exist)    │
│  3. Seed initial data (optional)    │
│  4. Verify initialization           │
└─────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────┐
│  MySQL Database                     │
│  - chat_messages table              │
│  - Sample conversation (11 msgs)   │
│  - John Doe & Jane Smith           │
└─────────────────────────────────────┘
```

### Initialization Steps

1. **Verify Connection**: Ensures database is reachable
2. **Create Tables**: Creates `chat_messages` table if it doesn't exist
3. **Seed Data**: Inserts sample conversation between John Doe and Jane Smith (only if table is empty)
   - 1 System welcome message
   - 2 JOIN messages (John Doe, Jane Smith)
   - 8 CHAT messages (conversation about the application)
   - Total: 11 messages
4. **Verify**: Confirms table is accessible and ready

## Running the Initializer

### Docker Compose

The initializer runs automatically before the main app:

```yaml
services:
  db-initializer:
    # Runs with 'initializer' profile
    command: ["java", "-jar", "app.jar", "--spring.profiles.active=initializer"]
    restart: "no"  # Run once and exit

  app:
    depends_on:
      db-initializer:
        condition: service_completed_successfully
```

**Startup sequence:**
1. MySQL starts
2. RabbitMQ starts
3. **db-initializer runs and exits**
4. Main app starts

```bash
docker-compose up
```

### Cloud Foundry

Run as a one-off task before starting the app:

```bash
# Deploy application (without starting)
cf push cloud-native-chat --no-start

# Run database initializer task
cf run-task cloud-native-chat \
  "java -jar app.jar --spring.profiles.active=initializer" \
  --name db-initializer

# Wait for task to complete, then start app
cf start cloud-native-chat
```

Or use the deployment script:

```bash
./deploy-cf.sh
```

### Manual Execution

Run locally against a database:

```bash
# Using Maven
mvn spring-boot:run -Dspring-boot.run.profiles=initializer

# Using JAR
java -jar target/cloud-native-chat-demo-1.0.0.jar \
  --spring.profiles.active=initializer \
  --spring.datasource.url=jdbc:mysql://localhost:3306/chatdb \
  --spring.datasource.username=chatuser \
  --spring.datasource.password=chatpass
```

## Configuration

### Profile: `initializer`

File: `src/main/resources/application-initializer.properties`

```properties
# Disable web server (CLI-only)
spring.main.web-application-type=none

# Disable Hibernate auto-DDL (we manage it manually)
spring.jpa.hibernate.ddl-auto=none

# Database connection (same as main app)
spring.datasource.url=jdbc:mysql://localhost:3306/chatdb
spring.datasource.username=chatuser
spring.datasource.password=chatpass
```

### Main App Configuration

File: `src/main/resources/application.properties`

```properties
# Schema managed by database initializer
spring.jpa.hibernate.ddl-auto=none
```

## Idempotency

The initializer is **idempotent** - safe to run multiple times:

```sql
-- Tables created with IF NOT EXISTS
CREATE TABLE IF NOT EXISTS chat_messages (...)

-- Data seeded only if table is empty
SELECT COUNT(*) FROM chat_messages;
-- If count > 0, skip seeding
```

## Cloud Foundry Tasks

### View Tasks

```bash
# List all tasks
cf tasks cloud-native-chat

# Example output:
# id   name           state       start time
# 1    db-initializer SUCCEEDED   2025-01-13T10:30:00Z
# 2    db-initializer SUCCEEDED   2025-01-13T11:15:00Z
```

### Run Task Manually

```bash
# Run the db-initializer task
./run-db-init-task.sh

# Or manually:
cf run-task cloud-native-chat \
  "java -jar app.jar --spring.profiles.active=initializer" \
  --name db-initializer
```

### View Task Logs

```bash
# Recent logs
cf logs cloud-native-chat --recent | grep db-initializer

# Follow logs in real-time
cf logs cloud-native-chat | grep db-initializer
```

## Schema Management

### Current Schema

```sql
CREATE TABLE chat_messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    timestamp DATETIME(6) NOT NULL,
    type VARCHAR(20) NOT NULL,
    INDEX idx_timestamp (timestamp),
    INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Future Migrations

For schema changes:

1. **Update** `DatabaseInitializerService.java`
2. **Add** migration logic (e.g., ALTER TABLE)
3. **Test** locally
4. **Run** as Cloud Foundry task before deployment
5. **Deploy** new app version

Example migration:

```java
// In DatabaseInitializerService
private void runMigrations() {
    // Check current schema version
    // Apply migrations as needed
    // Update schema version
}
```

## Testing

### Local Testing

```bash
# Start MySQL
docker run -d --name mysql-test \
  -e MYSQL_DATABASE=chatdb \
  -e MYSQL_USER=chatuser \
  -e MYSQL_PASSWORD=chatpass \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -p 3306:3306 mysql:8.0

# Run initializer
mvn spring-boot:run -Dspring-boot.run.profiles=initializer

# Verify tables
docker exec -it mysql-test mysql -uchatuser -pchatpass chatdb \
  -e "SHOW TABLES; SELECT * FROM chat_messages;"
```

### Docker Compose Testing

```bash
# Start services
docker-compose up -d mysql

# Run initializer
docker-compose up db-initializer

# Check logs
docker-compose logs db-initializer

# Verify exit code
docker inspect chat-db-initializer --format='{{.State.ExitCode}}'
# Should be: 0
```

## Troubleshooting

### Initializer Fails to Start

**Symptom**: Task fails immediately

**Solution**: Check database connectivity

```bash
# Cloud Foundry
cf logs cloud-native-chat --recent | grep db-initializer

# Docker
docker-compose logs db-initializer
```

### Tables Not Created

**Symptom**: App fails with "Table doesn't exist"

**Solution**: Verify initializer ran successfully

```bash
# Check task status
cf tasks cloud-native-chat

# Re-run initializer
./run-db-init-task.sh
```

### Schema Already Exists

**Symptom**: Errors about existing tables

**Solution**: This is normal! Initializer is idempotent and will skip existing tables.

## Benefits for Production

### Separation of Concerns
- Database operations separate from application logic
- Clear audit trail of schema changes
- Explicit deployment steps

### Zero-Downtime Deployments
1. Run schema migrations (task)
2. Deploy new app version (backwards compatible)
3. Old and new versions coexist during rollout

### Rollback Strategy
- Schema changes are versioned
- Can roll back application independently
- Database state is consistent

### Observability
- Task execution logged
- Success/failure clearly tracked
- Easy to monitor in Cloud Foundry

## References

- [12-Factor App: Admin Processes](https://12factor.net/admin-processes)
- [Cloud Foundry Tasks](https://docs.cloudfoundry.org/devguide/using-tasks.html)
- [Spring Boot Profiles](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.profiles)
- [Database Migrations Best Practices](https://martinfowler.com/articles/evodb.html)

---

**This demonstrates cloud-native best practices for database initialization and management.**
