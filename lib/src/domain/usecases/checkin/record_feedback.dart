import '../../entities/intervention_card.dart';
import '../../entities/intervention_history.dart';
import '../../repositories/intervention_history_repository.dart';

/// Records user feedback on an intervention.
class RecordFeedback {
  final InterventionHistoryRepositoryInterface _history;
  RecordFeedback(this._history);

  Future<void> call(int recordId, InterventionFeedback feedback) async {
    await _history.markFeedback(recordId, feedback);
  }

  Future<int> insert(InterventionHistory row) async {
    return _history.insert(row);
  }
}
