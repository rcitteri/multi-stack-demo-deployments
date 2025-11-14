# Quick Start Guide

Get the Cloud Native Chat application running in **5 minutes**!

## Prerequisites

- Java 21
- Maven
- Docker Desktop

## Step 1: Stop Old Containers (if any)

```bash
docker-compose down -v
```

## Step 2: Start Infrastructure

```bash
# Start MySQL and RabbitMQ
docker-compose up -d mysql rabbitmq

# Wait 15 seconds for services to be ready
sleep 15
```

## Step 3: Initialize Database

```bash
# Run database initializer (one-time setup)
docker-compose up db-initializer
```

**Expected Output:**
```
✓ Database initialized successfully. Message count: 11
Database initialization completed successfully
```

## Step 4: Test Connectivity

```bash
./test-connection.sh
```

**Expected Output:**
```
✓ MySQL connection successful
✓ RabbitMQ AMQP port (5672) is accessible
✓ RabbitMQ Management UI (15672) is accessible
✓ Guest user allowed from any host
```

## Step 5: Run Application

```bash
mvn spring-boot:run
```

**Expected Output:**
```
Started CloudNativeChatApplication in X.XXX seconds
```

## Step 6: Access Application

Open in browser:
- **Chat App**: http://localhost:8080
- **RabbitMQ UI**: http://localhost:15672 (guest/guest)
- **MySQL Workbench**: localhost:3306 (chatuser/chatpass)

## Success! 🎉

You should see:
1. Entry page asking for your name
2. After entering name, the chat room with:
   - Sample conversation from John Doe and Jane Smith
   - Your messages appear in real-time
   - System notifications for join/leave events

## What's Running?

| Service | Location | Purpose |
|---------|----------|---------|
| MySQL | Docker (localhost:3306) | Database with 11 sample messages |
| RabbitMQ | Docker (localhost:5672) | Message broker for chat |
| Spring Boot | Host machine (port 8080) | Main application |

## Try These Features

1. **Open Multiple Browser Tabs**: See real-time message synchronization
2. **Check Actuator**: http://localhost:8080/actuator/chat
3. **View RabbitMQ Queues**: http://localhost:15672 → Queues tab
4. **Query Database**: Use MySQL Workbench to see `chat_messages` table

## Troubleshooting

### RabbitMQ Connection Issues?

```bash
# Restart RabbitMQ
docker-compose restart rabbitmq
sleep 10

# Verify configuration
docker exec chat-rabbitmq cat /etc/rabbitmq/rabbitmq.conf
# Should show: loopback_users = none
```

### MySQL Connection Issues?

```bash
# Restart MySQL
docker-compose restart mysql
sleep 10

# Test connection
docker exec chat-mysql mysql -uchatuser -pchatpass -e "SHOW DATABASES;"
```

### Application Won't Start?

1. Check if ports are free:
```bash
lsof -i :8080  # Spring Boot
lsof -i :3306  # MySQL
lsof -i :5672  # RabbitMQ
```

2. Check logs:
```bash
docker logs chat-mysql
docker logs chat-rabbitmq
```

## Stopping Everything

```bash
# Stop containers (keep data)
docker-compose stop

# Stop and remove containers (keep data)
docker-compose down

# Remove everything including data
docker-compose down -v
```

## What Next?

- Read [README.md](README.md) for complete documentation
- See [RUN-ON-HOST.md](RUN-ON-HOST.md) for detailed development guide
- Check [DB-INITIALIZER.md](DB-INITIALIZER.md) for database initialization details
- Review [CLAUDE.md](CLAUDE.md) for 12-factor principles demonstrated

## Common Development Workflow

```bash
# 1. Start infrastructure (once per day)
docker-compose up -d mysql rabbitmq

# 2. Run app (restart as needed during development)
mvn spring-boot:run

# Make code changes, then Ctrl+C to stop, and run again
mvn spring-boot:run

# 3. End of day
docker-compose stop
```

---

**Need Help?** Check the detailed guides:
- [README.md](README.md) - Full documentation
- [RUN-ON-HOST.md](RUN-ON-HOST.md) - Host machine setup
- [DB-INITIALIZER.md](DB-INITIALIZER.md) - Database initialization
