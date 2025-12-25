// lib/presentation/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/local_storage_service.dart';

class AuthProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // User info getters
  String? get userId => _currentUser?['_id'] ?? _currentUser?['id'];
  String? get userName => _currentUser?['name'];
  String? get userEmail => _currentUser?['email'];
  String? get userRole => _currentUser?['role'];
  String? get userPhone => _currentUser?['phone'];
  String? get userAddress => _currentUser?['address'];

  // Constructor - Check if user is already logged in
  AuthProvider() {
    _initializeAuth();
  }

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    await _storage.init(); // Ensure storage is initialized
    await checkAuthStatus();
  }

  /// Check if user is already authenticated
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user is logged in
      final isLoggedIn = await AuthService.isAuthenticated();

      if (isLoggedIn) {
        // Try to get user from storage first
        _currentUser = await AuthService.getStoredUserProfile();

        // If no stored profile or need fresh data, fetch from API
        if (_currentUser == null) {
          final response = await AuthService.getCurrentUser();
          _currentUser = response['user'];
        }
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;

      if (kDebugMode) {
        print('Auth check error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthService.login(
        email: email,
        password: password,
      );

      // Extract user data from response
      _currentUser = response['user'] ?? response['data']?['user'];

      if (_currentUser == null) {
        throw Exception('Login successful but user data not found');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _currentUser = null;
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('Login error:  $e');
      }

      return false;
    }
  }

  /// Register new user
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthService.signup(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      // Extract user data from response
      _currentUser = response['user'] ?? response['data']?['user'];

      if (_currentUser == null) {
        throw Exception('Signup successful but user data not found');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _currentUser = null;
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('Signup error: $e');
      }

      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.logout();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);

      if (kDebugMode) {
        print('Logout error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh user data
  Future<bool> refreshUserData() async {
    if (!isAuthenticated) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.getCurrentUser();
      _currentUser = response['user'] ?? response['data']?['user'];

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('Refresh user data error: $e');
      }

      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_currentUser == null) {
      _errorMessage = 'No user logged in';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Note: You'll need to add this endpoint to your AuthService
      final token = await _storage.getAccessToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Build update data
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;

      // Make API call (you'll need to implement this in AuthService)
      // For now, update locally
      _currentUser = {
        ..._currentUser!,
        ...updateData,
      };

      // Save to storage
      await _storage.saveObject('user_profile', _currentUser!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('Update profile error: $e');
      }

      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!isAuthenticated) {
      _errorMessage = 'No user logged in';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('Change password error: $e');
      }

      return false;
    }
  }

  /// Request password reset
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.forgotPassword(email: email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('Forgot password error: $e');
      }

      return false;
    }
  }

  /// Reset password with token
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('Reset password error: $e');
      }

      return false;
    }
  }

  /// Verify email
  Future<bool> verifyEmail(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.verifyEmail(token: token);

      // Refresh user data to get updated verification status
      await refreshUserData();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('Verify email error: $e');
      }

      return false;
    }
  }

  /// Resend verification email
  Future<bool> resendVerificationEmail() async {
    if (!isAuthenticated) {
      _errorMessage = 'No user logged in';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.resendVerificationEmail();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('Resend verification error: $e');
      }

      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Extract user-friendly error message
  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      // Remove "Exception:  " prefix
      return message.replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  /// Check if user has specific role
  bool hasRole(String role) {
    return userRole?.toLowerCase() == role.toLowerCase();
  }

  /// Check if user is customer
  bool get isCustomer => hasRole('customer');

  /// Check if user is store owner
  bool get isStoreOwner => hasRole('store_owner') || hasRole('storeowner');

  /// Check if user is admin
  bool get isAdmin => hasRole('admin');

  /// Get user initials for avatar
  String get userInitials {
    if (userName == null || userName!.isEmpty) return '?';

    final parts = userName!.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return userName![0].toUpperCase();
  }

  /// Debug:  Print current state
  void debugPrintState() {
    if (!kDebugMode) return;

    print('═══════════════════════════════════════');
    print('📊 AUTH PROVIDER STATE');
    print('═══════════════════════════════════════');
    print('Is Authenticated: $isAuthenticated');
    print('Is Loading: $isLoading');
    print('Error: $_errorMessage');
    print('User ID: $userId');
    print('User Name: $userName');
    print('User Email: $userEmail');
    print('User Role:  $userRole');
    print('═══════════════════════════════════════');
  }
}
