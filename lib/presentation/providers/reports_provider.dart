import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Provider for managing reports and analytics
/// Handles expense tracking, waste analysis, and consumption patterns
class ReportsProvider with ChangeNotifier {
  // Since ApiService and LocalStorageService don't have the required methods,
  // we'll implement a simplified version that works with your existing services

  // Loading states
  bool _isLoading = false;
  bool _isExporting = false;
  String? _error;

  // Report data
  Map<String, dynamic>? _monthlyReport;
  Map<String, dynamic>? _categoryWiseReport;
  Map<String, dynamic>? _expiryReport;
  Map<String, dynamic>? _wasteReport;
  Map<String, dynamic>? _budgetReport;
  List<Map<String, dynamic>> _expenseHistory = [];
  List<Map<String, dynamic>> _consumptionPatterns = [];

  // Date range for reports
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  // Filters
  String _selectedCategory = 'All';
  String _reportType = 'monthly'; // monthly, weekly, yearly, custom

  // Getters
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  String? get error => _error;
  Map<String, dynamic>? get monthlyReport => _monthlyReport;
  Map<String, dynamic>? get categoryWiseReport => _categoryWiseReport;
  Map<String, dynamic>? get expiryReport => _expiryReport;
  Map<String, dynamic>? get wasteReport => _wasteReport;
  Map<String, dynamic>? get budgetReport => _budgetReport;
  List<Map<String, dynamic>> get expenseHistory => _expenseHistory;
  List<Map<String, dynamic>> get consumptionPatterns => _consumptionPatterns;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  String get selectedCategory => _selectedCategory;
  String get reportType => _reportType;

  /// Initialize reports provider
  Future<void> initialize() async {
    await loadAllReports();
  }

  /// Load all reports
  Future<void> loadAllReports() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load reports in parallel
      await Future.wait([
        _loadMonthlyReport(),
        _loadCategoryWiseReport(),
        _loadExpiryReport(),
        _loadWasteReport(),
        _loadBudgetReport(),
        _loadExpenseHistory(),
        _loadConsumptionPatterns(),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load reports:  ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading reports: $e');
    }
  }

  /// Load monthly expense report
  Future<void> _loadMonthlyReport() async {
    try {
      // TODO: Replace with actual API call when backend is ready
      // For now, use mock data or load from cache

      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('monthly_report');

      if (cachedData != null) {
        _monthlyReport = Map<String, dynamic>.from(jsonDecode(cachedData));
      } else {
        // Mock data for testing
        _monthlyReport = {
          'totalExpense': 0.0,
          'totalItems': 0,
          'avgExpensePerDay': 0.0,
          'expenseByCategory': {},
          'dailyExpenses': [],
          'topExpenses': [],
          'savingsAchieved': 0.0,
          'budgetUtilization': 0.0,
        };

        // Save mock data
        await prefs.setString('monthly_report', jsonEncode(_monthlyReport));
      }
    } catch (e) {
      debugPrint('Error loading monthly report:  $e');
      _monthlyReport = {
        'totalExpense': 0.0,
        'totalItems': 0,
        'avgExpensePerDay': 0.0,
        'expenseByCategory': {},
        'dailyExpenses': [],
        'topExpenses': [],
        'savingsAchieved': 0.0,
        'budgetUtilization': 0.0,
      };
    }
  }

  /// Load category-wise spending report
  Future<void> _loadCategoryWiseReport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('category_report');

      if (cachedData != null) {
        _categoryWiseReport = Map<String, dynamic>.from(jsonDecode(cachedData));
      } else {
        _categoryWiseReport = {
          'categories': [],
          'topCategory': {},
          'leastCategory': {},
          'percentageDistribution': {},
          'trends': [],
        };

        await prefs.setString(
            'category_report', jsonEncode(_categoryWiseReport));
      }
    } catch (e) {
      debugPrint('Error loading category report: $e');
      _categoryWiseReport = {
        'categories': [],
        'topCategory': {},
        'leastCategory': {},
        'percentageDistribution': {},
        'trends': [],
      };
    }
  }

  /// Load expiry and waste report
  Future<void> _loadExpiryReport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('expiry_report');

      if (cachedData != null) {
        _expiryReport = Map<String, dynamic>.from(jsonDecode(cachedData));
      } else {
        _expiryReport = {
          'expiringSoon': [],
          'expired': [],
          'totalWasteValue': 0.0,
          'wastePercentage': 0.0,
          'mostWastedCategory': '',
          'wasteReduction': 0.0,
        };

        await prefs.setString('expiry_report', jsonEncode(_expiryReport));
      }
    } catch (e) {
      debugPrint('Error loading expiry report: $e');
      _expiryReport = {
        'expiringSoon': [],
        'expired': [],
        'totalWasteValue': 0.0,
        'wastePercentage': 0.0,
        'mostWastedCategory': '',
        'wasteReduction': 0.0,
      };
    }
  }

  /// Load waste analysis report
  Future<void> _loadWasteReport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('waste_report');

      if (cachedData != null) {
        _wasteReport = Map<String, dynamic>.from(jsonDecode(cachedData));
      } else {
        _wasteReport = {
          'totalWastedItems': 0,
          'wasteByCategory': {},
          'monthlyWasteTrend': [],
          'recommendations': [],
          'potentialSavings': 0.0,
        };

        await prefs.setString('waste_report', jsonEncode(_wasteReport));
      }
    } catch (e) {
      debugPrint('Error loading waste report:  $e');
      _wasteReport = {
        'totalWastedItems': 0,
        'wasteByCategory': {},
        'monthlyWasteTrend': [],
        'recommendations': [],
        'potentialSavings': 0.0,
      };
    }
  }

  /// Load budget compliance report
  Future<void> _loadBudgetReport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('budget_report');

      if (cachedData != null) {
        _budgetReport = Map<String, dynamic>.from(jsonDecode(cachedData));
      } else {
        _budgetReport = {
          'totalBudget': 0.0,
          'spent': 0.0,
          'remaining': 0.0,
          'utilizationPercentage': 0.0,
          'overbudgetCategories': [],
          'underbudgetCategories': [],
          'projectedExpense': 0.0,
        };

        await prefs.setString('budget_report', jsonEncode(_budgetReport));
      }
    } catch (e) {
      debugPrint('Error loading budget report: $e');
      _budgetReport = {
        'totalBudget': 0.0,
        'spent': 0.0,
        'remaining': 0.0,
        'utilizationPercentage': 0.0,
        'overbudgetCategories': [],
        'underbudgetCategories': [],
        'projectedExpense': 0.0,
      };
    }
  }

  /// Load expense history
  Future<void> _loadExpenseHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('expense_history');

      if (cachedData != null) {
        final decoded = jsonDecode(cachedData);
        _expenseHistory = List<Map<String, dynamic>>.from(decoded);
      } else {
        _expenseHistory = [];
        await prefs.setString('expense_history', jsonEncode(_expenseHistory));
      }
    } catch (e) {
      debugPrint('Error loading expense history: $e');
      _expenseHistory = [];
    }
  }

  /// Load consumption patterns
  Future<void> _loadConsumptionPatterns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('consumption_patterns');

      if (cachedData != null) {
        final decoded = jsonDecode(cachedData);
        _consumptionPatterns = List<Map<String, dynamic>>.from(decoded);
      } else {
        _consumptionPatterns = [];
        await prefs.setString(
            'consumption_patterns', jsonEncode(_consumptionPatterns));
      }
    } catch (e) {
      debugPrint('Error loading consumption patterns: $e');
      _consumptionPatterns = [];
    }
  }

  /// Update date range
  void updateDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
    loadAllReports();
  }

  /// Set report type
  void setReportType(String type) {
    _reportType = type;

    final now = DateTime.now();
    switch (type) {
      case 'weekly':
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
        break;
      case 'monthly':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      case 'yearly':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = now;
        break;
      default:
        // Custom - no change
        break;
    }

    notifyListeners();
    loadAllReports();
  }

  /// Set selected category filter
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
    _loadExpenseHistory();
  }

  /// Export report as PDF
  Future<String?> exportReportAsPDF(String reportType) async {
    try {
      _isExporting = true;
      notifyListeners();

      // TODO: Implement PDF export when backend is ready
      await Future.delayed(const Duration(seconds: 2)); // Simulate export

      _isExporting = false;
      notifyListeners();

      return 'reports/${reportType}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    } catch (e) {
      _error = 'Failed to export report:  ${e.toString()}';
      _isExporting = false;
      notifyListeners();
      debugPrint('Error exporting report:  $e');
      return null;
    }
  }

  /// Export report as Excel
  Future<String?> exportReportAsExcel(String reportType) async {
    try {
      _isExporting = true;
      notifyListeners();

      // TODO: Implement Excel export when backend is ready
      await Future.delayed(const Duration(seconds: 2)); // Simulate export

      _isExporting = false;
      notifyListeners();

      return 'reports/${reportType}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    } catch (e) {
      _error = 'Failed to export report: ${e.toString()}';
      _isExporting = false;
      notifyListeners();
      debugPrint('Error exporting report:  $e');
      return null;
    }
  }

  /// Get expense summary
  Map<String, dynamic> getExpenseSummary() {
    if (_monthlyReport == null) return {};

    return {
      'total': _monthlyReport!['totalExpense'] ?? 0.0,
      'average': _monthlyReport!['avgExpensePerDay'] ?? 0.0,
      'highest': _getHighestExpense(),
      'lowest': _getLowestExpense(),
    };
  }

  /// Get highest expense day
  Map<String, dynamic> _getHighestExpense() {
    if (_monthlyReport == null || _monthlyReport!['dailyExpenses'] == null) {
      return {'date': '', 'amount': 0.0};
    }

    final dailyExpenses = List<Map<String, dynamic>>.from(
      _monthlyReport!['dailyExpenses'],
    );

    if (dailyExpenses.isEmpty) {
      return {'date': '', 'amount': 0.0};
    }

    return dailyExpenses.reduce(
      (a, b) => (a['amount'] ?? 0.0) > (b['amount'] ?? 0.0) ? a : b,
    );
  }

  /// Get lowest expense day
  Map<String, dynamic> _getLowestExpense() {
    if (_monthlyReport == null || _monthlyReport!['dailyExpenses'] == null) {
      return {'date': '', 'amount': 0.0};
    }

    final dailyExpenses = List<Map<String, dynamic>>.from(
      _monthlyReport!['dailyExpenses'],
    );

    if (dailyExpenses.isEmpty) {
      return {'date': '', 'amount': 0.0};
    }

    return dailyExpenses.reduce(
      (a, b) => (a['amount'] ?? 0.0) < (b['amount'] ?? 0.0) ? a : b,
    );
  }

  /// Get waste statistics
  Map<String, dynamic> getWasteStats() {
    if (_wasteReport == null) return {};

    return {
      'totalWasted': _wasteReport!['totalWastedItems'] ?? 0,
      'wasteValue': _expiryReport?['totalWasteValue'] ?? 0.0,
      'wastePercentage': _expiryReport?['wastePercentage'] ?? 0.0,
      'reduction': _expiryReport?['wasteReduction'] ?? 0.0,
    };
  }

  /// Get budget overview
  Map<String, dynamic> getBudgetOverview() {
    if (_budgetReport == null) return {};

    return {
      'total': _budgetReport!['totalBudget'] ?? 0.0,
      'spent': _budgetReport!['spent'] ?? 0.0,
      'remaining': _budgetReport!['remaining'] ?? 0.0,
      'percentage': _budgetReport!['utilizationPercentage'] ?? 0.0,
    };
  }

  /// Clear all cached reports
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('monthly_report');
      await prefs.remove('category_report');
      await prefs.remove('expiry_report');
      await prefs.remove('waste_report');
      await prefs.remove('budget_report');
      await prefs.remove('expense_history');
      await prefs.remove('consumption_patterns');

      _monthlyReport = null;
      _categoryWiseReport = null;
      _expiryReport = null;
      _wasteReport = null;
      _budgetReport = null;
      _expenseHistory = [];
      _consumptionPatterns = [];

      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cache:  $e');
    }
  }

  /// Refresh all reports
  Future<void> refresh() async {
    await clearCache();
    await loadAllReports();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Cleanup if needed
    super.dispose();
  }
}
