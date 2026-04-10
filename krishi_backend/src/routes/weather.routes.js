const express = require('express');
const { getWeatherByRegion } = require('../services/weather.service');
const router = express.Router();

/**
 * GET /api/weather
 * Fetch weather forecast by region
 * Query params: region (required)
 * Example: /api/weather?region=Punjab
 */
router.get('/weather', async (req, res) => {
  try {
    const { region } = req.query;

    if (!region) {
      return res.status(400).json({
        error: 'Region parameter is required',
        example: '/api/weather?region=Punjab',
      });
    }

    const weatherData = await getWeatherByRegion(region);
    res.json(weatherData);
  } catch (error) {
    res.status(500).json({
      error: error.message || 'Failed to fetch weather data',
    });
  }
});

module.exports = router;
