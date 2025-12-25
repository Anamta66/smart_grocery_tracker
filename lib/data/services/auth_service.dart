// lib/data/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_service.dart';
import 'local_storage_service.dart';

/// Authentication Service
/// Handles all authentication-related API calls
class AuthService {
  static final LocalStorageService _storage = LocalStorageService();

  // ========================================
  // 🔐 AUTHENTICATION METHODS
  // ========================================

  /// Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}');

      final response = await http
          .post(
            uri,
            headers: ApiConfig.headers(),
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = _handleResponse(response);

      // Save authentication data
      if (data['success'] == true || data['token'] != null) {
        await _saveAuthData(data);
      }

      return data;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Signup new user
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.signup}');

      final response = await http
          .post(
            uri,
            headers: ApiConfig.headers(),
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'role': role,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = _handleResponse(response);

      // Save authentication data
      if (data['success'] == true || data['token'] != null) {
        await _saveAuthData(data);
      }

      return data;
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  /// Get current authenticated user
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await _storage.getAccessToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.me}');

      final response = await http
          .get(
            uri,
            headers: ApiConfig.headers(token: token),
          )
          .timeout(ApiConfig.timeout);

      final data = _handleResponse(response);

      // Update stored user data
      if (data['user'] != null) {
        await _saveUserData(data['user']);
      }

      return data;
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  /// Logout user
  static Future<void> logout() async {
    try {
      // Optional: Call logout endpoint if your backend has one
      final token = await _storage.getAccessToken();

      if (token != null) {
        try {
          final uri = Uri.parse('${ApiConfig.baseUrl}/auth/logout');
          await http
              .post(
                uri,
                headers: ApiConfig.headers(token: token),
              )
              .timeout(const Duration(seconds: 5));
        } catch (e) {
          // Ignore logout endpoint errors, still clear local data
          print('Logout endpoint error (ignored): $e');
        }
      }

      // Clear all local authentication data
      await _storage.clearAuthData();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  /// Refresh access token
  static Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();

      if (refreshToken == null) {
        throw Exception('No refresh token found');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/refresh');

      final response = await http
          .post(
            uri,
            headers: ApiConfig.headers(),
            body: jsonEncode({
              'refreshToken': refreshToken,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = _handleResponse(response);

      // Update tokens
      if (data['token'] != null) {
        await _storage.saveAccessToken(data['token']);
      }

      if (data['refreshToken'] != null) {
        await _storage.saveRefreshToken(data['refreshToken']);
      }

      return data;
    } catch (e) {
      // If refresh fails, logout user
      await _storage.clearAuthData();
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  /// Change password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await _storage.getAccessToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/change-password');

      final response = await http
          .put(
            uri,
            headers: ApiConfig.headers(token: token),
            body: jsonEncode({
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Password change failed: ${e.toString()}');
    }
  }

  /// Request password reset
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password');

      final response = await http
          .post(
            uri,
            headers: ApiConfig.headers(),
            body: jsonEncode({
              'email': email,
            }),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Password reset request failed: ${e.toString()}');
    }
  }

  /// Reset password with token
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/reset-password');

      final response = await http
          .post(
            uri,
            headers: ApiConfig.headers(),
            body: jsonEncode({
              'token': token,
              'newPassword': newPassword,
            }),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  /// Verify email
  static Future<Map<String, dynamic>> verifyEmail({
    required String token,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/verify-email');

      final response = await http
          .post(
            uri,
            headers: ApiConfig.headers(),
            body: jsonEncode({
              'token': token,
            }),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Email verification failed: ${e.toString()}');
    }
  }

  /// Resend verification email
  static Future<Map<String, dynamic>> resendVerificationEmail() async {
    try {
      final token = await _storage.getAccessToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/resend-verification');

      final response = await http
          .post(
            uri,
            headers: ApiConfig.headers(token: token),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Resend verification failed: ${e.toString()}');
    }
  }

  // ========================================
  // 💾 HELPER METHODS
  // ========================================

  /// Save authentication data to local storage
  static Future<void> _saveAuthData(Map<String, dynamic> data) async {
    // Save token
    if (data['token'] != null) {
      await _storage.saveAccessToken(data['token']);
    }

    // Save refresh token
    if (data['refreshToken'] != null) {
      await _storage.saveRefreshToken(data['refreshToken']);
    }

    // Save user data
    if (data['user'] != null) {
      await _saveUserData(data['user']);
    }

    // Set logged in status
    await _storage.setLoggedIn(true);
  }

  /// Save user data to local storage
  static Future<void> _saveUserData(Map<String, dynamic> user) async {
    if (user['_id'] != null || user['id'] != null) {
      await _storage.saveUserId(user['_id'] ?? user['id']);
    }

    if (user['email'] != null) {
      await _storage.saveUserEmail(user['email']);
    }

    if (user['name'] != null) {
      await _storage.saveUserName(user['name']);
    }

    // Save entire user object as JSON
    await _storage.saveObject('user_profile', user);
  }

  /// Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body;

    // Handle empty response
    if (body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true};
      }
    }

    // Parse JSON response
    final Map<String, dynamic> data = jsonDecode(body);

    // Handle successful responses (2xx)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    // Handle error responses
    if (response.statusCode == 400) {
      throw Exception(data['message'] ?? 'Bad request');
    } else if (response.statusCode == 401) {
      throw Exception(data['message'] ?? 'Unauthorized.  Please login again.');
    } else if (response.statusCode == 403) {
      throw Exception(data['message'] ?? 'Access forbidden');
    } else if (response.statusCode == 404) {
      throw Exception(data['message'] ?? 'Resource not found');
    } else if (response.statusCode == 422) {
      // Validation errors
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        throw Exception(firstError is List ? firstError[0] : firstError);
      }
      throw Exception(data['message'] ?? 'Validation failed');
    } else if (response.statusCode == 429) {
      throw Exception('Too many requests. Please try again later.');
    } else if (response.statusCode >= 500) {
      throw Exception(
          data['message'] ?? 'Server error. Please try again later.');
    }

    // Default error
    throw Exception(
        data['message'] ?? 'Request failed with status ${response.statusCode}');
  }

  // ========================================
  // 🔍 UTILITY METHODS
  // ========================================

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await _storage.getAccessToken();
    final isLoggedIn = await _storage.isLoggedIn();
    return token != null && isLoggedIn;
  }

  /// Get stored user profile
  static Future<Map<String, dynamic>?> getStoredUserProfile() async {
    return await _storage.getObject('user_profile');
  }

  /// Get stored user ID
  static Future<String?> getStoredUserId() async {
    return await _storage.getUserId();
  }

  /// Get stored user email
  static Future<String?> getStoredUserEmail() async {
    return await _storage.getUserEmail();
  }

  /// Get stored user name
  static Future<String?> getStoredUserName() async {
    return await _storage.getUserName();
  }

  /// Clear all cached data (useful for debugging)
  static Future<void> clearCache() async {
    await _storage.clearAll();
  }
}
