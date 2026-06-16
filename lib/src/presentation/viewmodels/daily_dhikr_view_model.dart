import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../infrastructure/di/providers.dart';
import '../screens/home/utils/daily_dhikr_resolver.dart';

class DailyDhikrState extends Equatable {
  final DailyDhikr dhikr;
  final bool isLoading;
  final String? error;

  const DailyDhikrState({
    this.dhikr = DailyDhikr.empty,
    this.isLoading = true,
    this.error,
  });

  DailyDhikrState copyWith({
    DailyDhikr? dhikr,
    bool? isLoading,
    String? error,
  }) =>
      DailyDhikrState(
        dhikr: dhikr ?? this.dhikr,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [dhikr, isLoading, error];
}

/// View model for the Daily Dhikr section.
///
/// Single Responsibility: compute today's dhikr + the 15-day aggregation of
/// Allah Names from the user's check-in history. The dominant Nafs state is
/// derived from today's NafsHistory (queried via the resolver) so this view
/// model is self-contained.
class DailyDhikrViewModel extends StateNotifier<DailyDhikrState> {
  final DailyDhikrResolver _resolver;

  DailyDhikrViewModel({required DailyDhikrResolver resolver})
      : _resolver = resolver,
        super(const DailyDhikrState()) {
    // Auto-load on construction. This fires both on first mount AND whenever
    // the provider is invalidated (e.g., after a check-in is submitted), so
    // the section always reflects the latest data.
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dominantNafs = await _resolver.resolveDominantNafs(
        today: DateTime.now(),
      );
      final result = await _resolver.resolve(
        today: DateTime.now(),
        dominantNafs: dominantNafs,
      );
      state = state.copyWith(dhikr: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dailyDhikrViewModelProvider =
    StateNotifierProvider<DailyDhikrViewModel, DailyDhikrState>((ref) {
  final resolver = DailyDhikrResolver(
    checkins: ref.watch(checkinRepositoryProvider),
    emotions: ref.watch(emotionRepositoryProvider),
    history: ref.watch(nafsHistoryRepositoryProvider),
  );
  return DailyDhikrViewModel(resolver: resolver);
});
