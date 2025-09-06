import 'dart:io';
import 'package:http/http.dart' as http;

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is ApiError) {
      return error.message;
    } else if (error is Map<String, dynamic>) {
      // Handle Django REST framework error format
      if (error.containsKey('detail')) {
        return error['detail'];
      }
      
      // Handle field-specific errors
      if (error.containsKey('non_field_errors')) {
        return (error['non_field_errors'] as List).first;
      }
      
      // Handle first field error
      for (String key in error.keys) {
        final value = error[key];
        if (value is List && value.isNotEmpty) {
          return '$key: ${value.first}';
        }
      }
    }
    
    return error.toString();
  }
  
  static String getErrorType(dynamic error) {
    if (error is ApiError) {
      return error.type;
    } else if (isNetworkError(error.toString())) {
      return 'network';
    } else if (isAuthError(error.toString())) {
      return 'auth';
    } else {
      return 'unknown';
    }
  }
  
  static bool isNetworkError(String error) {
    return error.toLowerCase().contains('network') ||
           error.toLowerCase().contains('connection') ||
           error.toLowerCase().contains('timeout') ||
           error.toLowerCase().contains('socket');
  }
  
  static bool isAuthError(String error) {
    return error.toLowerCase().contains('unauthorized') ||
           error.toLowerCase().contains('authentication') ||
           error.toLowerCase().contains('login') ||
           error.toLowerCase().contains('token');
  }
  
  static ApiError handleException(dynamic error) {
    if (error is ApiError) {
      return error;
    }
    return ApiError.fromException(error);
  }
}

class ApiError {
  final String message;
  final String type;
  final int? statusCode;
  final dynamic data;

  ApiError({
    required this.message,
    required this.type,
    this.statusCode,
    this.data,
  });

  factory ApiError.fromException(dynamic error) {
    if (error is SocketException) {
      return ApiError(
        message: 'Network connection error: ${error.message}',
        type: 'network',
        data: error,
      );
    } else if (error is http.ClientException) {
      return ApiError(
        message: 'HTTP client error: ${error.message}',
        type: 'http',
        data: error,
      );
    } else if (error is FormatException) {
      return ApiError(
        message: 'Data format error: ${error.message}',
        type: 'format',
        data: error,
      );
    } else if (error is TimeoutException) {
      return ApiError(
        message: 'Request timed out',
        type: 'timeout',
        data: error,
      );
    } else {
      return ApiError(
        message: 'Unexpected error: ${error.toString()}',
        type: 'unknown',
        data: error,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'type': type,
      'statusCode': statusCode,
      'data': data?.toString(),
    };
  }
}

class TimeoutException implements Exception {
  final String message;
  
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}