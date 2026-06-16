import '../../../../domain/entities/nafs_history.dart';
import '../../../../domain/entities/vector4.dart';

/// Direction of the user's Nafs movement vs the previous day.
enum NafsTrendDirection { up, down, flat }

/// Pure value type that summarises a single day's movement on the Nafs
/// spectrum (toward Mutmainnah = up, toward Ammarah = down).
class NafsTrend {
  final NafsTrendDirection direction;
  /// Delta in percentage points of (Mutmainnah + Mulhamah).
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

  /// Compute the trend between [today] and [yesterday].
  ///
  /// The "score" we track is the share of (Mutmainnah + Mulhamah) — i.e. the
  /// share of the user's soul that is *above* the Lawwamah baseline. An
  /// increase in that share is movement toward Mutmainnah.
  NafsTrend compute({
    required NafsHistory? today,
    required NafsHistory? yesterday,
  }) {
    if (today == null || yesterday == null) return NafsTrend.none;
    final todayScore = today.mutmainnah + today.mulhamah;
    final yesterdayScore = yesterday.mutmainnah + yesterday.mulhamah;
    final delta = todayScore - yesterdayScore;
    final deltaPercent = (delta * 100).round();
    final NafsTrendDirection direction;
    if (delta > 0.005) {
      direction = NafsTrendDirection.up;
    } else if (delta < -0.005) {
      direction = NafsTrendDirection.down;
    } else {
      direction = NafsTrendDirection.flat;
    }
    return NafsTrend(direction: direction, deltaPercent: deltaPercent);
  }

  /// Convert a series of NafsHistory rows to a series of heart-health scores
  /// for a sparkline. Returns an empty list if no rows.
  List<int> sparklineScores(List<NafsHistory> rows) {
    if (rows.isEmpty) return const [];
    final out = <int>[];
    for (final r in rows) {
      final v = Vector4(r.ammarah, r.lawwamah, r.mulhamah, r.mutmainnah);
      out.add(v.heartHealthScore);
    }
    return out;
  }
}
