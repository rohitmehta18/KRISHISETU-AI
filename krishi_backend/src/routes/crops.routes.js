const express = require('express');
const { getCropRecommendations } = require('../services/crop.service');
const { SensorService } = require('../services/sensor.service');
const router = express.Router();

/**
 * GET /api/crops/recommend
 * Get crop recommendations based on current sensor data
 * Query params: region (required)
 */
router.get('/recommend', async (req, res) => {
  try {
    const { region } = req.query;

    if (!region) {
      return res.status(400).json({
        error: 'Region parameter is required',
        example: '/api/crops/recommend?region=Punjab',
      });
    }

    // Fetch latest sensor data
    let sensorData;
    try {
      sensorData = await SensorService.getLatestData();
    } catch (error) {
      // If no real sensor data, use mock data for testing
      sensorData = {
        temperature: 28,
        humidity: 65,
        soilPercent: 55,
        ph: 6.8,
        waterLevel: true,
        ldrRaw: 800,
      };
    }

    const recommendations = await getCropRecommendations(sensorData, region);
    res.json(recommendations);
  } catch (error) {
    res.status(500).json({
      error: error.message || 'Failed to get crop recommendations',
    });
  }
});

module.exports = router;
