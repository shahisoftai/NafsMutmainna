import 'package:equatable/equatable.dart';

/// Cause category for a heart attribute (per RI-3.1).
///
/// Classical tazkiya holds that every disease of the heart arises from three
/// co-operating causes (Ghazali, Ihya' 21): the *nafs* (self), *Shaytan*
/// (whisper), and *al-hawa* (whim). This enum lets the app surface the right
/// protective adhikr when a negative attribute is detected.
enum CauseType {
  nafsi,
  shaytani,
  hawi,
  mixed;

  /// Stable DB value used in CHECK constraint and seed JSON.
  String get dbValue => switch (this) {
        CauseType.nafsi => 'Nafsi',
        CauseType.shaytani => 'Shaytani',
        CauseType.hawi => 'Hawi',
        CauseType.mixed => 'Mixed',
      };

  /// User-facing label.
  String get label => switch (this) {
        CauseType.nafsi => 'Nafs (self)',
        CauseType.shaytani => 'Shaytan (whisper)',
        CauseType.hawi => 'Hawa (whim)',
        CauseType.mixed => 'Mixed (all three)',
      };

  /// Appropriate protective dhikr — each anchored to a classical source.
  String get protectiveDhikr => switch (this) {
        CauseType.nafsi =>
          'Renew your intention: "Lillah" — purify the action for Allah alone.',
        CauseType.shaytani =>
          "Recite 'A'udhu billahi min al-shaytan al-rajim' and the last two verses of Surah Al-Baqarah (Bukhari 5018).",
        CauseType.hawi =>
          'Pause and reflect: "Is this for Allah or for my desire?" (Quran 45:23)',
        CauseType.mixed =>
          'Recite Istighfar and the three Quls (Al-Ikhlas, Al-Falaq, Al-Nas) for full protection (Tirmidhi 3576).',
      };

  static CauseType fromDb(String? value) {
    switch (value) {
      case 'Nafsi':
        return CauseType.nafsi;
      case 'Shaytani':
        return CauseType.shaytani;
      case 'Hawi':
        return CauseType.hawi;
      default:
        return CauseType.mixed;
    }
  }
}

/// Authentication grade of an attribute's hadith reference.
///
/// Per RI-2.6, every attribute carries a `Hadith_Grade` so the user can see
/// how strong the evidence is.
enum HadithGrade {
  sahih,
  hasan,
  hasanLiGhayrihi,
  mutawatir,
  daif,
  unverified;

  String get dbValue => switch (this) {
        HadithGrade.sahih => 'Sahih',
        HadithGrade.hasan => 'Hasan',
        HadithGrade.hasanLiGhayrihi => 'Hasan li-ghayrihi',
        HadithGrade.mutawatir => 'Mutawatir',
        HadithGrade.daif => 'Daif',
        HadithGrade.unverified => 'Unverified',
      };

  static HadithGrade fromDb(String? value) {
    switch (value) {
      case 'Sahih':
        return HadithGrade.sahih;
      case 'Hasan':
        return HadithGrade.hasan;
      case 'Hasan li-ghayrihi':
        return HadithGrade.hasanLiGhayrihi;
      case 'Mutawatir':
        return HadithGrade.mutawatir;
      case 'Daif':
        return HadithGrade.daif;
      default:
        return HadithGrade.unverified;
    }
  }
}

/// One of 200 heart attributes.
///
/// Immutable, value-equality via Equatable. All string fields default to
/// empty (never null) for the new tazkiya-audit columns — this avoids
/// null-checks at every UI call site.
class HeartAttribute extends Equatable {
  final int id;
  final String name;
  final String arabicName;
  final String nature; // Positive | Negative
  final String definition;
  final String oppositeTrait;
  final String oppositeArabic;
  final String keywords;
  final String quranReference;
  final String quranArabic;
  final String quranEnglish;
  final String quranUrdu;
  final String hadithReference;
  final String hadithArabic;
  final String hadithUrdu;
  final String quranicDuaReference;
  final String quranicDuaArabic;
  final String quranicDuaUrd;  // Legacy — keep as alias
  final String propheticDuaReference;
  final String propheticDuaArabic;
  final String propheticDuaUrdu;
  final String relevantAllahNames;
  final String practicalUnderstanding;
  // New columns added in v11 (RI-2.6, 2.7, 3.1, 3.2, 4.2, 5.4)
  final HadithGrade hadithGrade;
  final bool quranPrimary;
  final CauseType causeType;
  final String sourceEmphasis;
  final String dailyAction;
  final String dailyActionSource;

  const HeartAttribute({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.nature,
    required this.definition,
    this.oppositeTrait = '',
    this.oppositeArabic = '',
    this.keywords = '',
    this.quranReference = '',
    this.quranArabic = '',
    this.quranEnglish = '',
    this.quranUrdu = '',
    this.hadithReference = '',
    this.hadithArabic = '',
    this.hadithUrdu = '',
    this.quranicDuaReference = '',
    this.quranicDuaArabic = '',
    this.quranicDuaUrd = '',
    this.propheticDuaReference = '',
    this.propheticDuaArabic = '',
    this.propheticDuaUrdu = '',
    this.relevantAllahNames = '',
    this.practicalUnderstanding = '',
    this.hadithGrade = HadithGrade.unverified,
    this.quranPrimary = true,
    this.causeType = CauseType.mixed,
    this.sourceEmphasis = '',
    this.dailyAction = '',
    this.dailyActionSource = '',
  });

  /// Convenience getter for Urdu Quranic dua.
  String get quranicDuaUrdu => quranicDuaUrd;

  /// Is this a "positive" heart attribute (a virtue to cultivate)?
  bool get isPositive => nature == 'Positive';

  /// Is this a "negative" heart attribute (a disease of the heart)?
  bool get isNegative => nature == 'Negative';

  @override
  List<Object?> get props => [
        id,
        name,
        arabicName,
        nature,
        hadithGrade,
        causeType,
      ];
}