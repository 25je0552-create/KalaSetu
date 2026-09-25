const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Request logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} ${res.statusCode} - ${duration}ms`);
  });
  next();
});

// Root & Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    service: 'KalaSetu Backend API',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: '1.0.0'
  });
});

app.get('/', (req, res) => {
  res.json({
    name: 'KalaSetu API',
    description: 'Empowering rural artisans through handcraft marketplace technology',
    health: '/health'
  });
});

// Route skeletons
const productsRoutes = require('./routes/products.routes');
const ordersRoutes = require('./routes/orders.routes');
const fairsRoutes = require('./routes/fairs.routes');
const artisansRoutes = require('./routes/artisans.routes');
const usersRoutes = require('./routes/users.routes');

app.use('/api/products', productsRoutes);
app.use('/api/orders', ordersRoutes);
app.use('/api/fairs', fairsRoutes);
app.use('/api/artisans', artisansRoutes);
app.use('/api/users', usersRoutes);

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('API Error:', err);
  res.status(err.status || 500).json({
    error: {
      message: err.message || 'Internal Server Error',
      status: err.status || 500
    }
  });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`KalaSetu Backend server running on http://localhost:${PORT}`);
    console.log(`Health endpoint available at http://localhost:${PORT}/health`);
  });
}

module.exports = app;
