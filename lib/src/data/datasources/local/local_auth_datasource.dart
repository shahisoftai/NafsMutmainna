import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:nafsmutmainna/core/error/exception.dart';
import 'package:nafsmutmainna/core/logger/logger.dart';
import 'package:nafsmutmainna/src/domain/entities/user.dart';

/// Local data source for authentication.
abstract class ILocalAuthDataSource {
  /// Get cached user
  Future<User?> getCachedUser();

  /// Cache user
  Future<void> cacheUser(User user);

  /// Clear auth data
  Future<void> clearAuthData();
}

class LocalAuthDataSource implements ILocalAuthDataSource {
  static const String _userKey = 'user';
  final Box<String> _authBox;

  LocalAuthDataSource(this._authBox);

  @override
  Future<User?> getCachedUser() async {
    try {
      final userJson = _authBox.get(_userKey);
      if (userJson == null) return null;
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return User(
        id: map['id'] as String,
        email: map['email'] as String,
        displayName: map['display_name'] as String?,
        photoUrl: map['photo_url'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        lastLoginAt: map['last_login_at'] != null ? DateTime.parse(map['last_login_at'] as String) : null,
      );
    } catch (e) {
      Logger.error('LocalAuthDataSource: Failed to get cached user', error: e);
      throw LocalStorageException(message: 'Failed to read cached user', originalError: e);
    }
  }

  @override
  Future<void> cacheUser(User user) async {
    try {
      await _authBox.put(_userKey, jsonEncode({
        'id': user.id,
        'email': user.email,
        'display_name': user.displayName,
        'photo_url': user.photoUrl,
        'created_at': user.createdAt.toIso8601String(),
        'last_login_at': user.lastLoginAt?.toIso8601String(),
      }));
    } catch (e) {
      Logger.error('LocalAuthDataSource: Failed to cache user', error: e);
      throw LocalStorageException(message: 'Failed to cache user', originalError: e);
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await _authBox.clear();
    } catch (e) {
      Logger.error('LocalAuthDataSource: Failed to clear auth data', error: e);
      throw LocalStorageException(message: 'Failed to clear auth data', originalError: e);
    }
  }
}