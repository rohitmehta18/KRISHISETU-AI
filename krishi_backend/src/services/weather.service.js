const axios = require('axios');

// Using Open-Meteo API (free, no API key required)
// Alternative: OpenWeatherMap, WeatherAPI, etc.
const WEATHER_API_URL = 'https://api.open-meteo.com/v1/forecast';

/**
 * Geocode a region name to latitude and longitude
 * Using Open-Meteo Geocoding API
 */
async function geocodeRegion(region) {
  try {
    const response = await axios.get('https://geocoding-api.open-meteo.com/v1/search', {
      params: {
        name: region,
        count: 1,
        language: 'en',
        format: 'json',
      },
      timeout: 5000,
    });

    if (response.data.results && response.data.results.length > 0) {
      const result = response.data.results[0];
      return {
        latitude: result.latitude,
        longitude: result.longitude,
        name: result.name,
        country: result.country,
      };
    }
    throw new Error(`Region "${region}" not found`);
  } catch (error) {
    console.error('[Weather Geocode Error]', error.message);
    throw new Error('Unable to geocode region');
  }
}

/**
 * Fetch weather forecast for a given region
 */
async function getWeatherByRegion(region) {
  try {
    // Step 1: Geocode the region
    const coordinates = await geocodeRegion(region);

    // Step 2: Fetch weather data
    const response = await axios.get(WEATHER_API_URL, {
      params: {
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        current: 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
        hourly: 'temperature_2m,precipitation_probability,weather_code',
        daily: 'weather_code,temperature_2m_max,temperature_2m_min,rain_sum,precipitation_probability_max',
        temperature_unit: 'celsius',
        wind_speed_unit: 'kmh',
        precipitation_unit: 'mm',
        timezone: 'auto',
        forecast_days: 7,
      },
      timeout: 5000,
    });

    // Parse weather data
    const current = response.data.current;
    const daily = response.data.daily;

    return {
      region: coordinates.name,
      country: coordinates.country,
      current: {
        temperature: current.temperature_2m,
        humidity: current.relative_humidity_2m,
        windSpeed: current.wind_speed_10m,
        weatherCode: current.weather_code,
        description: getWeatherDescription(current.weather_code),
      },
      forecast: daily.time.map((time, index) => ({
        date: time,
        maxTemp: daily.temperature_2m_max[index],
        minTemp: daily.temperature_2m_min[index],
        rainSum: daily.rain_sum[index],
        precipitationProbability: daily.precipitation_probability_max[index],
        weatherCode: daily.weather_code[index],
        description: getWeatherDescription(daily.weather_code[index]),
      })),
    };
  } catch (error) {
    console.error('[Weather Service Error]', error.message);
    throw error;
  }
}

/**
 * Convert WMO weather code to description
 * Reference: https://www.open-meteo.com/en/docs
 */
function getWeatherDescription(code) {
  const weatherCodes = {
    0: 'Clear sky',
    1: 'Mainly clear',
    2: 'Partly cloudy',
    3: 'Overcast',
    45: 'Foggy',
    48: 'Depositing rime fog',
    51: 'Light drizzle',
    53: 'Moderate drizzle',
    55: 'Dense drizzle',
    61: 'Slight rain',
    63: 'Moderate rain',
    65: 'Heavy rain',
    71: 'Slight snow',
    73: 'Moderate snow',
    75: 'Heavy snow',
    77: 'Snow grains',
    80: 'Slight rain showers',
    81: 'Moderate rain showers',
    82: 'Violent rain showers',
    85: 'Slight snow showers',
    86: 'Heavy snow showers',
    95: 'Thunderstorm',
    96: 'Thunderstorm with slight hail',
    99: 'Thunderstorm with heavy hail',
  };
  return weatherCodes[code] || 'Unknown';
}

module.exports = {
  getWeatherByRegion,
  geocodeRegion,
  getWeatherDescription,
};
