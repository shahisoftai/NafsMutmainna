import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/services/privacy_lock_service.dart';

final privacyLockServiceProvider = Provider<PrivacyLockService>((ref) {
  return PrivacyLockService();
});

final privacyLockEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(privacyLockServiceProvider);
  return service.isEnabled();
});

final canUseBiometricsProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(privacyLockServiceProvider);
  return service.canUseBiometrics();
});

final availableBiometricsProvider = FutureProvider<List<BiometricType>>((ref) async {
  final service = ref.watch(privacyLockServiceProvider);
  return service.getAvailableBiometrics();
});

final isPinSetUpProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(privacyLockServiceProvider);
  return service.isPinSetUp();
});

class PrivacyLockNotifier extends StateNotifier<PrivacyLockState> {
  final PrivacyLockService _service;

  PrivacyLockNotifier(this._service) : super(PrivacyLockState.initial());

  Future<void> checkInitialState() async {
    final isEnabled = await _service.isEnabled();
    final isPinSetUp = await _service.isPinSetUp();
    final canUseBiometrics = await _service.canUseBiometrics();

    state = state.copyWith(
      isEnabled: isEnabled,
      isPinSetUp: isPinSetUp,
      canUseBiometrics: canUseBiometrics,
      isLoading: false,
    );
  }

  Future<void> setupPin(String pin) async {
    await _service.setupPin(pin);
    state = state.copyWith(isPinSetUp: true);
  }

  Future<bool> verifyPin(String pin) async {
    final success = await _service.verifyPin(pin);
    if (success) {
      state = state.copyWith(isAuthenticated: true);
    }
    return success;
  }

  Future<bool> authenticateWithBiometrics() async {
    final success = await _service.authenticateWithBiometrics();
    if (success) {
      state = state.copyWith(isAuthenticated: true);
    }
    return success;
  }

  Future<void> setEnabled(bool enabled) async {
    await _service.setEnabled(enabled);
    state = state.copyWith(isEnabled: enabled);
  }

  Future<void> disable() async {
    await _service.disable();
    state = state.copyWith(isEnabled: false);
  }

  void setAuthenticated(bool value) {
    state = state.copyWith(isAuthenticated: value);
  }

  void reset() {
    state = PrivacyLockState.initial();
  }
}

final privacyLockProvider = StateNotifierProvider<PrivacyLockNotifier, PrivacyLockState>((ref) {
  final service = ref.watch(privacyLockServiceProvider);
  return PrivacyLockNotifier(service);
});

class PrivacyLockState {
  final bool isEnabled;
  final bool isPinSetUp;
  final bool canUseBiometrics;
  final bool isAuthenticated;
  final bool isLoading;

  PrivacyLockState({
    required this.isEnabled,
    required this.isPinSetUp,
    required this.canUseBiometrics,
    required this.isAuthenticated,
    required this.isLoading,
  });

  factory PrivacyLockState.initial() {
    return PrivacyLockState(
      isEnabled: false,
      isPinSetUp: false,
      canUseBiometrics: false,
      isAuthenticated: false,
      isLoading: true,
    );
  }

  PrivacyLockState copyWith({
    bool? isEnabled,
    bool? isPinSetUp,
    bool? canUseBiometrics,
    bool? isAuthenticated,
    bool? isLoading,
  }) {
    return PrivacyLockState(
      isEnabled: isEnabled ?? this.isEnabled,
      isPinSetUp: isPinSetUp ?? this.isPinSetUp,
      canUseBiometrics: canUseBiometrics ?? this.canUseBiometrics,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
