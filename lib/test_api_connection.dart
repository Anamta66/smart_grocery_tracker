import 'package:flutter/material.dart';
import 'core/services/api_service.dart';
import 'core/config/api_config.dart';

class TestApiConnection extends StatefulWidget {
  @override
  _TestApiConnectionState createState() => _TestApiConnectionState();
}

class _TestApiConnectionState extends State<TestApiConnection> {
  final ApiService _apiService = ApiService();
  String _status = 'Not tested';
  bool _isLoading = false;

  Future<void> testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing... ';
    });

    try {
      final response = await _apiService.get(
        '${ApiConfig.baseUrl}/status',
        requiresAuth: false,
      );

      setState(() {
        _status = 'Connected!  \n${response.toString()}';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('API Connection Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Base URL: ${ApiConfig.baseUrl}'),
            SizedBox(height: 20),
            Text(_status),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : testConnection,
              child: Text('Test Connection'),
            ),
          ],
        ),
      ),
    );
  }
}
