import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Following the Either pattern for functional error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Network-related failure
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });
}

/// Server-side failure
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
  });
}

/// Local storage failure
class LocalStorageFailure extends Failure {
  const LocalStorageFailure({
    required super.message,
    super.code,
  });
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });
}

/// Authentication failure
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    required super.message,
    super.code,
  });
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

/// Unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    required super.message,
    super.code,
  });
}