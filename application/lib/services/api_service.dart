// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1'; // Change to your Django server URL
  static const String authUrl = 'http://localhost:8000/api/auth';
  
  // Headers for API requests
  Map<String, String> get headers => {
    'Content-Type': 'application/json', 
    'Accept': 'application/json',
  };

  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Token ${_token ?? ''}',
  };

  String? _token;

  // Initialize token from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Save token to storage
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }

  // Remove token from storage
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
  }

  // Authentication Methods
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/login/'),
        headers: headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        await _saveToken(data['token']);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['detail'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$authUrl/logout/'),
        headers: authHeaders,
      );
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _removeToken();
    }
  }

  // Athlete Profile Methods
  Future<Map<String, dynamic>> registerAthlete(Map<String, dynamic> athleteData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/athletes/register_athlete/'),
        headers: authHeaders,
        body: jsonEncode(athleteData),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getAthleteProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/athletes/'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['results']};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateAthleteProfile(String athleteId, Map<String, dynamic> updateData) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/athletes/$athleteId/'),
        headers: authHeaders,
        body: jsonEncode(updateData),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Fitness Tests Methods
  Future<Map<String, dynamic>> getFitnessTests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fitness-tests/'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['results']};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getBenchmarks(int testId, int age, String gender) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fitness-tests/$testId/benchmarks/?age=$age&gender=$gender'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Assessment Session Methods
  Future<Map<String, dynamic>> startAssessment() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assessment-sessions/start_assessment/'),
        headers: authHeaders,
        body: jsonEncode({
          'device_info': await _getDeviceInfo(),
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getAssessmentSessions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/assessment-sessions/'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['results']};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> submitToSAI(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assessment-sessions/$sessionId/submit_to_sai/'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Video Upload Methods
  Future<Map<String, dynamic>> uploadVideo(
    String sessionId,
    int fitnessTestId,
    File videoFile, {
    double? deviceAnalysisScore,
    double? deviceAnalysisConfidence,
    Map<String, dynamic>? deviceAnalysisData,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/test-recordings/upload_video/'),
      );

      // Add headers
      request.headers.addAll(authHeaders);

      // Add fields
      request.fields['session_id'] = sessionId;
      request.fields['fitness_test_id'] = fitnessTestId.toString();

      if (deviceAnalysisScore != null) {
        request.fields['device_analysis_score'] = deviceAnalysisScore.toString();
      }
      if (deviceAnalysisConfidence != null) {
        request.fields['device_analysis_confidence'] = deviceAnalysisConfidence.toString();
      }
      if (deviceAnalysisData != null) {
        request.fields['device_analysis_data'] = jsonEncode(deviceAnalysisData);
      }
      request.fields['device_info'] = jsonEncode(await _getDeviceInfo());

      // Add video file
      request.files.add(await http.MultipartFile.fromPath(
        'video_file',
        videoFile.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Upload error: $e'};
    }
  }

  Future<Map<String, dynamic>> getAnalysisStatus(String recordingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test-recordings/$recordingId/analysis_status/'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Leaderboard Methods
  Future<Map<String, dynamic>> getNationalRankings({
    int? testId,
    String? ageGroup,
    String? gender,
    int limit = 100,
  }) async {
    try {
      var queryParams = <String, String>{
        'limit': limit.toString(),
      };
      
      if (testId != null) queryParams['test_id'] = testId.toString();
      if (ageGroup != null) queryParams['age_group'] = ageGroup;
      if (gender != null) queryParams['gender'] = gender;

      final uri = Uri.parse('$baseUrl/leaderboards/national_rankings/')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: authHeaders);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getStateRankings(String state, {int? testId}) async {
    try {
      var queryParams = <String, String>{'state': state};
      if (testId != null) queryParams['test_id'] = testId.toString();

      final uri = Uri.parse('$baseUrl/leaderboards/state_rankings/')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: authHeaders);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getAthleteRankings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboards/athlete_rankings/'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Badge Methods
  Future<Map<String, dynamic>> getAthleteBadges() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/badges/athlete_badges/'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Statistics Methods
  Future<Map<String, dynamic>> getAthleteStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats/athlete_stats/'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getPlatformStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats/platform_stats/'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Device Optimization
  Future<Map<String, dynamic>> optimizeForDevice() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/device/optimize/'),
        headers: authHeaders,
        body: jsonEncode({
          'device_info': await _getDeviceInfo(),
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Health Check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/health/'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Helper method to get device info
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'device_type': Platform.isAndroid ? 'android' : 'ios',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Check if user is authenticated
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
}