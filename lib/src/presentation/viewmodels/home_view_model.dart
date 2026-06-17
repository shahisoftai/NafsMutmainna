import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/checkin.dart';
import '../../domain/entities/nafs_history.dart';
import '../../domain/entities/vector4.dart';
import '../../domain/repositories/checkin_repository.dart';
import '../../domain/repositories/nafs_history_repository.dart';
import '../../domain/usecases/nafs/compute_daily_nafs.dart';
import '../../infrastructure/di/providers.dart';
import '../screens/home/utils/nafs_trend_helper.dart';
import '../screens/home/utils/next_action_resolver.dart';

class HomeState extends Equatable {
  final Vector4 meter;
  final NafsType dominant;
  final int heartHealthScore;
  final Checkin? lastCheckin;
  final int positiveStreak;
  final bool isLoading;
  final String? error;
  final bool hasLoaded;
  final NafsTrend trend;
  final List<int> sparkline;

  const HomeState({
    required this.meter,
    required this.dominant,
    required this.heartHealthScore,
    this.lastCheckin,
    this.positiveStreak = 0,
    this.isLoading = false,
    this.error,
    this.hasLoaded = false,
    this.trend = NafsTrend.none,
    this.sparkline = const [],
  });

  HomeState copyWith({
    Vector4? meter,
    NafsType? dominant,
    int? heartHealthScore,
    Checkin? lastCheckin,
    int? positiveStreak,
    bool? isLoading,
    String? error,
    bool? hasLoaded,
    NafsTrend? trend,
    List<int>? sparkline,
  }) =>
      HomeState(
        meter: meter ?? this.meter,
        dominant: dominant ?? this.dominant,
        heartHealthScore: heartHealthScore ?? this.heartHealthScore,
        lastCheckin: lastCheckin ?? this.lastCheckin,
        positiveStreak: positiveStreak ?? this.positiveStreak,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        hasLoaded: hasLoaded ?? this.hasLoaded,
        trend: trend ?? this.trend,
        sparkline: sparkline ?? this.sparkline,
      );

  @override
  List<Object?> get props => [
        meter,
        dominant,
        heartHealthScore,
        lastCheckin,
        positiveStreak,
        isLoading,
        error,
        hasLoaded,
        trend,
        sparkline,
      ];
}

class HomeViewModel extends StateNotifier<HomeState> {
  final Meter15Day _meter;
  final CheckinRepositoryInterface _checkinRepo;
  final NafsHistoryRepositoryInterface _historyRepo;
  final Streak _streak;
  final NafsTrendHelper _trendHelper;
  final NextActionResolver _actionResolver;

  HomeViewModel({
    required Meter15Day meter,
    required CheckinRepositoryInterface checkinRepo,
    required NafsHistoryRepositoryInterface historyRepo,
    required Streak streak,
    NafsTrendHelper trendHelper = const NafsTrendHelper(),
    NextActionResolver actionResolver = const NextActionResolver(),
  })  : _meter = meter,
        _checkinRepo = checkinRepo,
        _historyRepo = historyRepo,
        _streak = streak,
        _trendHelper = trendHelper,
        _actionResolver = actionResolver,
        super(HomeState(
          meter: Vector4.ammarahStartup,
          dominant: NafsType.ammarah,
          heartHealthScore: 0,
        ));

  /// Idempotent load. Used on screen mount so warm starts don't flash a
  /// spinner. First call performs the load; subsequent calls are no-ops until
  /// [load] is called explicitly (e.g. pull-to-refresh).
  Future<void> ensureLoaded() async {
    if (state.hasLoaded || state.isLoading) return;
    await load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final meterVec = await _meter(today);
      final last = await _checkinRepo.findLatest();
      final streak = await _streak.positiveStreakAsOf(today);

      // Persist today's row if missing (preserves existing behavior).
      final existingToday = await _historyRepo.findForDate(today);
        if (existingToday == null) {
        await _historyRepo.upsert(NafsHistory(
          id: 0,
          date: today,
          ammarah: Vector4.ammarahStartup.ammarah,
          lawwamah: Vector4.ammarahStartup.lawwamah,
          mulhamah: Vector4.ammarahStartup.mulhamah,
          mutmainnah: Vector4.ammarahStartup.mutmainnah,
        ));
      }

      // Trend vs yesterday.
      final yesterdayRow = await _historyRepo.findForDate(yesterday);
      final trend = _trendHelper.compute(
        today: existingToday,
        yesterday: yesterdayRow,
      );

      // 7-day sparkline of heart-health scores.
      final sparkStart = today.subtract(const Duration(days: 6));
      final sparkRows = await _historyRepo.findBetween(sparkStart, today);
      final spark = _trendHelper.sparklineScores(sparkRows);

      state = state.copyWith(
        meter: meterVec,
        dominant: meterVec.dominant,
        heartHealthScore: meterVec.heartHealthScore,
        lastCheckin: last,
        positiveStreak: streak,
        trend: trend,
        sparkline: spark,
        isLoading: false,
        hasLoaded: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        error: e.toString(),
      );
    }
  }

  /// Computes the contextual Next Action for the current state.
  NextAction nextAction({
    required HabitStatusCount habits,
    DateTime? now,
  }) {
    return _actionResolver.resolve(
      dominant: state.dominant,
      lastCheckin: state.lastCheckin?.date,
      positiveStreak: state.positiveStreak,
      habits: habits,
      now: now ?? DateTime.now(),
    );
  }
}

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(
    meter: ref.watch(meter15DayProvider),
    checkinRepo: ref.watch(checkinRepositoryProvider),
    historyRepo: ref.watch(nafsHistoryRepositoryProvider),
    streak: ref.watch(streakProvider),
  );
});
