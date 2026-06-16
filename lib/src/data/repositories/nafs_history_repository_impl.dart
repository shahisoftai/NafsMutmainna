import '../../domain/entities/nafs_history.dart';
import '../../domain/repositories/nafs_history_repository.dart';
import '../datasources/local/app_database.dart';

class NafsHistoryRepositoryImpl implements NafsHistoryRepositoryInterface {
  final AppDatabase _db;
  NafsHistoryRepositoryImpl(this._db);

  @override
  Future<void> upsert(NafsHistory row) async {
    await _db.db.rawInsert(
      '''INSERT INTO nafs_history (Date, Ammarah, Lawwamah, Mulhamah, Mutmainnah)
         VALUES (?, ?, ?, ?, ?)
         ON CONFLICT(Date) DO UPDATE SET
           Ammarah = excluded.Ammarah,
           Lawwamah = excluded.Lawwamah,
           Mulhamah = excluded.Mulhamah,
           Mutmainnah = excluded.Mutmainnah''',
      [isoDate(row.date), row.ammarah, row.lawwamah, row.mulhamah, row.mutmainnah],
    );
  }

  @override
  Future<NafsHistory?> findForDate(DateTime d) async {
    final rows = await _db.db.query('nafs_history', where: 'Date = ?', whereArgs: [isoDate(d)], limit: 1);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<List<NafsHistory>> findBetween(DateTime start, DateTime end) async {
    final rows = await _db.db.query(
      'nafs_history',
      where: 'Date BETWEEN ? AND ?',
      whereArgs: [isoDate(start), isoDate(end)],
      orderBy: 'Date ASC',
    );
    return rows.map(_fromRow).toList();
  }

  NafsHistory _fromRow(Map<String, Object?> r) => NafsHistory(
        id: r['Record_ID'] as int,
        date: parseIsoDate(r['Date'] as String),
        ammarah: (r['Ammarah'] as num).toDouble(),
        lawwamah: (r['Lawwamah'] as num).toDouble(),
        mulhamah: (r['Mulhamah'] as num).toDouble(),
        mutmainnah: (r['Mutmainnah'] as num).toDouble(),
      );
}
