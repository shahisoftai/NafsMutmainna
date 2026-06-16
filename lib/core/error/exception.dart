import 'package:equatable/equatable.dart';

/// Base class for all exceptions in the application
abstract class AppException extends Equatable {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Exception for network-related errors
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for local storage errors
class LocalStorageException extends AppException {
  const LocalStorageException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for remote data source errors
class RemoteDataException extends AppException {
  const RemoteDataException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for validation errors
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for authentication errors
class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for cache errors
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for timeout errors
class TimeoutException extends AppException {
  const TimeoutException({
    required super.message,
    super.code,
    super.originalError,
  });
}