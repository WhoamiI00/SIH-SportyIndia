// lib/screens/connection_test_screen.dart
import 'package:flutter/material.dart';
import '../utils/connection_test.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../services/api_service.dart';
import '../models/api_response.dart';

class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  bool _isLoading = false;
  String _resultMessage = '';
  Map<String, dynamic>? _resultData;
  bool _isSuccess = false;
  String _errorType = '';
  String _helpMessage = '';

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _resultMessage = '';
      _resultData = null;
    });

    try {
      // Initialize the API service first
      final apiService = ApiService();
      final initResult = await apiService.init();
      
      if (!initResult.success) {
        setState(() {
          _isLoading = false;
          _isSuccess = false;
          _resultMessage = initResult.error ?? 'Connection initialization failed';
          _errorType = initResult.errorType ?? '';
          _setHelpMessage();
        });
        return;
      }
      
      final result = await ConnectionTest.testConnection();
      
      setState(() {
        _isLoading = false;
        _isSuccess = result.success;
        _resultMessage = result.success ? 'Connected to backend successfully' : (result.error ?? 'Connection failed');
        _resultData = result.data;
        _errorType = result.errorType ?? '';
        _setHelpMessage();
      });
    } catch (e) {
      final apiError = ErrorHandler.handleException(e);
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _resultMessage = apiError.message;
        _errorType = apiError.type;
        _setHelpMessage();
      });
    }
  }

  void _setHelpMessage() {
    if (_isSuccess) {
      _helpMessage = 'Connection successful! You can now proceed to use the app.';
      return;
    }
    
    switch (_errorType) {
      case 'timeout':
        _helpMessage = 'The connection timed out. This could be because:\n'
            '• The server is not running\n'
            '• Your device is not connected to the internet\n'
            '• The server is taking too long to respond\n\n'
            'Try increasing the timeout in constants.dart or check your server status.';
        break;
      case 'socket':
        _helpMessage = 'Could not establish a connection. This could be because:\n'
            '• Your device is not connected to the internet\n'
            '• The server address is incorrect\n'
            '• The server is not running\n\n'
            'If using an emulator, ensure 10.0.2.2 is used. If using a physical device, '
            'update the IP address in constants.dart to your computer\'s IP address.';
        break;
      case 'http':
        _helpMessage = 'The server was found but returned an error. This could be because:\n'
            '• The server is running but the health endpoint is not available\n'
            '• The server returned an error code\n\n'
            'Check your Django server logs for more information.';
        break;
      case 'format':
        _helpMessage = 'The server response could not be parsed. This could be because:\n'
            '• The server is returning invalid JSON\n'
            '• The response format has changed\n\n'
            'Check your Django server response format.';
        break;
      default:
        _helpMessage = 'An unknown error occurred. Please check your connection settings and server status.';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test Backend Connection'),
            ),
            const SizedBox(height: 20),
            if (_resultMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _resultMessage,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                    if (_resultData != null) ...[  
                      const SizedBox(height: 10),
                      const Text('Response Data:'),
                      const SizedBox(height: 5),
                      Text(
                        _resultData.toString(),
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ],
                    if (_helpMessage.isNotEmpty) ...[  
                      const SizedBox(height: 15),
                      const Text('Troubleshooting Help:', 
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(_helpMessage),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 20),
            if (!_isSuccess && _resultMessage.isNotEmpty) ...[  
              ExpansionTile(
                title: const Text('Connection Settings'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current API Settings:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Base URL: ${ApiConstants.apiBaseUrl}'),
                        Text('Auth URL: ${ApiConstants.apiAuthUrl}'),
                        Text('Timeout: ${ApiConstants.requestTimeout.inSeconds} seconds'),
                        const SizedBox(height: 16),
                        const Text('Troubleshooting Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('• For Android Emulator: Use 10.0.2.2 instead of localhost'),
                        const Text('• For Physical Device: Use your computer\'s IP address on the same network'),
                        const Text('• Ensure the Django server is running on 0.0.0.0:8000'),
                        const Text('• Check that your device has internet permissions'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Go to Login'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}