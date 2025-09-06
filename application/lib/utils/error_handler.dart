class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is Map<String, dynamic>) {
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
  
  static bool isNetworkError(String error) {
    return error.toLowerCase().contains('network') ||
           error.toLowerCase().contains('connection') ||
           error.toLowerCase().contains('timeout');
  }
  
  static bool isAuthError(String error) {
    return error.toLowerCase().contains('unauthorized') ||
           error.toLowerCase().contains('authentication') ||
           error.toLowerCase().contains('login');
  }
}