import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../../data/services/api_service.dart';

/// Authentication Service
/// Handles user login, registration, and session management
class AuthService {
  /// Register a new user
  /// [name] - User's full name
  /// [email] - User's email address
  /// [password] - User's password
  /// [role] - Either 'customer' or 'store_owner'
  /// [storeName] - Required if role is 'store_owner'
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? storeName,
    String? phone,
    String? address,
  }) async {
    final response = await ApiService.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      if (storeName != null) 'storeName': storeName,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
    });

    // Store token
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAccessToken, response['token']);

    return UserModel.fromJson(response['user']);
  }

  /// Login existing user
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    // Store token
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAccessToken, response['token']);

    return UserModel.fromJson(response['user']);
  }

  /// Get current logged in user
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyAccessToken);

      if (token == null) return null;

      final response = await ApiService.get('/auth/me');
      return UserModel.fromJson(response['user']);
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    final response = await ApiService.patch('/auth/profile', {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
    });

    return UserModel.fromJson(response['user']);
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ApiService.post('/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAccessToken);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyAccessToken) != null;
  }
}
