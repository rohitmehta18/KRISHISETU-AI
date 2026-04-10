const { getSensorData } = require('./esp.service');

class SensorService {
  /**
   * Get the latest sensor data from ESP32
   * @returns {Promise<Object>} Sensor data with temperature, humidity, soil info, etc.
   */
  static async getLatestData() {
    try {
      const data = await getSensorData();
      return data;
    } catch (error) {
      throw new Error(`Failed to fetch sensor data: ${error.message}`);
    }
  }
}

module.exports = { SensorService };
