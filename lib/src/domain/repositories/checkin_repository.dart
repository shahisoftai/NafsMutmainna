import '../entities/checkin.dart';

abstract class CheckinRepositoryInterface {
  Future<int> insert(Checkin c);
  Future<List<Checkin>> findForDate(DateTime d);
  Future<List<Checkin>> findBetween(DateTime start, DateTime end);
  Future<Checkin?> findLatest();
  Future<int> deleteForDate(DateTime d);
}
