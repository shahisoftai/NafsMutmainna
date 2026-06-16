import '../entities/habit.dart';

abstract class HabitRepositoryInterface {
  Future<int> insertHabit(Habit h);
  Future<List<Habit>> allHabits();
  Future<void> deleteHabit(int id);
  Future<void> logHabit(HabitLog log);
  Future<List<HabitLog>> logsBetween(DateTime start, DateTime end);
  Future<int> activeHabitsCount();
  Future<double> completionRateBetween(DateTime start, DateTime end);
}
