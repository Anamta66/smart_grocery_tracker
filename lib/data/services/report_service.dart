import 'api_service.dart';

/// Service for generating reports
class ReportService {
  /// Get expense report
  static Future<Map<String, dynamic>> getExpenseReport() async {
    try {
      final response = await ApiService.get('reports/expense');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch expense report: $e');
    }
  }

  /// Get usage statistics
  static Future<Map<String, dynamic>> getUsageStats() async {
    try {
      final response = await ApiService.get('reports/usage');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch usage stats: $e');
    }
  }
}
