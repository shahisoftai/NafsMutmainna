import '../entities/emotion.dart';
import '../entities/nafs_weights.dart';

abstract class EmotionRepositoryInterface {
  Future<List<Emotion>> getAll();
  Future<Emotion?> getById(int id);
  Future<EmotionNafsWeights> getNafsWeights(int id);
  Future<List<Emotion>> search(String query);
}
