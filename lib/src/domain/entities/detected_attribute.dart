import 'package:equatable/equatable.dart';

/// A row from detected_attributes (inferred from a check-in).
///
/// [role] preserves the semantic context from [EmotionAttributeLink.role]:
/// - 'Disease'    — the attribute is actively surfaced (a vice the emotion reveals).
/// - 'Treatment'  — a virtue to cultivate as a remedy.
/// - 'Core'       — the single most important attribute for this emotion.
/// - 'Strengthens'— a secondary virtue that grows as the core is worked on.
class DetectedAttribute extends Equatable {
  final int id;
  final DateTime date;
  final int attributeId;
  final double score; // 0.0 - 1.0
  final String role; // Disease | Treatment | Core | Strengthens

  const DetectedAttribute({
    required this.id,
    required this.date,
    required this.attributeId,
    required this.score,
    required this.role,
  });

  @override
  List<Object?> get props => [id, date, attributeId, role];
}
