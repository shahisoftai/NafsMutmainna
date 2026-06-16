import 'package:equatable/equatable.dart';

enum InterventionType { quran, hadith, dua, allahNames, dhikr, action }

extension InterventionTypeX on InterventionType {
  String get label => switch (this) {
        InterventionType.quran => 'Quran',
        InterventionType.hadith => 'Hadith',
        InterventionType.dua => 'Dua',
        InterventionType.allahNames => 'Allah Names',
        InterventionType.dhikr => 'Dhikr',
        InterventionType.action => 'Daily Action',
      };

  String get storage => switch (this) {
        InterventionType.quran => 'Quran',
        InterventionType.hadith => 'Hadith',
        InterventionType.dua => 'Dua',
        InterventionType.allahNames => 'Allah_Names',
        InterventionType.dhikr => 'Dhikr',
        InterventionType.action => 'Action',
      };

  static InterventionType fromStorage(String s) => switch (s) {
        'Quran' => InterventionType.quran,
        'Hadith' => InterventionType.hadith,
        'Dua' => InterventionType.dua,
        'Allah_Names' => InterventionType.allahNames,
        'Dhikr' => InterventionType.dhikr,
        'Action' => InterventionType.action,
        _ => InterventionType.action,
      };
}

enum InterventionFeedback { muchBetter, better, same, worse }

extension InterventionFeedbackX on InterventionFeedback {
  String get label => switch (this) {
        InterventionFeedback.muchBetter => 'Much better',
        InterventionFeedback.better => 'Better',
        InterventionFeedback.same => 'Same',
        InterventionFeedback.worse => 'Worse',
      };

  String get storage => switch (this) {
        InterventionFeedback.muchBetter => 'much_better',
        InterventionFeedback.better => 'better',
        InterventionFeedback.same => 'same',
        InterventionFeedback.worse => 'worse',
      };

  static InterventionFeedback? fromStorage(String? s) {
    if (s == null) return null;
    return switch (s) {
      'much_better' => InterventionFeedback.muchBetter,
      'better' => InterventionFeedback.better,
      'same' => InterventionFeedback.same,
      'worse' => InterventionFeedback.worse,
      _ => null,
    };
  }
}

/// A single intervention card shown on the Intervention screen.
class InterventionCard extends Equatable {
  final InterventionType type;
  final String title;
  final String subtitle;
  final String arabic;
  final String translation;
  final String urdu;
  final String why;
  final int attributeId;
  final int emotionId;
  final double score;

  const InterventionCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.arabic,
    required this.translation,
    required this.urdu,
    required this.why,
    required this.attributeId,
    required this.emotionId,
    required this.score,
  });

  @override
  List<Object?> get props => [type, title, attributeId, emotionId];
}
