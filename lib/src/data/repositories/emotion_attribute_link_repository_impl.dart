import '../../domain/entities/emotion_attribute_link.dart';
import '../../domain/repositories/emotion_attribute_link_repository.dart';
import '../datasources/local/app_database.dart';

class EmotionAttributeLinkRepositoryImpl
    implements EmotionAttributeLinkRepositoryInterface {
  final AppDatabase _db;
  EmotionAttributeLinkRepositoryImpl(this._db);

  @override
  Future<List<EmotionAttributeLink>> findForEmotion(int emotionId) async {
    final rows = await _db.db.query(
      'emotion_attribute_links',
      where: 'Emotion_ID = ?',
      whereArgs: [emotionId],
      orderBy: 'Weight DESC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<EmotionAttributeLink>> findForEmotionTop(
    int emotionId, {
    List<String>? roles,
    int limit = 3,
  }) async {
    // Build WHERE clause dynamically based on roles list.
    // Using a parameterised IN clause to avoid SQL injection.
    final whereParts = <String>['Emotion_ID = ?'];
    final args = <Object?>[emotionId];

    if (roles != null && roles.isNotEmpty) {
      // e.g. "Role IN (?,?)" for ['Treatment','Core']
      final placeholders = List.filled(roles.length, '?').join(',');
      whereParts.add('Role IN ($placeholders)');
      args.addAll(roles);
    }

    final rows = await _db.db.query(
      'emotion_attribute_links',
      where: whereParts.join(' AND '),
      whereArgs: args,
      orderBy: 'Weight DESC',
      limit: limit,
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<EmotionAttributeLink>> findForAttribute(int attributeId) async {
    final rows = await _db.db.query(
      'emotion_attribute_links',
      where: 'Attribute_ID = ?',
      whereArgs: [attributeId],
      orderBy: 'Weight DESC',
    );
    return rows.map(_fromRow).toList();
  }

  EmotionAttributeLink _fromRow(Map<String, Object?> r) {
    return EmotionAttributeLink(
      id: r['Link_ID'] as int,
      emotionId: r['Emotion_ID'] as int,
      attributeId: r['Attribute_ID'] as int,
      weight: (r['Weight'] as num).toDouble(),
      role: r['Role'] as String,
    );
  }
}
