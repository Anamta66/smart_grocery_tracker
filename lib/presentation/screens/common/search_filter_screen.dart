import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/grocery_provider.dart';
import '../../widgets/grocery_item_card.dart';
import '../../../core/widgets/custom_text_field.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _showExpiredOnly = false;

  @override
  void initState() {
    super.initState();
    // Fetch groceries when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroceryProvider>().fetchGroceryItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
        elevation: 0,
        actions: [
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

          return Column(
            children: [
              // Search & Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Search Bar
                    CustomTextField(
                      controller: _searchController,
                      hint: 'Search groceries...',
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),

                    // Filter Chips
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: categories
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilterChip(
                          label: const Text('Expired'),
                          selected: _showExpiredOnly,
                          onSelected: (value) {
                            setState(() {
                              _showExpiredOnly = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Results List
              Expanded(
                child: Builder(
                  builder: (context) {
                    // Apply search filter
                    var filteredItems =
                        provider.searchItems(_searchController.text);

                    // Apply category filter
                    if (_selectedCategory != 'All') {
                      filteredItems = filteredItems
                          .where((item) => item.categoryId == _selectedCategory)
                          .toList();
                    }

                    // Apply expiry filter
                    if (_showExpiredOnly) {
                      filteredItems = filteredItems
                          .where((item) =>
                              item.expiryDate?.isBefore(DateTime.now()) ??
                              false)
                          .toList();
                    }

                    if (filteredItems.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No items found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];

                        return GroceryItemCard(
                          item: item,
                          onTap: () {
                            // Navigate to item details
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (context) => GroceryDetailScreen(item: item),
                            // ));
                          },
                          onEdit: () {
                            // Navigate to edit screen
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (context) => AddEditGroceryScreen(item: item),
                            // ));
                          },
                          onDelete: () async {
                            // Show confirmation dialog and delete
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Item'),
                                content: Text('Delete "${item.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              final success =
                                  await provider.deleteGroceryItem(item.id);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? '${item.name} deleted'
                                          : 'Failed to delete ${item.name}',
                                    ),
                                    backgroundColor:
                                        success ? Colors.green : Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
