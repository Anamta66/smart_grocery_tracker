/// app_constants.dart
///
/// Central location for all application-wide constants
/// This file contains configuration values, API endpoints,
/// storage keys, UI constants, and other fixed values used throughout the app.

class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ========================================
  // 🔐 APP INFORMATION
  // ========================================
  static const String appName = 'Smart Grocery Manager';
  static const String appVersion = '1.0.0';
  static const String appTagline =
      'Manage groceries smartly, reduce waste efficiently';

  // ========================================
  // 🌐 API CONFIGURATION
  // ========================================

  // Base URL for backend API
  // TODO: Replace with your actual backend URL in production
  static const String baseUrl = 'http://localhost:3000/api/v1';

  // Alternative for emulator testing
  static const String emulatorBaseUrl = 'http://10.0.2.2:3000/api/v1';

  // Alternative for physical device testing (replace with your local IP)
  static const String deviceBaseUrl = 'http://192.168.1.100:3000/api/v1';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String userEndpoint = '/users';
  static const String groceryEndpoint = '/groceries';
  static const String categoryEndpoint = '/categories';
  static const String notificationEndpoint = '/notifications';
  static const String searchEndpoint = '/search';
  static const String expiryEndpoint = '/expiry';

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ========================================
  // 💾 LOCAL STORAGE KEYS
  // ========================================

  // Authentication keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyIsLoggedIn = 'is_logged_in';

  // User preferences
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyExpiryNotificationDays = 'expiry_notification_days';

  // App settings
  static const String keyFirstTime = 'first_time';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyLastSyncTime = 'last_sync_time';

  // Categories cache
  static const String keyCategoriesCache = 'categories_cache';
  static const String keyCategoriesCacheTime = 'categories_cache_time';

  // ========================================
  // 📱 UI CONSTANTS
  // ========================================

  // Spacing & Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusExtraLarge = 24.0;
  static const double borderRadiusCircular = 50.0;

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 48.0;

  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeNormal = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeTitle = 20.0;
  static const double fontSizeHeading = 24.0;
  static const double fontSizeDisplay = 32.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // ========================================
  // 🎨 CATEGORY ICONS & COLORS
  // ========================================

  // Default category icons (Material Icons names)
  static const Map<String, String> defaultCategoryIcons = {
    'Fruits': 'apple',
    'Vegetables': 'eco',
    'Dairy': 'water_drop',
    'Meat': 'restaurant',
    'Beverages': 'local_drink',
    'Snacks': 'cake',
    'Frozen': 'ac_unit',
    'Bakery': 'bakery_dining',
    'Grains': 'grass',
    'Other': 'category',
  };

  // ========================================
  // ⏰ EXPIRY SETTINGS
  // ========================================

  // Number of days before expiry to show warning
  static const int defaultExpiryWarningDays = 3;
  static const int maxExpiryWarningDays = 30;
  static const int minExpiryWarningDays = 1;

  // Notification times (hour of day, 0-23)
  static const int morningNotificationHour = 9;
  static const int eveningNotificationHour = 18;

  // ========================================
  // 🔢 PAGINATION & LIMITS
  // ========================================

  static const int defaultPageSize = 20;
  static const int maxSearchResults = 50;
  static const int maxRecentSearches = 10;
  static const int categoryCacheValidityHours = 24;

  // ========================================
  // 📝 VALIDATION RULES
  // ========================================

  // Email validation pattern
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Password rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;

  // Name rules
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Grocery item rules
  static const int minItemNameLength = 1;
  static const int maxItemNameLength = 100;
  static const int maxItemDescriptionLength = 500;

  // Quantity rules
  static const double minQuantity = 0.1;
  static const double maxQuantity = 9999.99;

  // ========================================
  // 🔔 NOTIFICATION CHANNELS
  // ========================================

  static const String notificationChannelId = 'grocery_notifications';
  static const String notificationChannelName = 'Grocery Notifications';
  static const String notificationChannelDescription =
      'Notifications for expiring items and reminders';

  // Notification IDs
  static const int expiryNotificationId = 1000;
  static const int reminderNotificationId = 2000;
  static const int generalNotificationId = 3000;

  // ========================================
  // 🌍 SUPPORTED LANGUAGES
  // ========================================

  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'es', 'fr', 'ur'];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'ur': 'اردو',
  };

  // ========================================
  // 🎭 ANIMATION DURATIONS
  // ========================================

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 2);

  // ========================================
  // 📊 CHART & STATISTICS
  // ========================================

  static const int daysForStatistics = 30;
  static const int maxChartItems = 10;

  // ========================================
  // 🔊 VOICE INPUT
  // ========================================

  static const String voiceInputLanguage = 'en-US';
  static const Duration voiceInputTimeout = Duration(seconds: 5);

  // ========================================
  // 🖼️ IMAGE SETTINGS
  // ========================================

  static const int maxImageSizeMB = 5;
  static const int imageQuality = 85;
  static const double maxImageDimension = 1920.0;

  // ========================================
  // 🌐 ERROR MESSAGES
  // ========================================

  static const String errorNoInternet =
      'No internet connection. Please check your network settings.';
  static const String errorServerUnavailable =
      'Server is currently unavailable. Please try again later. ';
  static const String errorUnauthorized =
      'Session expired. Please login again.';
  static const String errorGeneral = 'Something went wrong. Please try again.';
  static const String errorInvalidCredentials = 'Invalid email or password. ';
  static const String errorEmailExists =
      'Email already registered. Please login.';
  static const String errorFieldRequired = 'This field is required.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorPasswordTooShort =
      'Password must be at least 6 characters. ';

  // ========================================
  // ✅ SUCCESS MESSAGES
  // ========================================

  static const String successLogin = 'Welcome back! ';
  static const String successSignup = 'Account created successfully! ';
  static const String successItemAdded = 'Item added successfully!';
  static const String successItemUpdated = 'Item updated successfully!';
  static const String successItemDeleted = 'Item deleted successfully! ';
  static const String successCategoryAdded = 'Category added successfully!';
  static const String successCategoryUpdated = 'Category updated successfully!';
  static const String successCategoryDeleted = 'Category deleted successfully!';

  // ========================================
  // 🔧 DEBUG FLAGS
  // ========================================

  static const bool enableDebugLogs = true;
  static const bool enableNetworkLogs = true;
  static const bool useMockData =
      false; // Set to true for testing without backend

  // ========================================
  // 📅 DATE FORMATS
  // ========================================

  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';
  static const String timeFormat = 'hh:mm a';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-ddTHH:mm:ss. SSSZ';

  // ========================================
  // 🎯 REGEX PATTERNS
  // ========================================

  static final RegExp emailRegex = RegExp(emailPattern);
  static final RegExp numberRegex = RegExp(r'^\d+\. ?\d*$');
  static final RegExp alphaNumericRegex = RegExp(r'^[a-zA-Z0-9 ]+$');

  // ========================================
  // 🔐 SECURITY
  // ========================================

  static const int tokenRefreshThresholdMinutes = 5;
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);

  // ========================================
  // 📱 PLATFORM SPECIFIC
  // ========================================

  static const String appStoreId = 'com.smartgrocery.app';
  static const String playStoreId = 'com.smartgrocery.app';
}
