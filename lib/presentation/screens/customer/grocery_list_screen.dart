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
    // Fetch groceries when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroceryProvider>().fetchGroceryItems();
    });
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

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('Retry'),
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
            filteredItems = provider.filterByCategory(_selectedCategory);
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
                              'No items found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
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
            context.read<GroceryProvider>().refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  void _showFilterDialog() {
    // Implement filter dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: const Text('Filter dialog coming soon!'),
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
        provider.refresh();
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
    final String unit = item is Map ? item['unit'] : (item.unit ?? 'pcs');
    final DateTime? expiryDate = item is Map
        ? DateTime.tryParse(item['expiryDate'] ?? '')
        : item.expiryDate;

    final daysUntilExpiry =
        expiryDate?.difference(DateTime.now()).inDays ?? 999;
    final isExpiringSoon = daysUntilExpiry <= 7;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: isExpiringSoon ? Colors.orange : Colors.green,
          child: Text(
            name[0].toUpperCase(),
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
                    color: isExpiringSoon ? Colors.orange : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expires:  ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
                    style: TextStyle(
                      color: isExpiringSoon ? Colors.orange : Colors.grey,
                      fontSize: 12,
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
