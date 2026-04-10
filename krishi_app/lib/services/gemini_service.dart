import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sensor_service.dart';

const _apiKey = 'AIzaSyCv1Sa9qavkMcAMntyJvEuZPgBAo6wtA-c';
const _model   = 'gemini-2.5-flash-lite';
const _url =
    'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

// ── Public result type ────────────────────────────────────────────────────────
class GeminiAlert {
  final String title;
  final String summary;
  final String detail;
  final AlertLevel level; // critical | warning | fine

  const GeminiAlert({
    required this.title,
    required this.summary,
    required this.detail,
    required this.level,
  });
}

enum AlertLevel { critical, warning, fine }

// ── Main entry point ──────────────────────────────────────────────────────────
/// Calls Gemini with live sensor data and returns parsed alerts.
/// Falls back to rule-based alerts if the API call fails.
Future<List<GeminiAlert>> generateAlerts(SensorData data) async {
  try {
    final prompt = _buildPrompt(data);
    final raw = await _callGemini(prompt);
    final alerts = _parseResponse(raw, data);
    return alerts.isNotEmpty ? alerts : _fallback(data);
  } catch (_) {
    return _fallback(data);
  }
}

// ── Prompt builder ────────────────────────────────────────────────────────────
String _buildPrompt(SensorData d) {
  final waterStr  = d.waterLevel ? 'PRESENT' : 'NOT PRESENT';
  final pumpStr   = d.relay      ? 'ON'       : 'OFF';

  return '''
You are an agricultural AI assistant for Indian farmers.

Current sensor readings:
- Temperature   : ${d.temperature.toStringAsFixed(1)} °C
- Humidity      : ${d.humidity.toStringAsFixed(1)} %
- Soil Moisture : ${d.soilPercent.toStringAsFixed(0)} %
- Light (LDR)   : ${d.ldrRaw.toStringAsFixed(0)}
- pH Level      : ${d.ph.toStringAsFixed(2)}
- Water Level   : $waterStr
- Pump Status   : $pumpStr

Analyze the data and generate 3–5 short, actionable alerts for the farmer.

Rules:
- Soil moisture < 30% → suggest irrigation immediately
- Temperature > 35°C → warn about heat stress on crops
- pH < 5.5 → warn soil is too acidic, suggest lime
- pH > 7.5 → warn soil is too alkaline, suggest sulfur
- Water level NOT PRESENT → warn water shortage urgently
- If all values are normal → say "All conditions are optimal"

Output format — respond ONLY with a JSON array, no markdown, no explanation:
[
  {
    "title": "Short title (max 5 words)",
    "summary": "One line summary",
    "detail": "2–3 sentence detailed advice for the farmer",
    "level": "critical" | "warning" | "fine"
  }
]
''';
}

// ── Gemini HTTP call ──────────────────────────────────────────────────────────
Future<String> _callGemini(String prompt) async {
  final body = jsonEncode({
    'contents': [
      {
        'parts': [
          {'text': prompt}
        ]
      }
    ],
    'generationConfig': {
      'temperature': 0.3,
      'maxOutputTokens': 1024,
    },
  });

  final res = await http
      .post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      )
      .timeout(const Duration(seconds: 15));

  if (res.statusCode != 200) {
    throw Exception('Gemini API error ${res.statusCode}: ${res.body}');
  }

  final json = jsonDecode(res.body);
  return json['candidates'][0]['content']['parts'][0]['text'] as String;
}

// ── Response parser ───────────────────────────────────────────────────────────
List<GeminiAlert> _parseResponse(String raw, SensorData data) {
  try {
    // Strip markdown code fences if present
    var cleaned = raw.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceAll(RegExp(r'^```[a-z]*\n?'), '')
          .replaceAll(RegExp(r'```$'), '')
          .trim();
    }

    final list = jsonDecode(cleaned) as List<dynamic>;
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      return GeminiAlert(
        title:   map['title']   as String? ?? 'Alert',
        summary: map['summary'] as String? ?? '',
        detail:  map['detail']  as String? ?? '',
        level:   _parseLevel(map['level'] as String? ?? 'fine'),
      );
    }).toList();
  } catch (_) {
    // If JSON parse fails, try to extract plain text lines as fine alerts
    final lines = raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && l.length > 5)
        .take(5)
        .toList();

    if (lines.isEmpty) return [];
    return lines
        .map((l) => GeminiAlert(
              title:   l.length > 40 ? '${l.substring(0, 40)}…' : l,
              summary: l,
              detail:  l,
              level:   AlertLevel.fine,
            ))
        .toList();
  }
}

AlertLevel _parseLevel(String s) {
  switch (s.toLowerCase()) {
    case 'critical': return AlertLevel.critical;
    case 'warning':  return AlertLevel.warning;
    default:         return AlertLevel.fine;
  }
}

// ── Rule-based fallback ───────────────────────────────────────────────────────
List<GeminiAlert> _fallback(SensorData data) {
  final alerts = <GeminiAlert>[];

  if (!data.waterLevel) {
    alerts.add(const GeminiAlert(
      title:   'Water Tank Empty',
      summary: 'No water detected in tank',
      detail:  'The water tank sensor reports no water present. Refill the tank immediately to prevent pump damage and crop water stress.',
      level:   AlertLevel.critical,
    ));
  }

  if (data.soilPercent < 30) {
    alerts.add(GeminiAlert(
      title:   'Low Soil Moisture',
      summary: 'Soil at ${data.soilPercent.toStringAsFixed(0)}% — needs water',
      detail:  'Soil moisture is critically low at ${data.soilPercent.toStringAsFixed(0)}%. Irrigate immediately. Optimal range is 40–70%.',
      level:   AlertLevel.critical,
    ));
  }

  if (data.temperature > 35) {
    alerts.add(GeminiAlert(
      title:   'Heat Stress Warning',
      summary: 'Temperature ${data.temperature.toStringAsFixed(1)}°C is too high',
      detail:  'High temperature of ${data.temperature.toStringAsFixed(1)}°C detected. Increase irrigation frequency and consider shade nets for sensitive crops.',
      level:   AlertLevel.warning,
    ));
  }

  if (data.ph < 5.5) {
    alerts.add(GeminiAlert(
      title:   'Soil Too Acidic',
      summary: 'pH ${data.ph.toStringAsFixed(2)} — below safe range',
      detail:  'Soil pH of ${data.ph.toStringAsFixed(2)} is too acidic. Apply agricultural lime (dolomite) at 2 kg per 10 sq. metres to raise pH gradually.',
      level:   AlertLevel.warning,
    ));
  } else if (data.ph > 7.5) {
    alerts.add(GeminiAlert(
      title:   'Soil Too Alkaline',
      summary: 'pH ${data.ph.toStringAsFixed(2)} — above safe range',
      detail:  'Soil pH of ${data.ph.toStringAsFixed(2)} is too alkaline. Apply elemental sulfur or acidifying fertiliser to lower pH.',
      level:   AlertLevel.warning,
    ));
  }

  if (alerts.isEmpty) {
    alerts.add(const GeminiAlert(
      title:   'All Conditions Optimal',
      summary: 'Your farm is in great shape',
      detail:  'All sensor readings are within healthy ranges. Continue current irrigation and fertilisation schedule.',
      level:   AlertLevel.fine,
    ));
  }

  return alerts;
}
