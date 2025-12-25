// lib/presentation/screens/test_connection_screen.dart

import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../data/services/api_config.dart';

class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  String _status = 'Not tested';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing... ';
    });

    try {
      final response = await ApiService.get('/test'); // Create a test endpoint
      setState(() {
        _status = '✅ Connected!  Response: ${response.toString()}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Connection failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Backend Connection')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Backend URL: ${ApiConfig.baseUrl}'),
            const SizedBox(height: 20),
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Test Connection'),
            ),
          ],
        ),
      ),
    );
  }
}
