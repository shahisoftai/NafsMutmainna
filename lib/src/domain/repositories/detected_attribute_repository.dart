import '../entities/detected_attribute.dart';

abstract class DetectedAttributeRepositoryInterface {
  /// Upserts detected attributes for a given date.
  ///
  /// Each record is keyed on (Date, Attribute_ID, Role).  When the same
  /// (date, attributeId, role) appears more than once (e.g. user checks in
  /// the same emotion twice in a day) the scores are **added** and capped
  /// at 1.0, matching the spec in `detected_attributes.md §3`.
  Future<void> upsertMany(
    List<({DateTime date, int attributeId, double score, String role})> rows,
  );

  Future<List<DetectedAttribute>> findForDate(DateTime d);
  Future<void> deleteForDate(DateTime d);
}
