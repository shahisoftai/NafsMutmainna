import '../../domain/entities/emotion.dart';
import '../../domain/entities/nafs_weights.dart';
import '../../domain/repositories/emotion_repository.dart';
import '../datasources/local/app_database.dart';

class EmotionRepositoryImpl implements EmotionRepositoryInterface {
  final AppDatabase _db;
  EmotionRepositoryImpl(this._db);

  @override
  Future<List<Emotion>> getAll() async {
    final rows = await _db.db.query('emotions', orderBy: 'Emotion_ID ASC');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<Emotion?> getById(int id) async {
    final rows = await _db.db.query('emotions', where: 'Emotion_ID = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<EmotionNafsWeights> getNafsWeights(int id) async {
    final rows = await _db.db.query('emotion_nafs_weights', where: 'Emotion_ID = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) {
      return EmotionNafsWeights(emotionId: id, ammarah: 0, lawwamah: 0, mulhamah: 0, mutmainnah: 0);
    }
    final r = rows.first;
    return EmotionNafsWeights(
      emotionId: r['Emotion_ID'] as int,
      ammarah: (r['Ammarah'] as num).toDouble(),
      lawwamah: (r['Lawwamah'] as num).toDouble(),
      mulhamah: (r['Mulhamah'] as num).toDouble(),
      mutmainnah: (r['Mutmainnah'] as num).toDouble(),
    );
  }

  @override
  Future<List<Emotion>> search(String query) async {
    if (query.trim().isEmpty) return getAll();
    final q = '%${query.toLowerCase()}%';
    final rows = await _db.db.query(
      'emotions',
      where: 'LOWER(Core_Emotion) LIKE ? OR LOWER(Keywords) LIKE ? OR LOWER(Arabic_Name) LIKE ?',
      whereArgs: [q, q, q],
      orderBy: 'Emotion_ID ASC',
    );
    return rows.map(_fromRow).toList();
  }

  Emotion _fromRow(Map<String, Object?> r) {
    return Emotion(
      id: r['Emotion_ID'] as int,
      name: r['Core_Emotion'] as String,
      arabicName: r['Arabic_Name'] as String,
      category: r['Category'] as String,
      description: (r['Description'] as String?) ?? '',
      commonTriggers: (r['Common_Triggers'] as String?) ?? '',
      primaryNegativeAttributes: (r['Primary_Negative_Attributes'] as String?) ?? '',
      secondaryNegativeAttributes: (r['Secondary_Negative_Attributes'] as String?) ?? '',
      primaryPositiveAttributes: (r['Primary_Positive_Attributes'] as String?) ?? '',
      growthPath: (r['Growth_Path'] as String?) ?? '',
      dominantNafsState: r['Dominant_Nafs_State'] as String,
      severityWeight: r['Severity_Weight'] as int,
      recommendedAttributePriority: (r['Recommended_Attribute_Priority'] as String?) ?? '',
      recommendedInterventionType: (r['Recommended_Intervention_Type'] as String?) ?? '',
      recommendedDua: (r['Recommended_Dua'] as String?) ?? '',
      recommendedAllahNames: (r['Recommended_Allah_Names'] as String?) ?? '',
      recommendedDhikr: (r['Recommended_Dhikr'] as String?) ?? '',
      dailyAction: (r['Daily_Action'] as String?) ?? '',
      relatedEmotions: (r['Related_Emotions'] as String?) ?? '',
      relatedAttributeIds: (r['Related_Attribute_IDs'] as String?) ?? '',
      keywords: (r['Keywords'] as String?) ?? '',
    );
  }
}
