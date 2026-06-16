import '../entities/emotion_attribute_link.dart';

abstract class EmotionAttributeLinkRepositoryInterface {
  /// Returns all links for [emotionId], ordered by Weight DESC.
  Future<List<EmotionAttributeLink>> findForEmotion(int emotionId);

  /// Returns the top [limit] links for [emotionId], optionally filtered by role.
  ///
  /// [roles] — if non-null and non-empty, only links whose Role is in this list
  /// are returned.  Pass `['Treatment', 'Core']` to match the recommendation
  /// algorithm spec (recommendation_algorithm.md §4.2).
  Future<List<EmotionAttributeLink>> findForEmotionTop(
    int emotionId, {
    List<String>? roles,
    int limit = 3,
  });

  /// Returns all links for [attributeId], ordered by Weight DESC.
  Future<List<EmotionAttributeLink>> findForAttribute(int attributeId);
}
