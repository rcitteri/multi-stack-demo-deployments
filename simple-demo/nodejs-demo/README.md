# Node.js + React Demo Application

A cloud-native demo application built with Node.js, Express.js, and React.

## Features
- Web interface built with React showing tech stack information
- Instance UUID for multi-instance identification
- Configurable version and deployment color for blue/green deployments
- REST API endpoint for programmatic access
- Health check endpoints

## Prerequisites

### For Local Development
- Node.js 18.0 or later
- npm

### For Docker Build
- Docker
- Pack CLI (Buildpacks): `brew install buildpacks/tap/pack`

### For Cloud Foundry
- CF CLI
- Access to a Cloud Foundry environment

## Running Locally

### Install Dependencies
```bash
npm install
```

### Start the Application
```bash
npm start
```

The application will start on `http://localhost:8082`

### Development Mode (with auto-restart)
```bash
npm run dev
```

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
docker run -p 8082:8082 nodejs-demo:latest
```

## Deploying to Cloud Foundry

Cloud Foundry will automatically detect the Node.js application and use the appropriate buildpack.

### Quick Deploy (Default)

Deploy the default blue version:
```bash
./deploy-default.sh
```

This deploys a single app instance named `nodejs-demo` with version 1.0.0 (blue).

### Blue/Green Deployment Strategy

This application includes scripts for zero-downtime blue/green deployments on Cloud Foundry.

#### Deploy Blue Version
```bash
./deploy-blue.sh
```
- App name: `nodejs-demo-blue`
- Version: 1.0.0
- Color: Blue
- Instances: 2

#### Deploy Green Version
```bash
./deploy-green.sh
```
- App name: `nodejs-demo-green`
- Version: 2.0.0
- Color: Green
- Instances: 2

### Step-by-Step Blue/Green Cutover

This demonstrates a zero-downtime deployment with gradual traffic shifting:

**Step 1: Initial State - Blue is live (100% traffic)**
```bash
./deploy-blue.sh
cf map-route nodejs-demo-blue apps.example.com --hostname nodejs-demo
```
State: Blue (2 instances) → 100% traffic

**Step 2: Deploy Green (0% traffic)**
```bash
./deploy-green.sh
cf scale nodejs-demo-green -i 0
```
State: Blue (2 instances) → 100% traffic, Green (0 instances) → 0% traffic

**Step 3: Start Green instances and add to routing (50/50 split)**
```bash
cf scale nodejs-demo-green -i 2
cf map-route nodejs-demo-green apps.example.com --hostname nodejs-demo
```
State: Blue (2 instances) → 50% traffic, Green (2 instances) → 50% traffic

**Step 4: Monitor and verify Green is healthy**
```bash
cf app nodejs-demo-green
cf logs nodejs-demo-green --recent
# Test the endpoint and check UUIDs to verify both versions
curl https://nodejs-demo.apps.example.com/api/infos
```

**Step 5: Gradual cutover - Scale down Blue, keep Green (25/75 split)**
```bash
cf scale nodejs-demo-blue -i 1
```
State: Blue (1 instance) → 25% traffic, Green (2 instances) → 75% traffic

**Step 6: Complete cutover - Remove Blue (0/100 split)**
```bash
cf unmap-route nodejs-demo-blue apps.example.com --hostname nodejs-demo
cf scale nodejs-demo-blue -i 0
# Or delete the blue app entirely
cf delete nodejs-demo-blue
```
State: Blue (0 instances) → 0% traffic, Green (2 instances) → 100% traffic

**Step 7: Rollback (if needed)**

If issues are detected, instantly rollback:
```bash
cf scale nodejs-demo-blue -i 2
cf map-route nodejs-demo-blue apps.example.com --hostname nodejs-demo
cf unmap-route nodejs-demo-green apps.example.com --hostname nodejs-demo
```

### Manual Deployment

If you prefer manual deployment:
```bash
# Install dependencies
npm install --production

# Deploy using specific manifest
cf push -f manifest-blue.yml
# or
cf push -f manifest-green.yml
# or default
cf push -f manifest.yml
```

## Configuration

### Port Configuration

The application uses port 8082 by default, but can be customized via the `PORT` environment variable:

```bash
# Run on default port 8082
npm start

# Run on custom port
PORT=9000 npm start
```

The port is configured in `src/server.js` as:
```javascript
const PORT = process.env.PORT || 8082;
```

### Version and Color Configuration

Edit `.env` file to change:

```env
# Version and color for blue/green deployments
APP_VERSION=1.0.0
APP_DEPLOYMENT_COLOR=blue

# Server port
PORT=8082
```

Available colors: `blue`, `green`, `red`, `yellow`

### Environment Variables
You can also configure via environment variables:
```bash
export APP_VERSION=2.0.0
export APP_DEPLOYMENT_COLOR=green
npm start
```

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
- `GET /` - HTML page with tech stack information (React-based)

### REST API
- `GET /api/infos` - JSON response with tech stack details

### Health Checks
- `GET /health` - Application health status

## Example API Response

```json
{
  "uuid": "550e8400-e29b-41d4-a716-446655440000",
  "version": "1.0.0",
  "deploymentColor": "blue",
  "techStack": {
    "framework": "Express.js",
    "version": "4.18.2",
    "language": "JavaScript",
    "languageVersion": "v18.17.0",
    "runtime": "Node.js"
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
nodejs-demo/
├── src/
│   ├── server.js
│   └── uuid.js
├── public/
│   └── index.html
├── package.json
├── .env
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
- **Framework**: Express.js
- **Language**: JavaScript
- **Runtime**: Node.js 18+
- **Frontend**: React (via CDN)
- **Build Tool**: npm
- **Containerization**: Paketo Buildpacks
