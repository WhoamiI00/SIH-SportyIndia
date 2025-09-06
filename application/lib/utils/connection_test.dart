// lib/utils/connection_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../services/api_service.dart';
import 'constants.dart';
import 'error_handler.dart';

class ConnectionTest {
  static Future<ApiResponse<Map<String, dynamic>>> testConnection() async {
    final apiService = ApiService();
    try {
      // Use the ApiService's healthCheck method which tries multiple endpoints
      final result = await apiService.healthCheck();
      
      if (result.success) {
        return ApiResponse.success(result.data ?? {});
      } else {
        return ApiResponse.error(
        result.error ?? 'Could not connect to the backend server',
        errorType: result.errorType ?? 'unknown',
        statusCode: result.statusCode
      );
      }
    } catch (e) {
      print('Connection test error: $e');
      final error = ErrorHandler.handleException(e);
      
      return ApiResponse.error(
        error.message,
        errorType: error.type,
        statusCode: 0
      );
    }
  }
}