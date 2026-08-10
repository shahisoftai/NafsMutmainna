import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../navigation/app_router.dart';
import '../../theme/colors.dart';
import '../../viewmodels/home_view_model.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/specific/heart_health_score_widget.dart';
import '../../widgets/specific/nafs_arc_meter.dart';
import '../../widgets/specific/nafs_station_origin_dialog.dart';
import '../../widgets/specific/quran_of_the_day_card.dart';
import '../../widgets/specific/tazkiya_safe_banner.dart';
import 'widgets/daily_dhikr_section.dart';
import 'widgets/home_greeting_widget.dart';
import 'widgets/today_habits_strip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Idempotent: only loads if the view model hasn't been pre-populated
    // (e.g. by the reflect screen's pre-load).
    Future.microtask(
      () => ref.read(homeViewModelProvider.notifier).ensureLoaded(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final showFullLoader = state.isLoading && !state.hasLoaded;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('NafsMutmainna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_tree_outlined),
            tooltip: 'Heart Graph',
            onPressed: () => context.push(AppRouter.heartGraph),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () => context.push(AppRouter.history),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRouter.settings),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(homeViewModelProvider.notifier).load(),
          child: showFullLoader
              ? const LoadingIndicator()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    HomeGreetingWidget(displayName: null, now: DateTime.now()),
                    const SizedBox(height: 12),
                    _primaryCta(context),
                    const SizedBox(height: 14),
                    // Nafs Meter at the top — it's the app's core visual.
                    NafsArcMeter(
                      vector: state.meter,
                      dominant: state.dominant,
                      onTap: () => context.push(AppRouter.nafsDetail),
                      onLearnMore: () =>
                          NafsStationOriginDialog.show(context),
                    ),
                    // RI-5.1: Tazkiya-safe banner — reminds the user the meter
                    // reflects patterns, never judgment of the soul.
                    const TazkiyaSafeBanner(),
                    const SizedBox(height: 14),
                    HeartHealthScoreWidget(
                      score: state.heartHealthScore,
                      trend: state.trend,
                      tip: _heartHealthTip(state.heartHealthScore),
                    ),
                    const SizedBox(height: 16),
                    // RI-5.3: Quran of the Day — anchors the user in Quran
                    // independent of any emotion.
                    const QuranOfTheDayCard(),
                    const SizedBox(height: 16),
                    TodayHabitsStrip(
                      onManageTap: () => context.push(AppRouter.habits),
                    ),
                    const SizedBox(height: 16),
                    const DailyDhikrSection(),
                    const SizedBox(height: 16),
                    if (state.lastCheckin != null) _lastCheckinRow(state),
                    if (state.positiveStreak > 0)
                      _streakRow(state.positiveStreak),
                    const SizedBox(height: 12),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _primaryCta(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () => context.push(AppRouter.checkin),
        icon: const Icon(Icons.favorite, color: AppColors.textOnPrimary),
        label: const Text(
          'Begin check-in',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textOnPrimary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  String? _heartHealthTip(int score) {
    if (score >= 80) {
      return 'Mutmainnah — inner peace and trust in Allah.';
    } else if (score >= 60) {
      return 'Mulhamah — walking the inspired path.';
    } else if (score >= 40) {
      return 'Lawwamah — conscience is alive. Keep going.';
    } else if (score >= 20) {
      return 'Awakening. Try a 5-min Quran reflection.';
    }
    return 'Ammarah — heedlessness. Start with one small dhikr.';
  }

  Widget _lastCheckinRow(HomeState s) {
    final c = s.lastCheckin!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Last check-in: ${DateFormat.yMMMd().add_jm().format(c.date)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _streakRow(int streak) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: AppColors.accent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            '$streak-day positive streak',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
