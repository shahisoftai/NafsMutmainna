import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nafsmutmainna/core/error/exception.dart';
import 'package:nafsmutmainna/core/logger/logger.dart';

/// Secure storage service following Single Responsibility Principle
/// Handles all secure storage operations
class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Write a value securely
  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
      Logger.debug('SecureStorage: Wrote key=$key', tag: 'SecureStorage');
    } catch (e) {
      Logger.error('SecureStorage: Failed to write key=$key', error: e);
      throw LocalStorageException(
        message: 'Failed to write to secure storage',
        originalError: e,
      );
    }
  }

  /// Read a value securely
  Future<String?> read({required String key}) async {
    try {
      final value = await _storage.read(key: key);
      Logger.debug('SecureStorage: Read key=$key', tag: 'SecureStorage');
      return value;
    } catch (e) {
      Logger.error('SecureStorage: Failed to read key=$key', error: e);
      throw LocalStorageException(
        message: 'Failed to read from secure storage',
        originalError: e,
      );
    }
  }

  /// Delete a value securely
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
      Logger.debug('SecureStorage: Deleted key=$key', tag: 'SecureStorage');
    } catch (e) {
      Logger.error('SecureStorage: Failed to delete key=$key', error: e);
      throw LocalStorageException(
        message: 'Failed to delete from secure storage',
        originalError: e,
      );
    }
  }

  /// Delete all values
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      Logger.debug('SecureStorage: Deleted all', tag: 'SecureStorage');
    } catch (e) {
      Logger.error('SecureStorage: Failed to delete all', error: e);
      throw LocalStorageException(
        message: 'Failed to clear secure storage',
        originalError: e,
      );
    }
  }

  /// Check if a key exists
  Future<bool> containsKey({required String key}) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      Logger.error('SecureStorage: Failed to check key=$key', error: e);
      throw LocalStorageException(
        message: 'Failed to check key in secure storage',
        originalError: e,
      );
    }
  }
}