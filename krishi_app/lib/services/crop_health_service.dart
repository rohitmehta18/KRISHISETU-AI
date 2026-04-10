import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String get _baseUrl => 'https://setu-backend-jixd.onrender.com';

class HealthMetric {
  final int score;
  final String status;
  final String recommendation;

  const HealthMetric({
    required this.score,
    required this.status,
    required this.recommendation,
  });

  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      score: _toInt(json['score']),
      status: json['status'] ?? 'unknown',
      recommendation: json['recommendation'] ?? '',
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    return (v as num).toInt();
  }

  Color get statusColor {
    if (status == 'optimal') return const Color.fromARGB(255, 102, 187, 106);
    if (status == 'good') return const Color.fromARGB(255, 255, 202, 40);
    if (status == 'poor') return const Color.fromARGB(255, 255, 152, 0);
    if (status == 'critical') return const Color.fromARGB(255, 239, 83, 80);
    return Colors.grey;
  }

  String get displayScore => '$score%';
}

class CriticalAlert {
  final String parameter;
  final String recommendation;

  const CriticalAlert({
    required this.parameter,
    required this.recommendation,
  });

  factory CriticalAlert.fromJson(Map<String, dynamic> json) {
    return CriticalAlert(
      parameter: json['parameter'] ?? 'Unknown',
      recommendation: json['recommendation'] ?? '',
    );
  }
}

class HealthImprovement {
  final String parameter;
  final int score;
  final String recommendation;

  const HealthImprovement({
    required this.parameter,
    required this.score,
    required this.recommendation,
  });

  factory HealthImprovement.fromJson(Map<String, dynamic> json) {
    return HealthImprovement(
      parameter: json['parameter'] ?? 'Unknown',
      score: _toInt(json['score']),
      recommendation: json['recommendation'] ?? '',
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    return (v as num).toInt();
  }
}

class CropHealthReport {
  final int overallScore;
  final String healthStatus;
  final Map<String, HealthMetric> metrics;
  final List<CriticalAlert> criticalAlerts;
  final List<HealthImprovement> improvements;

  const CropHealthReport({
    required this.overallScore,
    required this.healthStatus,
    required this.metrics,
    required this.criticalAlerts,
    required this.improvements,
  });

  factory CropHealthReport.fromJson(Map<String, dynamic> json) {
    final metricsMap = <String, HealthMetric>{};
    if (json['metrics'] is Map) {
      (json['metrics'] as Map).forEach((key, value) {
        metricsMap[key] = HealthMetric.fromJson(value);
      });
    }

    return CropHealthReport(
      overallScore: _toInt(json['overallScore']),
      healthStatus: json['healthStatus'] ?? 'Unknown',
      metrics: metricsMap,
      criticalAlerts: (json['criticalAlerts'] as List<dynamic>?)
              ?.map((a) => CriticalAlert.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      improvements: (json['improvements'] as List<dynamic>?)
              ?.map((i) => HealthImprovement.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    return (v as num).toInt();
  }

  Color get statusColor {
    if (overallScore >= 85) return const Color.fromARGB(255, 102, 187, 106);
    if (overallScore >= 70) return const Color.fromARGB(255, 255, 202, 40);
    if (overallScore >= 50) return const Color.fromARGB(255, 255, 152, 0);
    if (overallScore >= 30) return const Color.fromARGB(255, 255, 112, 67);
    return const Color.fromARGB(255, 239, 83, 80);
  }

  IconData get statusIcon {
    if (overallScore >= 85) return Icons.favorite;
    if (overallScore >= 70) return Icons.favorite_border;
    if (overallScore >= 50) return Icons.warning_amber;
    return Icons.error;
  }
}

class CropHealthService {
  static const _timeout = Duration(seconds: 10);

  /// Get comprehensive crop health report
  static Future<CropHealthReport> getCropHealth() async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/api/health/crop'))
          .timeout(_timeout);

      if (res.statusCode == 200) {
        return CropHealthReport.fromJson(jsonDecode(res.body));
      }

      // ignore: avoid_print
      print('[CropHealthService] HTTP ${res.statusCode}: ${res.body}');
      throw CropHealthException('Failed to fetch crop health data');
    } catch (e) {
      // ignore: avoid_print
      print('[CropHealthService] getCropHealth error: $e');
      throw CropHealthException('Unable to fetch health report: $e');
    }
  }
}

class CropHealthException implements Exception {
  final String message;
  CropHealthException(this.message);

  @override
  String toString() => message;
}
