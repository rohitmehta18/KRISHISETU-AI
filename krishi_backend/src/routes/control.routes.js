const express = require('express');
const { setRelay } = require('../services/esp.service');

const router = express.Router();

/**
 * GET /api/on
 * Turns the relay (pump) ON via ESP32.
 * Calls: http://192.168.4.1/relay?state=on
 */
router.get('/on', async (req, res) => {
  try {
    await setRelay('on');
    res.json({ status: 'ON' });
  } catch (err) {
    if (err.message === 'Device not connected') {
      return res.status(503).json({ error: 'Device not connected' });
    }
    console.error('[/api/on]', err.message);
    res.status(500).json({ error: 'Failed to send ON command' });
  }
});

/**
 * GET /api/off
 * Turns the relay (pump) OFF via ESP32.
 * Calls: http://192.168.4.1/relay?state=off
 */
router.get('/off', async (req, res) => {
  try {
    await setRelay('off');
    res.json({ status: 'OFF' });
  } catch (err) {
    if (err.message === 'Device not connected') {
      return res.status(503).json({ error: 'Device not connected' });
    }
    console.error('[/api/off]', err.message);
    res.status(500).json({ error: 'Failed to send OFF command' });
  }
});

module.exports = router;
