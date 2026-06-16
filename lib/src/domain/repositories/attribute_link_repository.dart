import '../entities/attribute_link.dart';

abstract class AttributeLinkRepositoryInterface {
  Future<List<AttributeLink>> findOutgoing(int sourceId, {String? relationship});
  Future<List<AttributeLink>> findCure(int sourceId);
  Future<List<AttributeLink>> findAll();
}
