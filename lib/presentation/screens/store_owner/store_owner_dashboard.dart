import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import 'inventory_screen.dart';
import 'reports_screen.dart';
import 'store_owner_profile_screen.dart';
import '../../../core/constants/app_routes.dart';

class StoreOwnerDashboard extends StatefulWidget {
  const StoreOwnerDashboard({super.key});

  @override
  State<StoreOwnerDashboard> createState() => _StoreOwnerDashboardState();
}

class _StoreOwnerDashboardState extends State<StoreOwnerDashboard> {
  int _currentIndex = 0;

  final _screens = [
    const _OwnerHome(),
    const InventoryScreen(),
    const ReportsScreen(),
    const StoreOwnerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex:  _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon:  Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory), label: 'Inventory'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _OwnerHome extends StatelessWidget {
  const _OwnerHome();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, AppRoutes. login);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              color: Colors.blue.shade50,
              child:  Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius:  30,
                      backgroundColor:  Colors.blue,
                      child: Text(authProvider.userInitials, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Welcome Back!', style:  TextStyle(fontSize: 14, color: Colors.grey)),
                          Text(authProvider.userName ?? 'Store Owner', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(authProvider.userEmail ?? '', style: const TextStyle(fontSize:  12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Success Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors. blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Row(
                children:  [
                  Icon(Icons. check_circle, color: Colors. blue, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:  CrossAxisAlignment.start,
                      children: [
                        Text('🎉 Successfully Connected! ', style: TextStyle(fontSize:  16, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                        Text('Frontend ↔ Backend Integration Working', style: TextStyle(fontSize: 12, color: Colors. blue.shade700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            Text('Inventory Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children:  [
                Expanded(child:  _StatCard(icon: Icons. inventory, title: 'Total Items', value: '${inventoryProvider.inventoryItems.length}', color: Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.warning, title: 'Low Stock', value: '0', color: Colors.red)),
              ],
            ),
            const SizedBox(height:  12),
            Row(
              children: [
                Expanded(child: _StatCard(icon: Icons.attach_money, title: 'Revenue', value: '\$0', color: Colors.green)),
                const SizedBox(width:  12),
                Expanded(child: _StatCard(icon:  Icons.category, title: 'Categories', value: '0', color: Colors.purple)),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.add,
              title: 'Add Inventory Item',
              subtitle: 'Add new products to inventory',
              onTap: () => Navigator.pushNamed(context, AppRoutes.addEditInventory),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.bar_chart,
              title: 'View Reports',
              subtitle:  'Check sales and analytics',
              onTap: () => Navigator.pushNamed(context, AppRoutes.reports),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding:  const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color:  color, size: 32),
            const SizedBox(height:  12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({required this. icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: Colors.blue.withOpacity(0.1), child: Icon(icon, color:  Colors.blue)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}