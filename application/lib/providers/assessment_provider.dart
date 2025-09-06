import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/assessment_session.dart';
import '../models/fitness_test.dart';
import '../models/test_recording.dart';
import '../services/api_service.dart';

class AssessmentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<FitnessTest> _fitnessTests = [];
  AssessmentSession? _currentSession;
  List<TestRecording> _testRecordings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FitnessTest> get fitnessTests => _fitnessTests;
  AssessmentSession? get currentSession => _currentSession;
  List<TestRecording> get testRecordings => _testRecordings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadFitnessTests() async {
    _setLoading(true);
    
    try {
      final result = await _apiService.getFitnessTests();
      
      if (result['success']) {
        _fitnessTests = (result['data'] as List)
            .map((json) => FitnessTest.fromJson(json))
            .toList();
      } else {
        _setError(result['error'].toString());
      }
    } catch (e) {
      _setError('Error loading fitness tests: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> startAssessment() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.startAssessment();
      
      if (result['success']) {
        _currentSession = AssessmentSession.fromJson({
          ...result['data'],
          'progress_percentage': 0.0,
        });
        return true;
      } else {
        _setError(result['error'].toString());
        return false;
      }
    } catch (e) {
      _setError('Error starting assessment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAssessmentSessions() async {
    _setLoading(true);
    
    try {
      final result = await _apiService.getAssessmentSessions();
      
      if (result['success']) {
        final sessions = (result['data'] as List)
            .map((json) => AssessmentSession.fromJson(json))
            .toList();
        
        // Set current session to the most recent in-progress session
        if (sessions.isNotEmpty) {
          try {
            _currentSession = sessions.firstWhere(
              (session) => ['created', 'in_progress'].contains(session.status),
            );
          } catch (e) {
            // If no session with the desired status is found, use the first one
            _currentSession = sessions.first;
          }
        } else {
          _currentSession = null;
        }
      } else {
        _setError(result['error'].toString());
      }
    } catch (e) {
      _setError('Error loading assessment sessions: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadVideo(
    int fitnessTestId,
    File videoFile, {
    double? deviceAnalysisScore,
    double? deviceAnalysisConfidence,
    Map<String, dynamic>? deviceAnalysisData,
  }) async {
    if (_currentSession == null) {
      _setError('No active assessment session');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.uploadVideo(
        _currentSession!.id,
        fitnessTestId,
        videoFile,
        deviceAnalysisScore: deviceAnalysisScore,
        deviceAnalysisConfidence: deviceAnalysisConfidence,
        deviceAnalysisData: deviceAnalysisData,
      );
      
      if (result['success']) {
        // Update session progress
        final progressParts = result['data']['session_progress'].split('/');
        final completed = int.parse(progressParts[0]);
        final total = int.parse(progressParts[1]);
        
        _currentSession = AssessmentSession(
          id: _currentSession!.id,
          sessionName: _currentSession!.sessionName,
          status: completed >= total ? 'completed' : 'in_progress',
          totalTests: total,
          completedTests: completed,
          createdAt: _currentSession!.createdAt,
          progressPercentage: (completed / total) * 100,
        );
        
        return true;
      } else {
        _setError(result['error'].toString());
        return false;
      }
    } catch (e) {
      _setError('Error uploading video: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> checkAnalysisStatus(String recordingId) async {
    try {
      final result = await _apiService.getAnalysisStatus(recordingId);
      
      if (result['success']) {
        return result['data'];
      } else {
        _setError(result['error'].toString());
        return null;
      }
    } catch (e) {
      _setError('Error checking analysis status: $e');
      return null;
    }
  }

  Future<bool> submitToSAI() async {
    if (_currentSession == null || _currentSession!.status != 'completed') {
      _setError('Assessment must be completed before submission');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.submitToSAI(_currentSession!.id);
      
      if (result['success']) {
        // Update session status
        _currentSession = AssessmentSession(
          id: _currentSession!.id,
          sessionName: _currentSession!.sessionName,
          status: 'submitted_to_sai',
          totalTests: _currentSession!.totalTests,
          completedTests: _currentSession!.completedTests,
          createdAt: _currentSession!.createdAt,
          progressPercentage: _currentSession!.progressPercentage,
          submittedAt: DateTime.now(),
        );
        
        return true;
      } else {
        _setError(result['error'].toString());
        return false;
      }
    } catch (e) {
      _setError('Error submitting to SAI: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
