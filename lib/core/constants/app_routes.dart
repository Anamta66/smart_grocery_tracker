// app_routes.dart - Centralized route definitions for navigation
// All named routes are defined here for type-safe navigation

/// AppRoutes contains all route names used in the application
class AppRoutes {
  AppRoutes._();

  // Initial routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';

  // Customer routes
  static const String customerDashboard = '/customer/dashboard';
  static const String groceryList = '/customer/grocery-list';
  static const String addEditGrocery = '/customer/add-edit-grocery';
  static const String expiryTracking = '/customer/expiry-tracking';
  static const String customerProfile = '/customer/profile';

  // Store Owner routes
  static const String storeOwnerDashboard = '/store-owner/dashboard';
  static const String inventory = '/store-owner/inventory';
  static const String addEditInventory = '/store-owner/add-edit-inventory';
  static const String reports = '/store-owner/reports';
  static const String storeOwnerProfile = '/store-owner/profile';

  // Common routes (accessible by both roles)
  static const String categoryManagement = '/category-management';
  static const String notifications = '/notifications';
  static const String searchFilter = '/search-filter';
  static const String settings = '/settings';
}
