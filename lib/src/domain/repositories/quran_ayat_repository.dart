import '../entities/quran_ayat.dart';

/// Repository interface for the normalized Quranic ayat pool.
abstract class QuranAyatRepository {
  Future<List<QuranAyat>> getAll();
  Future<QuranAyat?> getById(int id);
  Future<List<QuranAyat>> findForEmotion(int emotionId, {int? limit});
  Future<QuranAyat?> findRandomForEmotionExcluding({
    required int emotionId,
    required Set<int> excludeIds,
  });

  /// Returns the top [limit] ayats for [emotionId] ordered by Weight DESC.
  ///
  /// Used by the v2 recommendation engine to deterministically pick the
  /// best-matching ayat for a core emotion (replaces v1's
  /// `findRandomForEmotionExcluding`).
  Future<List<QuranAyat>> findTopForEmotion(
    int emotionId, {
    int? limit,
  });

  /// Returns the top [limit] ayats for [emotionId] ordered by Weight DESC,
  /// skipping any id in [excludeIds] when possible. When every candidate is
  /// excluded, the function returns the top [limit] WITHOUT the filter so
  /// the caller always has content to show (soft-skip semantics).
  Future<List<QuranAyat>> findTopForEmotionExcluding(
    int emotionId, {
    int? limit,
    Set<int> excludeIds = const <int>{},
  });
}
