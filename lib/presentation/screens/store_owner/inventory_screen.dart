// lib/presentation/screens/store_owner/inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/inventory_item.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/inventory_item_card.dart';
import 'add_edit_inventory_screen.dart';

/// Inventory Screen for Store Owners
/// Displays all inventory items with stock tracking and management
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    // Load inventory on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadInventory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        elevation: 0,
        actions: [
          // Low Stock Filter Toggle
          IconButton(
            icon: Icon(
              _showLowStockOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showLowStockOnly ? theme.colorScheme.error : null,
            ),
            onPressed: () {
              setState(() {
                _showLowStockOnly = !_showLowStockOnly;
              });
            },
            tooltip: 'Show Low Stock Only',
          ),
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<InventoryProvider>().loadInventory();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilter(theme),

          // Inventory Stats Summary
          _buildInventoryStats(),

          // Inventory List
          Expanded(
            child: Consumer<InventoryProvider>(
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
                        Text(
                          provider.error!,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => provider.loadInventory(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredItems = _getFilteredItems(
                  provider.inventoryItems,
                );

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showLowStockOnly
                              ? 'No low stock items'
                              : 'No inventory items found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first item',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadInventory(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return InventoryItemCard(
                        item: item,
                        onTap: () => _navigateToEditItem(item),
                        onDelete: () => _confirmDelete(item),
                        onQuickUpdate: (newQuantity) =>
                            _updateStock(item, newQuantity),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddItem,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  /// Search and Category Filter
  Widget _buildSearchAndFilter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search inventory.. .',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor:
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 12),

          // Category Filter
          Consumer<InventoryProvider>(
            builder: (context, provider, child) {
              final categories = ['All', ...provider.categories];

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: theme.colorScheme.surface.withOpacity(
                          0.5,
                        ),
                        selectedColor:
                            theme.colorScheme.primaryContainer.withOpacity(0.5),
                        checkmarkColor: theme.colorScheme.primary,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Inventory Statistics Summary
  Widget _buildInventoryStats() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        final theme = Theme.of(context);
        final stats = provider.inventoryStats;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer.withOpacity(0.3),
                theme.colorScheme.secondaryContainer.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.inventory_2,
                label: 'Total Items',
                value: stats.totalItems.toString(),
                color: theme.colorScheme.primary,
              ),
              _buildStatItem(
                icon: Icons.warning_amber_rounded,
                label: 'Low Stock',
                value: stats.lowStockItems.toString(),
                color: theme.colorScheme.error,
              ),
              _buildStatItem(
                icon: Icons.attach_money,
                label: 'Total Value',
                value: '\$${stats.totalValue.toStringAsFixed(0)}',
                color: Colors.green,
              ),
            ],
          ),
        );
      },
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
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  /// Filter items based on search and category
  List<InventoryItem> _getFilteredItems(List<InventoryItem> items) {
    return items.where((item) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.barcode.contains(_searchQuery);

      // Category filter
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;

      // Low stock filter
      final matchesLowStock =
          !_showLowStockOnly || item.quantity <= item.lowStockThreshold;

      return matchesSearch && matchesCategory && matchesLowStock;
    }).toList();
  }

  /// Navigate to Add Item Screen
  void _navigateToAddItem() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditInventoryScreen()),
    );
  }

  /// Navigate to Edit Item Screen
  void _navigateToEditItem(InventoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditInventoryScreen(item: item),
      ),
    );
  }

  /// Update stock quantity quickly
  void _updateStock(InventoryItem item, int newQuantity) {
    context.read<InventoryProvider>().updateItemQuantity(item.id, newQuantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated ${item.name} stock to $newQuantity'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Confirm deletion
  void _confirmDelete(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<InventoryProvider>().deleteItem(item.id);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.name} deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
