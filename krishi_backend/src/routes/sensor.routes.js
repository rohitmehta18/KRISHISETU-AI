const express = require('express');
const { getSensorData } = require('../services/esp.service');

const router = express.Router();

/**
 * GET /api/data
 * Forwards the ESP32 JSON sensor payload directly to the client.
 *
 * ESP32 response shape:
 * {
 *   temperature : number,
 *   humidity    : number,
 *   soilPercent : number,
 *   ldrRaw      : number,
 *   ph          : number,
 *   waterLevel  : boolean,
 *   relay       : boolean,
 *   autoMode    : boolean
 * }
 */
router.get('/data', async (req, res) => {
  try {
    const data = await getSensorData();
    res.json(data);
  } catch (err) {
    if (err.message === 'Device not connected') {
      return res.status(503).json({ error: 'Device not connected' });
    }
    console.error('[/api/data]', err.message);
    res.status(500).json({ error: 'Failed to fetch sensor data' });
  }
});

module.exports = router;
