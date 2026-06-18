import '../../domain/entities/quran_ayat.dart';
import '../../domain/repositories/quran_ayat_repository.dart';
import '../datasources/local/app_database.dart';

class QuranAyatRepositoryImpl implements QuranAyatRepository {
  final AppDatabase _db;
  QuranAyatRepositoryImpl(this._db);

  @override
  Future<List<QuranAyat>> getAll() async {
    final rows = await _db.db.query('quran_ayat', orderBy: 'Ayat_ID ASC');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<QuranAyat?> getById(int id) async {
    final rows = await _db.db.query('quran_ayat', where: 'Ayat_ID = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<List<QuranAyat>> findForEmotion(int emotionId, {int? limit}) async {
    final query = '''
      SELECT q.* FROM quran_ayat q
      INNER JOIN emotion_quran_links eql ON q.Ayat_ID = eql.Ayat_ID
      WHERE eql.Emotion_ID = ?
      ORDER BY eql.Weight DESC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''';
    final rows = await _db.db.rawQuery(query, [emotionId]);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<QuranAyat?> findRandomForEmotionExcluding({
    required int emotionId,
    required Set<int> excludeIds,
  }) async {
    if (excludeIds.isEmpty) {
      final rows = await _db.db.rawQuery('''
        SELECT q.* FROM quran_ayat q
        INNER JOIN emotion_quran_links eql ON q.Ayat_ID = eql.Ayat_ID
        WHERE eql.Emotion_ID = ?
        ORDER BY RANDOM() LIMIT 1
      ''', [emotionId]);
      if (rows.isEmpty) return null;
      return _fromRow(rows.first);
    }

    final placeholders = List.filled(excludeIds.length, '?').join(',');
    final rows = await _db.db.rawQuery('''
      SELECT q.* FROM quran_ayat q
      INNER JOIN emotion_quran_links eql ON q.Ayat_ID = eql.Ayat_ID
      WHERE eql.Emotion_ID = ? AND q.Ayat_ID NOT IN ($placeholders)
      ORDER BY RANDOM() LIMIT 1
    ''', [emotionId, ...excludeIds]);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<List<QuranAyat>> findTopForEmotion(
    int emotionId, {
    int? limit,
  }) async {
    final lim = limit != null ? 'LIMIT $limit' : '';
    final rows = await _db.db.rawQuery('''
      SELECT q.* FROM quran_ayat q
      INNER JOIN emotion_quran_links eql ON q.Ayat_ID = eql.Ayat_ID
      WHERE eql.Emotion_ID = ?
      ORDER BY eql.Weight DESC
      $lim
    ''', [emotionId]);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<QuranAyat>> findTopForEmotionExcluding(
    int emotionId, {
    int? limit,
    Set<int> excludeIds = const <int>{},
  }) async {
    final lim = limit != null ? 'LIMIT $limit' : '';
    if (excludeIds.isEmpty) return findTopForEmotion(emotionId, limit: limit);

    final placeholders = List.filled(excludeIds.length, '?').join(',');
    // Try with exclusion filter first.
    final filtered = await _db.db.rawQuery('''
      SELECT q.* FROM quran_ayat q
      INNER JOIN emotion_quran_links eql ON q.Ayat_ID = eql.Ayat_ID
      WHERE eql.Emotion_ID = ? AND q.Ayat_ID NOT IN ($placeholders)
      ORDER BY eql.Weight DESC
      $lim
    ''', [emotionId, ...excludeIds]);
    if (filtered.isNotEmpty) return filtered.map(_fromRow).toList();

    // Soft-skip: if the filter excluded everything, return the top without
    // the filter so the caller always has content.
    return findTopForEmotion(emotionId, limit: limit);
  }

  QuranAyat _fromRow(Map<String, Object?> r) {
    return QuranAyat(
      id: r['Ayat_ID'] as int,
      arabicText: r['Arabic_Text'] as String,
      englishTranslation: r['English_Translation'] as String,
      urduTranslation: r['Urdu_Translation'] as String,
      surahName: r['Surah_Name'] as String,
      verseNumber: r['Verse_Number'] as int,
      fullReference: r['Full_Reference'] as String,
    );
  }
}
