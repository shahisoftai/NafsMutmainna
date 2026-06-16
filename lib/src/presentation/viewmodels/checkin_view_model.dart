import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/emotion.dart';
import '../../domain/repositories/emotion_repository.dart';
import '../../infrastructure/di/providers.dart';

class CheckinState extends Equatable {
  final List<Emotion> emotions;
  final Emotion? primary;
  final int intensity;
  final String notes;
  final bool isLoading;
  final String? error;

  const CheckinState({
    this.emotions = const [],
    this.primary,
    this.intensity = 5,
    this.notes = '',
    this.isLoading = true,
    this.error,
  });

  CheckinState copyWith({
    List<Emotion>? emotions,
    Emotion? primary,
    int? intensity,
    String? notes,
    bool? isLoading,
    String? error,
  }) =>
      CheckinState(
        emotions: emotions ?? this.emotions,
        primary: primary ?? this.primary,
        intensity: intensity ?? this.intensity,
        notes: notes ?? this.notes,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [emotions, primary, intensity, notes, isLoading, error];
}

class CheckinViewModel extends StateNotifier<CheckinState> {
  final EmotionRepositoryInterface _emotions;

  CheckinViewModel(this._emotions) : super(const CheckinState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final all = await _emotions.getAll();
      state = state.copyWith(emotions: all, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectPrimary(Emotion e) => state = state.copyWith(primary: e);
  void setIntensity(int v) => state = state.copyWith(intensity: v);
  void setNotes(String s) => state = state.copyWith(notes: s);
}

final checkinViewModelProvider =
    StateNotifierProvider<CheckinViewModel, CheckinState>((ref) {
  return CheckinViewModel(ref.watch(emotionRepositoryProvider));
});
