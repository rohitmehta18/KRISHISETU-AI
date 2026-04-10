/**
 * Crop Health Analysis Service
 * Analyzes environmental data to determine crop health status
 */

/**
 * Score individual health parameters
 */
function analyzeHealthMetrics(sensorData) {
  const { temperature, humidity, soilPercent, ph, waterLevel } = sensorData;
  
  const metrics = {
    temperature: _analyzeTemperature(temperature),
    moisture: _analyzeMoisture(soilPercent),
    humidity: _analyzeHumidity(humidity),
    ph: _analyzePH(ph),
    water: _analyzeWater(waterLevel),
  };

  // Calculate overall health score
  const scores = Object.values(metrics).map(m => m.score);
  const overallScore = Math.round(scores.reduce((a, b) => a + b, 0) / scores.length);

  return {
    overall: overallScore,
    metrics,
  };
}

function _analyzeTemperature(temp) {
  let score = 100;
  let status = 'optimal';
  let recommendation = 'Temperature is in optimal range';

  // Ideal crop temp: 20-28°C
  if (temp < 10) {
    score = 20;
    status = 'critical';
    recommendation = `Critical cold: ${temp.toFixed(1)}°C - provide frost protection or use greenhouse`;
  } else if (temp < 15) {
    score = 45;
    status = 'poor';
    recommendation = `Too cold: ${temp.toFixed(1)}°C - consider heating or cover crops`;
  } else if (temp < 20) {
    score = 75;
    status = 'good';
    recommendation = `Slightly cool: ${temp.toFixed(1)}°C - acceptable but suboptimal`;
  } else if (temp <= 28) {
    score = 100;
    status = 'optimal';
    recommendation = `Perfect temperature: ${temp.toFixed(1)}°C`;
  } else if (temp <= 32) {
    score = 80;
    status = 'good';
    recommendation = `Slightly warm: ${temp.toFixed(1)}°C - ensure adequate irrigation`;
  } else if (temp <= 35) {
    score = 50;
    status = 'poor';
    recommendation = `High heat: ${temp.toFixed(1)}°C - increase watering frequency`;
  } else {
    score = 25;
    status = 'critical';
    recommendation = `Extreme heat: ${temp.toFixed(1)}°C - risk of crop damage, provide shade`;
  }

  return { score, status, recommendation };
}

function _analyzeMoisture(moisture) {
  let score = 100;
  let status = 'optimal';
  let recommendation = 'Soil moisture is well-balanced';

  if (moisture < 20) {
    score = 15;
    status = 'critical';
    recommendation = `${moisture.toFixed(0)}% - Severe drought stress! Irrigate immediately`;
  } else if (moisture < 35) {
    score = 40;
    status = 'poor';
    recommendation = `${moisture.toFixed(0)}% - Dry conditions, increase watering`;
  } else if (moisture < 50) {
    score = 75;
    status = 'good';
    recommendation = `${moisture.toFixed(0)}% - Acceptable, monitor closely`;
  } else if (moisture <= 75) {
    score = 100;
    status = 'optimal';
    recommendation = `${moisture.toFixed(0)}% - Perfect moisture level`;
  } else if (moisture <= 85) {
    score = 75;
    status = 'good';
    recommendation = `${moisture.toFixed(0)}% - Slightly wet, reduce irrigation`;
  } else {
    score = 30;
    status = 'critical';
    recommendation = `${moisture.toFixed(0)}% - Waterlogged! Risk of root rot, improve drainage`;
  }

  return { score, status, recommendation };
}

function _analyzeHumidity(humidity) {
  let score = 100;
  let status = 'optimal';
  let recommendation = 'Humidity levels are healthy';

  if (humidity < 30) {
    score = 50;
    status = 'poor';
    recommendation = `${humidity.toFixed(0)}% - Very dry air, increase misting/irrigation`;
  } else if (humidity < 45) {
    score = 75;
    status = 'good';
    recommendation = `${humidity.toFixed(0)}% - Low humidity, monitor for pests`;
  } else if (humidity <= 75) {
    score = 100;
    status = 'optimal';
    recommendation = `${humidity.toFixed(0)}% - Ideal humidity for crop growth`;
  } else if (humidity <= 90) {
    score = 75;
    status = 'good';
    recommendation = `${humidity.toFixed(0)}% - High humidity, watch for fungal diseases`;
  } else {
    score = 45;
    status = 'poor';
    recommendation = `${humidity.toFixed(0)}% - Excessive moisture, improve ventilation`;
  }

  return { score, status, recommendation };
}

function _analyzePH(ph) {
  let score = 100;
  let status = 'optimal';
  let recommendation = 'Soil pH is suitable';

  // Ideal: 6.0-7.5
  if (ph < 4.5) {
    score = 20;
    status = 'critical';
    recommendation = `pH ${ph.toFixed(2)} - Very acidic! Add lime immediately`;
  } else if (ph < 5.5) {
    score = 50;
    status = 'poor';
    recommendation = `pH ${ph.toFixed(2)} - Too acidic, apply lime fertilizer`;
  } else if (ph < 6.0) {
    score = 80;
    status = 'good';
    recommendation = `pH ${ph.toFixed(2)} - Slightly acidic but acceptable`;
  } else if (ph <= 7.5) {
    score = 100;
    status = 'optimal';
    recommendation = `pH ${ph.toFixed(2)} - Perfect soil pH for most crops`;
  } else if (ph <= 8.0) {
    score = 80;
    status = 'good';
    recommendation = `pH ${ph.toFixed(2)} - Slightly alkaline but acceptable`;
  } else if (ph < 8.5) {
    score = 50;
    status = 'poor';
    recommendation = `pH ${ph.toFixed(2)} - Too alkaline, add sulfur`;
  } else {
    score = 20;
    status = 'critical';
    recommendation = `pH ${ph.toFixed(2)} - Very alkaline! Add sulfur immediately`;
  }

  return { score, status, recommendation };
}

function _analyzeWater(waterLevel) {
  let score = 100;
  let status = 'optimal';
  let recommendation = 'Water supply is available';

  if (waterLevel) {
    score = 100;
    status = 'optimal';
    recommendation = 'Water tank has sufficient water';
  } else {
    score = 20;
    status = 'critical';
    recommendation = 'Water tank is empty! Refill immediately';
  }

  return { score, status, recommendation };
}

/**
 * Get comprehensive crop health report
 */
async function getCropHealthReport(sensorData) {
  try {
    if (!sensorData) {
      throw new Error('Sensor data is required');
    }

    const health = analyzeHealthMetrics(sensorData);
    const healthStatus = getHealthStatus(health.overall);

    // Generate critical alerts
    const criticalAlerts = Object.entries(health.metrics)
      .filter(([_, m]) => m.status === 'critical')
      .map(([key, m]) => ({
        parameter: key.charAt(0).toUpperCase() + key.slice(1),
        recommendation: m.recommendation,
      }));

    // Generate improvement recommendations
    const improvements = Object.entries(health.metrics)
      .filter(([_, m]) => m.score < 100)
      .sort((a, b) => a[1].score - b[1].score)
      .slice(0, 3)
      .map(([key, m]) => ({
        parameter: key.charAt(0).toUpperCase() + key.slice(1),
        score: m.score,
        recommendation: m.recommendation,
      }));

    return {
      overallScore: health.overall,
      healthStatus,
      metrics: health.metrics,
      criticalAlerts,
      improvements,
      lastUpdated: new Date().toISOString(),
    };
  } catch (error) {
    console.error('[Crop Health Error]', error.message);
    throw error;
  }
}

function getHealthStatus(score) {
  if (score >= 85) return 'Excellent';
  if (score >= 70) return 'Good';
  if (score >= 50) return 'Fair';
  if (score >= 30) return 'Poor';
  return 'Critical';
}

module.exports = {
  getCropHealthReport,
  analyzeHealthMetrics,
  getHealthStatus,
};
