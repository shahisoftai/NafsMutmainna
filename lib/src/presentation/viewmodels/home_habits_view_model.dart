import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../infrastructure/di/providers.dart';
import '../screens/home/utils/habit_category_resolver.dart';

/// A habit paired with its completion status for today and visual metadata.
class HabitWithStatus extends Equatable {
  final Habit habit;
  final bool completedToday;
  final IconData icon;
  final int colorValue;

  const HabitWithStatus({
    required this.habit,
    required this.completedToday,
    required this.icon,
    required this.colorValue,
  });

  @override
  List<Object?> get props => [habit, completedToday, icon, colorValue];
}

class HomeHabitsState extends Equatable {
  final List<HabitWithStatus> habits;
  final bool isLoading;
  final String? error;

  const HomeHabitsState({
    this.habits = const [],
    this.isLoading = true,
    this.error,
  });

  int get doneCount => habits.where((h) => h.completedToday).length;
  int get totalCount => habits.length;
  double get completionRatio =>
      totalCount == 0 ? 0 : doneCount / totalCount;

  HomeHabitsState copyWith({
    List<HabitWithStatus>? habits,
    bool? isLoading,
    String? error,
  }) =>
      HomeHabitsState(
        habits: habits ?? this.habits,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [habits, isLoading, error];
}

/// View model for the Today's Habits strip on the home page.
///
/// Kept separate from the main HomeViewModel so toggling a habit does not
/// rebuild the entire dashboard. Single Responsibility: this view model
/// owns habits + their today's status; nothing else.
class HomeHabitsViewModel extends StateNotifier<HomeHabitsState> {
  final HabitRepositoryInterface _repo;
  final HabitCategoryResolver _categoryResolver;

  HomeHabitsViewModel({
    required HabitRepositoryInterface repo,
    HabitCategoryResolver categoryResolver = const HabitCategoryResolver(),
  })  : _repo = repo,
        _categoryResolver = categoryResolver,
        super(const HomeHabitsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final today = _dateOnly(DateTime.now());
      final habits = await _repo.allHabits();
      final logs = await _repo.logsBetween(today, today);
      final completedById = <int>{
        for (final l in logs)
          if (l.completed) l.habitId,
      };
      final enriched = habits.map((h) {
        final style = _categoryResolver.resolve(h.category);
        return HabitWithStatus(
          habit: h,
          completedToday: completedById.contains(h.id),
          icon: style.icon,
          colorValue: style.color.toARGB32(),
        );
      }).toList();
      state = state.copyWith(habits: enriched, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Optimistic toggle: flip the in-memory state immediately, then persist.
  /// On error, revert and surface the error.
  Future<void> toggle(HabitWithStatus h) async {
    final previous = state;
    final updated = state.habits
        .map((x) => x.habit.id == h.habit.id
            ? HabitWithStatus(
                habit: x.habit,
                completedToday: !x.completedToday,
                icon: x.icon,
                colorValue: x.colorValue,
              )
            : x)
        .toList();
    state = state.copyWith(habits: updated);
    try {
      await _repo.logHabit(HabitLog(
        id: 0,
        date: DateTime.now(),
        habitId: h.habit.id,
        completed: !h.completedToday,
      ));
    } catch (e) {
      state = previous.copyWith(error: e.toString());
    }
  }

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);
}

final homeHabitsViewModelProvider =
    StateNotifierProvider<HomeHabitsViewModel, HomeHabitsState>((ref) {
  return HomeHabitsViewModel(
    repo: ref.watch(habitRepositoryProvider),
  );
});
