// lib/presentation/screens/store_owner/add_edit_inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/inventory_item.dart';
import '../../providers/inventory_provider.dart';

/// Screen to Add or Edit Inventory Items
class AddEditInventoryScreen extends StatefulWidget {
  final InventoryItem? item; // null = Add mode, non-null = Edit mode

  const AddEditInventoryScreen({super.key, this.item});

  @override
  State<AddEditInventoryScreen> createState() => _AddEditInventoryScreenState();
}

class _AddEditInventoryScreenState extends State<AddEditInventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _lowStockController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditMode => widget.item != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing
    if (_isEditMode) {
      _nameController.text = widget.item!.name;
      _barcodeController.text = widget.item!.barcode;
      _categoryController.text = widget.item!.category;
      _quantityController.text = widget.item!.quantity.toString();
      _lowStockController.text = widget.item!.lowStockThreshold.toString();
      _priceController.text = widget.item!.price?.toStringAsFixed(2) ?? '0.00';
      _descriptionController.text = widget.item!.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _lowStockController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Item' : 'Add New Item'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Item Name
            _buildTextField(
              controller: _nameController,
              label: 'Item Name',
              hint: 'e.g., Fresh Milk',
              icon: Icons.shopping_bag,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter item name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Barcode with Scan Button
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _barcodeController,
                    label: 'Barcode',
                    hint: '123456789012',
                    icon: Icons.qr_code,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter barcode';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Scan Barcode Button
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.qr_code_scanner,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    onPressed: _scanBarcode,
                    tooltip: 'Scan Barcode',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category
            _buildTextField(
              controller: _categoryController,
              label: 'Category',
              hint: 'e.g., Dairy',
              icon: Icons.category,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Quantity and Low Stock Threshold
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _quantityController,
                    label: 'Quantity',
                    hint: '100',
                    icon: Icons.inventory,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _lowStockController,
                    label: 'Low Stock Alert',
                    hint: '10',
                    icon: Icons.warning_amber,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price
            _buildTextField(
              controller: _priceController,
              label: 'Price (\$)',
              hint: '3.99',
              icon: Icons.attach_money,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter price';
                }
                if (double.tryParse(value) == null) {
                  return 'Invalid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description (Optional)
            _buildTextField(
              controller: _descriptionController,
              label: 'Description (Optional)',
              hint: 'Additional details.. .',
              icon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Save Button
            FilledButton.icon(
              onPressed: _isLoading ? null : _handleSubmit,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isEditMode ? 'Update Item' : 'Add Item'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Delete Button (only in edit mode)
            if (_isEditMode) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete),
                label: const Text('Delete Item'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Reusable Text Field Builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
      ),
    );
  }

  /// Simulate Barcode Scan
  void _scanBarcode() async {
    // TODO: Integrate actual barcode scanner plugin
    // For now, show a mock scanner dialog
    final barcode = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan Barcode'),
        content: const Text(
          'Barcode scanner would open here.\n\nFor demo, enter manually or use mock data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Mock barcode
              Navigator.pop(
                  context, '${DateTime.now().millisecondsSinceEpoch}');
            },
            child: const Text('Use Mock'),
          ),
        ],
      ),
    );

    if (barcode != null) {
      _barcodeController.text = barcode;
    }
  }

  /// Handle Form Submission
  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<InventoryProvider>();

      final itemData = InventoryItem(
        id: _isEditMode ? widget.item!.id : DateTime.now().toString(),
        userId: widget.item!.userId,
        name: _nameController.text.trim(),
        barcode: _barcodeController.text.trim(),
        category: _categoryController.text.trim(),
        quantity: int.parse(_quantityController.text.trim()),
        lowStockThreshold: int.parse(_lowStockController.text.trim()),
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: _isEditMode ? widget.item!.createdAt : DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      if (_isEditMode) {
        await provider.updateItem(itemData);
      } else {
        await provider.addItem(itemData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Item updated successfully'
                  : 'Item added successfully',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Confirm Deletion
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content:
            Text('Are you sure you want to delete "${widget.item!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              try {
                await context
                    .read<InventoryProvider>()
                    .deleteItem(widget.item!.id);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item deleted successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  Navigator.pop(context); // Go back to inventory screen
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting item: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
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
