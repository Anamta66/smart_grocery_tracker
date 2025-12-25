class ApiConfig {
  // For Android Emulator
  //static const String baseUrl = 'http://10.0.2.2:5000/api/v1';

  // For Web (localhost)
  static const String baseUrl = 'http://localhost:5000/api/v1';

  // For iOS Simulator (uncomment if using iOS)
  // static const String baseUrl = 'http://localhost:5000/api/v1';

  static const Duration timeout = Duration(seconds: 30);

  // ========================================
  // Authentication Endpoints
  // ========================================
  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String signup = '$auth/signup';
  static const String me = '$auth/me';

  // ========================================
  // Grocery Endpoints
  // ========================================
  static const String groceries = '/groceries';

  // ========================================
  // Category Endpoints
  // ========================================
  static const String categories = '/categories';

  // ========================================
  // Inventory Endpoints
  // ========================================
  static const String inventory = '/inventory';

  // ========================================
  // Notification Endpoints
  // ========================================
  static const String notifications = '/notifications';

  // ========================================
  // Expiry Endpoints
  // ========================================
  static const String expiry = '/expiry';

  // ========================================
  // Search Endpoints
  // ========================================
  static const String search = '/search';

  // ========================================
  // 🆕 Reports Endpoints (NEW)
  // ========================================
  static const String reports = '/reports';
  static const String monthlyReport = '$reports/monthly';
  static const String categoryWiseReport = '$reports/category-wise';
  static const String wasteReport = '$reports/waste';
  static const String budgetReport = '$reports/budget';
  static const String expenseHistory = '$reports/expense-history';
  static const String consumptionPatterns = '$reports/consumption-patterns';
  static const String exportPDF = '$reports/export/pdf';
  static const String exportExcel = '$reports/export/excel';

  // ========================================
  // Headers
  // ========================================
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
