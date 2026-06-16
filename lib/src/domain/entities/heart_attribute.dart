import 'package:equatable/equatable.dart';

/// One of 200 heart attributes.
class HeartAttribute extends Equatable {
  final int id;
  final String name;
  final String arabicName;
  final String nature; // Positive | Negative
  final String definition;
  final String? oppositeTrait;
  final String? oppositeArabic;
  final String keywords;
  final String? quranReference;
  final String? quranArabic;
  final String? quranEnglish;
  final String? quranUrdu;
  final String? hadithReference;
  final String? hadithArabic;
  final String? hadithUrdu;
  final String? quranicDuaReference;
  final String? quranicDuaArabic;
  final String? quranicDuaUrdu;
  final String? propheticDuaReference;
  final String? propheticDuaArabic;
  final String? propheticDuaUrdu;
  final String? relevantAllahNames;
  final String? practicalUnderstanding;

  const HeartAttribute({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.nature,
    required this.definition,
    this.oppositeTrait,
    this.oppositeArabic,
    required this.keywords,
    this.quranReference,
    this.quranArabic,
    this.quranEnglish,
    this.quranUrdu,
    this.hadithReference,
    this.hadithArabic,
    this.hadithUrdu,
    this.quranicDuaReference,
    this.quranicDuaArabic,
    this.quranicDuaUrdu,
    this.propheticDuaReference,
    this.propheticDuaArabic,
    this.propheticDuaUrdu,
    this.relevantAllahNames,
    this.practicalUnderstanding,
  });

  @override
  List<Object?> get props => [id, name, arabicName, nature];
}
