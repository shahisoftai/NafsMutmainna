/// Hadees entity for the normalized hadees pool.
class Hadees {
  final int id;
  final String arabicText;
  final String englishTranslation;
  final String urduTranslation;
  final String sourceBook;
  final String hadithNumber;
  final String grade;

  const Hadees({
    required this.id,
    required this.arabicText,
    required this.englishTranslation,
    required this.urduTranslation,
    required this.sourceBook,
    required this.hadithNumber,
    required this.grade,
  });
}
