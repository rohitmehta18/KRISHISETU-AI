import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

String get _baseUrl => 'https://setu-backend-jixd.onrender.com';

class WeatherData {
  final String region;
  final String country;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String description;
  final int weatherCode;

  const WeatherData({
    required this.region,
    required this.country,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.weatherCode,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? {};
    return WeatherData(
      region: json['region'] ?? 'Unknown',
      country: json['country'] ?? '',
      temperature: _toDouble(current['temperature']),
      humidity: _toInt(current['humidity']),
      windSpeed: _toDouble(current['windSpeed']),
      description: current['description'] ?? 'Unknown',
      weatherCode: _toInt(current['weatherCode']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    return (v as num).toDouble();
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    return (v as num).toInt();
  }
}

class WeatherForecastDay {
  final String date;
  final double maxTemp;
  final double minTemp;
  final double rainSum;
  final int precipitationProbability;
  final String description;
  final int weatherCode;

  const WeatherForecastDay({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.rainSum,
    required this.precipitationProbability,
    required this.description,
    required this.weatherCode,
  });

  factory WeatherForecastDay.fromJson(Map<String, dynamic> json) {
    return WeatherForecastDay(
      date: json['date'] ?? '',
      maxTemp: _toDouble(json['maxTemp']),
      minTemp: _toDouble(json['minTemp']),
      rainSum: _toDouble(json['rainSum']),
      precipitationProbability:
          _toInt(json['precipitationProbability']),
      description: json['description'] ?? 'Unknown',
      weatherCode: _toInt(json['weatherCode']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    return (v as num).toDouble();
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    return (v as num).toInt();
  }
}

class WeatherService {
  static const _timeout = Duration(seconds: 8);

  /// Fetch current weather data for a region
  static Future<WeatherData> fetchCurrentWeather(String region) async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/api/weather?region=$region'))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        return WeatherData.fromJson(jsonDecode(res.body));
      }

      // ignore: avoid_print
      print('[WeatherService] HTTP ${res.statusCode}: ${res.body}');
      throw WeatherException('Failed to fetch weather data');
    } catch (e) {
      // ignore: avoid_print
      print('[WeatherService] fetchCurrentWeather error: $e');
      throw WeatherException('Unable to fetch weather: $e');
    }
  }

  /// Fetch weather forecast for a region
  static Future<List<WeatherForecastDay>> fetchWeatherForecast(
    String region,
  ) async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/api/weather?region=$region'))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final forecast = (data['forecast'] as List?)
                ?.map((f) => WeatherForecastDay.fromJson(f))
                .toList() ??
            [];
        return forecast;
      }

      // ignore: avoid_print
      print('[WeatherService] HTTP ${res.statusCode}: ${res.body}');
      throw WeatherException('Failed to fetch weather forecast');
    } catch (e) {
      // ignore: avoid_print
      print('[WeatherService] fetchWeatherForecast error: $e');
      throw WeatherException('Unable to fetch forecast: $e');
    }
  }

  /// Get weather icon based on weather code
  static String getWeatherIcon(int weatherCode) {
    if (weatherCode == 0) return '☀️'; // Clear sky
    if (weatherCode == 1 || weatherCode == 2) return '🌤️'; // Mainly clear / Partly cloudy
    if (weatherCode == 3) return '☁️'; // Overcast
    if (weatherCode == 45 || weatherCode == 48) return '🌫️'; // Foggy
    if (weatherCode >= 51 && weatherCode <= 55) return '🌧️'; // Drizzle
    if (weatherCode >= 61 && weatherCode <= 67) return '🌧️'; // Rain
    if (weatherCode >= 71 && weatherCode <= 77) return '❄️'; // Snow
    if (weatherCode >= 80 && weatherCode <= 86) return '⛈️'; // Showers
    if (weatherCode >= 95 && weatherCode <= 99) return '⛈️'; // Thunderstorm
    return '🌤️'; // Default
  }
}

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);

  @override
  String toString() => message;
}
