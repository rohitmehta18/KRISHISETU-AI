import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'session.dart';

String get _baseUrl => 'https://setu-backend-jixd.onrender.com';

// ── Models ────────────────────────────────────────────────────────────────────
class AuthResult {
  final String name;
  final String email;
  final String token;
  const AuthResult({required this.name, required this.email, required this.token});
}

class UserProfile {
  final String name;
  final String email;
  final int? age;
  final String? region;
  final String? farmerType;
  final double? landSize;
  final String? farmingType;
  final List<String> crops;
  final String? waterSource;
  final String? irrigationType;
  final bool usesPesticides;
  final String? language;

  const UserProfile({
    required this.name,
    required this.email,
    this.age,
    this.region,
    this.farmerType,
    this.landSize,
    this.farmingType,
    this.crops = const [],
    this.waterSource,
    this.irrigationType,
    this.usesPesticides = false,
    this.language,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        name:           j['name']           as String? ?? '',
        email:          j['email']          as String? ?? '',
        age:            j['age']            as int?,
        region:         j['region']         as String?,
        farmerType:     j['farmerType']     as String?,
        landSize:       j['landSize'] != null ? (j['landSize'] as num).toDouble() : null,
        farmingType:    j['farmingType']    as String?,
        crops:          (j['crops'] as List<dynamic>?)?.cast<String>() ?? [],
        waterSource:    j['waterSource']    as String?,
        irrigationType: j['irrigationType'] as String?,
        usesPesticides: j['usesPesticides'] as bool? ?? false,
        language:       j['language']       as String?,
      );
}

// ── Service ───────────────────────────────────────────────────────────────────
class AuthService {
  static const _timeout = Duration(seconds: 10);

  static Future<AuthResult> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(_timeout);

    final body = jsonDecode(res.body);
    if (res.statusCode == 200) {
      final r = AuthResult(
          name: body['user']['name'],
          email: body['user']['email'],
          token: body['token']);
      Session.save(t: r.token, n: r.name, e: r.email);
      return r;
    }
    throw AuthException(body['error'] ?? 'Login failed');
  }

  static Future<AuthResult> signup(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ).timeout(_timeout);

    final body = jsonDecode(res.body);
    if (res.statusCode == 201) {
      final r = AuthResult(
          name: body['user']['name'],
          email: body['user']['email'],
          token: body['token']);
      Session.save(t: r.token, n: r.name, e: r.email);
      return r;
    }
    throw AuthException(body['error'] ?? 'Signup failed');
  }

  static Future<UserProfile> fetchProfile() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/api/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Session.token}',
      },
    ).timeout(_timeout);

    final body = jsonDecode(res.body);
    if (res.statusCode == 200) return UserProfile.fromJson(body);
    throw AuthException(body['error'] ?? 'Failed to fetch profile');
  }

  static Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/api/user/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Session.token}',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    ).timeout(_timeout);

    final body = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw AuthException(body['error'] ?? 'Failed to change password');
    }
  }

  static void logout() => Session.clear();
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}
