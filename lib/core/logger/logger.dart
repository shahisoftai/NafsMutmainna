/// Logger utility following Single Responsibility Principle
/// Handles all logging operations in the application
class Logger {
  static const String _tag = 'NafsMutmainna';

  /// Log debug message
  static void debug(String message, {String? tag}) {
    _log('DEBUG', message, tag: tag);
  }

  /// Log info message
  static void info(String message, {String? tag}) {
    _log('INFO', message, tag: tag);
  }

  /// Log warning message
  static void warning(String message, {String? tag}) {
    _log('WARN', message, tag: tag);
  }

  /// Log error message
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, tag: tag);
    if (error != null) {
      _log('ERROR', 'Error: $error', tag: tag);
    }
    if (stackTrace != null) {
      _log('ERROR', 'StackTrace: $stackTrace', tag: tag);
    }
  }

  /// Log verbose message
  static void verbose(String message, {String? tag}) {
    _log('VERBOSE', message, tag: tag);
  }

  static void _log(String level, String message, {String? tag}) {
    final timestamp = DateTime.now().toIso8601String();
    final effectiveTag = tag ?? _tag;
    // In production, this would send to a logging service like Firebase Crashlytics
    // ignore: avoid_print
    print('[$timestamp][$level][$effectiveTag] $message');
  }
}