import '../../domain/entities/domain.dart';
import '../../domain/entities/domain_link.dart';
import '../../domain/repositories/domain_repository.dart';
import '../datasources/local/app_database.dart';

class DomainRepositoryImpl implements DomainRepositoryInterface {
  final AppDatabase _db;
  DomainRepositoryImpl(this._db);

  @override
  Future<List<Domain>> getAll() async {
    final rows = await _db.db.query('domains', orderBy: 'Domain_ID ASC');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<Domain?> getById(int id) async {
    final rows = await _db.db.query('domains', where: 'Domain_ID = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<List<DomainAttributeLink>> findAttributesForDomain(int domainId) async {
    final rows = await _db.db.query(
      'domain_attribute_links',
      where: 'Domain_ID = ?',
      whereArgs: [domainId],
      orderBy: 'Weight DESC',
    );
    return rows.map(_fromDomainAttr).toList();
  }

  @override
  Future<List<DomainEmotionLink>> findEmotionsForDomain(int domainId) async {
    final rows = await _db.db.query(
      'domain_emotion_links',
      where: 'Domain_ID = ?',
      whereArgs: [domainId],
      orderBy: 'Weight DESC',
    );
    return rows.map(_fromDomainEmo).toList();
  }

  Domain _fromRow(Map<String, Object?> r) => Domain(
        id: r['Domain_ID'] as int,
        name: r['Domain_Name'] as String,
        arabicName: r['Arabic_Name'] as String,
        description: r['Description'] as String,
      );

  DomainAttributeLink _fromDomainAttr(Map<String, Object?> r) => DomainAttributeLink(
        id: r['Link_ID'] as int,
        domainId: r['Domain_ID'] as int,
        attributeId: r['Attribute_ID'] as int,
        weight: (r['Weight'] as num).toDouble(),
      );

  DomainEmotionLink _fromDomainEmo(Map<String, Object?> r) => DomainEmotionLink(
        id: r['Link_ID'] as int,
        domainId: r['Domain_ID'] as int,
        emotionId: r['Emotion_ID'] as int,
        weight: (r['Weight'] as num).toDouble(),
      );
}
