import 'package:flutter/foundation.dart';

/// Enum representing the type of report
enum ReportType {
  dailySummary,
  weeklySummary,
  monthlySummary,
  expiryReport,
  spendingReport,
  consumptionReport,
  wasteReport,
  shoppingTrends,
  categoryBreakdown,
  custom,
}

/// Enum representing the time period for reports
enum ReportPeriod {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  last3Months,
  last6Months,
  thisYear,
  lastYear,
  custom,
}

/// Extension to get display names for ReportType
extension ReportTypeExtension on ReportType {
  String get displayName {
    switch (this) {
      case ReportType.dailySummary:
        return 'Daily Summary';
      case ReportType.weeklySummary:
        return 'Weekly Summary';
      case ReportType.monthlySummary:
        return 'Monthly Summary';
      case ReportType.expiryReport:
        return 'Expiry Report';
      case ReportType.spendingReport:
        return 'Spending Report';
      case ReportType.consumptionReport:
        return 'Consumption Report';
      case ReportType.wasteReport:
        return 'Waste Report';
      case ReportType.shoppingTrends:
        return 'Shopping Trends';
      case ReportType.categoryBreakdown:
        return 'Category Breakdown';
      case ReportType.custom:
        return 'Custom Report';
    }
  }

  String get description {
    switch (this) {
      case ReportType.dailySummary:
        return 'Overview of daily grocery activities';
      case ReportType.weeklySummary:
        return 'Weekly grocery management summary';
      case ReportType.monthlySummary:
        return 'Monthly grocery insights and statistics';
      case ReportType.expiryReport:
        return 'Items approaching or past expiry date';
      case ReportType.spendingReport:
        return 'Analysis of grocery spending';
      case ReportType.consumptionReport:
        return 'Tracking of item consumption patterns';
      case ReportType.wasteReport:
        return 'Report on expired and wasted items';
      case ReportType.shoppingTrends:
        return 'Analysis of shopping patterns';
      case ReportType.categoryBreakdown:
        return 'Spending and consumption by category';
      case ReportType.custom:
        return 'Custom report with selected metrics';
    }
  }
}

/// Model for category statistics in reports
@immutable
class CategoryStatistic {
  final String categoryId;
  final String categoryName;
  final int itemCount;
  final double totalSpent;
  final double percentageOfTotal;

  const CategoryStatistic({
    required this.categoryId,
    required this.categoryName,
    required this.itemCount,
    required this.totalSpent,
    required this.percentageOfTotal,
  });

  factory CategoryStatistic.fromJson(Map<String, dynamic> json) {
    return CategoryStatistic(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      itemCount: json['itemCount'] as int,
      totalSpent: (json['totalSpent'] as num).toDouble(),
      percentageOfTotal: (json['percentageOfTotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'itemCount': itemCount,
      'totalSpent': totalSpent,
      'percentageOfTotal': percentageOfTotal,
    };
  }
}

/// Model for daily spending data in reports
@immutable
class DailySpending {
  final DateTime date;
  final double amount;
  final int itemsPurchased;

  const DailySpending({
    required this.date,
    required this.amount,
    required this.itemsPurchased,
  });

  factory DailySpending.fromJson(Map<String, dynamic> json) {
    return DailySpending(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      itemsPurchased: json['itemsPurchased'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'itemsPurchased': itemsPurchased,
    };
  }
}

/// Model for expiry statistics
@immutable
class ExpiryStatistic {
  final int expiredCount;
  final int expiringSoonCount;
  final int expiringThisWeek;
  final int expiringThisMonth;
  final double potentialWasteValue;

  const ExpiryStatistic({
    required this.expiredCount,
    required this.expiringSoonCount,
    required this.expiringThisWeek,
    required this.expiringThisMonth,
    required this.potentialWasteValue,
  });

  factory ExpiryStatistic.fromJson(Map<String, dynamic> json) {
    return ExpiryStatistic(
      expiredCount: json['expiredCount'] as int,
      expiringSoonCount: json['expiringSoonCount'] as int,
      expiringThisWeek: json['expiringThisWeek'] as int,
      expiringThisMonth: json['expiringThisMonth'] as int,
      potentialWasteValue: (json['potentialWasteValue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expiredCount': expiredCount,
      'expiringSoonCount': expiringSoonCount,
      'expiringThisWeek': expiringThisWeek,
      'expiringThisMonth': expiringThisMonth,
      'potentialWasteValue': potentialWasteValue,
    };
  }
}

/// Main report model containing all report data
///
/// This comprehensive model handles various types of reports including:
/// - Spending analysis
/// - Consumption patterns
/// - Expiry tracking
/// - Category breakdowns
/// - Shopping trends
@immutable
class ReportModel {
  /// Unique identifier for the report
  final String id;

  /// Type of report
  final ReportType type;

  /// Title of the report
  final String title;

  /// Description of the report
  final String? description;

  /// User ID who owns this report
  final String userId;

  /// Start date of the report period
  final DateTime startDate;

  /// End date of the report period
  final DateTime endDate;

  /// Date when the report was generated
  final DateTime generatedAt;

  // Summary Statistics
  /// Total amount spent during the period
  final double totalSpent;

  /// Total number of items purchased
  final int totalItemsPurchased;

  /// Total number of shopping trips
  final int totalShoppingTrips;

  /// Average spending per shopping trip
  final double averageSpendingPerTrip;

  /// Budget for the period (if set)
  final double? budget;

  /// Amount saved from estimated prices
  final double? savings;

  // Detailed Statistics
  /// Category-wise breakdown
  final List<CategoryStatistic> categoryBreakdown;

  /// Daily spending data for charts
  final List<DailySpending> dailySpending;

  /// Expiry-related statistics
  final ExpiryStatistic? expiryStats;

  // Top Items
  /// Most frequently purchased items
  final List<String> topPurchasedItems;

  /// Most expensive items
  final List<String> topExpensiveItems;

  // Waste Statistics
  /// Number of items wasted (expired before use)
  final int? itemsWasted;

  /// Value of wasted items
  final double? wasteValue;

  // Comparison Data
  /// Percentage change in spending from previous period
  final double? spendingChangePercent;

  /// Percentage change in items purchased from previous period
  final double? itemsChangePercent;

  /// Notes or insights
  final String? insights;

  /// Constructor for ReportModel
  const ReportModel({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    this.totalSpent = 0,
    this.totalItemsPurchased = 0,
    this.totalShoppingTrips = 0,
    this.averageSpendingPerTrip = 0,
    this.budget,
    this.savings,
    this.categoryBreakdown = const [],
    this.dailySpending = const [],
    this.expiryStats,
    this.topPurchasedItems = const [],
    this.topExpensiveItems = const [],
    this.itemsWasted,
    this.wasteValue,
    this.spendingChangePercent,
    this.itemsChangePercent,
    this.insights,
  });

  /// Get the report period duration in days
  int get periodDays => endDate.difference(startDate).inDays + 1;

  /// Get average daily spending
  double get averageDailySpending =>
      periodDays > 0 ? totalSpent / periodDays : 0;

  /// Check if over budget
  bool get isOverBudget => budget != null && totalSpent > budget!;

  /// Get budget utilization percentage
  double? get budgetUtilization =>
      budget != null && budget! > 0 ? (totalSpent / budget!) * 100 : null;

  /// Get formatted total spent
  String get formattedTotalSpent => '\$${totalSpent.toStringAsFixed(2)}';

  /// Get formatted budget
  String? get formattedBudget =>
      budget != null ? '\$${budget!.toStringAsFixed(2)}' : null;

  /// Get formatted savings
  String? get formattedSavings =>
      savings != null ? '\$${savings!.toStringAsFixed(2)}' : null;

  /// Create a copy with updated fields
  ReportModel copyWith({
    String? id,
    ReportType? type,
    String? title,
    String? description,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? generatedAt,
    double? totalSpent,
    int? totalItemsPurchased,
    int? totalShoppingTrips,
    double? averageSpendingPerTrip,
    double? budget,
    double? savings,
    List<CategoryStatistic>? categoryBreakdown,
    List<DailySpending>? dailySpending,
    ExpiryStatistic? expiryStats,
    List<String>? topPurchasedItems,
    List<String>? topExpensiveItems,
    int? itemsWasted,
    double? wasteValue,
    double? spendingChangePercent,
    double? itemsChangePercent,
    String? insights,
  }) {
    return ReportModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      generatedAt: generatedAt ?? this.generatedAt,
      totalSpent: totalSpent ?? this.totalSpent,
      totalItemsPurchased: totalItemsPurchased ?? this.totalItemsPurchased,
      totalShoppingTrips: totalShoppingTrips ?? this.totalShoppingTrips,
      averageSpendingPerTrip:
          averageSpendingPerTrip ?? this.averageSpendingPerTrip,
      budget: budget ?? this.budget,
      savings: savings ?? this.savings,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      dailySpending: dailySpending ?? this.dailySpending,
      expiryStats: expiryStats ?? this.expiryStats,
      topPurchasedItems: topPurchasedItems ?? this.topPurchasedItems,
      topExpensiveItems: topExpensiveItems ?? this.topExpensiveItems,
      itemsWasted: itemsWasted ?? this.itemsWasted,
      wasteValue: wasteValue ?? this.wasteValue,
      spendingChangePercent:
          spendingChangePercent ?? this.spendingChangePercent,
      itemsChangePercent: itemsChangePercent ?? this.itemsChangePercent,
      insights: insights ?? this.insights,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'generatedAt': generatedAt.toIso8601String(),
      'totalSpent': totalSpent,
      'totalItemsPurchased': totalItemsPurchased,
      'totalShoppingTrips': totalShoppingTrips,
      'averageSpendingPerTrip': averageSpendingPerTrip,
      'budget': budget,
      'savings': savings,
      'categoryBreakdown': categoryBreakdown.map((e) => e.toJson()).toList(),
      'dailySpending': dailySpending.map((e) => e.toJson()).toList(),
      'expiryStats': expiryStats?.toJson(),
      'topPurchasedItems': topPurchasedItems,
      'topExpensiveItems': topExpensiveItems,
      'itemsWasted': itemsWasted,
      'wasteValue': wasteValue,
      'spendingChangePercent': spendingChangePercent,
      'itemsChangePercent': itemsChangePercent,
      'insights': insights,
    };
  }

  /// Create model from JSON
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      type: ReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReportType.custom,
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      userId: json['userId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0,
      totalItemsPurchased: json['totalItemsPurchased'] as int? ?? 0,
      totalShoppingTrips: json['totalShoppingTrips'] as int? ?? 0,
      averageSpendingPerTrip:
          (json['averageSpendingPerTrip'] as num?)?.toDouble() ?? 0,
      budget: (json['budget'] as num?)?.toDouble(),
      savings: (json['savings'] as num?)?.toDouble(),
      categoryBreakdown:
          (json['categoryBreakdown'] as List<dynamic>?)
              ?.map(
                (e) => CategoryStatistic.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      dailySpending:
          (json['dailySpending'] as List<dynamic>?)
              ?.map((e) => DailySpending.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      expiryStats: json['expiryStats'] != null
          ? ExpiryStatistic.fromJson(
              json['expiryStats'] as Map<String, dynamic>,
            )
          : null,
      topPurchasedItems:
          (json['topPurchasedItems'] as List<dynamic>?)?.cast<String>() ?? [],
      topExpensiveItems:
          (json['topExpensiveItems'] as List<dynamic>?)?.cast<String>() ?? [],
      itemsWasted: json['itemsWasted'] as int?,
      wasteValue: (json['wasteValue'] as num?)?.toDouble(),
      spendingChangePercent: (json['spendingChangePercent'] as num?)
          ?.toDouble(),
      itemsChangePercent: (json['itemsChangePercent'] as num?)?.toDouble(),
      insights: json['insights'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReportModel(id: $id, type: ${type.displayName}, '
        'period: $startDate - $endDate, totalSpent: $formattedTotalSpent)';
  }
}
