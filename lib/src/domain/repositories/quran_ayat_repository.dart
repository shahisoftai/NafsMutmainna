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
}
