import '../../domain/entities/heart_attribute.dart';
import '../../domain/entities/nafs_weights.dart';
import '../../domain/repositories/attribute_repository.dart';
import '../datasources/local/app_database.dart';

/// Concrete attribute repository backed by SQLite.
///
/// Maps each row from `attributes` to a [HeartAttribute]. The mapping is
/// pure (no I/O, no clock) and tolerant of missing/legacy columns so a
/// pre-v11 database migrates without data loss.
class AttributeRepositoryImpl implements AttributeRepositoryInterface {
  final AppDatabase _db;
  AttributeRepositoryImpl(this._db);

  @override
  Future<List<HeartAttribute>> getAll() async {
    final rows = await _db.db.query('attributes', orderBy: 'Attribute_ID ASC');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<HeartAttribute?> getById(int id) async {
    final rows = await _db.db.query(
      'attributes',
      where: 'Attribute_ID = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<AttributeNafsWeights> getNafsWeights(int id) async {
    final rows = await _db.db.query(
      'attribute_nafs_weights',
      where: 'Attribute_ID = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return const AttributeNafsWeights(
        attributeId: 0,
        ammarah: 0,
        lawwamah: 0,
        mulhamah: 0,
        mutmainnah: 0,
      );
    }
    final r = rows.first;
    return AttributeNafsWeights(
      attributeId: r['Attribute_ID'] as int,
      ammarah: (r['Ammarah'] as num).toDouble(),
      lawwamah: (r['Lawwamah'] as num).toDouble(),
      mulhamah: (r['Mulhamah'] as num).toDouble(),
      mutmainnah: (r['Mutmainnah'] as num).toDouble(),
    );
  }

  /// Maps a database row to a [HeartAttribute] entity.
  ///
  /// Handles legacy databases that may not yet have the v11 columns by
  /// defaulting missing values to safe tazkiya-audit defaults.
  HeartAttribute _fromRow(Map<String, Object?> r) {
    return HeartAttribute(
      id: r['Attribute_ID'] as int,
      name: r['Attribute'] as String,
      arabicName: r['Arabic_Name'] as String,
      nature: r['Nature'] as String,
      definition: (r['Definition'] as String?) ?? '',
      oppositeTrait: r['Opposite_Trait'] as String? ?? '',
      oppositeArabic: r['Opposite_Arabic_Name'] as String? ?? '',
      keywords: (r['Keywords'] as String?) ?? '',
      quranReference: r['Quran_Reference'] as String? ?? '',
      quranArabic: r['Quran_Arabic'] as String? ?? '',
      quranEnglish: r['Quran_English'] as String? ?? '',
      quranUrdu: r['Quran_Urdu'] as String? ?? '',
      hadithReference: r['Hadith_Reference'] as String? ?? '',
      hadithArabic: r['Hadith_Arabic'] as String? ?? '',
      hadithUrdu: r['Hadith_Urdu'] as String? ?? '',
      quranicDuaReference: r['Quranic_Dua_Reference'] as String? ?? '',
      quranicDuaArabic: r['Quranic_Dua_Arabic'] as String? ?? '',
      quranicDuaUrd: r['Quranic_Dua_Urdu'] as String? ?? '',
      propheticDuaReference: r['Prophetic_Dua_Reference'] as String? ?? '',
      propheticDuaArabic: r['Prophetic_Dua_Arabic'] as String? ?? '',
      propheticDuaUrdu: r['Prophetic_Dua_Urdu'] as String? ?? '',
      relevantAllahNames: r['Relevant_Allah_Names'] as String? ?? '',
      practicalUnderstanding: r['Practical_Understanding'] as String? ?? '',
      hadithGrade: HadithGrade.fromDb(r['Hadith_Grade'] as String?),
      quranPrimary: ((r['Quran_Primary'] as int?) ?? 1) == 1,
      causeType: CauseType.fromDb(r['Cause_Type'] as String?),
      sourceEmphasis: r['Source_Emphasis'] as String? ?? '',
      dailyAction: r['Daily_Action'] as String? ?? '',
      dailyActionSource: r['Daily_Action_Source'] as String? ?? '',
    );
  }
}