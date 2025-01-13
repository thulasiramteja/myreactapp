const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { Sequelize } = require('sequelize');
const promClient = require('prom-client');
const userRoutes = require('./routes/userRoutes');
require('dotenv').config(); // Load environment variables from .env

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use('/users', userRoutes);

// Setup Prometheus metrics
const register = promClient.register;
const collectDefaultMetrics = promClient.collectDefaultMetrics;
collectDefaultMetrics(); // Collect default metrics like CPU usage, memory, etc.

const httpRequestsTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
});

// Middleware to track HTTP requests
app.use((req, res, next) => {
  res.on('finish', () => {
    httpRequestsTotal.inc({ method: req.method, route: req.originalUrl, status_code: res.statusCode });
  });
  next();
});

// Expose metrics at /metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Set up Sequelize connection using environment variables from .env
const sequelize = new Sequelize({
  host: process.env.DB_HOST,
  dialect: 'postgres',
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT || 5432,
  logging: false,
});

sequelize.authenticate()
  .then(() => console.log('Database connected successfully'))
  .catch((err) => console.error('Failed to connect to the database:', err));

sequelize.sync()
  .then(() => console.log('Database synced'))
  .catch((err) => console.error('Failed to sync DB:', err));

// Get port and deployment URL
const PORT = process.env.PORT || 3000;
const PUBLIC_URL = process.env.PUBLIC_URL || 'http://localhost';

// Start the server
app.listen(PORT, () => {
  const url =
    process.env.RAILWAY_ENVIRONMENT === 'production'
      ? `https://${process.env.PUBLIC_URL}`
      : `${PUBLIC_URL}:${PORT}`;
  console.log(`Server running at ${url}`);
});
