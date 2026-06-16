import '../entities/nafs_history.dart';

abstract class NafsHistoryRepositoryInterface {
  Future<void> upsert(NafsHistory row);
  Future<NafsHistory?> findForDate(DateTime d);
  Future<List<NafsHistory>> findBetween(DateTime start, DateTime end);
}
