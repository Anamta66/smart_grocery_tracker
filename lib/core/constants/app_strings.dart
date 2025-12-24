// app_strings.dart - All text strings used in the application
// Centralized for easy localization and maintenance

/// AppStrings contains all static text used throughout the app
class AppStrings {
  AppStrings._();

  // App name and taglines
  static const String appName = 'Smart Grocery Tracker';
  static const String appTagline = 'Manage your groceries smartly';

  // Authentication strings
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String name = 'Full Name';
  static const String phone = 'Phone Number';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String selectRole = 'Select Your Role';
  static const String customer = 'Customer';
  static const String storeOwner = 'Store Owner';

  // Dashboard strings
  static const String dashboard = 'Dashboard';
  static const String welcomeBack = 'Welcome Back';
  static const String myGroceryList = 'My Grocery List';
  static const String expiringItems = 'Expiring Items';
  static const String totalItems = 'Total Items';
  static const String categories = 'Categories';

  // Grocery management strings
  static const String groceryList = 'Grocery List';
  static const String addGrocery = 'Add Grocery';
  static const String editGrocery = 'Edit Grocery';
  static const String deleteGrocery = 'Delete Grocery';
  static const String itemName = 'Item Name';
  static const String quantity = 'Quantity';
  static const String unit = 'Unit';
  static const String expiryDate = 'Expiry Date';
  static const String category = 'Category';
  static const String addVoice = 'Add by Voice';
  static const String speakNow = 'Speak now... ';
  static const String voiceExample = 'Example:  "Add milk, 2 liters"';

  // Inventory management strings (Store Owner)
  static const String inventory = 'Inventory';
  static const String addStock = 'Add Stock';
  static const String editStock = 'Edit Stock';
  static const String deleteStock = 'Delete Stock';
  static const String price = 'Price';
  static const String lowStockThreshold = 'Low Stock Alert At';
  static const String lowStockItems = 'Low Stock Items';
  static const String inStockItems = 'In Stock Items';
  static const String outOfStock = 'Out of Stock';

  // Expiry tracking strings
  static const String expiryTracking = 'Expiry Tracking';
  static const String expiringSoon = 'Expiring Soon';
  static const String expired = 'Expired';
  static const String fresh = 'Fresh';
  static const String daysLeft = 'days left';
  static const String daysAgo = 'days ago';

  // Notification strings
  static const String notifications = 'Notifications';
  static const String noNotifications = 'No notifications yet';
  static const String expiryAlert = 'Expiry Alert';
  static const String lowStockAlert = 'Low Stock Alert';
  static const String markAllRead = 'Mark All as Read';

  // Report strings
  static const String reports = 'Reports';
  static const String inventorySummary = 'Inventory Summary';
  static const String salesReport = 'Sales Report';
  static const String stockReport = 'Stock Report';
  static const String exportPDF = 'Export as PDF';
  static const String exportCSV = 'Export as CSV';

  // Category strings
  static const String manageCategories = 'Manage Categories';
  static const String addCategory = 'Add Category';
  static const String editCategory = 'Edit Category';
  static const String deleteCategory = 'Delete Category';
  static const String categoryName = 'Category Name';
  static const String fruits = 'Fruits';
  static const String vegetables = 'Vegetables';
  static const String dairy = 'Dairy';
  static const String bakery = 'Bakery';
  static const String meat = 'Meat';
  static const String beverages = 'Beverages';
  static const String grains = 'Grains';
  static const String frozen = 'Frozen';

  // Profile strings
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String settings = 'Settings';
  static const String darkMode = 'Dark Mode';
  static const String notificationSettings = 'Notification Settings';
  static const String language = 'Language';
  static const String about = 'About';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';

  // Action buttons
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String confirm = 'Confirm';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sortBy = 'Sort By';
  static const String apply = 'Apply';
  static const String reset = 'Reset';

  // Error messages
  static const String errorOccurred = 'An error occurred';
  static const String tryAgain = 'Please try again';
  static const String noInternet = 'No internet connection';
  static const String invalidEmail = 'Invalid email address';
  static const String invalidPassword =
      'Password must be at least 6 characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String fieldRequired = 'This field is required';
  static const String invalidQuantity = 'Invalid quantity';

  // Success messages
  static const String itemAdded = 'Item added successfully';
  static const String itemUpdated = 'Item updated successfully';
  static const String itemDeleted = 'Item deleted successfully';
  static const String profileUpdated = 'Profile updated successfully';
  static const String loginSuccess = 'Login successful';
  static const String signupSuccess = 'Account created successfully';

  // Empty states
  static const String noItems = 'No items found';
  static const String noGroceries = 'Your grocery list is empty';
  static const String noInventory = 'No inventory items';
  static const String startAdding = 'Start adding items! ';
}
