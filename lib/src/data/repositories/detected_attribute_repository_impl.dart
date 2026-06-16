import '../../domain/entities/detected_attribute.dart';
import '../../domain/repositories/detected_attribute_repository.dart';
import '../datasources/local/app_database.dart';

class DetectedAttributeRepositoryImpl
    implements DetectedAttributeRepositoryInterface {
  final AppDatabase _db;
  DetectedAttributeRepositoryImpl(this._db);

  @override
  Future<void> upsertMany(
    List<({DateTime date, int attributeId, double score, String role})> rows,
  ) async {
    if (rows.isEmpty) return;
    final batch = _db.db.batch();
    for (final r in rows) {
      // Scores are ADDITIVE across multiple check-ins on the same day for the
      // same (attribute, role) pair, capped at 1.0.
      // This matches detected_attributes.md §3:
      //   "ON CONFLICT … SET Score = Score + excluded.Score"  (capped at 1.0)
      //
      // The unique key is (Date, Attribute_ID, Role) so that Disease and Core
      // entries for the same attribute are stored as separate rows, preserving
      // full role context for the Insight screen.
      batch.rawInsert(
        '''INSERT INTO detected_attributes (Date, Attribute_ID, Score, Role)
           VALUES (?, ?, ?, ?)
           ON CONFLICT(Date, Attribute_ID, Role)
           DO UPDATE SET Score = MIN(Score + excluded.Score, 1.0)''',
        [isoDate(r.date), r.attributeId, r.score, r.role],
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<DetectedAttribute>> findForDate(DateTime d) async {
    final rows = await _db.db.query(
      'detected_attributes',
      where: 'Date = ?',
      whereArgs: [isoDate(d)],
      orderBy: 'Score DESC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> deleteForDate(DateTime d) async {
    await _db.db.delete(
      'detected_attributes',
      where: 'Date = ?',
      whereArgs: [isoDate(d)],
    );
  }

  DetectedAttribute _fromRow(Map<String, Object?> r) => DetectedAttribute(
        id: r['Record_ID'] as int,
        date: parseIsoDate(r['Date'] as String),
        attributeId: r['Attribute_ID'] as int,
        score: (r['Score'] as num).toDouble(),
        role: (r['Role'] as String?) ?? 'Disease',
      );
}
