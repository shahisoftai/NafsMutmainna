import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/di/providers.dart';
import '../screens/home/utils/daily_dhikr_resolver.dart';

class JourneyState extends Equatable {
  final JourneyData data;
  final bool isLoading;
  final String? error;

  const JourneyState({
    this.data = JourneyData.empty,
    this.isLoading = true,
    this.error,
  });

  JourneyState copyWith({
    JourneyData? data,
    bool? isLoading,
    String? error,
  }) =>
      JourneyState(
        data: data ?? this.data,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [data, isLoading, error];
}

class JourneyViewModel extends StateNotifier<JourneyState> {
  final DailyDhikrResolver _resolver;

  JourneyViewModel({required DailyDhikrResolver resolver})
      : _resolver = resolver,
        super(const JourneyState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _resolver.resolveJourney(today: DateTime.now());
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final journeyViewModelProvider =
    StateNotifierProvider<JourneyViewModel, JourneyState>((ref) {
  final resolver = DailyDhikrResolver(
    checkins: ref.watch(checkinRepositoryProvider),
    emotions: ref.watch(emotionRepositoryProvider),
    history: ref.watch(nafsHistoryRepositoryProvider),
  );
  return JourneyViewModel(resolver: resolver);
});
