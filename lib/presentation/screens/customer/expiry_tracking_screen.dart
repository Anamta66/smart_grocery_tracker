import 'package:flutter/material.dart';

/// Expiry Tracking Screen - Shows items expiring soon
/// Features: Color-coded warnings, sorting by expiry date
class ExpiryTrackingScreen extends StatelessWidget {
  const ExpiryTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final items = [
      {'name': 'Bread', 'expiryDate': '2024-01-20', 'daysLeft': 2},
      {'name': 'Milk', 'expiryDate': '2024-01-25', 'daysLeft': 7},
      {'name': 'Cheese', 'expiryDate': '2024-01-18', 'daysLeft': 0},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Expiry Tracking')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final daysLeft = item['daysLeft'] as int;
          Color statusColor;
          String status;

          if (daysLeft <= 0) {
            statusColor = Colors.red;
            status = 'Expired';
          } else if (daysLeft <= 3) {
            statusColor = Colors.orange;
            status = 'Critical';
          } else {
            statusColor = Colors.green;
            status = 'Safe';
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: statusColor,
                child: Text(
                  '$daysLeft',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(item['name'] as String),
              subtitle: Text('Expires: ${item['expiryDate']}'),
              trailing: Chip(
                label: Text(status),
                backgroundColor: statusColor.withOpacity(0.2),
                labelStyle: TextStyle(color: statusColor),
              ),
            ),
          );
        },
      ),
    );
  }
}
