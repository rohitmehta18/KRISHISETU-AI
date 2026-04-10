require('dotenv').config();

module.exports = {
  ESP_BASE_URL: process.env.ESP_BASE_URL || 'http://192.168.4.1',
  TIMEOUT_MS: parseInt(process.env.TIMEOUT_MS) || 5000, // 5 seconds before giving up on ESP
};
