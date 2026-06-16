import '../../domain/entities/intervention_card.dart';
import '../../domain/entities/intervention_history.dart';
import '../../domain/repositories/intervention_history_repository.dart';
import '../datasources/local/app_database.dart';

class InterventionHistoryRepositoryImpl implements InterventionHistoryRepositoryInterface {
  final AppDatabase _db;
  InterventionHistoryRepositoryImpl(this._db);

  @override
  Future<int> insert(InterventionHistory row) async {
    // Use NULL for Attribute_ID if it's 0 (Dhikr/Action cards from emotion-level)
    final attributeId = row.attributeId == 0 ? null : row.attributeId;
    return _db.db.insert('interventions_history', {
      'Date': isoDate(row.date),
      'Emotion_ID': row.emotionId,
      'Attribute_ID': attributeId,
      'Intervention_Type': row.interventionType.storage,
      'Completed': row.completed ? 1 : 0,
      'Feedback': row.feedback?.storage,
    });
  }

  @override
  Future<List<InterventionHistory>> findRecent(int days) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final sinceDate = '${since.year.toString().padLeft(4, '0')}-${since.month.toString().padLeft(2, '0')}-${since.day.toString().padLeft(2, '0')}';
    final rows = await _db.db.query(
      'interventions_history',
      where: 'Date >= ?',
      whereArgs: [sinceDate],
      orderBy: 'Record_ID DESC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> markCompleted(int recordId, bool completed) async {
    await _db.db.update(
      'interventions_history',
      {'Completed': completed ? 1 : 0},
      where: 'Record_ID = ?',
      whereArgs: [recordId],
    );
  }

  @override
  Future<void> markFeedback(int recordId, InterventionFeedback feedback) async {
    await _db.db.update(
      'interventions_history',
      {'Feedback': feedback.storage},
      where: 'Record_ID = ?',
      whereArgs: [recordId],
    );
  }

  @override
  Future<int> countCompletedForToday(DateTime date) async {
    final result = await _db.db.rawQuery(
      'SELECT COUNT(*) AS c FROM interventions_history WHERE Date = ? AND Completed = 1',
      [isoDate(date)],
    );
    return (result.first['c'] as int?) ?? 0;
  }

  InterventionHistory _fromRow(Map<String, Object?> r) => InterventionHistory(
        id: r['Record_ID'] as int,
        date: parseIsoDate(r['Date'] as String),
        emotionId: r['Emotion_ID'] as int,
        attributeId: (r['Attribute_ID'] as int?) ?? 0,
        interventionType: InterventionTypeX.fromStorage(r['Intervention_Type'] as String),
        completed: (r['Completed'] as int) == 1,
        feedback: InterventionFeedbackX.fromStorage(r['Feedback'] as String?),
      );
}
