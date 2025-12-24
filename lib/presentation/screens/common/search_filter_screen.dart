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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search & Filter'), elevation: 0),
      body: Column(
        children: [
          // Search & Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
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
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            ['All', 'Fruits', 'Vegetables', 'Dairy', 'Bakery']
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
            child: Consumer<GroceryProvider>(
              builder: (context, provider, child) {
                final filteredItems = provider.groceryItems.where((item) {
                  final matchesSearch = item.name.toLowerCase().contains(
                        _searchController.text.toLowerCase(),
                      );

                  final matchesCategory = _selectedCategory == 'All' ||
                      item.categoryId == _selectedCategory;

                  final matchesExpiry = !_showExpiredOnly ||
                      item.expiryDate.isBefore(DateTime.now());

                  return matchesSearch && matchesCategory && matchesExpiry;
                }).toList();

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
                    return GroceryItemCard(item: filteredItems[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
