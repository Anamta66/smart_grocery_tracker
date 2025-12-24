import 'package:flutter/material.dart';

/// Badge widget to show expiry status
class ExpiryBadge extends StatelessWidget {
  final int daysUntilExpiry;
  final bool isExpired;

  const ExpiryBadge({
    Key? key,
    required this.daysUntilExpiry,
    this.isExpired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String label;
    IconData icon;

    if (isExpired) {
      badgeColor = Colors.red.shade700;
      label = 'Expired';
      icon = Icons.cancel_outlined;
    } else if (daysUntilExpiry <= 3) {
      badgeColor = Colors.orange.shade700;
      label = '$daysUntilExpiry days';
      icon = Icons.warning_amber_rounded;
    } else if (daysUntilExpiry <= 7) {
      badgeColor = Colors.amber.shade700;
      label = '$daysUntilExpiry days';
      icon = Icons.access_time_rounded;
    } else {
      badgeColor = Colors.green.shade700;
      label = '$daysUntilExpiry days';
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
