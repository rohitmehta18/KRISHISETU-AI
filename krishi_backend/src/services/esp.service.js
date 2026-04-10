const axios = require('axios');
const { ESP_BASE_URL, TIMEOUT_MS } = require('../config/esp.config');

/**
 * Fetch live sensor data from the ESP32 JSON API.
 * @returns {Promise<Object>} Raw JSON from ESP32
 */
async function getSensorData() {
  return espGet('/data');
}

/**
 * Send a relay command to the ESP32.
 * @param {'on'|'off'} state
 * @returns {Promise<Object>}
 */
async function setRelay(state) {
  return espGet(`/relay?state=${state}`);
}

/**
 * Internal GET helper — all ESP calls go through here.
 * Throws a clean 'Device not connected' error on network failure.
 */
async function espGet(path) {
  try {
    const { data } = await axios.get(`${ESP_BASE_URL}${path}`, {
      timeout: TIMEOUT_MS,
    });
    return data;
  } catch (err) {
    const networkFailure =
      err.code === 'ECONNREFUSED' ||
      err.code === 'ECONNABORTED' ||
      err.code === 'ETIMEDOUT'    ||
      err.code === 'ENOTFOUND'    ||
      err.message.toLowerCase().includes('timeout');

    if (networkFailure) throw new Error('Device not connected');
    throw err;
  }
}

module.exports = { getSensorData, setRelay };
