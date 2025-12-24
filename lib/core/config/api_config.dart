/// API Configuration
/// Contains all backend API endpoints and configuration

class ApiConfig {
  // Private constructor
  ApiConfig._();

  // ============================================
  // BASE URL CONFIGURATION
  // ============================================

  // For Android Emulator
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:5000';

  // For iOS Simulator
  static const String _iosSimulatorBaseUrl = 'http://localhost:5000';

  // For Physical Device (replace with your computer's IP)
  static const String _physicalDeviceBaseUrl = 'http://192.168.1.100:5000';

  // For Production (replace with your deployed backend URL)
  static const String _productionBaseUrl = 'https://api.smartgrocery.com';

  /// Get base URL based on environment
  static String get baseUrl {
    // Change this based on your testing environment
    const bool isProduction = bool.fromEnvironment('dart.vm.product');

    if (isProduction) {
      return _productionBaseUrl;
    }

    // For development, choose based on platform
    // You can also use flutter run --dart-define=BASE_URL=...
    return const String.fromEnvironment(
      'BASE_URL',
      defaultValue: _androidEmulatorBaseUrl, // Change as needed
    );
  }

  // ============================================
  // API ENDPOINTS
  // ============================================

  static String get apiVersion => '/api/v1';
  static String get apiUrl => '$baseUrl$apiVersion';

  // Authentication Endpoints
  static String get authLogin => '$apiUrl/auth/login';
  static String get authRegister => '$apiUrl/auth/register';
  static String get authLogout => '$apiUrl/auth/logout';
  static String get authMe => '$apiUrl/auth/me';
  static String get authUpdatePassword => '$apiUrl/auth/update-password';
  static String get authForgotPassword => '$apiUrl/auth/forgot-password';
  static String get authResetPassword => '$apiUrl/auth/reset-password';

  // User Endpoints
  static String get userProfile => '$apiUrl/users/profile';
  static String get userPreferences => '$apiUrl/users/preferences';

  // Grocery Endpoints
  static String get groceries => '$apiUrl/groceries';
  static String groceryById(String id) => '$groceries/$id';
  static String get groceryStats => '$groceries/stats';
  static String groceryByCategory(String categoryId) =>
      '$groceries/category/$categoryId';

  // Category Endpoints
  static String get categories => '$apiUrl/categories';
  static String categoryById(String id) => '$categories/$id';
  static String get categoriesSeed => '$categories/seed';

  // Expiry Endpoints
  static String get expiryExpiringSoon => '$apiUrl/expiry/expiring-soon';
  static String get expiryExpired => '$apiUrl/expiry/expired';
  static String get expirySummary => '$apiUrl/expiry/summary';
  static String expiryCheck(String id) => '$apiUrl/expiry/check/$id';

  // Notification Endpoints
  static String get notifications => '$apiUrl/notifications';
  static String notificationById(String id) => '$notifications/$id';
  static String get notificationUnreadCount => '$notifications/unread-count';
  static String get notificationReadAll => '$notifications/read-all';

  // Search Endpoints
  static String get search => '$apiUrl/search';
  static String get searchSuggestions => '$search/suggestions';
  static String get searchRecent => '$search/recent';

  // Inventory Endpoints (Store Owner)
  static String get inventory => '$apiUrl/inventory';
  static String inventoryById(String id) => '$inventory/$id';

  // ============================================
  // REQUEST CONFIGURATION
  // ============================================

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============================================
  // HEADERS
  // ============================================

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> headersWithAuth(String token) => {
        ...headers,
        'Authorization': 'Bearer $token',
      };
}
