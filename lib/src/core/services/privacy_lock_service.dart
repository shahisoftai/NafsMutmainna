import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class PrivacyLockService {
  static const String _kPinKey = 'privacy_lock_pin';
  static const String _kEnabledKey = 'privacy_lock_enabled';
  static const String _kHasSetupPinKey = 'privacy_lock_has_pin';

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  PrivacyLockService()
      : _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
        ),
        _localAuth = LocalAuthentication();

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<bool> isPinSetUp() async {
    final value = await _secureStorage.read(key: _kHasSetupPinKey);
    return value == '1';
  }

  Future<bool> isEnabled() async {
    final value = await _secureStorage.read(key: _kEnabledKey);
    return value == '1';
  }

  Future<void> setEnabled(bool enabled) async {
    await _secureStorage.write(key: _kEnabledKey, value: enabled ? '1' : '0');
  }

  Future<void> setupPin(String pin) async {
    final hashedPin = _hashPin(pin);
    await _secureStorage.write(key: _kPinKey, value: hashedPin);
    await _secureStorage.write(key: _kHasSetupPinKey, value: '1');
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = await _secureStorage.read(key: _kPinKey);
    if (storedHash == null) return false;
    return _hashPin(pin) == storedHash;
  }

  Future<bool> canUseBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isAvailable || !isDeviceSupported) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access HeartOS',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate() async {
    final biometricAvailable = await canUseBiometrics();
    if (biometricAvailable) {
      final success = await authenticateWithBiometrics();
      if (success) return true;
    }
    return false;
  }

  Future<void> clearPin() async {
    await _secureStorage.delete(key: _kPinKey);
    await _secureStorage.delete(key: _kHasSetupPinKey);
  }

  Future<void> disable() async {
    await _secureStorage.write(key: _kEnabledKey, value: '0');
  }

  Future<void> reset() async {
    await _secureStorage.delete(key: _kPinKey);
    await _secureStorage.delete(key: _kHasSetupPinKey);
    await _secureStorage.delete(key: _kEnabledKey);
  }
}
