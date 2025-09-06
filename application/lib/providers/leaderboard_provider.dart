import 'package:flutter/foundation.dart';
import '../models/leaderboard.dart';
import '../services/api_service.dart';

class LeaderboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<LeaderboardEntry> _nationalRankings = [];
  List<LeaderboardEntry> _stateRankings = [];
  List<LeaderboardEntry> _athleteRankings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LeaderboardEntry> get nationalRankings => _nationalRankings;
  List<LeaderboardEntry> get stateRankings => _stateRankings;
  List<LeaderboardEntry> get athleteRankings => _athleteRankings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadNationalRankings({
    int? testId,
    String? ageGroup,
    String? gender,
    int limit = 100,
  }) async {
    _setLoading(true);
    
    try {
      final result = await _apiService.getNationalRankings(
        testId: testId,
        ageGroup: ageGroup,
        gender: gender,
        limit: limit,
      );
      
      if (result['success']) {
        _nationalRankings = (result['data']['rankings'] as List)
            .map((json) => LeaderboardEntry.fromJson(json))
            .toList();
      } else {
        _setError(result['error'].toString());
      }
    } catch (e) {
      _setError('Error loading national rankings: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStateRankings(String state, {int? testId}) async {
    _setLoading(true);
    
    try {
      final result = await _apiService.getStateRankings(state, testId: testId);
      
      if (result['success']) {
        _stateRankings = (result['data']['rankings'] as List)
            .map((json) => LeaderboardEntry.fromJson(json))
            .toList();
      } else {
        _setError(result['error'].toString());
      }
    } catch (e) {
      _setError('Error loading state rankings: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAthleteRankings() async {
    _setLoading(true);
    
    try {
      final result = await _apiService.getAthleteRankings();
      
      if (result['success']) {
        _athleteRankings = (result['data']['rankings'] as List)
            .map((json) => LeaderboardEntry.fromJson(json))
            .toList();
      } else {
        _setError(result['error'].toString());
      }
    } catch (e) {
      _setError('Error loading athlete rankings: $e');
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