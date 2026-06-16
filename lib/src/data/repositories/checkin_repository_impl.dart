import '../../domain/entities/checkin.dart';
import '../../domain/repositories/checkin_repository.dart';
import '../datasources/local/app_database.dart';

class CheckinRepositoryImpl implements CheckinRepositoryInterface {
  final AppDatabase _db;
  CheckinRepositoryImpl(this._db);

  @override
  Future<int> insert(Checkin c) async {
    return _db.db.insert('checkins', {
      if (c.id != 0) 'Checkin_ID': c.id,
      'Date': isoDate(c.date),
      'Emotion_ID': c.emotionId,
      'Intensity': c.intensity,
      'Notes': c.notes,
    });
  }

  @override
  Future<List<Checkin>> findForDate(DateTime d) async {
    final rows = await _db.db.query('checkins', where: 'Date = ?', whereArgs: [isoDate(d)], orderBy: 'Checkin_ID ASC');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<Checkin>> findBetween(DateTime start, DateTime end) async {
    final rows = await _db.db.query(
      'checkins',
      where: 'Date BETWEEN ? AND ?',
      whereArgs: [isoDate(start), isoDate(end)],
      orderBy: 'Checkin_ID ASC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<Checkin?> findLatest() async {
    final rows = await _db.db.query('checkins', orderBy: 'Checkin_ID DESC', limit: 1);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<int> deleteForDate(DateTime d) async {
    return _db.db.delete('checkins', where: 'Date = ?', whereArgs: [isoDate(d)]);
  }

  Checkin _fromRow(Map<String, Object?> r) => Checkin(
        id: r['Checkin_ID'] as int,
        date: parseIsoDate(r['Date'] as String),
        emotionId: r['Emotion_ID'] as int,
        intensity: r['Intensity'] as int,
        notes: r['Notes'] as String?,
      );
}
