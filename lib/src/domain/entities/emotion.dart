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
  final String? recommendedDuaArabic;
  final String? recommendedDuaEnglish;
  final String? recommendedDuaUrdu;
  final String? recommendedDuaReference;

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
    this.recommendedDuaArabic,
    this.recommendedDuaEnglish,
    this.recommendedDuaUrdu,
    this.recommendedDuaReference,
  });

  @override
  List<Object?> get props => [id, name, arabicName, category, severityWeight];

  /// Parses [growthPath] (e.g. "Ghadab→Sabr→Hilm→Rifq") into a list of
  /// non-empty, trimmed step names.
  ///
  /// Returns an empty list when [growthPath] is blank. The first step is
  /// often the disease attribute (e.g. "Ghadab") or even the emotion name
  /// itself (e.g. "Anxiety"); the recommendation algorithm intentionally
  /// does NOT always skip it, because for positive emotions the first step
  /// is the current virtue (e.g. "Raja") and IS the next step to deepen.
  /// Callers that need to skip a leading disease attribute must filter on
  /// [category] themselves.
  List<String> get growthPathSteps {
    if (growthPath.trim().isEmpty) return const [];
    return growthPath
        .split('→')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }

  /// Parses [primaryPositiveAttributes] (e.g. "Sabr;Hilm;Rifq") into a list
  /// of attribute names. Used as a fallback when the Growth_Path produces
  /// no resolvable steps.
  List<String> get primaryPositiveAttributeNames {
    if (primaryPositiveAttributes.trim().isEmpty) return const [];
    return primaryPositiveAttributes
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }

  /// Best-available Arabic text for the recommended dua, preferring the
  /// dedicated Arabic column over the short [recommendedDua] transliteration.
  String get recommendedDuaArabicOrFallback =>
      (recommendedDuaArabic?.trim().isNotEmpty ?? false)
          ? recommendedDuaArabic!
          : recommendedDua;

  /// Best-available English translation for the recommended dua.
  String get recommendedDuaEnglishOrFallback =>
      (recommendedDuaEnglish?.trim().isNotEmpty ?? false)
          ? recommendedDuaEnglish!
          : '';

  /// Best-available Urdu translation for the recommended dua.
  String get recommendedDuaUrduOrFallback =>
      (recommendedDuaUrdu?.trim().isNotEmpty ?? false)
          ? recommendedDuaUrdu!
          : '';

  /// Reference string for the recommended dua, e.g. "Sahih Muslim 771".
  String get recommendedDuaReferenceOrFallback =>
      (recommendedDuaReference?.trim().isNotEmpty ?? false)
          ? recommendedDuaReference!
          : '';
}
