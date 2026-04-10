const express = require('express');
const { getCropHealthReport } = require('../services/crop_health.service');
const router = express.Router();

/**
 * GET /api/health/crop
 * Get crop health analysis based on current sensor data
 */
router.get('/crop', async (req, res) => {
  try {
    // Fetch latest sensor data
    let sensorData;
    try {
      const sensorRes = await fetch('http://10.60.16.166:3000/api/data');
      sensorData = await sensorRes.json();
    } catch (error) {
      // If no real sensor data, use mock data for testing
      sensorData = {
        temperature: 26,
        humidity: 70,
        soilPercent: 65,
        ph: 6.8,
        waterLevel: true,
        ldrRaw: 900,
      };
    }

    const healthReport = await getCropHealthReport(sensorData);
    res.json(healthReport);
  } catch (error) {
    res.status(500).json({
      error: error.message || 'Failed to get crop health report',
    });
  }
});

module.exports = router;
