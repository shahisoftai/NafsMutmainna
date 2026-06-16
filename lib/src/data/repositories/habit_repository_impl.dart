import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/local/app_database.dart';

class HabitRepositoryImpl implements HabitRepositoryInterface {
  final AppDatabase _db;
  HabitRepositoryImpl(this._db);

  @override
  Future<int> insertHabit(Habit h) async {
    return _db.db.insert('habits', {'Name': h.name, 'Category': h.category});
  }

  @override
  Future<List<Habit>> allHabits() async {
    final rows = await _db.db.query('habits', orderBy: 'Habit_ID ASC');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> deleteHabit(int id) async {
    await _db.db.delete('habits', where: 'Habit_ID = ?', whereArgs: [id]);
  }

  @override
  Future<void> logHabit(HabitLog log) async {
    await _db.db.rawInsert(
      '''INSERT INTO habit_logs (Date, Habit_ID, Completed) VALUES (?, ?, ?)
         ON CONFLICT(Date, Habit_ID) DO UPDATE SET Completed = excluded.Completed''',
      [isoDate(log.date), log.habitId, log.completed ? 1 : 0],
    );
  }

  @override
  Future<List<HabitLog>> logsBetween(DateTime start, DateTime end) async {
    final rows = await _db.db.query(
      'habit_logs',
      where: 'Date BETWEEN ? AND ?',
      whereArgs: [isoDate(start), isoDate(end)],
    );
    return rows.map(_fromLogRow).toList();
  }

  @override
  Future<int> activeHabitsCount() async {
    final r = await _db.db.rawQuery('SELECT COUNT(*) AS c FROM habits');
    return (r.first['c'] as int?) ?? 0;
  }

  @override
  Future<double> completionRateBetween(DateTime start, DateTime end) async {
    final r = await _db.db.rawQuery(
      'SELECT AVG(Completed) AS rate FROM habit_logs WHERE Date BETWEEN ? AND ?',
      [isoDate(start), isoDate(end)],
    );
    final v = r.first['rate'];
    if (v == null) return 0.0;
    return (v as num).toDouble();
  }

  Habit _fromRow(Map<String, Object?> r) => Habit(
        id: r['Habit_ID'] as int,
        name: r['Name'] as String,
        category: r['Category'] as String,
      );

  HabitLog _fromLogRow(Map<String, Object?> r) => HabitLog(
        id: r['Record_ID'] as int,
        date: parseIsoDate(r['Date'] as String),
        habitId: r['Habit_ID'] as int,
        completed: (r['Completed'] as int) == 1,
      );
}
