import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/grocery_provider.dart';

/// Expiry Tracking Screen - Shows items expiring soon
/// Features: Color-coded warnings, sorting by expiry date
class ExpiryTrackingScreen extends StatefulWidget {
  const ExpiryTrackingScreen({super.key});

  @override
  State<ExpiryTrackingScreen> createState() => _ExpiryTrackingScreenState();
}

class _ExpiryTrackingScreenState extends State<ExpiryTrackingScreen> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expiry Tracking'),
        actions: [
          IconButton(
            icon: Icon(_showExpiredOnly
                ? Icons.filter_alt
                : Icons.filter_alt_outlined),
            onPressed: () {
              setState(() {
                _showExpiredOnly = !_showExpiredOnly;
              });
            },
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

          // Get expiring or expired items
          final items = _showExpiredOnly
              ? provider.getExpiredItems()
              : provider.getExpiringSoonItems();

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _showExpiredOnly
                        ? 'No expired items'
                        : 'No items expiring soon',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final daysLeft =
                  item.expiryDate!.difference(DateTime.now()).inDays;

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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(item.name),
                  subtitle: Text(
                    'Expires: ${item.expiryDate!.day}/${item.expiryDate!.month}/${item.expiryDate!.year}',
                  ),
                  trailing: Chip(
                    label: Text(status),
                    backgroundColor: statusColor.withOpacity(0.2),
                    labelStyle: TextStyle(color: statusColor),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
