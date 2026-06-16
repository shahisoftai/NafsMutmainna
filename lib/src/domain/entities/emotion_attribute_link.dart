import 'package:equatable/equatable.dart';

/// Link between an emotion and an attribute, with role and weight.
class EmotionAttributeLink extends Equatable {
  final int id;
  final int emotionId;
  final int attributeId;
  final double weight; // 0.0 - 1.0
  final String role; // Disease | Treatment | Core | Strengthens

  const EmotionAttributeLink({
    required this.id,
    required this.emotionId,
    required this.attributeId,
    required this.weight,
    required this.role,
  });

  @override
  List<Object?> get props => [id, emotionId, attributeId, role];
}
