import '../../domain/entities/hadees.dart';
import '../../domain/repositories/hadees_repository.dart';
import '../datasources/local/app_database.dart';

class HadeesRepositoryImpl implements HadeesRepository {
  final AppDatabase _db;
  HadeesRepositoryImpl(this._db);

  @override
  Future<List<Hadees>> getAll() async {
    final rows = await _db.db.query('hadees', orderBy: 'Hadees_ID ASC');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<Hadees?> getById(int id) async {
    final rows = await _db.db.query('hadees', where: 'Hadees_ID = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<List<Hadees>> findForEmotion(int emotionId, {int? limit}) async {
    final query = '''
      SELECT h.* FROM hadees h
      INNER JOIN emotion_hadees_links ehl ON h.Hadees_ID = ehl.Hadees_ID
      WHERE ehl.Emotion_ID = ?
      ORDER BY ehl.Weight DESC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''';
    final rows = await _db.db.rawQuery(query, [emotionId]);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<Hadees?> findRandomForEmotionExcluding({
    required int emotionId,
    required Set<int> excludeIds,
  }) async {
    if (excludeIds.isEmpty) {
      final rows = await _db.db.rawQuery('''
        SELECT h.* FROM hadees h
        INNER JOIN emotion_hadees_links ehl ON h.Hadees_ID = ehl.Hadees_ID
        WHERE ehl.Emotion_ID = ?
        ORDER BY RANDOM() LIMIT 1
      ''', [emotionId]);
      if (rows.isEmpty) return null;
      return _fromRow(rows.first);
    }

    final placeholders = List.filled(excludeIds.length, '?').join(',');
    final rows = await _db.db.rawQuery('''
      SELECT h.* FROM hadees h
      INNER JOIN emotion_hadees_links ehl ON h.Hadees_ID = ehl.Hadees_ID
      WHERE ehl.Emotion_ID = ? AND h.Hadees_ID NOT IN ($placeholders)
      ORDER BY RANDOM() LIMIT 1
    ''', [emotionId, ...excludeIds]);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<List<Hadees>> findTopForEmotion(
    int emotionId, {
    int? limit,
  }) async {
    final lim = limit != null ? 'LIMIT $limit' : '';
    final rows = await _db.db.rawQuery('''
      SELECT h.* FROM hadees h
      INNER JOIN emotion_hadees_links ehl ON h.Hadees_ID = ehl.Hadees_ID
      WHERE ehl.Emotion_ID = ?
      ORDER BY ehl.Weight DESC
      $lim
    ''', [emotionId]);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<Hadees>> findTopForEmotionExcluding(
    int emotionId, {
    int? limit,
    Set<int> excludeIds = const <int>{},
  }) async {
    final lim = limit != null ? 'LIMIT $limit' : '';
    if (excludeIds.isEmpty) return findTopForEmotion(emotionId, limit: limit);

    final placeholders = List.filled(excludeIds.length, '?').join(',');
    final filtered = await _db.db.rawQuery('''
      SELECT h.* FROM hadees h
      INNER JOIN emotion_hadees_links ehl ON h.Hadees_ID = ehl.Hadees_ID
      WHERE ehl.Emotion_ID = ? AND h.Hadees_ID NOT IN ($placeholders)
      ORDER BY ehl.Weight DESC
      $lim
    ''', [emotionId, ...excludeIds]);
    if (filtered.isNotEmpty) return filtered.map(_fromRow).toList();

    // Soft-skip: fall back to unfiltered top.
    return findTopForEmotion(emotionId, limit: limit);
  }

  Hadees _fromRow(Map<String, Object?> r) {
    return Hadees(
      id: r['Hadees_ID'] as int,
      arabicText: r['Arabic_Text'] as String,
      englishTranslation: r['English_Translation'] as String,
      urduTranslation: r['Urdu_Translation'] as String,
      sourceBook: r['Source_Book'] as String,
      hadithNumber: r['Hadith_Number'] as String,
      grade: r['Grade'] as String,
    );
  }
}
