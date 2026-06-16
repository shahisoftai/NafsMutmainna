import 'package:equatable/equatable.dart';

/// One of 50 core emotions.
class Emotion extends Equatable {
  final int id;
  final String name;
  final String arabicName;
  final String category; // Negative | Positive
  final String description;
  final String commonTriggers;
  final String primaryNegativeAttributes;
  final String secondaryNegativeAttributes;
  final String primaryPositiveAttributes;
  final String growthPath;
  final String dominantNafsState;
  final int severityWeight; // 1-10
  final String recommendedAttributePriority;
  final String recommendedInterventionType;
  final String recommendedDua;
  final String recommendedAllahNames;
  final String recommendedDhikr;
  final String dailyAction;
  final String relatedEmotions;
  final String relatedAttributeIds;
  final String keywords;

  const Emotion({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.category,
    required this.description,
    required this.commonTriggers,
    required this.primaryNegativeAttributes,
    required this.secondaryNegativeAttributes,
    required this.primaryPositiveAttributes,
    required this.growthPath,
    required this.dominantNafsState,
    required this.severityWeight,
    required this.recommendedAttributePriority,
    required this.recommendedInterventionType,
    required this.recommendedDua,
    required this.recommendedAllahNames,
    required this.recommendedDhikr,
    required this.dailyAction,
    required this.relatedEmotions,
    required this.relatedAttributeIds,
    required this.keywords,
  });

  @override
  List<Object?> get props => [id, name, arabicName, category, severityWeight];
}
