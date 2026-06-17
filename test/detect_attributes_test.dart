import 'package:flutter_test/flutter_test.dart';
import 'package:nafsmutmainna/src/domain/entities/emotion_attribute_link.dart';
import 'package:nafsmutmainna/src/domain/repositories/emotion_attribute_link_repository.dart';
import 'package:nafsmutmainna/src/domain/usecases/graph/detect_attributes.dart';

class _StubLinks implements EmotionAttributeLinkRepositoryInterface {
  _StubLinks(this._links);
  final List<EmotionAttributeLink> _links;

  @override
  Future<List<EmotionAttributeLink>> findForEmotion(int emotionId) async =>
      _links.where((l) => l.emotionId == emotionId).toList();

  @override
  Future<List<EmotionAttributeLink>> findForEmotionTop(
    int emotionId, {
    List<String>? roles,
    int limit = 3,
  }) async =>
      _links.where((l) => l.emotionId == emotionId).toList();

  @override
  Future<List<EmotionAttributeLink>> findForAttribute(int attributeId) async =>
      _links.where((l) => l.attributeId == attributeId).toList();
}

EmotionAttributeLink _link(int eid, int aid, double w, String role, {int id = 1}) =>
    EmotionAttributeLink(id: id, emotionId: eid, attributeId: aid, weight: w, role: role);

void main() {
  group('DetectAttributes', () {
    test('returns one row per attribute — keeps highest score (Core > Treatment)', () async {
      // Mirrors the seed: Zuhd is the Core (w=1.0) AND Treatment (w=0.9) of Sadness.
      final stub = _StubLinks([
        _link(5, 75, 1.0, 'Core', id: 1),
        _link(5, 75, 0.9, 'Treatment', id: 2),
      ]);
      final detect = DetectAttributes(stub);

      final result = await detect(5, 5);

      expect(result, hasLength(1));
      expect(result.first.attributeId, 75);
      expect(result.first.score, closeTo(0.5, 1e-9)); // 1.0 * 5/10
      expect(result.first.role, 'Core');
    });

    test('keeps distinct attributes (no collapse across different attributeIds)', () async {
      final stub = _StubLinks([
        _link(5, 75, 1.0, 'Core'),
        _link(5, 92, 0.8, 'Treatment'),
        _link(5, 168, 0.9, 'Treatment'),
      ]);
      final detect = DetectAttributes(stub);

      final result = await detect(5, 5);

      expect(result, hasLength(3));
      expect(result.map((r) => r.attributeId).toSet(), {75, 92, 168});
    });

    test('Tawadu case: Core and Treatment roles collapse to one row', () async {
      // Mirrors the seed: Tawadu is the Core (w=1.0) AND Treatment (w=0.8)
      // of Hard-heartedness (Emo 24).
      final stub = _StubLinks([
        _link(24, 92, 1.0, 'Core', id: 1),
        _link(24, 92, 0.8, 'Treatment', id: 2),
      ]);
      final detect = DetectAttributes(stub);

      final result = await detect(24, 5);

      expect(result, hasLength(1));
      expect(result.first.attributeId, 92);
      expect(result.first.score, closeTo(0.5, 1e-9));
      expect(result.first.role, 'Core');
    });

    test('Haybah case: Treatment and Strengthens collapse to Treatment (higher weight)', () async {
      // Mirrors the seed: Haybah is the Treatment (w=0.85) AND Strengthens (w=0.55)
      // of Trust (Emo 43).
      final stub = _StubLinks([
        _link(43, 100, 0.85, 'Treatment', id: 1),
        _link(43, 100, 0.55, 'Strengthens', id: 2),
      ]);
      final detect = DetectAttributes(stub);

      final result = await detect(43, 5);

      expect(result, hasLength(1));
      expect(result.first.attributeId, 100);
      expect(result.first.score, closeTo(0.425, 1e-9));
      expect(result.first.role, 'Treatment');
    });

    test('Ikhlas al-Mahabbah case: at intensity 9 produces 90 and 81 → both collapse', () async {
      // Mirrors the seed: Ikhlas al-Mahabbah (168) is the Core (w=1.0) AND
      // Treatment (w=0.9) of Reverence (Emo 45).
      final stub = _StubLinks([
        _link(45, 168, 1.0, 'Core', id: 1),
        _link(45, 168, 0.9, 'Treatment', id: 2),
      ]);
      final detect = DetectAttributes(stub);

      final result = await detect(45, 9);

      expect(result, hasLength(1));
      expect(result.first.attributeId, 168);
      expect(result.first.score, closeTo(0.9, 1e-9));
      expect(result.first.role, 'Core');
    });

    test('Tie-break by role priority Disease > Core > Treatment > Strengthens', () async {
      // Same score for two roles — Disease should win.
      final stub = _StubLinks([
        _link(1, 99, 1.0, 'Treatment', id: 1),
        _link(1, 99, 1.0, 'Disease', id: 2),
        _link(1, 99, 1.0, 'Strengthens', id: 3),
        _link(1, 99, 1.0, 'Core', id: 4),
      ]);
      final detect = DetectAttributes(stub);

      final result = await detect(1, 10);

      expect(result, hasLength(1));
      expect(result.first.role, 'Disease');
    });

    test('Score scales linearly with intensity (intensity 0 produces score 0)', () async {
      final stub = _StubLinks([_link(1, 75, 1.0, 'Core')]);
      final detect = DetectAttributes(stub);

      final at5 = await detect(1, 5);
      final at10 = await detect(1, 10);
      final at0 = await detect(1, 0);
      final at15 = await detect(1, 15);

      expect(at5.first.score, closeTo(0.5, 1e-9));
      expect(at10.first.score, closeTo(1.0, 1e-9));
      expect(at0.first.score, closeTo(0.0, 1e-9));
      // intensity is clamped to 1.0 max via (intensity/10).clamp(0,1)
      expect(at15.first.score, closeTo(1.0, 1e-9));
    });

    test('Empty link list returns empty result (no crash)', () async {
      final stub = _StubLinks(const []);
      final detect = DetectAttributes(stub);

      final result = await detect(999, 5);
      expect(result, isEmpty);
    });
  });
}
