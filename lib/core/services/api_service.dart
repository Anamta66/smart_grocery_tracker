import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../../data/services/local_storage_service.dart';

/// API Service
/// Handles all HTTP requests to the backend

class ApiService {
  final LocalStorageService _storage = LocalStorageService();

  /// GET Request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      // Build URI with query parameters
      final uri = queryParameters != null
          ? Uri.parse(endpoint).replace(queryParameters: queryParameters)
          : Uri.parse(endpoint);

      // Get headers
      final headers = await _getHeaders(requiresAuth);

      // Make request
      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('Server error');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  /// POST Request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final headers = await _getHeaders(requiresAuth);

      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  /// PUT Request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final headers = await _getHeaders(requiresAuth);

      final response = await http
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  /// DELETE Request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final headers = await _getHeaders(requiresAuth);

      final response = await http
          .delete(uri, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  /// PATCH Request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final headers = await _getHeaders(requiresAuth);

      final response = await http
          .patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Request failed:  $e');
    }
  }

  /// Upload File (Multipart)
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'image',
    Map<String, String>? additionalFields,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final token = await _storage.getAccessToken();

      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }

  /// Get headers with optional authentication
  Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    if (requiresAuth) {
      final token = await _storage.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      return ApiConfig.headersWithAuth(token);
    }
    return ApiConfig.headers;
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    // Try to decode JSON
    Map<String, dynamic> data;
    try {
      data = jsonDecode(body);
    } catch (e) {
      throw Exception('Invalid JSON response');
    }

    // Handle different status codes
    switch (statusCode) {
      case 200:
      case 201:
        return data;

      case 204:
        return {'success': true, 'message': 'Success'};

      case 400:
        throw Exception(data['message'] ?? 'Bad request');

      case 401:
        throw Exception(data['message'] ?? 'Unauthorized');

      case 403:
        throw Exception(data['message'] ?? 'Forbidden');

      case 404:
        throw Exception(data['message'] ?? 'Not found');

      case 422:
        throw Exception(data['message'] ?? 'Validation error');

      case 500:
        throw Exception(data['message'] ?? 'Server error');

      default:
        throw Exception('HTTP Error:  $statusCode');
    }
  }
}
