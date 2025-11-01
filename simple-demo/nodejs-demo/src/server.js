const express = require('express');
const cors = require('cors');
const path = require('path');
const { v4: uuidv4 } = require('./uuid');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8082;

// Generate UUID once at startup
const INSTANCE_UUID = uuidv4();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../public')));

// Configuration
const appConfig = {
  version: process.env.APP_VERSION || '1.0.0',
  deploymentColor: process.env.APP_DEPLOYMENT_COLOR || 'blue'
};

// API Routes
app.get('/api/infos', (req, res) => {
  const nodeVersion = process.version;
  const techStackInfo = {
    uuid: INSTANCE_UUID,
    version: appConfig.version,
    deploymentColor: appConfig.deploymentColor,
    techStack: {
      framework: 'Express.js',
      version: require('express/package.json').version,
      language: 'JavaScript',
      languageVersion: nodeVersion,
      runtime: 'Node.js'
    }
  };

  res.json(techStackInfo);
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP' });
});

// Serve index.html for root route
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Node.js Demo App running on port ${PORT}`);
  console.log(`Instance UUID: ${INSTANCE_UUID}`);
  console.log(`Version: ${appConfig.version}`);
  console.log(`Deployment Color: ${appConfig.deploymentColor}`);
});
