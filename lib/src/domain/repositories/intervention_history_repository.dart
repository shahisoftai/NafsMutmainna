import '../entities/intervention_history.dart';
import '../entities/intervention_card.dart';

abstract class InterventionHistoryRepositoryInterface {
  Future<int> insert(InterventionHistory row);
  Future<List<InterventionHistory>> findRecent(int days);
  Future<void> markCompleted(int recordId, bool completed);
  Future<void> markFeedback(int recordId, InterventionFeedback feedback);
  Future<int> countCompletedForToday(DateTime date);
}
