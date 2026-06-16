import '../../domain/entities/attribute_link.dart';
import '../../domain/repositories/attribute_link_repository.dart';
import '../datasources/local/app_database.dart';

class AttributeLinkRepositoryImpl implements AttributeLinkRepositoryInterface {
  final AppDatabase _db;
  AttributeLinkRepositoryImpl(this._db);

  @override
  Future<List<AttributeLink>> findOutgoing(int sourceId, {String? relationship}) async {
    final where = StringBuffer('Source_Attribute_ID = ?');
    final args = <Object?>[sourceId];
    if (relationship != null) {
      where.write(' AND Relationship = ?');
      args.add(relationship);
    }
    final rows = await _db.db.query(
      'attribute_links',
      where: where.toString(),
      whereArgs: args,
      orderBy: 'Weight DESC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<AttributeLink>> findCure(int sourceId) async {
    return findOutgoing(sourceId, relationship: 'Cure');
  }

  @override
  Future<List<AttributeLink>> findAll() async {
    final rows = await _db.db.query('attribute_links', orderBy: 'Link_ID ASC');
    return rows.map(_fromRow).toList();
  }

  AttributeLink _fromRow(Map<String, Object?> r) {
    return AttributeLink(
      id: r['Link_ID'] as int,
      sourceAttributeId: r['Source_Attribute_ID'] as int,
      targetAttributeId: r['Target_Attribute_ID'] as int,
      weight: (r['Weight'] as num).toDouble(),
      relationship: r['Relationship'] as String,
    );
  }
}
