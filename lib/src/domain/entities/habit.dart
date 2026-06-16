import 'package:equatable/equatable.dart';

/// A user-defined daily habit.
class Habit extends Equatable {
  final int id;
  final String name;
  final String category; // Prayer | Quran | Dhikr | Charity | Exercise | Other

  const Habit({
    required this.id,
    required this.name,
    required this.category,
  });

  @override
  List<Object?> get props => [id, name, category];
}

/// A daily log of habit completion.
class HabitLog extends Equatable {
  final int id;
  final DateTime date;
  final int habitId;
  final bool completed;

  const HabitLog({
    required this.id,
    required this.date,
    required this.habitId,
    required this.completed,
  });

  @override
  List<Object?> get props => [id, date, habitId, completed];
}
