// lib/providers/reports_provider.dart

import 'package:flutter/foundation.dart';
import '../../domain/entities/grocery_item.dart';
import '../../data/models/category_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';

/// Provider for managing reports and analytics
/// Handles expense tracking, waste analysis, and consumption patterns
class ReportsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorage = LocalStorageService();

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
      final response = await _apiService.getMonthlyReport(
        startDate: _startDate,
        endDate: _endDate,
      );

      _monthlyReport = {
        'totalExpense': response['totalExpense'] ?? 0.0,
        'totalItems': response['totalItems'] ?? 0,
        'avgExpensePerDay': response['avgExpensePerDay'] ?? 0.0,
        'expenseByCategory': response['expenseByCategory'] ?? {},
        'dailyExpenses': response['dailyExpenses'] ?? [],
        'topExpenses': response['topExpenses'] ?? [],
        'savingsAchieved': response['savingsAchieved'] ?? 0.0,
        'budgetUtilization': response['budgetUtilization'] ?? 0.0,
      };

      // Cache locally
      await _localStorage.saveData('monthly_report', _monthlyReport!);
    } catch (e) {
      // Load from cache if API fails
      _monthlyReport = await _localStorage.getData('monthly_report');
      debugPrint('Error loading monthly report: $e');
    }
  }

  /// Load category-wise spending report
  Future<void> _loadCategoryWiseReport() async {
    try {
      final response = await _apiService.getCategoryWiseReport(
        startDate: _startDate,
        endDate: _endDate,
      );

      _categoryWiseReport = {
        'categories': response['categories'] ?? [],
        'topCategory': response['topCategory'] ?? {},
        'leastCategory': response['leastCategory'] ?? {},
        'percentageDistribution': response['percentageDistribution'] ?? {},
        'trends': response['trends'] ?? [],
      };

      await _localStorage.saveData('category_report', _categoryWiseReport!);
    } catch (e) {
      _categoryWiseReport = await _localStorage.getData('category_report');
      debugPrint('Error loading category report: $e');
    }
  }

  /// Load expiry and waste report
  Future<void> _loadExpiryReport() async {
    try {
      final response = await _apiService.getExpiryReport(
        startDate: _startDate,
        endDate: _endDate,
      );

      _expiryReport = {
        'expiringSoon': response['expiringSoon'] ?? [],
        'expired': response['expired'] ?? [],
        'totalWasteValue': response['totalWasteValue'] ?? 0.0,
        'wastePercentage': response['wastePercentage'] ?? 0.0,
        'mostWastedCategory': response['mostWastedCategory'] ?? '',
        'wasteReduction': response['wasteReduction'] ?? 0.0,
      };

      await _localStorage.saveData('expiry_report', _expiryReport!);
    } catch (e) {
      _expiryReport = await _localStorage.getData('expiry_report');
      debugPrint('Error loading expiry report: $e');
    }
  }

  /// Load waste analysis report
  Future<void> _loadWasteReport() async {
    try {
      final response = await _apiService.getWasteReport(
        startDate: _startDate,
        endDate: _endDate,
      );

      _wasteReport = {
        'totalWastedItems': response['totalWastedItems'] ?? 0,
        'wasteByCategory': response['wasteByCategory'] ?? {},
        'monthlyWasteTrend': response['monthlyWasteTrend'] ?? [],
        'recommendations': response['recommendations'] ?? [],
        'potentialSavings': response['potentialSavings'] ?? 0.0,
      };

      await _localStorage.saveData('waste_report', _wasteReport!);
    } catch (e) {
      _wasteReport = await _localStorage.getData('waste_report');
      debugPrint('Error loading waste report: $e');
    }
  }

  /// Load budget compliance report
  Future<void> _loadBudgetReport() async {
    try {
      final response = await _apiService.getBudgetReport(
        startDate: _startDate,
        endDate: _endDate,
      );

      _budgetReport = {
        'totalBudget': response['totalBudget'] ?? 0.0,
        'spent': response['spent'] ?? 0.0,
        'remaining': response['remaining'] ?? 0.0,
        'utilizationPercentage': response['utilizationPercentage'] ?? 0.0,
        'overbudgetCategories': response['overbudgetCategories'] ?? [],
        'underbudgetCategories': response['underbudgetCategories'] ?? [],
        'projectedExpense': response['projectedExpense'] ?? 0.0,
      };

      await _localStorage.saveData('budget_report', _budgetReport!);
    } catch (e) {
      _budgetReport = await _localStorage.getData('budget_report');
      debugPrint('Error loading budget report:  $e');
    }
  }

  /// Load expense history
  Future<void> _loadExpenseHistory() async {
    try {
      final response = await _apiService.getExpenseHistory(
        startDate: _startDate,
        endDate: _endDate,
        category: _selectedCategory != 'All' ? _selectedCategory : null,
      );

      _expenseHistory = List<Map<String, dynamic>>.from(
        response['history'] ?? [],
      );

      await _localStorage.saveData('expense_history', _expenseHistory);
    } catch (e) {
      final cached = await _localStorage.getData('expense_history');
      _expenseHistory =
          cached != null ? List<Map<String, dynamic>>.from(cached) : [];
      debugPrint('Error loading expense history: $e');
    }
  }

  /// Load consumption patterns
  Future<void> _loadConsumptionPatterns() async {
    try {
      final response = await _apiService.getConsumptionPatterns(
        startDate: _startDate,
        endDate: _endDate,
      );

      _consumptionPatterns = List<Map<String, dynamic>>.from(
        response['patterns'] ?? [],
      );

      await _localStorage.saveData(
          'consumption_patterns', _consumptionPatterns);
    } catch (e) {
      final cached = await _localStorage.getData('consumption_patterns');
      _consumptionPatterns =
          cached != null ? List<Map<String, dynamic>>.from(cached) : [];
      debugPrint('Error loading consumption patterns: $e');
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

      final response = await _apiService.exportReport(
        type: reportType,
        format: 'pdf',
        startDate: _startDate,
        endDate: _endDate,
      );

      _isExporting = false;
      notifyListeners();

      return response['filePath'];
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

      final response = await _apiService.exportReport(
        type: reportType,
        format: 'excel',
        startDate: _startDate,
        endDate: _endDate,
      );

      _isExporting = false;
      notifyListeners();

      return response['filePath'];
    } catch (e) {
      _error = 'Failed to export report: ${e.toString()}';
      _isExporting = false;
      notifyListeners();
      debugPrint('Error exporting report: $e');
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

    return dailyExpenses
        .reduce((a, b) => (a['amount'] ?? 0.0) > (b['amount'] ?? 0.0) ? a : b);
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

    return dailyExpenses
        .reduce((a, b) => (a['amount'] ?? 0.0) < (b['amount'] ?? 0.0) ? a : b);
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
    await _localStorage.deleteData('monthly_report');
    await _localStorage.deleteData('category_report');
    await _localStorage.deleteData('expiry_report');
    await _localStorage.deleteData('waste_report');
    await _localStorage.deleteData('budget_report');
    await _localStorage.deleteData('expense_history');
    await _localStorage.deleteData('consumption_patterns');

    _monthlyReport = null;
    _categoryWiseReport = null;
    _expiryReport = null;
    _wasteReport = null;
    _budgetReport = null;
    _expenseHistory = [];
    _consumptionPatterns = [];

    notifyListeners();
  }

  /// Refresh all reports
  Future<void> refresh() async {
    await clearCache();
    await loadAllReports();
  }

  @override
  void dispose() {
    // Cleanup if needed
    super.dispose();
  }
}
