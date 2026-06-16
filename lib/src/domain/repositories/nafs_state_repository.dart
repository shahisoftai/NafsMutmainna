import '../entities/nafs_state.dart';

abstract class NafsStateRepositoryInterface {
  Future<NafsState?> getCurrent();
  Future<void> setCurrent(NafsState s);
}
