import 'package:equatable/equatable.dart';
import 'intervention_card.dart';

/// A row from interventions_history.
class InterventionHistory extends Equatable {
  final int id;
  final DateTime date;
  final int emotionId;
  final int attributeId;
  final InterventionType interventionType;
  final bool completed;
  final InterventionFeedback? feedback;

  const InterventionHistory({
    required this.id,
    required this.date,
    required this.emotionId,
    required this.attributeId,
    required this.interventionType,
    required this.completed,
    this.feedback,
  });

  @override
  List<Object?> get props =>
      [id, date, emotionId, attributeId, interventionType, completed, feedback];
}
