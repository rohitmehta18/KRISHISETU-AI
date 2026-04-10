const express = require('express');
const { getPesticideRecommendations } = require('../services/pesticide.service');
const { getCropHealthReport } = require('../services/crop_health.service');
const { SensorService } = require('../services/sensor.service');
const router = express.Router();

/**
 * GET /api/pesticides/recommend
 * Get pesticide recommendations based on crop and health analysis
 * Query params: crop (required), region (optional)
 */
router.get('/recommend', async (req, res) => {
  try {
    const { crop, region = 'Default Region' } = req.query;

    if (!crop) {
      return res.status(400).json({
        error: 'Crop parameter is required',
        example: '/api/pesticides/recommend?crop=rice&region=Punjab',
      });
    }

    // Fetch latest sensor data
    let sensorData;
    try {
      sensorData = await SensorService.getLatestData();
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

    // Get crop health analysis
    const healthReport = await getCropHealthReport(sensorData);

    // Get pesticide recommendations
    const pesticideRecommendations = await getPesticideRecommendations(
      crop,
      healthReport,
      region
    );

    res.json({
      ...pesticideRecommendations,
      sensorData: {
        temperature: `${sensorData.temperature}°C`,
        humidity: `${sensorData.humidity}%`,
        soilMoisture: `${sensorData.soilPercent}%`,
        soilPH: sensorData.ph,
        lightLevel: sensorData.ldrRaw,
      },
    });
  } catch (error) {
    res.status(500).json({
      error: error.message || 'Failed to get pesticide recommendations',
    });
  }
});

module.exports = router;
