import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../providers/assessment_provider.dart';
import '../models/athlete_profile.dart';

class ApiUsageExamples extends StatefulWidget {
  const ApiUsageExamples({super.key});

  @override
  State<ApiUsageExamples> createState() => _ApiUsageExamplesState();
}

class _ApiUsageExamplesState extends State<ApiUsageExamples> {
  final ApiService _apiService = ApiService();
  String _result = '';

  @override
  void initState() {
    super.initState();
    _apiService.init();
  }

  // Example 1: Health Check
  Future<void> _testHealthCheck() async {
    setState(() => _result = 'Checking server health...');
    
    final result = await _apiService.healthCheck();
    
    setState(() {
      if (result['success']) {
        _result = 'Server is healthy!\n'
                 'Status: ${result['data']['status']}\n'
                 'Database: ${result['data']['services']['database']}\n'
                 'Cache: ${result['data']['services']['cache']}';
      } else {
        _result = 'Health check failed: ${result['error']}';
      }
    });
  }

  // Example 2: Login
  Future<void> _testLogin() async {
    setState(() => _result = 'Logging in...');
    
    final result = await _apiService.login('test_user', 'test_password');
    
    setState(() {
      if (result['success']) {
        _result = 'Login successful!\n'
                 'Token received and stored.';
      } else {
        _result = 'Login failed: ${result['error']}';
      }
    });
  }

  // Example 3: Get Fitness Tests
  Future<void> _testGetFitnessTests() async {
    setState(() => _result = 'Loading fitness tests...');
    
    final result = await _apiService.getFitnessTests();
    
    setState(() {
      if (result['success']) {
        final tests = result['data'] as List;
        _result = 'Found ${tests.length} fitness tests:\n' +
                 tests.map((test) => '- ${test['display_name']}').join('\n');
      } else {
        _result = 'Failed to load fitness tests: ${result['error']}';
      }
    });
  }

  // Example 4: Start Assessment (MISSING METHOD - NOW ADDED)
  Future<void> _testStartAssessment() async {
    setState(() => _result = 'Starting assessment...');
    
    final result = await _apiService.startAssessment();
    
    setState(() {
      if (result['success']) {
        _result = 'Assessment started successfully!\n'
                 'Session ID: ${result['data']['session_id']}\n'
                 'Status: ${result['data']['status']}';
      } else {
        _result = 'Failed to start assessment: ${result['error']}';
      }
    });
  }

  // Example 5: Get Athlete Profile
  Future<void> _testGetAthleteProfile() async {
    setState(() => _result = 'Loading athlete profile...');
    
    final result = await _apiService.getAthleteProfile();
    
    setState(() {
      if (result['success']) {
        final athletes = result['data'] as List;
        if (athletes.isNotEmpty) {
          final athlete = athletes.first;
          _result = 'Profile loaded:\n'
                   'Name: ${athlete['full_name']}\n'
                   'Age: ${athlete['age']}\n'
                   'State: ${athlete['state']}\n'
                   'Points: ${athlete['total_points']}';
        } else {
          _result = 'No athlete profile found';
        }
      } else {
        _result = 'Failed to load profile: ${result['error']}';
      }
    });
  }

  // Example 6: Get National Rankings
  Future<void> _testGetNationalRankings() async {
    setState(() => _result = 'Loading national rankings...');
    
    final result = await _apiService.getNationalRankings(limit: 10);
    
    setState(() {
      if (result['success']) {
        final rankings = result['data']['rankings'] as List;
        _result = 'Top ${rankings.length} athletes:\n' +
                 rankings.map((entry) => 
                   '#${entry['current_rank']} ${entry['athlete_name']} - ${entry['total_points']} pts'
                 ).join('\n');
      } else {
        _result = 'Failed to load rankings: ${result['error']}';
      }
    });
  }

  // Example 7: Device Optimization
  Future<void> _testDeviceOptimization() async {
    setState(() => _result = 'Optimizing for device...');
    
    final result = await _apiService.optimizeForDevice();
    
    setState(() {
      if (result['success']) {
        final recommendations = result['data']['recommendations'];
        _result = 'Device optimization complete:\n'
                 'Video quality: ${recommendations['video_quality']}\n'
                 'Offline analysis: ${recommendations['offline_analysis']}\n'
                 'Compression: ${recommendations['compression_level']}';
      } else {
        _result = 'Optimization failed: ${result['error']}';
      }
    });
  }

  // Example 8: Using with Provider pattern
  Future<void> _testWithProvider() async {
    setState(() => _result = 'Testing with provider...');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if authenticated
    if (!authProvider.isAuthenticated) {
      setState(() => _result = 'Not authenticated. Please login first.');
      return;
    }
    
    // Load athlete profile using provider
    await authProvider.loadAthleteProfile();
    
    if (authProvider.currentAthlete != null) {
      final athlete = authProvider.currentAthlete!;
      setState(() {
        _result = 'Provider test successful:\n'
                 'Athlete: ${athlete.fullName}\n'
                 'Level: ${athlete.level}\n'
                 'Total Points: ${athlete.totalPoints}';
      });
    } else {
      setState(() => _result = 'Provider test failed: ${authProvider.errorMessage}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Usage Examples'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _testHealthCheck,
                    child: const Text('1. Health Check'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testLogin,
                    child: const Text('2. Test Login'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testGetFitnessTests,
                    child: const Text('3. Get Fitness Tests'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testStartAssessment,
                    child: const Text('4. Start Assessment'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testGetAthleteProfile,
                    child: const Text('5. Get Athlete Profile'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testGetNationalRankings,
                    child: const Text('6. Get National Rankings'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testDeviceOptimization,
                    child: const Text('7. Device Optimization'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testWithProvider,
                    child: const Text('8. Test with Provider'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Response:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result.isEmpty ? 'Click a button above to test API calls' : _result,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: _result.contains('failed') || _result.contains('Failed') 
                            ? Colors.red 
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
