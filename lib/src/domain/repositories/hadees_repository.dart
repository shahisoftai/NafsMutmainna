import '../entities/hadees.dart';

/// Repository interface for the normalized hadees pool.
abstract class HadeesRepository {
  Future<List<Hadees>> getAll();
  Future<Hadees?> getById(int id);
  Future<List<Hadees>> findForEmotion(int emotionId, {int? limit});
  Future<Hadees?> findRandomForEmotionExcluding({
    required int emotionId,
    required Set<int> excludeIds,
  });

  /// Returns the top [limit] hadees for [emotionId] ordered by Weight DESC.
  Future<List<Hadees>> findTopForEmotion(
    int emotionId, {
    int? limit,
  });

  /// Returns the top [limit] hadees for [emotionId] ordered by Weight DESC,
  /// skipping ids in [excludeIds] when possible (soft-skip semantics).
  Future<List<Hadees>> findTopForEmotionExcluding(
    int emotionId, {
    int? limit,
    Set<int> excludeIds = const <int>{},
  });
}
