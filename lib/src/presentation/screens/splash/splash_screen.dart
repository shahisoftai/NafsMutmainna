import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/logger/logger.dart';
import 'package:nafsmutmainna/src/core/services/app_update_service.dart';
import '../../../infrastructure/di/providers.dart';
import '../../navigation/app_router.dart';
import '../../theme/colors.dart';
import '../../viewmodels/checkin_view_model.dart';
import '../../viewmodels/privacy_lock_view_model.dart';

const String _kAppVersion = '1.1.18';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_init);
  }

  Future<void> _init() async {
    try {
      final db = ref.read(appDatabaseProvider);
      await db.open();
      await ref.read(checkinViewModelProvider.notifier).load();
    } catch (e) {
      Logger.error('First database init failed: $e');
      // Retry once — the upgrade / seed may have completed partially and will
      // pick up where it left off.
      try {
        final db = ref.read(appDatabaseProvider);
        await db.open();
        await ref.read(checkinViewModelProvider.notifier).load();
      } catch (e2) {
        Logger.error('Second database init failed: $e2');
      }
    }
    if (!mounted) return;

    // Complete any pending flexible update from a prior session first.
    // This MUST be awaited — it may trigger a Play Store install dialog.
    await AppUpdateService.instance.completeFlexibleUpdate();

    if (!mounted) return;

    // Check for a new Play Store update. Fire-and-forget: we never block
    // the user on a background download. Failures are logged internally.
    AppUpdateService.instance.checkAndStartFlexibleUpdate();

    // Route to onboarding on first launch; home on every subsequent launch.
    // The `hasSeenOnboardingProvider` reads from the prefs Hive box opened
    // in main(). If reading fails for any reason we fall back to home so the
    // user is never stranded on the splash.
    bool hasSeenOnboarding = false;
    try {
      final seen = await ref.read(hasSeenOnboardingProvider.future);
      hasSeenOnboarding = seen;
    } catch (e) {
      Logger.error('hasSeenOnboarding read failed: $e');
    }
    if (!mounted) return;

    bool privacyLockEnabled = false;
    try {
      final lockNotifier = ref.read(privacyLockProvider.notifier);
      await lockNotifier.checkInitialState();
      final lockState = ref.read(privacyLockProvider);
      privacyLockEnabled = lockState.isEnabled;
    } catch (e) {
      Logger.error('Privacy lock check failed: $e');
    }

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      context.go(AppRouter.onboarding);
    } else if (privacyLockEnabled) {
      ref.read(privacyLockProvider.notifier).setAuthenticated(false);
      context.go(AppRouter.lock);
    } else {
      context.go(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _Logo(),
              const SizedBox(height: 24),
              const Text(
                'HeartOS',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textOnPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Spiritual Self-Improvement',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'v$_kAppVersion',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textOnPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders the HeartOS logo from the bundled asset. A square white
/// "card" backdrop is used so transparent / irregular logos remain
/// visible against the brand-green background.
///
/// Size is derived from the screen width (clamped) so the logo never
/// gets clipped on narrow devices and never overwhelms the screen on
/// tablets. Internal padding is generous to keep the logo visually
/// inset from the rounded card edge.
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // 32% of width, clamped between 96 and 140 px. Generous horizontal
    // padding (24% of size) prevents edge clipping on any device.
    final size = screenWidth * 0.32;
    final clamped = size.clamp(96.0, 140.0);
    final radius = clamped * 0.22;
    final innerRadius = clamped * 0.16;
    final padding = clamped * 0.20;

    return Container(
      width: clamped,
      height: clamped,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: Image.asset(
          'assets/images/heartos_logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
