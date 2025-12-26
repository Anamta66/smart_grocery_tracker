import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/grocery_provider.dart';
import 'add_edit_grocery_screen.dart';

/// Grocery List Screen - Displays all grocery items for customer
/// Features:  Search, filter by category, sort, delete items
class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Don't fetch groceries automatically - prevents auth errors
    // User starts with empty list and can add items manually
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Grocery List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GroceryProvider>().refresh();
            },
          ),
        ],
      ),
      body: Consumer<GroceryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle auth errors gracefully
          if (provider.errorMessage != null &&
              provider.errorMessage!.contains('Unauthorized')) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first grocery item',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // Handle other errors
          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Get categories from provider
          final categories = provider.categories;

          // Apply search and filter
          var filteredItems = provider.searchItems(_searchQuery);
          if (_selectedCategory != 'All') {
            filteredItems = filteredItems
                .where((item) => item.categoryId == _selectedCategory)
                .toList();
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search grocery items...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Category Filter Chips
              if (categories.length > 1) // Only show if there are categories
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == _selectedCategory;
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
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 8),

              // Items List
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty && _selectedCategory == 'All'
                                  ? 'No items yet'
                                  : 'No items found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty && _selectedCategory == 'All'
                                  ? 'Tap + to add your first item'
                                  : 'Try adjusting your search or filter',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.refresh(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return _GroceryItemCard(
                              item: item,
                              onEdit: () => _editItem(item.id),
                              onDelete: () => _deleteItem(item.id),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditGroceryScreen()),
          );
          if (result == true && mounted) {
            // Don't call refresh - items are already added to provider
            setState(() {}); // Just rebuild to show new items
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Expiring Soon'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Filter by expiring soon
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Expired'),
              onTap: () {
                Navigator.pop(context);
                // TODO:  Filter by expired
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Low Stock'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Filter by low stock
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editItem(String itemId) async {
    final provider = context.read<GroceryProvider>();
    final item = provider.getItemById(itemId);

    if (item != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddEditGroceryScreen(item: item),
        ),
      );
      if (result == true && mounted) {
        setState(() {}); // Rebuild to show updated items
      }
    }
  }

  void _deleteItem(String itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<GroceryProvider>();
      final success = await provider.deleteGroceryItem(itemId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Item deleted successfully'
                : 'Failed to delete item'),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

/// Grocery Item Card Widget
class _GroceryItemCard extends StatelessWidget {
  final dynamic item; // Can be Map or GroceryItemModel
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GroceryItemCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Handle both Map and GroceryItemModel
    final String name = item is Map ? item['name'] : item.name;
    final String category =
        item is Map ? item['category'] : (item.categoryId ?? 'Uncategorized');
    final double quantity =
        item is Map ? item['quantity'].toDouble() : item.quantity;
    final String unit = item is Map
        ? item['unit']
        : (item.unit?.toString().split('.').last ?? 'pcs');
    final DateTime? expiryDate = item is Map
        ? DateTime.tryParse(item['expiryDate'] ?? '')
        : item.expiryDate;

    final daysUntilExpiry =
        expiryDate?.difference(DateTime.now()).inDays ?? 999;
    final isExpiringSoon = daysUntilExpiry <= 7 && daysUntilExpiry >= 0;
    final isExpired = daysUntilExpiry < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: isExpired
              ? Colors.red
              : (isExpiringSoon ? Colors.orange : Colors.green),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '? ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('$quantity $unit • $category'),
            if (expiryDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isExpired
                        ? Colors.red
                        : (isExpiringSoon ? Colors.orange : Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isExpired
                        ? 'Expired: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}'
                        : 'Expires: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
                    style: TextStyle(
                      color: isExpired
                          ? Colors.red
                          : (isExpiringSoon ? Colors.orange : Colors.grey),
                      fontSize: 12,
                      fontWeight:
                          isExpired ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
        ),
      ),
    );
  }
}
