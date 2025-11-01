const express = require('express');
const { Pool } = require('pg');
const path = require('path');
const { v4: uuidv4 } = require('crypto').randomUUID ? {} : require('uuid');

const app = express();

// Configuration
const PORT = process.env.PORT || 8082;
const APP_VERSION = process.env.APP_VERSION || '1.0.0';
const APP_COLOR = process.env.APP_COLOR || 'blue';

// Generate or retrieve instance UUID
const INSTANCE_UUID = process.env.INSTANCE_UUID || (crypto.randomUUID ? crypto.randomUUID() : uuidv4());

// Database configuration from VCAP_SERVICES or environment
function getDatabaseConfig() {
    // Check for Cloud Foundry VCAP_SERVICES
    if (process.env.VCAP_SERVICES) {
        try {
            const vcapServices = JSON.parse(process.env.VCAP_SERVICES);

            // Look for postgres service
            if (vcapServices.postgres && vcapServices.postgres.length > 0) {
                const postgresService = vcapServices.postgres[0];
                const credentials = postgresService.credentials;

                console.log('✓ Using database credentials from VCAP_SERVICES');
                return {
                    host: credentials.host || credentials.hostname,
                    port: credentials.port,
                    database: credentials.name || credentials.database,
                    user: credentials.username || credentials.user,
                    password: credentials.password,
                    ssl: credentials.ssl ? { rejectUnauthorized: false } : false
                };
            }
        } catch (error) {
            console.error('Error parsing VCAP_SERVICES:', error);
        }
    }

    // Check for DATABASE_URL (Heroku-style)
    if (process.env.DATABASE_URL) {
        console.log('✓ Using DATABASE_URL');
        return {
            connectionString: process.env.DATABASE_URL,
            ssl: process.env.DATABASE_SSL === 'true' ? { rejectUnauthorized: false } : false
        };
    }

    // Fall back to individual environment variables or defaults
    console.log('✓ Using default database configuration');
    return {
        host: process.env.DB_HOST || 'localhost',
        port: process.env.DB_PORT || 5432,
        database: process.env.DB_NAME || 'demodb',
        user: process.env.DB_USER || 'demouser',
        password: process.env.DB_PASSWORD || 'demopass'
    };
}

// Create PostgreSQL connection pool
const pool = new Pool(getDatabaseConfig());

// Test database connection
pool.on('connect', () => {
    console.log('✓ Connected to PostgreSQL database');
});

pool.on('error', (err) => {
    console.error('✗ Unexpected error on idle client', err);
    process.exit(-1);
});

// Initialize database schema and sample data
async function initializeDatabase() {
    const client = await pool.connect();
    try {
        console.log('Initializing database...');

        // Create pets table if it doesn't exist
        await client.query(`
            CREATE TABLE IF NOT EXISTS pets (
                id SERIAL PRIMARY KEY,
                race VARCHAR(50) NOT NULL,
                gender VARCHAR(10) NOT NULL,
                name VARCHAR(50) NOT NULL,
                age INTEGER NOT NULL,
                description TEXT
            )
        `);
        console.log('✓ Pets table ready');

        // Check if data already exists
        const result = await client.query('SELECT COUNT(*) FROM pets');
        const count = parseInt(result.rows[0].count);

        if (count === 0) {
            console.log('Seeding sample pet data...');

            const samplePets = [
                { race: 'Golden Retriever', gender: 'Male', name: 'Max', age: 5, description: 'Friendly and energetic dog' },
                { race: 'Persian Cat', gender: 'Female', name: 'Luna', age: 3, description: 'Calm and fluffy cat' },
                { race: 'Labrador', gender: 'Male', name: 'Charlie', age: 7, description: 'Loyal companion' },
                { race: 'Siamese Cat', gender: 'Female', name: 'Bella', age: 2, description: 'Playful and vocal' },
                { race: 'German Shepherd', gender: 'Male', name: 'Rex', age: 4, description: 'Smart and protective' },
                { race: 'Maine Coon', gender: 'Male', name: 'Oliver', age: 6, description: 'Large and gentle cat' },
                { race: 'Parakeet', gender: 'Female', name: 'Kiwi', age: 1, description: 'Colorful and chirpy bird' },
                { race: 'Cockatiel', gender: 'Male', name: 'Sunny', age: 2, description: 'Friendly whistling bird' }
            ];

            for (const pet of samplePets) {
                await client.query(
                    'INSERT INTO pets (race, gender, name, age, description) VALUES ($1, $2, $3, $4, $5)',
                    [pet.race, pet.gender, pet.name, pet.age, pet.description]
                );
            }

            console.log(`✓ Inserted ${samplePets.length} sample pets`);
        } else {
            console.log(`✓ Database already contains ${count} pets`);
        }

        console.log('✓ Database initialization complete');
    } catch (error) {
        console.error('✗ Database initialization failed:', error);
        throw error;
    } finally {
        client.release();
    }
}

// Middleware
app.use(express.json());
app.use(express.static('public'));

// REST API: Get technology stack info
app.get('/api/infos', (req, res) => {
    const nodeVersion = process.version;
    const npmVersion = process.env.npm_package_version || 'N/A';

    res.json({
        uuid: INSTANCE_UUID,
        version: APP_VERSION,
        deploymentColor: APP_COLOR,
        techStack: {
            framework: 'Node.js + Express',
            version: nodeVersion,
            language: 'JavaScript',
            languageVersion: 'ES2024',
            runtime: `Node.js ${nodeVersion}`,
            database: 'PostgreSQL 17'
        }
    });
});

// REST API: Get all pets
app.get('/api/pets', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM pets ORDER BY id');
        res.json(result.rows);
    } catch (error) {
        console.error('Error fetching pets:', error);
        res.status(500).json({ error: 'Failed to fetch pets' });
    }
});

// Health check endpoint
app.get('/health', async (req, res) => {
    try {
        // Check database connection
        await pool.query('SELECT 1');
        res.status(200).send('Healthy');
    } catch (error) {
        console.error('Health check failed:', error);
        res.status(503).send('Unhealthy');
    }
});

// Serve index.html for root path
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Start server after database initialization
async function startServer() {
    try {
        // Initialize database
        await initializeDatabase();

        // Start HTTP server
        app.listen(PORT, () => {
            console.log('======================================');
            console.log(`Server running on port ${PORT}`);
            console.log(`Version: ${APP_VERSION} (${APP_COLOR})`);
            console.log(`Instance UUID: ${INSTANCE_UUID}`);
            console.log('======================================');
            console.log(`Access the app at: http://localhost:${PORT}`);
        });
    } catch (error) {
        console.error('Failed to start server:', error);
        process.exit(1);
    }
}

// Handle shutdown gracefully
process.on('SIGTERM', async () => {
    console.log('SIGTERM received, closing HTTP server and database pool...');
    await pool.end();
    process.exit(0);
});

process.on('SIGINT', async () => {
    console.log('SIGINT received, closing HTTP server and database pool...');
    await pool.end();
    process.exit(0);
});

// Start the application
startServer();
