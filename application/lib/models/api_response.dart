// lib/models/api_response.dart
import 'dart:convert';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;
  final String? errorType;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
    this.errorType,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? dataConverter) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && dataConverter != null ? dataConverter(json['data']) : null,
      error: json['error']?.toString(),
      statusCode: json['statusCode'],
      errorType: json['error_type'],
    );
  }

  factory ApiResponse.fromRawJson(String source, T Function(dynamic)? dataConverter) {
    return ApiResponse.fromJson(json.decode(source), dataConverter);
  }

  factory ApiResponse.success(T data) {
    return ApiResponse<T>(
      success: true,
      data: data,
    );
  }

  factory ApiResponse.error(String message, {String? errorType, int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      error: message,
      errorType: errorType,
      statusCode: statusCode,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data,
    'error': error,
    'statusCode': statusCode,
    'error_type': errorType,
  };

  String toRawJson() => json.encode(toJson());
}