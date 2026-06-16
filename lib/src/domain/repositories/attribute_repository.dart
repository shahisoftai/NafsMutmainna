import '../entities/heart_attribute.dart';
import '../entities/nafs_weights.dart';

abstract class AttributeRepositoryInterface {
  Future<List<HeartAttribute>> getAll();
  Future<HeartAttribute?> getById(int id);
  Future<AttributeNafsWeights> getNafsWeights(int id);
}
