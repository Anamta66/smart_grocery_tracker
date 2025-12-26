import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/category_model.dart';
import '../../../presentation/providers/category_provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch categories when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: CustomTextField(
          controller: nameController,
          label: 'Category Name',
          hint: 'e.g., Fruits, Dairy',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Add',
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a category name')),
                );
                return;
              }

              final provider = Provider.of<CategoryProvider>(
                context,
                listen: false,
              );

              final success = await provider.addCategory(
                nameController.text.trim(),
                null,
                null,
              );

              if (!mounted) return;
              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(provider.errorMessage ?? 'Failed to add category'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(CategoryModel category) {
    final nameController = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: CustomTextField(
          controller: nameController,
          label: 'Category Name',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Update',
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a category name')),
                );
                return;
              }

              final provider = Provider.of<CategoryProvider>(
                context,
                listen: false,
              );

              final success = await provider.updateCategory(
                category.id,
                nameController.text.trim(),
                null,
                null,
              );

              if (!mounted) return;
              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        provider.errorMessage ?? 'Failed to update category'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _deleteCategory(String categoryId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
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

    if (confirm != true) return;

    final provider = Provider.of<CategoryProvider>(context, listen: false);
    final success = await provider.deleteCategory(categoryId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to delete category'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<CategoryProvider>(context, listen: false)
                  .fetchCategories();
            },
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
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
                    onPressed: () => provider.fetchCategories(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a new category',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchCategories(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: category.color.withOpacity(0.2),
                      child: Icon(
                        Icons.category,
                        color: category.color,
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: category.description != null
                        ? Text(category.description!)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditCategoryDialog(category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategory(category.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
