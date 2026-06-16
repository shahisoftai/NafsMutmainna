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
}
