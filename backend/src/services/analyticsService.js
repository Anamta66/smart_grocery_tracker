/**
 * ============================================
 * Analytics Service
 * ============================================
 * Handles analytics, reporting, and statistics
 * 
 * Features:
 * - Expense tracking and analysis
 * - Consumption patterns
 * - Waste analysis
 * - Category-wise spending
 * - Monthly/yearly reports
 * - Trend analysis
 * ============================================
 */

const Grocery = require('../models/Grocery');
const User = require('../models/User');
const mongoose = require('mongoose');

class AnalyticsService {
  /**
   * Get user dashboard statistics
   */
  async getDashboardStats(userId) {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const [
        totalItems,
        activeItems,
        expiredItems,
        expiringInWeek,
        lowStockItems,
        totalValue,
        categoryCounts
      ] = await Promise.all([
        // Total items count
        Grocery.countDocuments({ user: userId }),

        // Active items
        Grocery.countDocuments({ user: userId, status: 'active' }),

        // Expired items
        Grocery.countDocuments({
          user: userId,
          expiryDate: { $lt: today },
          status: { $in: ['active', 'expired'] }
        }),

        // Expiring within 7 days
        Grocery. countDocuments({
          user:  userId,
          expiryDate: {
            $gte: today,
            $lte: new Date(today. getTime() + 7 * 24 * 60 * 60 * 1000)
          },
          status: 'active'
        }),

        // Low stock items
        Grocery.countDocuments({
          user: userId,
          isLowStock: true,
          status: 'active'
        }),

        // Total inventory value
        Grocery.aggregate([
          { $match: { user: mongoose.Types.ObjectId(userId), status: 'active' } },
          {
            $group:  {
              _id: null,
              total: { $sum: { $multiply: ['$quantity', '$price'] } }
            }
          }
        ]),

        // Category distribution
        Grocery.aggregate([
          { $match: { user:  mongoose.Types.ObjectId(userId), status: 'active' } },
          {
            $group: {
              _id: '$category',
              count: { $sum: 1 },
              value: { $sum: { $multiply: ['$quantity', '$price'] } }
            }
          },
          {
            $lookup: {
              from: 'categories',
              localField: '_id',
              foreignField: '_id',
              as: 'categoryInfo'
            }
          },
          { $unwind: '$categoryInfo' },
          {
            $project: {
              category: '$categoryInfo.name',
              count: 1,
              value: 1
            }
          }
        ])
      ]);

      return {
        overview: {
          totalItems,
          activeItems,
          expiredItems,
          expiringInWeek,
          lowStockItems,
          totalValue:  totalValue[0]?.total || 0
        },
        categoryDistribution: categoryCounts,
        alerts: {
          critical: expiredItems,
          warning: expiringInWeek,
          info: lowStockItems
        }
      };
    } catch (error) {
      console.error('❌ Get dashboard stats error:', error);
      throw error;
    }
  }

  /**
   * Get expense report for a date range
   */
  async getExpenseReport(userId, startDate, endDate) {
    try {
      const expenses = await Grocery.aggregate([
        {
          $match: {
            user: mongoose. Types.ObjectId(userId),
            purchaseDate: {
              $gte: new Date(startDate),
              $lte: new Date(endDate)
            }
          }
        },
        {
          $group: {
            _id: {
              year: { $year: '$purchaseDate' },
              month: { $month: '$purchaseDate' },
              day: { $dayOfMonth: '$purchaseDate' }
            },
            totalExpense: { $sum: { $multiply: ['$quantity', '$price'] } },
            itemCount: { $sum: 1 }
          }
        },
        { $sort: { '_id.year': 1, '_id.month': 1, '_id.day': 1 } }
      ]);

      // Calculate totals
      const totalExpense = expenses.reduce((sum, day) => sum + day.totalExpense, 0);
      const totalItems = expenses.reduce((sum, day) => sum + day.itemCount, 0);
      const avgExpensePerDay = expenses.length > 0 ? totalExpense / expenses.length : 0;

      // Group by category
      const categoryExpenses = await Grocery.aggregate([
        {
          $match: {
            user: mongoose.Types.ObjectId(userId),
            purchaseDate: {
              $gte:  new Date(startDate),
              $lte: new Date(endDate)
            }
          }
        },
        {
          $group: {
            _id: '$category',
            totalExpense: { $sum: { $multiply: ['$quantity', '$price'] } },
            itemCount:  { $sum: 1 }
          }
        },
        {
          $lookup: {
            from: 'categories',
            localField: '_id',
            foreignField: '_id',
            as: 'categoryInfo'
          }
        },
        { $unwind: '$categoryInfo' },
        {
          $project: {
            category: '$categoryInfo.name',
            totalExpense: 1,
            itemCount: 1,
            percentage: {
              $multiply: [
                { $divide:  ['$totalExpense', totalExpense || 1] },
                100
              ]
            }
          }
        },
        { $sort: { totalExpense: -1 } }
      ]);

      return {
        period: {
          startDate,
          endDate,
          days: expenses.length
        },
        summary: {
          totalExpense:  parseFloat(totalExpense.toFixed(2)),
          totalItems,
          avgExpensePerDay:  parseFloat(avgExpensePerDay.toFixed(2))
        },
        dailyExpenses: expenses.map(e => ({
          date: `${e._id.year}-${String(e._id.month).padStart(2, '0')}-${String(e._id.day).padStart(2, '0')}`,
          amount: parseFloat(e.totalExpense. toFixed(2)),
          items: e.itemCount
        })),
        categoryExpenses: categoryExpenses.map(c => ({
          category: c. category,
          amount: parseFloat(c.totalExpense.toFixed(2)),
          items: c.itemCount,
          percentage: parseFloat(c.percentage.toFixed(2))
        }))
      };
    } catch (error) {
      console.error('❌ Get expense report error:', error);
      throw error;
    }
  }

  /**
   * Get waste analysis report
   */
  async getWasteAnalysis(userId, startDate, endDate) {
    try {
      const wastedItems = await Grocery.find({
        user: userId,
        status: { $in: ['expired', 'wasted'] },
        updatedAt: {
          $gte: new Date(startDate),
          $lte: new Date(endDate)
        }
      }).populate('category');

      // Calculate waste statistics
      const totalWastedItems = wastedItems.length;
      const totalWasteValue = wastedItems.reduce(
        (sum, item) => sum + (item.quantity * item.price),
        0
      );

      // Group by category
      const wasteByCategory = {};
      wastedItems.forEach(item => {
        const categoryName = item.category?. name || 'Uncategorized';
        if (! wasteByCategory[categoryName]) {
          wasteByCategory[categoryName] = {
            count: 0,
            value:  0,
            items: []
          };
        }
        wasteByCategory[categoryName]. count++;
        wasteByCategory[categoryName].value += item. quantity * item.price;
        wasteByCategory[categoryName]. items.push({
          name: item.name,
          quantity: item.quantity,
          value: item.quantity * item.price,
          expiryDate: item.expiryDate
        });
      });

      // Calculate waste percentage
      const totalItems = await Grocery.countDocuments({
        user: userId,
        createdAt: {
          $gte: new Date(startDate),
          $lte: new Date(endDate)
        }
      });

      const wastePercentage = totalItems > 0 
        ? (totalWastedItems / totalItems) * 100 
        : 0;

      // Top wasted categories
      const topWastedCategories = Object.entries(wasteByCategory)
        .map(([category, data]) => ({
          category,
          count:  data.count,
          value: parseFloat(data.value.toFixed(2))
        }))
        .sort((a, b) => b.value - a.value)
        .slice(0, 5);

      // Recommendations
      const recommendations = this.generateWasteRecommendations(wasteByCategory);

      return {
        period: {
          startDate,
          endDate
        },
        summary: {
          totalWastedItems,
          totalWasteValue:  parseFloat(totalWasteValue.toFixed(2)),
          wastePercentage:  parseFloat(wastePercentage. toFixed(2))
        },
        wasteByCategory,
        topWastedCategories,
        recommendations,
        potentialSavings: parseFloat(totalWasteValue.toFixed(2))
      };
    } catch (error) {
      console.error('❌ Get waste analysis error:', error);
      throw error;
    }
  }

  /**
   * Generate waste reduction recommendations
   */
  generateWasteRecommendations(wasteByCategory) {
    const recommendations = [];

    Object.entries(wasteByCategory).forEach(([category, data]) => {
      if (data.count >= 3) {
        recommendations.push({
          category,
          issue: `High waste in ${category} category`,
          recommendation: `Consider buying smaller quantities of ${category} items or planning meals better`,
          impact: 'high'
        });
      }

      if (data.value > 50) {
        recommendations.push({
          category,
          issue: `Significant financial loss in ${category}`,
          recommendation: `Review purchase frequency and storage methods for ${category} items`,
          impact: 'high'
        });
      }
    });

    if (recommendations.length === 0) {
      recommendations.push({
        category: 'General',
        issue: 'Low waste levels',
        recommendation: 'Keep up the good work! Continue monitoring expiry dates.',
        impact: 'positive'
      });
    }

    return recommendations;
  }

  /**
   * Get consumption patterns
   */
  async getConsumptionPatterns(userId, days = 30) {
    try {
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      const consumedItems = await Grocery.find({
        user: userId,
        status: 'consumed',
        consumedAt: { $gte:  startDate }
      }).populate('category');

      // Group by category
      const consumptionByCategory = {};
      consumedItems.forEach(item => {
        const categoryName = item. category?.name || 'Uncategorized';
        if (!consumptionByCategory[categoryName]) {
          consumptionByCategory[categoryName] = {
            count: 0,
            totalQuantity: 0,
            items: []
          };
        }
        consumptionByCategory[categoryName].count++;
        consumptionByCategory[categoryName]. totalQuantity += item.quantity;
        consumptionByCategory[categoryName].items.push(item. name);
      });

      // Calculate consumption rate
      const avgItemsPerDay = consumedItems. length / days;

      // Find most consumed items
      const itemCounts = {};
      consumedItems.forEach(item => {
        itemCounts[item.name] = (itemCounts[item.name] || 0) + 1;
      });

      const topConsumedItems = Object.entries(itemCounts)
        .map(([name, count]) => ({ name, count }))
        .sort((a, b) => b.count - a.count)
        .slice(0, 10);

      return {
        period: {
          days,
          startDate,
          endDate: new Date()
        },
        summary: {
          totalConsumed: consumedItems.length,
          avgItemsPerDay: parseFloat(avgItemsPerDay.toFixed(2))
        },
        consumptionByCategory,
        topConsumedItems,
        insights: this.generateConsumptionInsights(consumptionByCategory, avgItemsPerDay)
      };
    } catch (error) {
      console.error('❌ Get consumption patterns error:', error);
      throw error;
    }
  }

  /**
   * Generate consumption insights
   */
  generateConsumptionInsights(consumptionByCategory, avgItemsPerDay) {
    const insights = [];

    // Find top category
    const topCategory = Object.entries(consumptionByCategory)
      .sort((a, b) => b[1].count - a[1]. count)[0];

    if (topCategory) {
      insights.push({
        type: 'top_category',
        message: `You consume ${topCategory[0]} items most frequently (${topCategory[1].count} items)`,
        category: topCategory[0]
      });
    }

    // Consumption rate insight
    if (avgItemsPerDay > 5) {
      insights.push({
        type: 'high_consumption',
        message: `High consumption rate: ${avgItemsPerDay.toFixed(1)} items per day`,
        suggestion: 'Consider bulk buying frequently used items'
      });
    } else if (avgItemsPerDay < 1) {
      insights.push({
        type: 'low_consumption',
        message: 'Low consumption rate detected',
        suggestion: 'You might be over-purchasing.  Buy smaller quantities.'
      });
    }

    return insights;
  }

  /**
   * Get monthly trend analysis
   */
  async getMonthlyTrends(userId, months = 6) {
    try {
      const startDate = new Date();
      startDate.setMonth(startDate.getMonth() - months);

      const trends = await Grocery.aggregate([
        {
          $match: {
            user: mongoose. Types.ObjectId(userId),
            createdAt: { $gte:  startDate }
          }
        },
        {
          $group: {
            _id: {
              year: { $year: '$createdAt' },
              month: { $month: '$createdAt' }
            },
            itemsAdded: { $sum: 1 },
            totalValue:  { $sum: { $multiply:  ['$quantity', '$price'] } },
            avgPrice: { $avg: '$price' }
          }
        },
        { $sort: { '_id.year': 1, '_id.month': 1 } }
      ]);

      // Format data for charts
      const monthlyData = trends.map(t => ({
        month: `${t._id.year}-${String(t._id.month).padStart(2, '0')}`,
        itemsAdded: t.itemsAdded,
        totalValue: parseFloat(t.totalValue.toFixed(2)),
        avgPrice: parseFloat(t.avgPrice.toFixed(2))
      }));

      // Calculate trends
      const isIncreasing = trends.length >= 2 &&
        trends[trends.length - 1].totalValue > trends[0].totalValue;

      return {
        period: {
          months,
          startDate,
          endDate: new Date()
        },
        monthlyData,
        trend: {
          direction: isIncreasing ? 'increasing' : 'decreasing',
          message: isIncreasing 
            ? 'Your grocery spending is increasing over time'
            : 'Your grocery spending is decreasing over time'
        }
      };
    } catch (error) {
      console.error('❌ Get monthly trends error:', error);
      throw error;
    }
  }

  /**
   * Get category-wise spending report
   */
  async getCategorySpendingReport(userId, startDate, endDate) {
    try {
      const report = await Grocery.aggregate([
        {
          $match: {
            user: mongoose.Types.ObjectId(userId),
            purchaseDate:  {
              $gte: new Date(startDate),
              $lte: new Date(endDate)
            }
          }
        },
        {
          $group: {
            _id:  '$category',
            totalSpent: { $sum: { $multiply: ['$quantity', '$price'] } },
            itemCount: { $sum: 1 },
            avgItemPrice: { $avg: '$price' },
            totalQuantity: { $sum: '$quantity' }
          }
        },
        {
          $lookup:  {
            from: 'categories',
            localField: '_id',
            foreignField: '_id',
            as: 'categoryInfo'
          }
        },
        { $unwind: '$categoryInfo' },
        {
          $project: {
            category: '$categoryInfo.name',
            icon: '$categoryInfo.icon',
            color: '$categoryInfo.color',
            totalSpent: 1,
            itemCount: 1,
            avgItemPrice:  1,
            totalQuantity: 1
          }
        },
        { $sort: { totalSpent: -1 } }
      ]);

      const totalSpending = report.reduce((sum, cat) => sum + cat.totalSpent, 0);

      // Add percentage
      const reportWithPercentage = report.map(cat => ({
        ...cat,
        totalSpent: parseFloat(cat. totalSpent.toFixed(2)),
        avgItemPrice: parseFloat(cat. avgItemPrice.toFixed(2)),
        percentage: parseFloat(((cat.totalSpent / totalSpending) * 100).toFixed(2))
      }));

      return {
        period:  {
          startDate,
          endDate
        },
        totalSpending:  parseFloat(totalSpending.toFixed(2)),
        categories: reportWithPercentage
      };
    } catch (error) {
      console.error('❌ Get category spending report error:', error);
      throw error;
    }
  }

  /**
   * Export report data (CSV format)
   */
  async exportReport(userId, reportType, startDate, endDate) {
    try {
      let data;

      switch (reportType) {
        case 'expense':
          data = await this. getExpenseReport(userId, startDate, endDate);
          break;
        case 'waste':
          data = await this. getWasteAnalysis(userId, startDate, endDate);
          break;
        case 'consumption':
          data = await this.getConsumptionPatterns(userId, 30);
          break;
        default:
          throw new Error('Invalid report type');
      }

      // Convert to CSV (simplified)
      const csv = this.convertToCSV(data);

      return {
        success: true,
        data: csv,
        filename: `${reportType}_report_${Date.now()}.csv`,
        contentType: 'text/csv'
      };
    } catch (error) {
      console.error('❌ Export report error:', error);
      throw error;
    }
  }

  /**
   * Convert data to CSV format
   */
  convertToCSV(data) {
    // Simplified CSV conversion
    // In production, use a proper CSV library like 'csv-writer'
    const headers = Object.keys(data).join(',');
    const values = Object.values(data).join(',');
    return `${headers}\n${values}`;
  }
}

module.exports = new AnalyticsService();