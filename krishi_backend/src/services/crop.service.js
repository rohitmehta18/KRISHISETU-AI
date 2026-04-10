/**
 * Crop Recommendation Service
 * Analyzes environmental data and recommends suitable crops
 */

// Comprehensive crop database with environmental requirements
const CROP_DATABASE = {
  rice: {
    name: 'Rice',
    tempMin: 15,
    tempMax: 35,
    humidityMin: 60,
    humidityMax: 100,
    moistureMin: 60,
    moistureMax: 100,
    phMin: 5.5,
    phMax: 7.5,
    waterNeed: 'high',
    lightNeed: 'moderate',
    regions: ['Punjab', 'Bihar', 'Odisha', 'Tamil Nadu', 'Jharkhand', 'West Bengal'],
    season: ['monsoon', 'kharif'],
  },
  wheat: {
    name: 'Wheat',
    tempMin: 15,
    tempMax: 25,
    humidityMin: 40,
    humidityMax: 70,
    moistureMin: 40,
    moistureMax: 70,
    phMin: 6.0,
    phMax: 7.5,
    waterNeed: 'medium',
    lightNeed: 'high',
    regions: ['Punjab', 'Haryana', 'Uttar Pradesh', 'Madhya Pradesh'],
    season: ['rabi', 'winter'],
  },
  cotton: {
    name: 'Cotton',
    tempMin: 20,
    tempMax: 35,
    humidityMin: 30,
    humidityMax: 70,
    moistureMin: 35,
    moistureMax: 65,
    phMin: 6.0,
    phMax: 7.5,
    waterNeed: 'medium',
    lightNeed: 'high',
    regions: ['Maharashtra', 'Gujarat', 'Telangana', 'Andhra Pradesh'],
    season: ['kharif'],
  },
  sugarcane: {
    name: 'Sugarcane',
    tempMin: 15,
    tempMax: 30,
    humidityMin: 50,
    humidityMax: 100,
    moistureMin: 60,
    moistureMax: 90,
    phMin: 6.0,
    phMax: 8.0,
    waterNeed: 'high',
    lightNeed: 'high',
    regions: ['Maharashtra', 'Karnataka', 'Uttar Pradesh'],
    season: ['kharif', 'rabi'],
  },
  maize: {
    name: 'Maize (Corn)',
    tempMin: 18,
    tempMax: 27,
    humidityMin: 40,
    humidityMax: 80,
    moistureMin: 45,
    moistureMax: 75,
    phMin: 5.5,
    phMax: 7.5,
    waterNeed: 'medium',
    lightNeed: 'high',
    regions: ['Rajasthan', 'Madhya Pradesh', 'Karnataka'],
    season: ['kharif', 'rabi'],
  },
  soybean: {
    name: 'Soybean',
    tempMin: 18,
    tempMax: 30,
    humidityMin: 50,
    humidityMax: 80,
    moistureMin: 50,
    moistureMax: 70,
    phMin: 6.0,
    phMax: 7.5,
    waterNeed: 'medium',
    lightNeed: 'high',
    regions: ['Madhya Pradesh', 'Maharashtra', 'Rajasthan'],
    season: ['kharif'],
  },
  tomato: {
    name: 'Tomato',
    tempMin: 15,
    tempMax: 28,
    humidityMin: 50,
    humidityMax: 80,
    moistureMin: 50,
    moistureMax: 70,
    phMin: 6.0,
    phMax: 7.0,
    waterNeed: 'medium',
    lightNeed: 'high',
    regions: ['Karnataka', 'Andhra Pradesh', 'Tamil Nadu'],
    season: ['kharif', 'rabi'],
  },
  onion: {
    name: 'Onion',
    tempMin: 10,
    tempMax: 25,
    humidityMin: 40,
    humidityMax: 70,
    moistureMin: 40,
    moistureMax: 60,
    phMin: 6.0,
    phMax: 7.5,
    waterNeed: 'low',
    lightNeed: 'high',
    regions: ['Maharashtra', 'Karnataka', 'Madhya Pradesh'],
    season: ['rabi'],
  },
  potato: {
    name: 'Potato',
    tempMin: 10,
    tempMax: 20,
    humidityMin: 50,
    humidityMax: 80,
    moistureMin: 60,
    moistureMax: 80,
    phMin: 5.5,
    phMax: 7.5,
    waterNeed: 'medium',
    lightNeed: 'high',
    regions: ['Uttar Pradesh', 'Bihar', 'Punjab'],
    season: ['rabi'],
  },
};

/**
 * Score a crop based on sensor data
 */
function scoreCrop(crop, sensorData, region) {
  let score = 100;
  let reasons = [];

  const { temperature, humidity, soilPercent, ph } = sensorData;

  // Temperature scoring
  if (temperature < crop.tempMin) {
    const diff = crop.tempMin - temperature;
    score -= diff * 2;
    reasons.push(`Temperature ${diff.toFixed(1)}°C below ideal`);
  } else if (temperature > crop.tempMax) {
    const diff = temperature - crop.tempMax;
    score -= diff * 2;
    reasons.push(`Temperature ${diff.toFixed(1)}°C above ideal`);
  } else {
    reasons.push(`Perfect temperature`);
  }

  // Humidity scoring
  if (humidity < crop.humidityMin) {
    const diff = crop.humidityMin - humidity;
    score -= diff * 0.5;
    reasons.push(`Humidity ${diff.toFixed(1)}% below ideal`);
  } else if (humidity > crop.humidityMax) {
    const diff = humidity - crop.humidityMax;
    score -= diff * 0.3;
    reasons.push(`Humidity slightly high`);
  } else {
    reasons.push(`Good humidity level`);
  }

  // Soil moisture scoring
  if (soilPercent < crop.moistureMin) {
    const diff = crop.moistureMin - soilPercent;
    score -= diff * 1.5;
    reasons.push(`Soil too dry (${diff.toFixed(0)}% below ideal)`);
  } else if (soilPercent > crop.moistureMax) {
    const diff = soilPercent - crop.moistureMax;
    score -= diff * 1;
    reasons.push(`Soil too wet`);
  } else {
    reasons.push(`Ideal soil moisture`);
  }

  // pH scoring
  if (ph < crop.phMin) {
    const diff = crop.phMin - ph;
    score -= diff * 5;
    reasons.push(`Soil too acidic (pH ${diff.toFixed(1)} below ideal)`);
  } else if (ph > crop.phMax) {
    const diff = ph - crop.phMax;
    score -= diff * 5;
    reasons.push(`Soil too alkaline (pH ${diff.toFixed(1)} above ideal)`);
  } else {
    reasons.push(`Ideal soil pH`);
  }

  // Region bonus
  if (crop.regions.includes(region)) {
    reasons.push(`Well-suited for ${region}`);
  }

  // Water availability bonus
  if (sensorData.waterLevel && crop.waterNeed === 'high') {
    reasons.push(`Adequate water supply`);
  }

  score = Math.max(0, Math.min(100, score));

  return {
    cropKey: crop,
    name: crop.name,
    score,
    reasons: reasons.slice(0, 3), // Top 3 reasons
    tempRange: `${crop.tempMin}°C - ${crop.tempMax}°C`,
    moistureRange: `${crop.moistureMin}% - ${crop.moistureMax}%`,
    phRange: `${crop.phMin} - ${crop.phMax}`,
  };
}

/**
 * Get crop recommendations based on sensor data and region
 */
async function getCropRecommendations(sensorData, region) {
  try {
    if (!sensorData || !region) {
      throw new Error('Sensor data and region are required');
    }

    // Score all crops
    const scores = Object.entries(CROP_DATABASE).map(([key, crop]) => {
      const scored = scoreCrop(crop, sensorData, region);
      return { key, ...scored };
    });

    // Sort by score and get top 3
    const topCrops = scores
      .sort((a, b) => b.score - a.score)
      .slice(0, 3);

    // Filter out crops with very low scores (< 40%)
    const recommendedCrops = topCrops.filter((c) => c.score > 40);

    if (recommendedCrops.length === 0) {
      return {
        region,
        recommendations: topCrops.slice(0, 2),
        message: 'Environmental conditions are challenging. Consider soil amendments or irrigation improvements.',
      };
    }

    return {
      region,
      recommendations: recommendedCrops,
      message: `Based on current conditions in ${region}, these crops are recommended.`,
    };
  } catch (error) {
    console.error('[Crop Recommendation Error]', error.message);
    throw error;
  }
}

module.exports = {
  getCropRecommendations,
  scoreCrop,
  CROP_DATABASE,
};
