class ApiConstants {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const String authUrl = 'http://localhost:8000/api/auth';
  
  // For production, replace with your actual server URL:
  // static const String baseUrl = 'https://your-django-server.com/api/v1';
  // static const String authUrl = 'https://your-django-server.com/api/auth';
  
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);
  
  // HTTP status codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;
}