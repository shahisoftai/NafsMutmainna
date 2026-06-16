import '../../repositories/emotion_attribute_link_repository.dart';

/// Resolves an emotion into a list of detected attributes with scores.
class DetectAttributes {
  final EmotionAttributeLinkRepositoryInterface _links;
  DetectAttributes(this._links);

  /// Returns `[{attributeId, score, role}, ...]` for the given emotion and intensity.
  /// `score` = link.weight * (intensity / 10).
  Future<List<({int attributeId, double score, String role})>> call(int emotionId, int intensity) async {
    final links = await _links.findForEmotion(emotionId);
    final mult = (intensity / 10.0).clamp(0.0, 1.0);
    return links.map((l) => (
          attributeId: l.attributeId,
          score: l.weight * mult,
          role: l.role,
        )).toList();
  }
}
