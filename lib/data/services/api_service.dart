// lib/data/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../services/local_storage_service.dart';

class ApiService {
  static final LocalStorageService _storage = LocalStorageService();

  /// GET Request
  static Future<dynamic> get(String endpoint,
      {Map<String, String>? params}) async {
    try {
      final token = await _storage.getAccessToken();
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
          .replace(queryParameters: params);

      final response = await http
          .get(
            uri,
            headers: ApiConfig.headers(token: token),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  /// POST Request
  static Future<dynamic> post(String endpoint, dynamic body) async {
    try {
      final token = await _storage.getAccessToken();
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await http
          .post(
            uri,
            headers: ApiConfig.headers(token: token),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  /// PUT Request
  static Future<dynamic> put(String endpoint, dynamic body) async {
    try {
      final token = await _storage.getAccessToken();
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await http
          .put(
            uri,
            headers: ApiConfig.headers(token: token),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  /// DELETE Request
  static Future<dynamic> delete(String endpoint) async {
    try {
      final token = await _storage.getAccessToken();
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await http
          .delete(
            uri,
            headers: ApiConfig.headers(token: token),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  /// Handle API Response
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized.  Please login again.');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found');
    } else if (response.statusCode == 500) {
      throw Exception('Server error.  Please try again later.');
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Request failed');
    }
  }
}
