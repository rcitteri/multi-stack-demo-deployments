# Running the Application on Host Machine

This guide explains how to run the main Spring Boot application **on your local machine** (outside Docker) while using MySQL and RabbitMQ services running in Docker containers.

## Architecture

```
┌─────────────────────────────────────────┐
│  Host Machine (macOS)                   │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  Spring Boot App                  │ │
│  │  (mvn spring-boot:run)            │ │
│  │  Port: 8080                       │ │
│  └───────────┬───────────────────────┘ │
│              │                          │
│              │ localhost:3306 (MySQL)   │
│              │ localhost:5672 (RabbitMQ)│
└──────────────┼──────────────────────────┘
               │
          Docker Network
               │
    ┌──────────┴──────────┐
    │                     │
┌───▼────────┐     ┌─────▼──────┐
│   MySQL    │     │  RabbitMQ  │
│  Container │     │  Container │
│  :3306     │     │  :5672     │
└────────────┘     └────────────┘
```

## Prerequisites

1. **Java 25** installed
2. **Maven** installed
3. **Docker & Docker Compose** installed
4. Application built: `mvn clean package`

## Step 1: Start Infrastructure Services

Start only the infrastructure services (MySQL + RabbitMQ), **not the app**:

```bash
# Start MySQL and RabbitMQ
docker-compose up -d mysql rabbitmq

# Wait for services to be healthy (about 10-15 seconds)
docker-compose ps
```

You should see:
```
NAME              STATUS
chat-mysql        Up (healthy)
chat-rabbitmq     Up (healthy)
```

## Step 2: Run Database Initializer

Run the database initializer **once** to set up the schema and seed data:

### Option A: Run as Docker Container (Recommended)

```bash
docker-compose up db-initializer
```

Wait for the message:
```
========================================
Database initialization completed successfully
========================================
```

### Option B: Run from Host Machine

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=initializer
```

## Step 3: Test Connectivity

Before running the main app, verify connectivity:

```bash
./test-connection.sh
```

**Expected Output:**
```
✓ MySQL connection successful
✓ RabbitMQ AMQP port (5672) is accessible
✓ RabbitMQ Management UI (15672) is accessible
```

### Manual Tests

**Test MySQL:**
```bash
# If you have MySQL client installed
mysql -h 127.0.0.1 -P 3306 -u chatuser -pchatpass -e "SHOW DATABASES;"

# Or using Docker
docker exec chat-mysql mysql -uchatuser -pchatpass -e "SHOW DATABASES;"
```

**Test RabbitMQ:**
```bash
# Check AMQP port
nc -zv 127.0.0.1 5672

# Check Management UI
curl http://localhost:15672
# Or open in browser: http://localhost:15672 (guest/guest)
```

## Step 4: Run the Application

Now run the main application on your host machine:

```bash
mvn spring-boot:run
```

**Expected Output:**
```
Started CloudNativeChatApplication in 3.456 seconds
```

The application will connect to:
- **MySQL** at `localhost:3306`
- **RabbitMQ** at `localhost:5672`

## Step 5: Access the Application

Open your browser:
- **Chat App**: http://localhost:8080
- **RabbitMQ Management**: http://localhost:15672 (guest/guest)
- **Actuator Health**: http://localhost:8080/actuator/health
- **Chat Stats**: http://localhost:8080/actuator/chat

## Configuration

The application reads from `src/main/resources/application.properties`:

```properties
# MySQL Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/chatdb?...
spring.datasource.username=chatuser
spring.datasource.password=chatpass

# RabbitMQ Configuration
spring.rabbitmq.host=localhost
spring.rabbitmq.port=5672
spring.rabbitmq.username=guest
spring.rabbitmq.password=guest
```

These settings work when:
1. Docker containers expose their ports to the host
2. MySQL binds to `0.0.0.0` (all interfaces)

## Troubleshooting

### Problem: Connection Refused to MySQL

**Symptom:**
```
java.net.ConnectException: Connection refused
```

**Solutions:**

1. **Verify MySQL is running and exposed:**
```bash
docker ps | grep chat-mysql
# Should show: 0.0.0.0:3306->3306/tcp
```

2. **Restart MySQL with proper configuration:**
```bash
docker-compose down
docker-compose up -d mysql
docker logs chat-mysql
```

3. **Check MySQL bind address:**
```bash
docker exec chat-mysql mysql -uroot -prootpass -e \
  "SHOW VARIABLES LIKE 'bind_address';"
# Should show: bind_address | 0.0.0.0
```

4. **Test from host:**
```bash
telnet localhost 3306
# Should connect (press Ctrl+] then 'quit' to exit)
```

### Problem: Connection Refused to RabbitMQ

**Symptom:**
```
org.springframework.amqp.AmqpConnectException: Connection refused
```

**Solutions:**

1. **Verify RabbitMQ is running and exposed:**
```bash
docker ps | grep chat-rabbitmq
# Should show: 0.0.0.0:5672->5672/tcp
```

2. **Check RabbitMQ logs:**
```bash
docker logs chat-rabbitmq
```

3. **Verify RabbitMQ is ready:**
```bash
docker exec chat-rabbitmq rabbitmq-diagnostics ping
# Should output: Ping succeeded
```

### Problem: RabbitMQ Connection Reset (Connection established but immediately dropped)

**Symptom:**
```
java.net.SocketException: Connection reset
org.springframework.amqp.AmqpIOException: java.io.IOException
```

**Root Cause:** By default, RabbitMQ's `guest` user can only connect from `localhost`. When connecting from the host machine to a Docker container, you're not connecting from `localhost` from RabbitMQ's perspective.

**Solution:**

This is already fixed in the project! The `rabbitmq.conf` file configures RabbitMQ to allow guest from any host:

```ini
# Allow guest user to connect from any host (not just localhost)
loopback_users = none
```

**If you still have issues:**

1. **Restart RabbitMQ with the configuration:**
```bash
docker-compose down
docker-compose up -d rabbitmq

# Wait for RabbitMQ to start (10-15 seconds)
docker logs chat-rabbitmq
```

2. **Verify the configuration is loaded:**
```bash
docker exec chat-rabbitmq cat /etc/rabbitmq/rabbitmq.conf
# Should show: loopback_users = none
```

3. **Check guest user permissions:**
```bash
docker exec chat-rabbitmq rabbitmqctl list_users
# Should show: guest [administrator]

docker exec chat-rabbitmq rabbitmqctl list_permissions
# Should show guest with full permissions
```

4. **Test connection from host:**
```bash
# The test script checks this automatically
./test-connection.sh
```

**Important:** The `loopback_users = none` setting is **only for development**. In production, create specific users with proper permissions.

### Problem: MySQL Authentication Failed

**Symptom:**
```
Access denied for user 'chatuser'@'xxx.xxx.xxx.xxx'
```

**Solutions:**

1. **Recreate MySQL with fresh data:**
```bash
docker-compose down -v  # Remove volumes
docker-compose up -d mysql
# Wait 10 seconds
docker-compose up db-initializer
```

2. **Manually grant permissions (if needed):**
```bash
docker exec -it chat-mysql mysql -uroot -prootpass
```
```sql
CREATE USER IF NOT EXISTS 'chatuser'@'%' IDENTIFIED BY 'chatpass';
GRANT ALL PRIVILEGES ON chatdb.* TO 'chatuser'@'%';
FLUSH PRIVILEGES;
EXIT;
```

### Problem: Port Already in Use

**Symptom:**
```
Bind for 0.0.0.0:3306 failed: port is already allocated
```

**Solutions:**

1. **Check what's using the port:**
```bash
lsof -i :3306  # For MySQL
lsof -i :5672  # For RabbitMQ
lsof -i :8080  # For Spring Boot
```

2. **Stop conflicting service or change port:**

For MySQL (in `docker-compose.yaml`):
```yaml
ports:
  - "3307:3306"  # Use different host port
```

Then update `application.properties`:
```properties
spring.datasource.url=jdbc:mysql://localhost:3307/chatdb?...
```

## Stopping Services

```bash
# Stop just the infrastructure services (keep data)
docker-compose stop mysql rabbitmq

# Stop and remove containers (keep data)
docker-compose down

# Stop and remove everything including data
docker-compose down -v
```

## Development Workflow

**Typical development cycle:**

```bash
# 1. Start infrastructure (once)
docker-compose up -d mysql rabbitmq

# 2. Initialize database (once, or after schema changes)
docker-compose up db-initializer

# 3. Run app (iterative development)
mvn spring-boot:run

# Make code changes, stop app (Ctrl+C), run again
mvn spring-boot:run

# 4. When done for the day
docker-compose stop
```

## Advantages of Running on Host

✅ **Fast feedback loop** - No need to rebuild Docker images
✅ **Live reload** - Spring Boot DevTools works
✅ **Easy debugging** - Can attach debugger from IDE
✅ **Logs in console** - Direct output without `docker logs`
✅ **Resource efficient** - Less Docker overhead

## Switching Between Host and Docker

### Running in Docker:
```bash
docker-compose up
```

### Running on Host:
```bash
docker-compose up -d mysql rabbitmq  # Infrastructure only
mvn spring-boot:run                   # App on host
```

Both configurations use the **same settings** and demonstrate identical behavior!

---

**Next Steps:**
- Try scaling: Run multiple instances on different ports
- Use MySQL Workbench to inspect the database
- Monitor RabbitMQ queues in the management UI
- Deploy to Cloud Foundry when ready
