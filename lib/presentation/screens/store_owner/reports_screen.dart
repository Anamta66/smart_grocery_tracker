import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/reports_provider.dart';

/// Reports and Analytics Screen for Store Owners
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'Month'; // Week, Month, Year

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReports();
    });
  }

  void _loadReports() {
    final provider = context.read<ReportsProvider>();
    switch (_selectedPeriod) {
      case 'Week':
        provider.setReportType('weekly');
        break;
      case 'Month':
        provider.setReportType('monthly');
        break;
      case 'Year':
        provider.setReportType('yearly');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Reports & Analytics'),
        elevation: 0,
        actions: [
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ReportsProvider>().refresh();
            },
          ),
        ],
      ),
      body: Consumer<ReportsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Period Selector
              _buildPeriodSelector(),
              const SizedBox(height: 24),

              // Summary Cards
              _buildSummaryCards(provider),
              const SizedBox(height: 24),

              // Sales Chart
              _buildSalesChart(provider),
              const SizedBox(height: 24),

              // Top Selling Items
              _buildTopSellingItems(provider),
              const SizedBox(height: 24),

              // Low Stock Alerts
              _buildLowStockAlerts(provider),
            ],
          );
        },
      ),
    );
  }

  /// Period Selector (Week / Month / Year)
  Widget _buildPeriodSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'Week', label: Text('Week')),
        ButtonSegment(value: 'Month', label: Text('Month')),
        ButtonSegment(value: 'Year', label: Text('Year')),
      ],
      selected: {_selectedPeriod},
      onSelectionChanged: (Set<String> selected) {
        setState(() {
          _selectedPeriod = selected.first;
        });
        _loadReports();
      },
    );
  }

  /// Summary Cards (Revenue, Orders, Items Sold)
  Widget _buildSummaryCards(ReportsProvider provider) {
    final theme = Theme.of(context);
    final monthlyData = provider.monthlyReport ?? {};

    // Extract data from monthly report
    final totalRevenue = (monthlyData['totalExpense'] ?? 0.0) as double;
    final totalItems = (monthlyData['totalItems'] ?? 0) as int;
    final avgExpense = (monthlyData['avgExpensePerDay'] ?? 0.0) as double;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.attach_money,
            label: 'Revenue',
            value: '\$${totalRevenue.toStringAsFixed(0)}',
            color: Colors.green,
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.shopping_cart,
            label: 'Items',
            value: totalItems.toString(),
            color: theme.colorScheme.primary,
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            label: 'Avg/Day',
            value: '\$${avgExpense.toStringAsFixed(0)}',
            color: Colors.orange,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  /// Sales Chart
  Widget _buildSalesChart(ReportsProvider provider) {
    final theme = Theme.of(context);
    final monthlyData = provider.monthlyReport ?? {};
    final dailyExpenses = (monthlyData['dailyExpenses'] ?? []) as List;

    // Convert daily expenses to chart data
    List<double> salesData = [];
    if (dailyExpenses.isNotEmpty) {
      for (var expense in dailyExpenses) {
        salesData.add((expense['amount'] ?? 0.0).toDouble());
      }
    } else {
      // Mock data if no data available
      salesData = [120, 180, 150, 200, 170, 220, 190];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Trend',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < labels.length) {
                          return Text(
                            labels[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: salesData
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Top Selling Items
  Widget _buildTopSellingItems(ReportsProvider provider) {
    final theme = Theme.of(context);
    final monthlyData = provider.monthlyReport ?? {};
    final topExpenses = (monthlyData['topExpenses'] ?? []) as List;

    // Convert to proper format or use mock data
    final List<TopSellingItem> items = [];

    if (topExpenses.isNotEmpty) {
      for (var item in topExpenses.take(5)) {
        items.add(TopSellingItem(
          name: item['name'] ?? 'Unknown',
          soldQuantity: item['quantity'] ?? 0,
          revenue: (item['amount'] ?? 0.0).toDouble(),
        ));
      }
    } else {
      // Mock data
      items.addAll([
        TopSellingItem(name: 'Milk', soldQuantity: 45, revenue: 135.0),
        TopSellingItem(name: 'Bread', soldQuantity: 38, revenue: 76.0),
        TopSellingItem(name: 'Eggs', soldQuantity: 32, revenue: 96.0),
      ]);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Selling Items',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('No data available'),
              ),
            )
          else
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.shopping_bag,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${item.soldQuantity} sold',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${item.revenue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  /// Low Stock Alerts
  Widget _buildLowStockAlerts(ReportsProvider provider) {
    final theme = Theme.of(context);
    final expiryData = provider.expiryReport ?? {};
    final expiringSoon = (expiryData['expiringSoon'] ?? []) as List;

    // Convert to proper format or use mock data
    final List<LowStockItem> items = [];

    if (expiringSoon.isNotEmpty) {
      for (var item in expiringSoon.take(5)) {
        items.add(LowStockItem(
          name: item['name'] ?? 'Unknown',
          quantity: item['quantity'] ?? 0,
        ));
      }
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Text(
                'Low Stock Alerts',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    '${item.quantity} left',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Helper classes for data models
class TopSellingItem {
  final String name;
  final int soldQuantity;
  final double revenue;

  TopSellingItem({
    required this.name,
    required this.soldQuantity,
    required this.revenue,
  });
}

class LowStockItem {
  final String name;
  final int quantity;

  LowStockItem({
    required this.name,
    required this.quantity,
  });
}
