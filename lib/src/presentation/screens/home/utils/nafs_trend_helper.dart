import '../../../../domain/entities/vector4.dart';

/// Direction of the user's Nafs movement vs the previous day.
enum NafsTrendDirection { up, down, flat }

/// Pure value type that summarises a single day's movement on the Nafs
/// spectrum (toward Mutmainnah = up, toward Ammarah = down).
class NafsTrend {
  final NafsTrendDirection direction;
  /// Delta in canonical heart-health points (0-100).
  final int deltaPercent;
  const NafsTrend({
    required this.direction,
    required this.deltaPercent,
  });

  static const NafsTrend flat0 = NafsTrend(
    direction: NafsTrendDirection.flat,
    deltaPercent: 0,
  );

  static const NafsTrend none = flat0;

  bool get isMeaningful => direction != NafsTrendDirection.flat;
}

/// Pure helpers for computing the Nafs trend shown next to the Nafs meter.
class NafsTrendHelper {
  const NafsTrendHelper();

  /// Compute the trend between [today] and [yesterday] vectors.
  ///
  /// Uses the canonical full-spectrum heart-health score (0-100): an increase
  /// is movement toward Mutmainnah. Thresholds (|delta| > 2) match the
  /// ring-style trend rendering.
  NafsTrend compute({
    required Vector4? today,
    required Vector4? yesterday,
  }) {
    if (today == null || yesterday == null) return NafsTrend.none;
    final delta = today.heartHealthScore - yesterday.heartHealthScore;
    final NafsTrendDirection direction;
    if (delta > 2) {
      direction = NafsTrendDirection.up;
    } else if (delta < -2) {
      direction = NafsTrendDirection.down;
    } else {
      direction = NafsTrendDirection.flat;
    }
    return NafsTrend(direction: direction, deltaPercent: delta);
  }

  /// Convert a series of vectors to a series of canonical heart-health scores
  /// for a sparkline. Returns an empty list if no rows.
  List<int> sparklineScores(Iterable<Vector4> vectors) {
    final out = <int>[];
    for (final v in vectors) {
      out.add(v.heartHealthScore);
    }
    return out;
  }
}
