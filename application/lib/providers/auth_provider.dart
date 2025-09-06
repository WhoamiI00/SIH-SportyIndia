import 'package:flutter/foundation.dart';
import '../models/athlete_profile.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  AthleteProfile? _currentAthlete;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  AthleteProfile? get currentAthlete => _currentAthlete;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> init() async {
    await _apiService.init();
    _isAuthenticated = _apiService.isAuthenticated;
    if (_isAuthenticated) {
      await loadAthleteProfile();
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.login(username, password);
      
      if (result['success']) {
        _isAuthenticated = true;
        await loadAthleteProfile();
        return true;
      } else {
        _setError(result['error']);
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _apiService.logout();
    } catch (e) {
      // Log error but continue with logout
      print('Logout error: $e');
    } finally {
      _currentAthlete = null;
      _isAuthenticated = false;
      _clearError();
      _setLoading(false);
    }
  }

  Future<bool> registerAthlete(Map<String, dynamic> athleteData) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.registerAthlete(athleteData);
      
      if (result['success']) {
        // Reload profile after registration
        await loadAthleteProfile();
        return true;
      } else {
        _setError(result['error'].toString());
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAthleteProfile() async {
    _setLoading(true);
    
    try {
      final result = await _apiService.getAthleteProfile();
      
      if (result['success'] && result['data'].isNotEmpty) {
        _currentAthlete = AthleteProfile.fromJson(result['data'][0]);
      } else {
        _setError(result['error']?.toString() ?? 'Failed to load profile');
      }
    } catch (e) {
      _setError('Error loading profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updateData) async {
    if (_currentAthlete == null) return false;
    
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.updateAthleteProfile(_currentAthlete!.id, updateData);
      
      if (result['success']) {
        _currentAthlete = AthleteProfile.fromJson(result['data']);
        return true;
      } else {
        _setError(result['error'].toString());
        return false;
      }
    } catch (e) {
      _setError('Update failed: $e');
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