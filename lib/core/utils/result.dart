import 'package:dartz/dartz.dart';
import 'package:nafsmutmainna/core/error/failure.dart';

/// Result type for functional error handling
/// Following the Either pattern from functional programming
typedef Result<T> = Either<Failure, T>;

/// Extension methods for Result
extension ResultExtensions<T> on Result<T> {
  /// Map the success value
  Result<R> map<R>(R Function(T) mapper) {
    return fold(
      (failure) => Left(failure),
      (value) => Right(mapper(value)),
    );
  }

  /// Map the success value asynchronously
  Future<Result<R>> mapAsync<R>(Future<R> Function(T) mapper) async {
    return fold(
      (failure) => Left(failure),
      (value) async => Right(await mapper(value)),
    );
  }

  /// Fold the result to a single value
  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) {
    return this.fold(onFailure, onSuccess);
  }

  /// Get the value or null
  T? getOrNull() {
    return fold((_) => null, (value) => value);
  }

  /// Get the value or throw
  T getOrThrow() {
    return fold(
      (failure) => throw Exception(failure.message),
      (value) => value,
    );
  }
}