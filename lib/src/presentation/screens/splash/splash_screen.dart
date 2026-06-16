import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/logger/logger.dart';
import '../../../infrastructure/di/providers.dart';
import '../../theme/colors.dart';
import '../../viewmodels/checkin_view_model.dart';

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
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.spa, size: 80, color: AppColors.textOnPrimary),
            SizedBox(height: 16),
            Text(
              'HeartOS',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Spiritual Self-Improvement',
              style: TextStyle(fontSize: 14, color: AppColors.textOnPrimary),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
