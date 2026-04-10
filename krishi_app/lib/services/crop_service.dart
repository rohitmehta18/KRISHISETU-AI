import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'sensor_service.dart';

String get _baseUrl => 'https://setu-backend-jixd.onrender.com';

class CropRecommendation {
  final String name;
  final int score;
  final List<String> reasons;
  final String tempRange;
  final String moistureRange;
  final String phRange;

  const CropRecommendation({
    required this.name,
    required this.score,
    required this.reasons,
    required this.tempRange,
    required this.moistureRange,
    required this.phRange,
  });

  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    return CropRecommendation(
      name: json['name'] ?? 'Unknown',
      score: _toInt(json['score']),
      reasons: (json['reasons'] as List<dynamic>?)
              ?.map((r) => r.toString())
              .toList() ??
          [],
      tempRange: json['tempRange'] ?? '',
      moistureRange: json['moistureRange'] ?? '',
      phRange: json['phRange'] ?? '',
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    return (v as num).toInt();
  }

  String get scoreLabel {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  Color get scoreColor {
    if (score >= 80) return const Color.fromARGB(255, 102, 187, 106);
    if (score >= 60) return const Color.fromARGB(255, 255, 202, 40);
    if (score >= 40) return const Color.fromARGB(255, 255, 152, 0);
    return const Color.fromARGB(255, 239, 83, 80);
  }
}

class CropRecommendationsResult {
  final String region;
  final List<CropRecommendation> recommendations;
  final String message;

  const CropRecommendationsResult({
    required this.region,
    required this.recommendations,
    required this.message,
  });

  factory CropRecommendationsResult.fromJson(Map<String, dynamic> json) {
    return CropRecommendationsResult(
      region: json['region'] ?? 'Unknown',
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((r) => CropRecommendation.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message'] ?? 'No recommendations available',
    );
  }
}

class CropService {
  static const _timeout = Duration(seconds: 10);

  /// Get crop recommendations for a region based on sensor data
  static Future<CropRecommendationsResult> getCropRecommendations(
    String region,
  ) async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/api/crops/recommend?region=$region'))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        return CropRecommendationsResult.fromJson(jsonDecode(res.body));
      }

      // ignore: avoid_print
      print('[CropService] HTTP ${res.statusCode}: ${res.body}');
      throw CropException('Failed to fetch crop recommendations');
    } catch (e) {
      // ignore: avoid_print
      print('[CropService] getCropRecommendations error: $e');
      throw CropException('Unable to fetch recommendations: $e');
    }
  }
}

class CropException implements Exception {
  final String message;
  CropException(this.message);

  @override
  String toString() => message;
}
