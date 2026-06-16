import 'package:nafsmutmainna/core/error/exception.dart';

/// Centralized error handler following SOLID principles
/// Handles different exception types and converts them to user-friendly messages
class ErrorHandler {
  /// Handle exception and return appropriate message
  String handleException(AppException exception) {
    switch (exception) {
      case NetworkException():
        return _handleNetworkException(exception);
      case LocalStorageException():
        return _handleLocalStorageException(exception);
      case RemoteDataException():
        return _handleRemoteDataException(exception);
      case ValidationException():
        return _handleValidationException(exception);
      case AuthenticationException():
        return _handleAuthenticationException(exception);
      case CacheException():
        return _handleCacheException(exception);
      case TimeoutException():
        return _handleTimeoutException(exception);
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  String _handleNetworkException(NetworkException e) {
    // Single responsibility: Network error handling
    if (e.message.contains('No internet')) {
      return 'Please check your internet connection and try again.';
    }
    if (e.message.contains('timeout')) {
      return 'The request timed out. Please try again.';
    }
    return 'Network error occurred. Please try again later.';
  }

  String _handleLocalStorageException(LocalStorageException e) {
    // Single responsibility: Local storage error handling
    return 'Failed to access local storage. Please restart the app.';
  }

  String _handleRemoteDataException(RemoteDataException e) {
    // Single responsibility: Remote data error handling
    if (e.code == '404') {
      return 'The requested resource was not found.';
    }
    if (e.code == '500') {
      return 'Server error. Please try again later.';
    }
    return 'Failed to fetch data. Please try again.';
  }

  String _handleValidationException(ValidationException e) {
    // Single responsibility: Validation error handling
    return e.message;
  }

  String _handleAuthenticationException(AuthenticationException e) {
    // Single responsibility: Authentication error handling
    if (e.code == 'invalid_credentials') {
      return 'Invalid email or password.';
    }
    if (e.code == 'session_expired') {
      return 'Your session has expired. Please log in again.';
    }
    return 'Authentication failed. Please try again.';
  }

  String _handleCacheException(CacheException e) {
    // Single responsibility: Cache error handling
    return 'Failed to load cached data. Please refresh.';
  }

  String _handleTimeoutException(TimeoutException e) {
    // Single responsibility: Timeout error handling
    return 'Request timed out. Please check your connection and try again.';
  }
}