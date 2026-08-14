import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Raw response envelope from the API, including both data and optional meta.
class ApiResponse {
  final dynamic data;
  final Map<String, dynamic>? meta;
  const ApiResponse({required this.data, this.meta});
}

class ApiClient {
  static const String _authTokenKey = 'ahuike_auth_token';

  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;
    if (kIsWeb) return 'http://127.0.0.1:4000/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:4000/api/v1';
    return 'http://127.0.0.1:4000/api/v1';
  }

  String? _token;

  ApiClient({String? token}) : _token = token;

  Future<void> setAuthToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(_authTokenKey, token);
    } else {
      await prefs.remove(_authTokenKey);
    }
  }

  Future<String?> loadSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_authTokenKey);
    return _token;
  }

  String? get currentToken => _token;

  final http.Client _client = http.Client();

  Map<String, String> get _headers {
    final map = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      map['Authorization'] = 'Bearer $_token';
    } else {
      map['x-patient-id'] = dotenv.env['PATIENT_ID'] ?? 'test-patient-001';
    }
    return map;
  }

  /// Returns raw ApiResponse with both data and meta.
  Future<ApiResponse> get(String endpoint, {Map<String, String>? queryParameters}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParameters);
      debugPrint('GET: $uri');
      final response = await _client.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Returns raw ApiResponse — callers extract .data or .meta as needed.
  Future<ApiResponse> post(String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('POST: $uri');
      final response = await _client.post(uri, headers: _headers, body: jsonEncode(body));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  ApiResponse _handleResponse(http.Response response) {
    final dynamic decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final meta = decoded['meta'] as Map<String, dynamic>?;
      return ApiResponse(data: decoded['data'] ?? decoded, meta: meta);
    }
    final message = decoded['error']?['message'] ?? 'Unknown API Error';
    throw Exception(message);
  }
}
