class ApiConfig {
  // For Android Emulator
  //static const String baseUrl = 'http://10.0.2.2:5000/api/v1';
  // For Web (localhost)
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  
  // For iOS Simulator (uncomment if using iOS)
  // static const String baseUrl = 'http://localhost:5000/api/v1';
  
  static const Duration timeout = Duration(seconds: 30);
  
  // Endpoints
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
  
  // Headers
  static Map<String, String> headers({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}