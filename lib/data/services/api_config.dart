// lib/data/services/api_config.dart

class ApiConfig {
  // IMPORTANT: Change this based on your environment

  // For Android Emulator
  static const String baseUrl = 'http://10.0.2.2:5000/api/v1';

  // For iOS Simulator
  // static const String baseUrl = 'http://localhost:5000/api/v1';

  // For Physical Device (replace with your computer's IP)
  // static const String baseUrl = 'http://192.168.1.100:5000/api/v1';

  // For Production
  // static const String baseUrl = 'https://your-backend. herokuapp.com/api/v1';

  // Timeout duration
  static const Duration timeout = Duration(seconds: 30);

  // API Endpoints
  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String signup = '$auth/signup';
  static const String me = '$auth/me';

  static const String groceries = '/groceries';
  static const String categories = '/categories';
  static const String inventory = '/inventory';
  static const String notifications = '/notifications';
  static const String expiry = '/expiry';
  static const String search = '/search';
  static const String analytics = '/analytics';

  // Headers
  static Map<String, String> headers({String? token}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
