import '../../repositories/emotion_attribute_link_repository.dart';

/// Resolves an emotion into a list of detected attributes with scores.
class DetectAttributes {
  final EmotionAttributeLinkRepositoryInterface _links;
  DetectAttributes(this._links);

  /// Returns `[{attributeId, score, role}, ...]` for the given emotion and intensity.
  /// `score` = link.weight * (intensity / 10).
  ///
  /// The same attribute can legitimately be linked to a single emotion with
  /// multiple roles in the seed (e.g. Zuhd is the `Core` of Sadness AND its
  /// `Treatment`). The raw `emotion_attribute_links` rows therefore contain
  /// duplicates by `attributeId` that would surface as the same attribute
  /// appearing twice in the post-check-in Insight list and be double-counted
  /// by the daily Nafs score.
  ///
  /// To keep the public contract — one detected row per attribute per
  /// check-in — we collapse to a single row per `attributeId`. The kept row
  /// is the one with the **higher score** (stronger detection). Ties are
  /// broken by role priority `Disease > Core > Treatment > Strengthens` so
  /// the more action-oriented role wins.
  static const List<String> _rolePriority = [
    'Disease',
    'Core',
    'Treatment',
    'Strengthens',
  ];

  Future<List<({int attributeId, double score, String role})>> call(int emotionId, int intensity) async {
    final links = await _links.findForEmotion(emotionId);
    final mult = (intensity / 10.0).clamp(0.0, 1.0);
    // attributeId -> {score, role} of the best row seen so far.
    final collapsed = <int, ({double score, String role})>{};
    for (final l in links) {
      final score = l.weight * mult;
      final existing = collapsed[l.attributeId];
      if (existing == null || _isBetter(score, l.role, existing.score, existing.role)) {
        collapsed[l.attributeId] = (score: score, role: l.role);
      }
    }
    return collapsed.entries
        .map((e) => (
              attributeId: e.key,
              score: e.value.score,
              role: e.value.role,
            ))
        .toList();
  }

  /// Returns true when `(scoreA, roleA)` should win over `(scoreB, roleB)`.
  /// Higher score wins; on a tie, the role earlier in [_rolePriority] wins.
  static bool _isBetter(double scoreA, String roleA, double scoreB, String roleB) {
    if (scoreA != scoreB) return scoreA > scoreB;
    final ia = _rolePriority.indexOf(roleA);
    final ib = _rolePriority.indexOf(roleB);
    final ra = ia < 0 ? _rolePriority.length : ia;
    final rb = ib < 0 ? _rolePriority.length : ib;
    return ra < rb;
  }
}
