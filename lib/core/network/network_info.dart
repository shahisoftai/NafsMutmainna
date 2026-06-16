import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nafsmutmainna/core/error/exception.dart';

/// Network information service following Single Responsibility Principle
/// Checks network connectivity status
class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  /// Check if device is connected to the internet
  Future<bool> get isConnected async {
    try {
      final result = await _connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      throw const NetworkException(
        message: 'Failed to check network connectivity',
      );
    }
  }

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) => !results.contains(ConnectivityResult.none),
    );
  }
}