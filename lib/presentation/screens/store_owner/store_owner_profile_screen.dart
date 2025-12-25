// lib/presentation/screens/store_owner/store_owner_profile_screen. dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Store Owner Profile Screen
class StoreOwnerProfileScreen extends StatefulWidget {
  const StoreOwnerProfileScreen({super.key});

  @override
  State<StoreOwnerProfileScreen> createState() =>
      _StoreOwnerProfileScreenState();
}

class _StoreOwnerProfileScreenState extends State<StoreOwnerProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh user data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().refreshUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditProfile(),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Show loading state
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error state
          if (authProvider.errorMessage != null) {
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
                  Text(
                    authProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => authProvider.refreshUserData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Main content
          return RefreshIndicator(
            onRefresh: () => authProvider.refreshUserData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Header
                _buildProfileHeader(authProvider, theme),
                const SizedBox(height: 24),

                // Account Statistics
                _buildStatisticsSection(theme),
                const SizedBox(height: 24),

                // Business Information Section
                _buildSectionTitle('Business Information', theme),
                const SizedBox(height: 12),
                _buildInfoTile(
                  icon: Icons.store,
                  title: 'Store Name',
                  subtitle: authProvider.userName ?? 'My Grocery Store',
                  theme: theme,
                  onTap: () => _showEditDialog(
                    'Store Name',
                    authProvider.userName ?? '',
                    (value) => authProvider.updateProfile(name: value),
                  ),
                ),
                _buildInfoTile(
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: authProvider.userEmail ?? 'store@example.com',
                  theme: theme,
                ),
                _buildInfoTile(
                  icon: Icons.phone,
                  title: 'Phone',
                  subtitle: authProvider.userPhone ?? 'Not set',
                  theme: theme,
                  onTap: () => _showEditDialog(
                    'Phone Number',
                    authProvider.userPhone ?? '',
                    (value) => authProvider.updateProfile(phone: value),
                  ),
                ),
                _buildInfoTile(
                  icon: Icons.location_on,
                  title: 'Address',
                  subtitle: authProvider.userAddress ?? 'Not set',
                  theme: theme,
                  onTap: () => _showEditDialog(
                    'Address',
                    authProvider.userAddress ?? '',
                    (value) => authProvider.updateProfile(address: value),
                  ),
                ),
                const SizedBox(height: 24),

                // Account Section
                _buildSectionTitle('Account', theme),
                const SizedBox(height: 12),
                _buildSettingsTile(
                  icon: Icons.lock,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  onTap: () => _navigateToChangePassword(),
                  theme: theme,
                ),
                _buildSettingsTile(
                  icon: Icons.verified_user,
                  title: 'Account Verification',
                  subtitle: 'Verify your account',
                  onTap: () => _handleVerification(authProvider),
                  theme: theme,
                ),
                const SizedBox(height: 24),

                // Settings Section
                _buildSectionTitle('Settings', theme),
                const SizedBox(height: 12),
                _buildSettingsTile(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () => _navigateToNotificationSettings(),
                  theme: theme,
                ),
                _buildSettingsTile(
                  icon: Icons.palette,
                  title: 'Appearance',
                  subtitle: 'Theme and display settings',
                  onTap: () => _navigateToAppearanceSettings(),
                  theme: theme,
                ),
                _buildSettingsTile(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () => _navigateToLanguageSettings(),
                  theme: theme,
                ),
                const SizedBox(height: 24),

                // Support Section
                _buildSectionTitle('Support', theme),
                const SizedBox(height: 12),
                _buildSettingsTile(
                  icon: Icons.help,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () => _navigateToHelp(),
                  theme: theme,
                ),
                _buildSettingsTile(
                  icon: Icons.info,
                  title: 'About',
                  subtitle: 'App version and info',
                  onTap: () => _showAboutDialog(),
                  theme: theme,
                ),
                const SizedBox(height: 24),

                // Logout Button
                FilledButton.icon(
                  onPressed: () => _handleLogout(authProvider),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  // ========================================
  // BUILD METHODS
  // ========================================

  Widget _buildProfileHeader(AuthProvider authProvider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  authProvider.userInitials,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.store,
                    size: 16,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            authProvider.userName ?? 'Store Owner',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            authProvider.userEmail ?? 'store@example.com',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Role Badge
          Chip(
            label: Text(
              authProvider.userRole?.toUpperCase() ?? 'STORE OWNER',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            backgroundColor: theme.colorScheme.primaryContainer,
            avatar: Icon(
              Icons.verified,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.inventory_2,
            label: 'Products',
            value: '0',
            color: theme.colorScheme.primary,
          ),
          _buildStatItem(
            icon: Icons.shopping_cart,
            label: 'Orders',
            value: '0',
            color: Colors.orange,
          ),
          _buildStatItem(
            icon: Icons.star,
            label: 'Rating',
            value: '0. 0',
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: onTap != null ? const Icon(Icons.edit, size: 20) : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ========================================
  // ACTION METHODS
  // ========================================

  void _navigateToEditProfile() {
    // TODO: Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile feature coming soon')),
    );
  }

  void _navigateToChangePassword() {
    showDialog(
      context: context,
      builder: (context) => _ChangePasswordDialog(),
    );
  }

  void _handleVerification(AuthProvider authProvider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Verification'),
        content: const Text(
          'Would you like to resend the verification email?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send Email'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final success = await authProvider.resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Verification email sent!'
                  : authProvider.errorMessage ?? 'Failed to send email',
            ),
            backgroundColor:
                success ? Colors.green : Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _navigateToNotificationSettings() {
    Navigator.pushNamed(context, '/notification-settings');
  }

  void _navigateToAppearanceSettings() {
    Navigator.pushNamed(context, '/appearance-settings');
  }

  void _navigateToLanguageSettings() {
    Navigator.pushNamed(context, '/language-settings');
  }

  void _navigateToHelp() {
    Navigator.pushNamed(context, '/help');
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Smart Grocery Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.shopping_basket, size: 48),
      children: [
        const Text('A smart solution for managing your grocery inventory. '),
      ],
    );
  }

  void _showEditDialog(
    String title,
    String currentValue,
    Future<bool> Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final success = await onSave(controller.text.trim());
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? '$title updated!' : 'Failed to update $title',
                    ),
                    backgroundColor: success
                        ? Colors.green
                        : Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? '),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// ========================================
// CHANGE PASSWORD DIALOG
// ========================================

class _ChangePasswordDialog extends StatefulWidget {
  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty == true) return 'Required';
                if (value!.length < 6) return 'Min 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleChangePassword,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Change'),
        ),
      ],
    );
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Password changed successfully!'
                : authProvider.errorMessage ?? 'Failed to change password',
          ),
          backgroundColor:
              success ? Colors.green : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
