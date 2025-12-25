// main.dart - Entry point of the Smart Grocery Tracker App
// This file initializes the app with providers for state management,
// sets up theming, and configures routing.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_routes.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/grocery_provider.dart';
import 'presentation/providers/inventory_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/customer/customer_dashboard.dart';
import 'presentation/screens/customer/grocery_list_screen.dart';
import 'presentation/screens/customer/add_edit_grocery_screen.dart';
import 'presentation/screens/customer/expiry_tracking_screen.dart';
import 'presentation/screens/customer/customer_profile_screen.dart';
import 'presentation/screens/store_owner/store_owner_dashboard.dart';
import 'presentation/screens/store_owner/inventory_screen.dart';
import 'presentation/screens/store_owner/add_edit_inventory_screen.dart';
import 'presentation/screens/store_owner/reports_screen.dart';
import 'presentation/screens/store_owner/store_owner_profile_screen.dart';
import 'presentation/screens/common/category_management_screen.dart';
import 'presentation/screens/common/notifications_screen.dart';
import 'presentation/screens/common/search_filter_screen.dart';
import 'presentation/screens/common/settings_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized before running app
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database for scheduling notifications
  tz.initializeTimeZones();
  // Set preferred orientations to portrait only for consistent UI
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SmartGroceryTrackerApp());
}

/// Main application widget that sets up providers and theme
class SmartGroceryTrackerApp extends StatelessWidget {
  const SmartGroceryTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider wraps the app to provide state management across all screens
    return MultiProvider(
      providers: [
        // Theme provider for dark/light mode switching
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // Authentication provider for login/logout state
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Grocery provider for customer grocery list management
        ChangeNotifierProvider(create: (_) => GroceryProvider()),

        // Inventory provider for store owner stock management
        ChangeNotifierProvider(create: (_) => InventoryProvider()),

        // Notification provider for expiry and low-stock alerts
        ChangeNotifierProvider(create: (_) => NotificationProvider()),

        // Category provider for grocery categorization
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Smart Grocery Tracker',
            debugShowCheckedModeBanner: false,

            // Apply light or dark theme based on user preference
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Start with splash screen
            initialRoute: AppRoutes.splash,

            // Define all application routes
            routes: {
              AppRoutes.splash: (context) => const SplashScreen(),
              AppRoutes.login: (context) => const LoginScreen(),
              AppRoutes.signup: (context) => const SignupScreen(),
              AppRoutes.customerDashboard: (context) =>
                  const CustomerDashboard(),
              AppRoutes.groceryList: (context) => const GroceryListScreen(),
              AppRoutes.addEditGrocery: (context) =>
                  const AddEditGroceryScreen(),
              AppRoutes.expiryTracking: (context) =>
                  const ExpiryTrackingScreen(),
              AppRoutes.customerProfile: (context) =>
                  const CustomerProfileScreen(),
              AppRoutes.storeOwnerDashboard: (context) =>
                  const StoreOwnerDashboard(),
              AppRoutes.inventory: (context) => const InventoryScreen(),
              AppRoutes.addEditInventory: (context) =>
                  const AddEditInventoryScreen(),
              AppRoutes.reports: (context) => const ReportsScreen(),
              AppRoutes.storeOwnerProfile: (context) =>
                  const StoreOwnerProfileScreen(),
              AppRoutes.categoryManagement: (context) =>
                  const CategoryManagementScreen(),
              AppRoutes.notifications: (context) => const NotificationsScreen(),
              AppRoutes.searchFilter: (context) => const SearchFilterScreen(),
              AppRoutes.settings: (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
