// lib/presentation/widgets/grocery_item_card.dart

import 'package:flutter/material.dart';
import '../../data/models/grocery_item_model.dart'; // Changed import

class GroceryItemCard extends StatelessWidget {
  final GroceryItemModel item; // Changed from GroceryItem to GroceryItemModel
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GroceryItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate days until expiry
    final daysUntilExpiry = item.expiryDate != null
        ? item.expiryDate!.difference(DateTime.now()).inDays
        : null;

    // Determine expiry status color
    Color getExpiryColor() {
      if (daysUntilExpiry == null) return Colors.grey;
      if (daysUntilExpiry < 0) return Colors.red; // Expired
      if (daysUntilExpiry <= 2) return Colors.orange; // Critical
      if (daysUntilExpiry <= 7) return Colors.amber; // Warning
      return Colors.green; // Fresh
    }

    // Get expiry status text
    String getExpiryText() {
      if (daysUntilExpiry == null) return 'No expiry date';
      if (daysUntilExpiry < 0) return 'Expired ${-daysUntilExpiry} days ago';
      if (daysUntilExpiry == 0) return 'Expires today';
      if (daysUntilExpiry == 1) return 'Expires tomorrow';
      return 'Expires in $daysUntilExpiry days';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Item Icon/Image
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shopping_basket,
                      size: 28,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),

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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quantity: ${item.quantity.toInt()}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
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
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Expiry Status Bar
              if (daysUntilExpiry != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: getExpiryColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: getExpiryColor().withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        daysUntilExpiry < 0
                            ? Icons.error
                            : daysUntilExpiry <= 2
                                ? Icons.warning_amber
                                : Icons.access_time,
                        size: 16,
                        color: getExpiryColor(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        getExpiryText(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: getExpiryColor(),
                        ),
                      ),
                    ],
                  ),
                ),

              // Category (if available)
              if (item.categoryId != null && item.categoryId!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.categoryId!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
