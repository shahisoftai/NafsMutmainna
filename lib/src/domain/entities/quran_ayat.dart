/// QuranAyat entity for the normalized Quran pool.
class QuranAyat {
  final int id;
  final String arabicText;
  final String englishTranslation;
  final String urduTranslation;
  final String surahName;
  final int verseNumber;
  final String fullReference;

  const QuranAyat({
    required this.id,
    required this.arabicText,
    required this.englishTranslation,
    required this.urduTranslation,
    required this.surahName,
    required this.verseNumber,
    required this.fullReference,
  });
}
