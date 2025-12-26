import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/grocery_provider.dart';
import '../../../data/models/grocery_item_model.dart';

/// Add/Edit Grocery Screen - Form to add or update grocery items
/// Features:  Validation, category selection, date picker
class AddEditGroceryScreen extends StatefulWidget {
  final GroceryItemModel? item;

  const AddEditGroceryScreen({super.key, this.item});

  @override
  State<AddEditGroceryScreen> createState() => _AddEditGroceryScreenState();
}

class _AddEditGroceryScreenState extends State<AddEditGroceryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = 'Dairy';
  String _selectedUnit = 'Kg';
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));

  final List<String> _categories = [
    'Dairy',
    'Bakery',
    'Fruits',
    'Vegetables',
    'Meat',
  ];
  final List<String> _units = ['Kg', 'Grams', 'Liters', 'Pieces', 'Packet'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _quantityController.text = widget.item!.quantity.toString();
      _priceController.text = widget.item!.price
          .toString(); // Fix: Remove null check since price is non-null

      // Fix: Handle categoryId properly
      if (widget.item!.categoryId.isNotEmpty) {
        // Fix: Remove null check since categoryId is non-null
        _selectedCategory = widget.item!.categoryId;
      }

      // Fix: Handle unit properly - GroceryUnit enum to String
      _selectedUnit =
          widget.item!.unit.name; // Fix: Use . name to get enum name

      // Make sure it's in our list, otherwise use default
      if (!_units.contains(_selectedUnit)) {
        _selectedUnit = 'Kg';
      }

      _expiryDate = widget.item!.expiryDate ??
          DateTime.now().add(const Duration(days: 7));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Item' : 'Add New Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  prefixIcon: const Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Quantity and Unit Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon: const Icon(Icons.scale),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem(value: unit, child: Text(unit));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Price Field
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price (PKR)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid price';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Expiry Date Picker
              ListTile(
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(Icons.calendar_today),
                title: const Text('Expiry Date'),
                subtitle: Text(
                  '${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _expiryDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _expiryDate = date;
                    });
                  }
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEdit ? 'Update Item' : 'Add Item',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<GroceryProvider>();

    try {
      // Parse quantity and price with null safety
      final quantity = double.tryParse(_quantityController.text) ?? 0.0;
      final price = double.tryParse(_priceController.text) ?? 0.0;

      // Convert string unit to GroceryUnit enum
      final GroceryUnit unitEnum = _stringToGroceryUnit(_selectedUnit);

      // Create grocery item model
      final groceryItem = GroceryItemModel(
        id: widget.item?.id ?? '',
        name: _nameController.text.trim(),
        categoryId: _selectedCategory,
        quantity: quantity,
        unit: unitEnum, // Fix: Pass GroceryUnit enum instead of String
        price: price,
        expiryDate: _expiryDate,
        userId: widget.item?.userId ?? '',
        createdAt: widget.item?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        minQuantity:
            (widget.item?.minQuantity ?? 1.0).toInt(), // Fix: Convert to int
      );

      bool success;
      if (widget.item == null) {
        // Add new item
        success = await provider.addGroceryItem(groceryItem);
      } else {
        // Update existing item
        success = await provider.updateGroceryItem(groceryItem);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(widget.item == null ? 'Item added!' : 'Item updated!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to save item'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Helper method to convert String to GroceryUnit enum
  GroceryUnit _stringToGroceryUnit(String unit) {
    switch (unit) {
      case 'Kg':
        return GroceryUnit.kg;
      case 'Grams':
        return GroceryUnit.grams;
      case 'Liters':
        return GroceryUnit.liters;
      case 'Pieces':
        return GroceryUnit.pieces;
      case 'Packet':
        return GroceryUnit.pieces;
      // Changed to a valid enum value, update as needed
      default:
        return GroceryUnit.kg; // Default fallback
    }
  }
}
