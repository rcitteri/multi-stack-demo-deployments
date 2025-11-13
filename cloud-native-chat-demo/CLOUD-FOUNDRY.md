# Cloud Foundry Deployment Guide

This guide explains how to deploy the Cloud Native Chat application to Cloud Foundry using **java-cfenv-boot** for automatic service binding.

## How java-cfenv-boot Works

The `java-cfenv-boot` library provides **zero-configuration** Cloud Foundry support:

### Magic Behind the Scenes

1. **Detects Cloud Foundry Environment**
   - Checks for `VCAP_APPLICATION` and `VCAP_SERVICES` environment variables
   - Only activates when running on Cloud Foundry

2. **Parses Service Bindings**
   - Reads `VCAP_SERVICES` JSON automatically
   - Extracts connection details for bound services

3. **Sets Spring Boot Properties**
   - Overrides `spring.datasource.*` properties for MySQL
   - Overrides `spring.rabbitmq.*` properties for RabbitMQ
   - No code changes needed!

### Configuration Flow

```
┌─────────────────────────────────────────────────────┐
│  Local Development                                  │
│  ┌──────────────────────────────────────────────┐   │
│  │ application.properties                       │   │
│  │ spring.datasource.url=localhost:3306         │   │
│  │ spring.rabbitmq.host=localhost               │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
                      │
                      ▼
            ┌─────────────────┐
            │  Application    │
            │     Runs        │
            └─────────────────┘


┌─────────────────────────────────────────────────────┐
│  Cloud Foundry Deployment                           │
│  ┌──────────────────────────────────────────────┐   │
│  │ VCAP_SERVICES (environment variable)         │   │
│  │ {                                            │   │
│  │   "p.mysql": [{                              │   │
│  │     "credentials": {                         │   │
│  │       "uri": "mysql://host:port/db",         │   │
│  │       "username": "...",                     │   │
│  │       "password": "..."                      │   │
│  │     }                                        │   │
│  │   }],                                        │   │
│  │   "rabbitmq": [{ ... }]                      │   │
│  │ }                                            │   │
│  └──────────────────────────────────────────────┘   │
│                    │                                │
│                    ▼                                │
│  ┌──────────────────────────────────────────────┐   │
│  │ java-cfenv-boot (automatic detection)        │   │
│  │ - Detects CF environment                     │   │
│  │ - Parses VCAP_SERVICES                       │   │
│  │ - Sets Spring Boot properties                │   │
│  └──────────────────────────────────────────────┘   │
│                    │                                │
│                    ▼                                │
│  ┌──────────────────────────────────────────────┐   │
│  │ Application Runs with CF services            │   │
│  │ spring.datasource.url=<CF MySQL>             │   │
│  │ spring.rabbitmq.host=<CF RabbitMQ>           │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

## Prerequisites

1. **Cloud Foundry CLI** installed
2. **Access to Cloud Foundry** platform
3. **Application built**: `mvn clean package`

## Deployment Steps

### Option 1: Automated Deployment (Recommended)

```bash
# Build the application
mvn clean package

# Run the deployment script (handles everything)
./deploy-cf.sh
```

**What the script does:**
1. ✓ Creates MySQL service (`demodb`)
2. ✓ Creates RabbitMQ service (`chatqueue`)
3. ✓ Pushes application (without starting)
4. ✓ Binds services
5. ✓ Runs database initializer task
6. ✓ Starts application

### Option 2: Manual Deployment

#### Step 1: Login to Cloud Foundry

```bash
cf login -a https://api.your-cf-domain.com
```

#### Step 2: Create Services

```bash
# Create services if they don't exist
./create-services.sh

# Or manually:
cf create-service p.mysql small demodb
cf create-service rabbitmq small chatqueue
```

#### Step 3: Push Application

```bash
# Push without starting
cf push cloud-native-chat -f manifest.yml --no-start
```

#### Step 4: Run Database Initializer Task

**Important:** Run the database initializer BEFORE starting the app:

```bash
cf run-task cloud-native-chat \
  "java -jar app.jar --spring.profiles.active=initializer" \
  --name db-initializer

# Wait for task to complete
cf tasks cloud-native-chat

# Check logs
cf logs cloud-native-chat --recent | grep db-initializer
```

#### Step 5: Start Application

```bash
cf start cloud-native-chat
```

## How Services Are Bound

### manifest.yml Configuration

```yaml
applications:
  - name: cloud-native-chat
    services:
      - chatqueue  # RabbitMQ service
      - demodb     # MySQL service
```

When you deploy, Cloud Foundry:
1. Injects `VCAP_SERVICES` with service credentials
2. java-cfenv-boot detects and parses it
3. Spring Boot connects automatically

### Example VCAP_SERVICES

```json
{
  "p.mysql": [{
    "name": "demodb",
    "credentials": {
      "uri": "mysql://aaa-bbb-ccc.mysql.service.cf.internal:3306/service_instance_db",
      "username": "abcd1234",
      "password": "secret-password",
      "hostname": "aaa-bbb-ccc.mysql.service.cf.internal",
      "port": 3306,
      "database": "service_instance_db"
    }
  }],
  "rabbitmq": [{
    "name": "chatqueue",
    "credentials": {
      "uri": "amqp://user:pass@host:5672/vhost",
      "hostname": "xxx-yyy-zzz.rabbitmq.service.cf.internal",
      "port": 5672,
      "username": "abcd-efgh-ijkl",
      "password": "secret-rabbit-password",
      "vhost": "12345678-1234-1234-1234-123456789abc"
    }
  }]
}
```

### How java-cfenv-boot Maps This

**MySQL Mapping:**
```
VCAP_SERVICES["p.mysql"][0].credentials.uri
  → spring.datasource.url

VCAP_SERVICES["p.mysql"][0].credentials.username
  → spring.datasource.username

VCAP_SERVICES["p.mysql"][0].credentials.password
  → spring.datasource.password
```

**RabbitMQ Mapping:**
```
VCAP_SERVICES["rabbitmq"][0].credentials.hostname
  → spring.rabbitmq.host

VCAP_SERVICES["rabbitmq"][0].credentials.port
  → spring.rabbitmq.port

VCAP_SERVICES["rabbitmq"][0].credentials.username
  → spring.rabbitmq.username

VCAP_SERVICES["rabbitmq"][0].credentials.password
  → spring.rabbitmq.password

VCAP_SERVICES["rabbitmq"][0].credentials.vhost
  → spring.rabbitmq.virtual-host
```

## Verifying the Deployment

### 1. Check Application Status

```bash
cf app cloud-native-chat
```

Expected output:
```
     state: started
instances: 2/2
  memory: 1G
    disk: 1G
```

### 2. View Application Logs

```bash
# Recent logs
cf logs cloud-native-chat --recent

# Follow logs in real-time
cf logs cloud-native-chat
```

Look for:
```
✓ Connected to MySQL via VCAP_SERVICES
✓ Connected to RabbitMQ via VCAP_SERVICES
Started CloudNativeChatApplication in X.XXX seconds
```

### 3. Test the Application

```bash
# Get the application URL
cf app cloud-native-chat | grep routes

# Access the application
curl https://cloud-native-chat.your-cf-domain.com

# Check actuator health
curl https://cloud-native-chat.your-cf-domain.com/actuator/health

# Check chat stats
curl https://cloud-native-chat.your-cf-domain.com/actuator/chat
```

### 4. Verify Service Bindings

```bash
# List bound services
cf services

# Check specific service details
cf service demodb
cf service chatqueue

# View environment variables (includes VCAP_SERVICES)
cf env cloud-native-chat
```

## Scaling the Application

```bash
# Scale horizontally (more instances)
cf scale cloud-native-chat -i 3

# Scale vertically (more memory)
cf scale cloud-native-chat -m 2G

# Both at once
cf scale cloud-native-chat -i 5 -m 2G
```

**Why this works:**
- ✅ Stateless application design
- ✅ RabbitMQ distributes messages across instances
- ✅ MySQL shared across all instances
- ✅ WebSocket connections per instance

## Blue/Green Deployment

```bash
# Deploy new version as "green"
cf push cloud-native-chat-green -f manifest-green.yml

# Test the green deployment
curl https://cloud-native-chat-green.your-cf-domain.com

# Switch traffic from blue to green
cf map-route cloud-native-chat-green your-cf-domain.com --hostname cloud-native-chat
cf unmap-route cloud-native-chat your-cf-domain.com --hostname cloud-native-chat

# Delete old blue deployment
cf delete cloud-native-chat -f
cf rename cloud-native-chat-green cloud-native-chat
```

## Troubleshooting

### Application Won't Start

**Check logs:**
```bash
cf logs cloud-native-chat --recent
```

**Common issues:**

1. **Service not bound:**
   ```
   Error: Unable to acquire JDBC Connection
   ```
   **Fix:** Ensure services are bound:
   ```bash
   cf bind-service cloud-native-chat demodb
   cf bind-service cloud-native-chat chatqueue
   cf restage cloud-native-chat
   ```

2. **Database not initialized:**
   ```
   Table 'chat_messages' doesn't exist
   ```
   **Fix:** Run the database initializer:
   ```bash
   ./run-db-init-task.sh
   ```

3. **Out of memory:**
   ```
   OutOfMemoryError: Java heap space
   ```
   **Fix:** Increase memory:
   ```bash
   cf scale cloud-native-chat -m 2G
   ```

### How to Debug java-cfenv-boot

**Enable debug logging:**

Add to `application.properties`:
```properties
logging.level.io.pivotal.cfenv=DEBUG
```

Or set environment variable:
```bash
cf set-env cloud-native-chat LOGGING_LEVEL_IO_PIVOTAL_CFENV DEBUG
cf restage cloud-native-chat
```

**Check logs for:**
```
CfEnvProcessor: Cloud Foundry environment detected
CfEnvProcessor: Found service: demodb [p.mysql]
CfEnvProcessor: Found service: chatqueue [rabbitmq]
CfDataSourceEnvironmentPostProcessor: Setting spring.datasource.url from CF service
CfRabbitEnvironmentPostProcessor: Setting spring.rabbitmq.host from CF service
```

## Advanced Configuration

### Custom Service Detection

If you need custom service detection logic:

```java
@Configuration
public class CustomCfConfig {

    @Bean
    public CfEnvProcessor cfEnvProcessor() {
        return CfEnvProcessorBuilder.forPivotalCf()
            .withPostProcessor(new CustomCfEnvPostProcessor())
            .build();
    }
}
```

### Multiple Database Instances

For multiple databases, use service tags:

```yaml
services:
  - name: primary-db
    label: p.mysql
    tags: [primary]
  - name: replica-db
    label: p.mysql
    tags: [replica]
```

## Summary

### Local Development
- Uses `application.properties` settings
- Connects to `localhost:3306` (MySQL)
- Connects to `localhost:5672` (RabbitMQ)

### Cloud Foundry Deployment
- Uses VCAP_SERVICES environment variables
- java-cfenv-boot automatically detects and configures
- **Zero code changes needed!**
- Same JAR file works in both environments

### The Magic
```
Local:  application.properties → Spring Boot
Cloud:  VCAP_SERVICES → java-cfenv-boot → Spring Boot
```

This is **Factor III (Config)** and **Factor IV (Backing Services)** of the 12-Factor App methodology in action!

---

**Related Documentation:**
- [README.md](README.md) - Main project documentation
- [DB-INITIALIZER.md](DB-INITIALIZER.md) - Database initialization details
- [RUN-ON-HOST.md](RUN-ON-HOST.md) - Local development guide
- [java-cfenv-boot Documentation](https://github.com/pivotal-cf/java-cfenv)
