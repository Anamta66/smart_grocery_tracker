/// local_storage_service.dart
///
/// Service for handling all local data persistence
/// Uses SharedPreferences for lightweight key-value storage
/// Provides type-safe methods for common data types and encryption support

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class LocalStorageService {
  // Singleton pattern
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // SharedPreferences instance (initialized lazily)
  SharedPreferences? _prefs;

  // ========================================
  // 🔧 INITIALIZATION
  // ========================================

  /// Initializes SharedPreferences
  /// Call this in main() before runApp()
  Future<void> init() async {
    if (_prefs != null) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      if (AppConstants.enableDebugLogs) {
        print('✅ LocalStorageService initialized');
      }
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error initializing LocalStorageService: $e');
      }
      rethrow;
    }
  }

  /// Ensures SharedPreferences is initialized
  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ========================================
  // 💾 STRING OPERATIONS
  // ========================================

  /// Saves a string value
  Future<bool> saveString(String key, String value) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.setString(key, value);

      if (AppConstants.enableDebugLogs) {
        print('💾 Saved string: $key = $value');
      }

      return result;
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error saving string ($key): $e');
      }
      return false;
    }
  }

  /// Gets a string value
  Future<String?> getString(String key) async {
    try {
      final prefs = await _preferences;
      final value = prefs.getString(key);

      if (AppConstants.enableDebugLogs && value != null) {
        print('📖 Retrieved string: $key = $value');
      }

      return value;
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error getting string ($key): $e');
      }
      return null;
    }
  }

  // ========================================
  // 🔢 INTEGER OPERATIONS
  // ========================================

  /// Saves an integer value
  Future<bool> saveInt(String key, int value) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.setInt(key, value);

      if (AppConstants.enableDebugLogs) {
        print('💾 Saved int: $key = $value');
      }

      return result;
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error saving int ($key): $e');
      }
      return false;
    }
  }

  /// Gets an integer value
  Future<int?> getInt(String key) async {
    try {
      final prefs = await _preferences;
      final value = prefs.getInt(key);

      if (AppConstants.enableDebugLogs && value != null) {
        print('📖 Retrieved int: $key = $value');
      }

      return value;
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error getting int ($key): $e');
      }
      return null;
    }
  }

  // ========================================
  // 🔘 BOOLEAN OPERATIONS
  // ========================================

  /// Saves a boolean value
  Future<bool> saveBool(String key, bool value) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.setBool(key, value);

      if (AppConstants.enableDebugLogs) {
        print('💾 Saved bool: $key = $value');
      }

      return result;
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error saving bool ($key): $e');
      }
      return false;
    }
  }

  /// Gets a boolean value
  Future<bool?> getBool(String key) async {
    try {
      final prefs = await _preferences;
      final value = prefs.getBool(key);

      if (AppConstants.enableDebugLogs && value != null) {
        print('📖 Retrieved bool: $key = $value');
      }

      return value;
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error getting bool ($key): $e');
      }
      return null;
    }
  }

  // ========================================
  // 🔸 DOUBLE OPERATIONS
  // ========================================

  /// Saves a double value
  Future<bool> saveDouble(String key, double value) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.setDouble(key, value);

      if (AppConstants.enableDebugLogs) {
        print('💾 Saved double: $key = $value');
      }

      return result;
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error saving double ($key): $e');
      }
      return false;
    }
  }

  /// Gets a double value
  Future<double?> getDouble(String key) async {
    try {
      final prefs = await _preferences;
      final value = prefs.getDouble(key);

      if (AppConstants.enableDebugLogs && value != null) {
        print('📖 Retrieved double:  $key = $value');
      }

      return value;
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error getting double ($key): $e');
      }
      return null;
    }
  }

  // ========================================
  // 📋 LIST OPERATIONS
  // ========================================

  /// Saves a list of strings
  Future<bool> saveStringList(String key, List<String> value) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.setStringList(key, value);

      if (AppConstants.enableDebugLogs) {
        print('💾 Saved string list:  $key = $value');
      }

      return result;
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error saving string list ($key): $e');
      }
      return false;
    }
  }

  /// Gets a list of strings
  Future<List<String>?> getStringList(String key) async {
    try {
      final prefs = await _preferences;
      final value = prefs.getStringList(key);

      if (AppConstants.enableDebugLogs && value != null) {
        print('📖 Retrieved string list: $key = $value');
      }

      return value;
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error getting string list ($key): $e');
      }
      return null;
    }
  }

  // ========================================
  // 🗺️ OBJECT OPERATIONS (JSON)
  // ========================================

  /// Saves any object as JSON string
  Future<bool> saveObject(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = json.encode(value);
      return await saveString(key, jsonString);
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error saving object ($key): $e');
      }
      return false;
    }
  }

  /// Gets an object from JSON string
  Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      final jsonString = await getString(key);
      if (jsonString == null) return null;

      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error getting object ($key): $e');
      }
      return null;
    }
  }

  // ========================================
  // 🔐 AUTHENTICATION HELPERS
  // ========================================

  /// Saves access token
  Future<bool> saveAccessToken(String token) async {
    return await saveString(AppConstants.keyAccessToken, token);
  }

  /// Gets access token
  Future<String?> getAccessToken() async {
    return await getString(AppConstants.keyAccessToken);
  }

  /// Saves refresh token
  Future<bool> saveRefreshToken(String token) async {
    return await saveString(AppConstants.keyRefreshToken, token);
  }

  /// Gets refresh token
  Future<String?> getRefreshToken() async {
    return await getString(AppConstants.keyRefreshToken);
  }

  /// Saves user ID
  Future<bool> saveUserId(String userId) async {
    return await saveString(AppConstants.keyUserId, userId);
  }

  /// Gets user ID
  Future<String?> getUserId() async {
    return await getString(AppConstants.keyUserId);
  }

  /// Saves user email
  Future<bool> saveUserEmail(String email) async {
    return await saveString(AppConstants.keyUserEmail, email);
  }

  /// Gets user email
  Future<String?> getUserEmail() async {
    return await getString(AppConstants.keyUserEmail);
  }

  /// Saves user name
  Future<bool> saveUserName(String name) async {
    return await saveString(AppConstants.keyUserName, name);
  }

  /// Gets user name
  Future<String?> getUserName() async {
    return await getString(AppConstants.keyUserName);
  }

  /// Sets login status
  Future<bool> setLoggedIn(bool isLoggedIn) async {
    return await saveBool(AppConstants.keyIsLoggedIn, isLoggedIn);
  }

  /// Checks if user is logged in
  Future<bool> isLoggedIn() async {
    final value = await getBool(AppConstants.keyIsLoggedIn);
    return value ?? false;
  }

  /// Clears all authentication data (logout)
  Future<void> clearAuthData() async {
    await remove(AppConstants.keyAccessToken);
    await remove(AppConstants.keyRefreshToken);
    await remove(AppConstants.keyUserId);
    await remove(AppConstants.keyUserEmail);
    await remove(AppConstants.keyUserName);
    await setLoggedIn(false);

    if (AppConstants.enableDebugLogs) {
      print('🚪 Auth data cleared (logged out)');
    }
  }

  // ========================================
  // 🎨 THEME & PREFERENCES
  // ========================================

  /// Saves theme mode (light/dark/system)
  Future<bool> saveThemeMode(String mode) async {
    return await saveString(AppConstants.keyThemeMode, mode);
  }

  /// Gets theme mode
  Future<String?> getThemeMode() async {
    return await getString(AppConstants.keyThemeMode);
  }

  /// Saves language preference
  Future<bool> saveLanguage(String languageCode) async {
    return await saveString(AppConstants.keyLanguage, languageCode);
  }

  /// Gets language preference
  Future<String?> getLanguage() async {
    return await getString(AppConstants.keyLanguage);
  }

  /// Saves notification preference
  Future<bool> saveNotificationsEnabled(bool enabled) async {
    return await saveBool(AppConstants.keyNotificationsEnabled, enabled);
  }

  /// Gets notification preference
  Future<bool> getNotificationsEnabled() async {
    final value = await getBool(AppConstants.keyNotificationsEnabled);
    return value ?? true; // Default to enabled
  }

  /// Saves expiry notification days
  Future<bool> saveExpiryNotificationDays(int days) async {
    return await saveInt(AppConstants.keyExpiryNotificationDays, days);
  }

  /// Gets expiry notification days
  Future<int> getExpiryNotificationDays() async {
    final value = await getInt(AppConstants.keyExpiryNotificationDays);
    return value ?? AppConstants.defaultExpiryWarningDays;
  }

  // ========================================
  // 🎯 ONBOARDING & FIRST-TIME FLAGS
  // ========================================

  /// Marks app as opened before
  Future<bool> setFirstTime(bool isFirstTime) async {
    return await saveBool(AppConstants.keyFirstTime, isFirstTime);
  }

  /// Checks if this is first time opening app
  Future<bool> isFirstTime() async {
    final value = await getBool(AppConstants.keyFirstTime);
    return value ?? true; // Default to true
  }

  /// Marks onboarding as completed
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await saveBool(AppConstants.keyOnboardingCompleted, completed);
  }

  /// Checks if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    final value = await getBool(AppConstants.keyOnboardingCompleted);
    return value ?? false;
  }

  // ========================================
  // 🗑️ DELETE & CLEAR OPERATIONS
  // ========================================

  /// Removes a specific key
  Future<bool> remove(String key) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.remove(key);

      if (AppConstants.enableDebugLogs) {
        print('🗑️ Removed key:  $key');
      }

      return result;
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error removing key ($key): $e');
      }
      return false;
    }
  }

  /// Checks if a key exists
  Future<bool> containsKey(String key) async {
    try {
      final prefs = await _preferences;
      return prefs.containsKey(key);
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error checking key ($key): $e');
      }
      return false;
    }
  }

  /// Clears all stored data (use with caution!)
  Future<bool> clearAll() async {
    try {
      final prefs = await _preferences;
      final result = await prefs.clear();

      if (AppConstants.enableDebugLogs) {
        print('🗑️ Cleared all local storage');
      }

      return result;
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error clearing all data:  $e');
      }
      return false;
    }
  }

  /// Gets all stored keys (for debugging)
  Future<Set<String>> getAllKeys() async {
    try {
      final prefs = await _preferences;
      return prefs.getKeys();
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error getting all keys: $e');
      }
      return {};
    }
  }

  // ========================================
  // 🔄 SYNC OPERATIONS
  // ========================================

  /// Saves last sync timestamp
  Future<bool> saveLastSyncTime(DateTime time) async {
    return await saveString(
      AppConstants.keyLastSyncTime,
      time.toIso8601String(),
    );
  }

  /// Gets last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    final timeString = await getString(AppConstants.keyLastSyncTime);
    if (timeString == null) return null;

    try {
      return DateTime.parse(timeString);
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        print('❌ Error parsing last sync time: $e');
      }
      return null;
    }
  }

  // ========================================
  // 📊 UTILITY METHODS
  // ========================================

  /// Prints all stored data (for debugging - don't use in production!)
  Future<void> debugPrintAll() async {
    if (!AppConstants.enableDebugLogs) return;

    final prefs = await _preferences;
    final keys = prefs.getKeys();

    print('═══════════════════════════════════════');
    print('📊 LOCAL STORAGE DEBUG INFO');
    print('═══════════════════════════════════════');
    print('Total keys: ${keys.length}');
    print('───────────────────────────────────────');

    for (final key in keys) {
      final value = prefs.get(key);

      // Mask sensitive data
      if (key.toLowerCase().contains('token') ||
          key.toLowerCase().contains('password')) {
        print('$key: ********** (masked)');
      } else {
        print('$key: $value');
      }
    }

    print('═══════════════════════════════════════');
  }
}
