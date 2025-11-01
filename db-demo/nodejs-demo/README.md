# Node.js PostgreSQL Demo Application

A cloud-native demo application built with Node.js, Express, and PostgreSQL 17, demonstrating database integration, service binding, and blue/green deployment patterns.

## Features

- **PostgreSQL 17 Integration** - Native pg (node-postgres) driver
- **Auto Database Initialization** - Creates schema and seeds sample data on startup
- **REST API** - Endpoints for tech stack info and pets data
- **Cloud Foundry Service Binding** - VCAP_SERVICES parsing for database credentials
- **Blue/Green Deployment** - Version and color-based deployment strategies
- **Docker Support** - Docker Compose with PostgreSQL and pgAdmin 4
- **Health Checks** - HTTP endpoint for container orchestration
- **Graceful Shutdown** - Proper cleanup on SIGTERM/SIGINT

## Tech Stack

- **Runtime**: Node.js 22 (LTS)
- **Framework**: Express.js 4.x
- **Database**: PostgreSQL 17 with pg (node-postgres)
- **Language**: JavaScript (ES2024)
- **Frontend**: HTML + Vanilla JavaScript
- **Build Tool**: npm
- **Container**: Docker + Paketo Buildpacks

## Prerequisites

- Node.js 22+ and npm 10+
- Docker and Docker Compose (for local development)
- Cloud Foundry CLI (for CF deployments)
- PostgreSQL 17 (or use Docker Compose)

## Quick Start

### Option 1: Docker Compose (Recommended)

```bash
# Start PostgreSQL, pgAdmin, and the application
docker-compose up --build

# Access the application
open http://localhost:8082

# Access pgAdmin (database admin UI)
open http://localhost:5050
# Login: admin@demo.com / admin
```

### Option 2: Local Development

```bash
# Ensure PostgreSQL is running locally or via Docker
docker-compose up postgres -d

# Install dependencies
npm install

# Run the application
npm start

# Access the application
open http://localhost:8082
```

## Configuration

### Environment Variables

The application supports multiple configuration sources with the following priority:

1. **VCAP_SERVICES** - Cloud Foundry service binding (highest priority)
2. **DATABASE_URL** - Heroku-style connection string
3. **Individual DB_* variables** - Separate configuration
4. **.env file** - Local development defaults (lowest priority)

**Available Variables:**

- `PORT` - HTTP port (default: 8082)
- `APP_VERSION` - Application version (default: 1.0.0)
- `APP_COLOR` - Deployment color (default: blue)
- `DATABASE_URL` - Full PostgreSQL connection string
- `DB_HOST` - PostgreSQL host (default: localhost)
- `DB_PORT` - PostgreSQL port (default: 5432)
- `DB_NAME` - Database name (default: demodb)
- `DB_USER` - Database user (default: demouser)
- `DB_PASSWORD` - Database password (default: demopass)

### .env File (Local Development)

```env
APP_VERSION=1.0.0
APP_COLOR=blue
PORT=8082

DB_HOST=localhost
DB_PORT=5432
DB_NAME=demodb
DB_USER=demouser
DB_PASSWORD=demopass
```

## Database Schema

### Pets Table

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

Sample data is automatically seeded on first startup:
- 8 pet records (dogs, cats, birds)
- Includes race, gender, name, age, and descriptions

## REST API Endpoints

### GET /api/infos

Returns technology stack information and application metadata.

**Response:**
```json
{
  "uuid": "550e8400-e29b-41d4-a716-446655440000",
  "version": "1.0.0",
  "deploymentColor": "blue",
  "techStack": {
    "framework": "Node.js + Express",
    "version": "v22.1.0",
    "language": "JavaScript",
    "languageVersion": "ES2024",
    "runtime": "Node.js v22.1.0",
    "database": "PostgreSQL 17"
  }
}
```

### GET /api/pets

Returns all pets from the database.

**Response:**
```json
[
  {
    "id": 1,
    "race": "Golden Retriever",
    "gender": "Male",
    "name": "Max",
    "age": 5,
    "description": "Friendly and energetic dog"
  }
]
```

### GET /health

Health check endpoint for Cloud Foundry and container orchestration.

**Response:** `200 OK` with "Healthy" text (includes database connectivity check)

## Cloud Foundry Deployment

### 1. Create PostgreSQL Service

```bash
# Create the database service (idempotent)
chmod +x create-db-service.sh
./create-db-service.sh

# Verify service is ready
cf service my-demo-db
```

### 2. Deploy Application

The application automatically detects Cloud Foundry environment and:
- Parses `VCAP_SERVICES` for database credentials
- Uses Cloud Foundry provided `PORT` environment variable
- Initializes database schema and sample data

```bash
# Deploy with default manifest
cf push

# Or deploy specific version
cf push -f manifest-blue.yml   # Version 1.0.0 (blue)
cf push -f manifest-green.yml  # Version 2.0.0 (green)
```

### VCAP_SERVICES Integration

The application automatically parses Cloud Foundry service bindings:

```javascript
function getDatabaseConfig() {
    if (process.env.VCAP_SERVICES) {
        const vcapServices = JSON.parse(process.env.VCAP_SERVICES);

        if (vcapServices.postgres && vcapServices.postgres.length > 0) {
            const postgresService = vcapServices.postgres[0];
            const credentials = postgresService.credentials;

            return {
                host: credentials.host || credentials.hostname,
                port: credentials.port,
                database: credentials.name || credentials.database,
                user: credentials.username || credentials.user,
                password: credentials.password,
                ssl: credentials.ssl ? { rejectUnauthorized: false } : false
            };
        }
    }
    // Fall back to other configuration sources
}
```

## Blue/Green Deployment

### Version Toggle

```bash
# Make script executable
chmod +x toggle.sh

# Toggle between versions 1.0.0 (blue) and 2.0.0 (green)
./toggle.sh
```

This updates `.env`:
- Version: 1.0.0 ↔ 2.0.0
- DeploymentColor: blue ↔ green

### Deploy Blue Version

```bash
chmod +x deploy-blue.sh
./deploy-blue.sh
```

Steps:
1. Auto-toggles to version 1.0.0 if needed
2. Installs dependencies
3. Pushes to Cloud Foundry as `nodejs-db-demo-blue`
4. Maps to temporary route

### Deploy Green Version

```bash
chmod +x deploy-green.sh
./deploy-green.sh
```

Steps:
1. Auto-toggles to version 2.0.0 if needed
2. Installs dependencies
3. Pushes to Cloud Foundry as `nodejs-db-demo-green`
4. Maps to temporary route

### Blue/Green Cutover Process

**Step 1: Deploy new version (green) alongside existing (blue)**
```bash
# Current production: blue on nodejs-db-demo.apps.example.com
cf apps
# nodejs-db-demo-blue - nodejs-db-demo.apps.example.com (production)

# Deploy green version
./deploy-green.sh
# nodejs-db-demo-green - nodejs-db-demo-green-temp.apps.example.com (testing)
```

**Step 2: Test green version**
```bash
# Access green via temporary route
curl https://nodejs-db-demo-green-temp.apps.example.com/api/infos
# Verify database connectivity and functionality
```

**Step 3: Map production route to green**
```bash
cf map-route nodejs-db-demo-green apps.example.com --hostname nodejs-db-demo
```

**Step 4: Verify both versions receiving traffic**
```bash
cf apps
# Both blue and green now serve production traffic
```

**Step 5: Remove production route from blue**
```bash
cf unmap-route nodejs-db-demo-blue apps.example.com --hostname nodejs-db-demo
```

**Step 6: Cleanup**
```bash
# Optional: Delete old blue deployment
cf delete nodejs-db-demo-blue

# Or keep for quick rollback
cf stop nodejs-db-demo-blue
```

**Rollback:** Simply reverse the route mapping to switch back to blue instantly.

## Docker Compose Services

### PostgreSQL
- **Image**: postgres:17
- **Database**: demodb
- **User**: demouser
- **Password**: demopass
- **Port**: 5432 (internal only, no external mapping)
- **Volume**: postgres_data (persistent storage)

### pgAdmin
- **Image**: dpage/pgadmin4:latest
- **Port**: 5050
- **Login**: admin@demo.com / admin
- **Purpose**: Database administration UI

### Application
- **Build**: Dockerfile in current directory
- **Port**: 8082
- **Dependencies**: Waits for PostgreSQL health check
- **Network**: Shared network with PostgreSQL

## Database Initialization

The application performs idempotent database initialization on startup:

1. **On Startup**: Creates `pets` table if it doesn't exist
2. **Check Data**: Counts existing records
3. **If Empty**: Seeds 8 sample pet records
4. **If Exists**: Skips seeding (idempotent)

```javascript
async function initializeDatabase() {
    const client = await pool.connect();

    // Create table
    await client.query(`CREATE TABLE IF NOT EXISTS pets (...)`);

    // Check if data exists
    const result = await client.query('SELECT COUNT(*) FROM pets');
    const count = parseInt(result.rows[0].count);

    if (count === 0) {
        // Seed sample data
    }
}
```

## Project Structure

```
nodejs-demo/
├── server.js                    # Application entry point, VCAP_SERVICES parsing
├── package.json                 # Dependencies and scripts
├── .env                         # Local environment configuration
├── public/
│   └── index.html               # Frontend UI
├── docker-compose.yaml          # Multi-container setup
├── Dockerfile                   # Container build
├── manifest.yml                 # Default CF manifest
├── manifest-blue.yml            # Blue version manifest
├── manifest-green.yml           # Green version manifest
├── toggle.sh                    # Version toggle script
├── deploy-blue.sh               # Blue deployment script
├── deploy-green.sh              # Green deployment script
└── create-db-service.sh         # CF service creation script
```

## Cloud-Native Patterns Demonstrated

1. **Externalized Configuration** - Environment variables and VCAP_SERVICES
2. **Service Binding** - Automatic database credential injection
3. **Health Checks** - HTTP endpoint with database connectivity check
4. **Stateless Design** - All state in PostgreSQL
5. **Blue/Green Deployment** - Zero-downtime deployments
6. **Auto-scaling Ready** - Stateless design supports horizontal scaling
7. **Containerization** - Docker support with buildpacks
8. **Graceful Shutdown** - Proper connection pool cleanup
9. **Idempotent Initialization** - Safe to restart and redeploy

## Troubleshooting

### Port Already in Use

If port 8082 is occupied:
```bash
# Find process using port
lsof -ti:8082

# Kill process
kill -9 <PID>

# Or change port
export PORT=8083
npm start
```

### Database Connection Failed

```bash
# Check PostgreSQL is running
docker-compose ps

# View PostgreSQL logs
docker-compose logs postgres

# Restart PostgreSQL
docker-compose restart postgres

# Test connection manually
docker-compose exec postgres psql -U demouser -d demodb
```

### pgAdmin Cannot Connect

In pgAdmin, create server connection:
- **Host**: postgres (not localhost when using Docker Compose)
- **Port**: 5432
- **Database**: demodb
- **Username**: demouser
- **Password**: demopass

### Application Crashes on Startup

```bash
# View application logs
docker-compose logs app

# Check for missing dependencies
npm install

# Verify environment variables
cat .env
```

## Development

### Adding New Endpoints

```javascript
// In server.js
app.get('/api/your-endpoint', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM your_table');
        res.json(result.rows);
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: 'Error message' });
    }
});
```

### Database Migrations

For schema changes, add migration logic in `initializeDatabase()`:

```javascript
// Add new column (idempotent)
await client.query(`
    ALTER TABLE pets
    ADD COLUMN IF NOT EXISTS new_field VARCHAR(100)
`);
```

## License

MIT
