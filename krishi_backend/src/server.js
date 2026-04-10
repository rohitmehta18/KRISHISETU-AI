require('dotenv').config();

const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');
const sensorRoutes = require('./routes/sensor.routes');
const controlRoutes = require('./routes/control.routes');
const authRoutes   = require('./routes/auth.routes');
const userRoutes   = require('./routes/user.routes');
const weatherRoutes = require('./routes/weather.routes');
const cropsRoutes = require('./routes/crops.routes');
const healthRoutes = require('./routes/health.routes');
const pesticidesRoutes = require('./routes/pesticides.routes');
const insuranceRoutes = require('./routes/insurance.routes');

const app = express();
const PORT = process.env.PORT || 3000;

// ── Connect MongoDB ───────────────────────────────────────────────────────────
connectDB();

// ── Middleware ────────────────────────────────────────────────────────────────
// Simple CORS that works
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ── Routes ────────────────────────────────────────────────────────────────────
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api', sensorRoutes);
app.use('/api', controlRoutes);
app.use('/api', weatherRoutes);
app.use('/api/crops', cropsRoutes);
app.use('/api/health', healthRoutes);
app.use('/api/insurance', insuranceRoutes);
app.use('/api/pesticides', pesticidesRoutes);

// ── Health check ──────────────────────────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({ status: 'Krishi backend running', version: '1.0.0' });
});

// ── 404 handler ───────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// ── Global error handler ──────────────────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('[Error]', err.message);
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Server running on port ${PORT}`);
  console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🌐 Base URL: https://setu-backend-jixd.onrender.com`);
});

// Handle shutdown gracefully
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...');
  server.close(() => console.log('Server closed'));
  process.exit(0);
});
