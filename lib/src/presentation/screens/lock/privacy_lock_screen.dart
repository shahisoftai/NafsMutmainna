import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/app_router.dart';
import '../../theme/colors.dart';
import '../../viewmodels/privacy_lock_view_model.dart';

class PrivacyLockScreen extends ConsumerStatefulWidget {
  final bool isSetupMode;

  const PrivacyLockScreen({super.key, this.isSetupMode = false});

  @override
  ConsumerState<PrivacyLockScreen> createState() => _PrivacyLockScreenState();
}

class _PrivacyLockScreenState extends ConsumerState<PrivacyLockScreen> {
  final List<TextEditingController> _pinControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isConfirming = false;
  String _firstPin = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _showBiometricOption = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLock();
    });
  }

  Future<void> _initializeLock() async {
    final notifier = ref.read(privacyLockProvider.notifier);
    await notifier.checkInitialState();

    final state = ref.read(privacyLockProvider);
    setState(() {
      _showBiometricOption = state.canUseBiometrics && !widget.isSetupMode;
    });

    if (_showBiometricOption) {
      _attemptBiometricAuth();
    }
  }

  @override
  void dispose() {
    for (final controller in _pinControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _currentPin {
    return _pinControllers.map((c) => c.text).join();
  }

  void _clearPin() {
    for (final controller in _pinControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _onPinDigitChanged(int index, String value) async {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        await _handlePinComplete();
      }
    }
    setState(() {});
  }

  Future<void> _handlePinComplete() async {
    if (_currentPin.length != 6) return;

    if (widget.isSetupMode) {
      if (!_isConfirming) {
        setState(() {
          _firstPin = _currentPin;
          _isConfirming = true;
          _errorMessage = null;
        });
        _clearPin();
      } else {
        if (_currentPin == _firstPin) {
          setState(() => _isLoading = true);
          await ref.read(privacyLockProvider.notifier).setupPin(_firstPin);
          await ref.read(privacyLockProvider.notifier).setEnabled(true);
          if (mounted) {
            context.go(AppRouter.home);
          }
        } else {
          setState(() {
            _errorMessage = 'PINs do not match. Try again.';
            _isConfirming = false;
            _firstPin = '';
          });
          _clearPin();
        }
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = true);
      final success = await ref.read(privacyLockProvider.notifier).verifyPin(_currentPin);
      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          context.go(AppRouter.home);
        }
      } else {
        setState(() {
          _errorMessage = 'Incorrect PIN. Try again.';
        });
        _clearPin();
      }
    }
  }

  Future<void> _attemptBiometricAuth() async {
    setState(() => _isLoading = true);
    final success = await ref.read(privacyLockProvider.notifier).authenticateWithBiometrics();
    setState(() => _isLoading = false);

    if (success && mounted) {
      context.go(AppRouter.home);
    }
  }

  void _onKeyTap(String value) {
    HapticFeedback.lightImpact();
    final currentIndex = _pinControllers.indexWhere((c) => c.text.isEmpty);
    if (currentIndex == -1) return;

    _pinControllers[currentIndex].text = value;
    _onPinDigitChanged(currentIndex, value);
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    final currentIndex = _pinControllers.indexWhere((c) => c.text.isEmpty);
    final indexToClear = currentIndex == -1 ? 5 : currentIndex - 1;
    if (indexToClear >= 0) {
      _pinControllers[indexToClear].clear();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                ),
              )
            : Column(
                children: [
                  const Spacer(),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildPinDots(),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const Spacer(),
                  _buildKeypad(),
                  const SizedBox(height: 24),
                  if (_showBiometricOption) ...[
                    _buildBiometricButton(),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    String title;
    String subtitle;

    if (widget.isSetupMode) {
      if (_isConfirming) {
        title = 'Confirm PIN';
        subtitle = 'Enter your PIN again to confirm';
      } else {
        title = 'Set up PIN';
        subtitle = 'Create a 6-digit PIN to secure your app';
      }
    } else {
      title = 'HeartOS Locked';
      subtitle = 'Enter your PIN or use biometrics';
    }

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/images/heartos_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textOnPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textOnPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isFilled = index < _currentPin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? Colors.white : Colors.transparent,
            border: Border.all(color: Colors.white, width: 2),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['1', '2', '3'].map((d) => _buildKey(d)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['4', '5', '6'].map((d) => _buildKey(d)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['7', '8', '9'].map((d) => _buildKey(d)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 72),
              _buildKey('0'),
              _buildBackspaceKey(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String digit) {
    return InkWell(
      onTap: () => _onKeyTap(digit),
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return InkWell(
      onTap: _onBackspace,
      borderRadius: BorderRadius.circular(36),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Icon(
          Icons.backspace_outlined,
          color: AppColors.textOnPrimary.withValues(alpha: 0.8),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return TextButton.icon(
      onPressed: _attemptBiometricAuth,
      icon: const Icon(Icons.fingerprint, color: AppColors.textOnPrimary),
      label: const Text(
        'Use Biometrics',
        style: TextStyle(color: AppColors.textOnPrimary),
      ),
    );
  }
}
