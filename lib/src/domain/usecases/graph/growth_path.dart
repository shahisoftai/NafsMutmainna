import '../../entities/attribute_link.dart';
import '../../entities/heart_attribute.dart';
import '../../repositories/attribute_link_repository.dart';
import '../../repositories/attribute_repository.dart';

/// BFS the Heart Graph from a source attribute following Cure / Leads_To / Strengthens.
class GrowthPath {
  final AttributeLinkRepositoryInterface _links;
  final AttributeRepositoryInterface _attrs;

  GrowthPath(this._links, this._attrs);

  /// Returns a chain of attributes (up to maxHops) starting at [sourceId].
  Future<List<HeartAttribute>> call(int sourceId, {int maxHops = 4}) async {
    final path = <HeartAttribute>[];
    final visited = <int>{};
    var current = sourceId;

    for (var i = 0; i < maxHops; i++) {
      if (visited.contains(current)) break;
      visited.add(current);
      final attr = await _attrs.getById(current);
      if (attr == null) break;
      path.add(attr);

      AttributeLink? best;
      final outgoing = await _links.findOutgoing(current);
      for (final e in outgoing) {
        if (e.relationship != 'Cure' &&
            e.relationship != 'Leads_To' &&
            e.relationship != 'Strengthens') {
          continue;
        }
        if (best == null || e.weight > best.weight) best = e;
      }
      if (best == null) break;
      current = best.targetAttributeId;
    }
    return path;
  }
}
