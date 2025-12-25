// lib/presentation/widgets/inventory_item_card.dart

import 'package:flutter/material.dart';
import '../../data/models/grocery_item_model.dart';

class InventoryItemCard extends StatelessWidget {
  final GroceryItemModel item; // Changed from InventoryItem
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(int) onQuickUpdate;

  const InventoryItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.onQuickUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLowStock = item.quantity < 5;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Item Icon/Image
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Item Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Category: ${item.categoryId ?? "Uncategorized"}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: theme.colorScheme.error,
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stock Information
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stock',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              isLowStock
                                  ? Icons.warning_amber
                                  : Icons.check_circle,
                              size: 16,
                              color: isLowStock ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.quantity.toInt()} items',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isLowStock ? Colors.orange : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Quick Update Buttons
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (item.quantity > 0) {
                            onQuickUpdate(item.quantity.toInt() - 1);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        color: theme.colorScheme.primary,
                      ),
                      IconButton(
                        onPressed: () {
                          onQuickUpdate(item.quantity.toInt() + 1);
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),

              // Low Stock Warning
              if (isLowStock)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Low Stock Alert',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
