import '../../entities/checkin.dart';
import '../../entities/intervention_card.dart';
import '../../entities/nafs_history.dart';
import '../../entities/vector4.dart';
import '../../repositories/attribute_repository.dart';
import '../../repositories/checkin_repository.dart';
import '../../repositories/detected_attribute_repository.dart';
import '../../repositories/emotion_repository.dart';
import '../../repositories/habit_repository.dart';
import '../../repositories/nafs_history_repository.dart';
import 'constants.dart';
import '../graph/detect_attributes.dart';
import '../recommendations/recommend.dart';

/// Orchestrates the full check-in pipeline:
/// 1. INSERT checkin
/// 2. detect attributes (via emotion -> attributes)
/// 3. UPSERT detected_attributes
/// 4. recompute today's Nafs vector
/// 5. UPSERT nafs_history
/// 6. return SubmitCheckinResult
class SubmitCheckin {
  final CheckinRepositoryInterface _checkins;
  final DetectAttributes _detect;
  final DetectedAttributeRepositoryInterface _detectedRepo;
  final ComputeDailyNafs _nafs;
  final NafsHistoryRepositoryInterface _history;
  final Recommend _recommend;

  SubmitCheckin(
    this._checkins,
    this._detect,
    this._detectedRepo,
    this._nafs,
    this._history,
    this._recommend,
  );

  Future<SubmitCheckinResult> call(Checkin checkin) async {
    await _checkins.insert(checkin);

    final detected = await _detect(checkin.emotionId, checkin.intensity);
    // Pass role through to the repository so it is persisted in detected_attributes.
    // This allows the Insight screen to distinguish Disease attributes from
    // Treatment/Core attributes, preserving the semantic intent of each link.
    await _detectedRepo.upsertMany(detected
        .map((d) => (
              date: checkin.date,
              attributeId: d.attributeId,
              score: d.score,
              role: d.role,
            ))
        .toList());

    final nafsVector = await _nafs(checkin.date);
    await _history.upsert(NafsHistory(
      id: 0,
      date: checkin.date,
      ammarah: nafsVector.ammarah,
      lawwamah: nafsVector.lawwamah,
      mulhamah: nafsVector.mulhamah,
      mutmainnah: nafsVector.mutmainnah,
    ));

    final cards = await _recommend(checkin.emotionId, checkin.intensity);

    return SubmitCheckinResult(
      checkin: checkin,
      detected: detected,
      cards: cards,
      nafs: nafsVector,
    );
  }
}

/// Aggregated result of a SubmitCheckin.
class SubmitCheckinResult {
  final Checkin checkin;
  final List<({int attributeId, double score, String role})> detected;
  final List<InterventionCard> cards;
  final Vector4 nafs;

  const SubmitCheckinResult({
    required this.checkin,
    required this.detected,
    required this.cards,
    required this.nafs,
  });
}

/// Pure-Dart 50/20/20/10 daily Nafs computation.
class ComputeDailyNafs {
  final CheckinRepositoryInterface _checkins;
  final DetectedAttributeRepositoryInterface _detected;
  final HabitRepositoryInterface _habits;
  final NafsHistoryRepositoryInterface _history;
  final EmotionRepositoryInterface _emotions;
  final AttributeRepositoryInterface _attrs;

  ComputeDailyNafs(
    this._checkins,
    this._detected,
    this._habits,
    this._history,
    this._emotions,
    this._attrs,
  );

  Future<Vector4> call(DateTime date) async {
    final a = await _attributeScore(date);
    final e = await _emotionScore(date);
    final h = await _habitScore(date);
    final t = await _trendScore(date);
    final combined = (a * NafsConstants.wAttribute) +
        (e * NafsConstants.wEmotion) +
        (h * NafsConstants.wHabit) +
        (t * NafsConstants.wTrend);
    return combined.normalised;
  }

  /// AttributeScore: score-weighted average of attribute_nafs_weights.
  ///
  /// Per scoring_algorithm.md §3:
  ///   total += Vector4(Ammarah, Lawwamah, Mulhamah, Mutmainnah) * score
  ///   return total.normalise()
  ///
  /// The Nafs weights are stored on a 0–100 scale.  We convert to 0–1 before
  /// accumulating so the final `.normalised` call (which divides by component
  /// sum) produces the correct proportional vector regardless of scale.
  Future<Vector4> _attributeScore(DateTime date) async {
    final detected = await _detected.findForDate(date);
    if (detected.isEmpty) return Vector4.neutral;
    var total = const Vector4(0, 0, 0, 0);
    for (final d in detected) {
      final w = await _attrs.getNafsWeights(d.attributeId);
      // Convert 0-100 weights to 0-1 before multiplying by score.
      total = total + Vector4(w.ammarah, w.lawwamah, w.mulhamah, w.mutmainnah) * (d.score / 100.0);
    }
    return total.normalised;
  }

  /// EmotionScore: intensity-weighted average of emotion_nafs_weights.
  ///
  /// Per scoring_algorithm.md §4:
  ///   mult = Intensity / 10
  ///   total += Vector4(Ammarah, …) * mult
  ///   return total.normalise()
  Future<Vector4> _emotionScore(DateTime date) async {
    final checkins = await _checkins.findForDate(date);
    if (checkins.isEmpty) return Vector4.neutral;
    var total = const Vector4(0, 0, 0, 0);
    for (final c in checkins) {
      final w = await _emotions.getNafsWeights(c.emotionId);
      final mult = (c.intensity / 10.0).clamp(0.0, 1.0);
      // Convert 0-100 weights to 0-1 then scale by intensity multiplier.
      total = total + Vector4(w.ammarah, w.lawwamah, w.mulhamah, w.mutmainnah) * (mult / 100.0);
    }
    return total.normalised;
  }

  /// HabitScore: bucketed habit completion rate from last 7 days.
  Future<Vector4> _habitScore(DateTime date) async {
    final start = date.subtract(const Duration(days: NafsConstants.habitWindowDays - 1));
    final rate = await _habits.completionRateBetween(start, date);
    return NafsConstants.habitBiasFor(rate);
  }

  /// TrendScore: compares the recent half vs the older half of the available
  /// nafs_history window to detect whether the user is improving or declining.
  ///
  /// Implementation note (vs. scoring_algorithm.md §6):
  /// The spec compares "today vs 14-day weighted average" which requires today's
  /// nafs_history row to already exist.  This implementation instead splits the
  /// *previous* N days into two halves and computes the delta between them, which
  /// is causal (no future data) and works correctly on first-run or sparse history.
  ///
  /// The nudge direction is the same as the spec:
  ///   deltaM > 0  → user is trending toward higher stations → nudge toward Mulhamah/Mutmainnah
  ///   deltaM < 0  → user is declining                        → nudge toward Ammarah/Lawwamah
  Future<Vector4> _trendScore(DateTime date) async {
    final end = date.subtract(const Duration(days: 1));
    final start = end.subtract(const Duration(days: NafsConstants.trendWindowDays - 1));
    final rows = await _history.findBetween(start, end);
    if (rows.isEmpty) return Vector4.neutral;
    final half = rows.length ~/ 2;
    final recent = rows.sublist(half);
    final older = rows.sublist(0, half);
    Vector4 avg(List<NafsHistory> xs) {
      if (xs.isEmpty) return Vector4.neutral;
      final v = xs.map((r) => r.vector).reduce((a, b) => a + b);
      return (v * (1.0 / xs.length));
    }
    final r = avg(recent);
    final o = avg(older);
    final deltaM = r.mulhamah + r.mutmainnah - (o.mulhamah + o.mutmainnah);
    final nudge = deltaM * NafsConstants.trendNudgeSize;
    if (nudge.abs() < 0.001) return Vector4.neutral;
    if (nudge > 0) {
      return Vector4(0.5 - nudge / 2, 0.5 - nudge / 2, nudge / 2, nudge / 2);
    } else {
      return Vector4(0.5 + nudge.abs() / 2, 0.5 + nudge.abs() / 2, 0, 0);
    }
  }
}

/// Computes a 15-day weighted moving average of the user's Nafs.
/// Today weighs 1.0, 14 days ago weighs 0.2.
class Meter15Day {
  final NafsHistoryRepositoryInterface _history;
  Meter15Day(this._history);

  Future<Vector4> call(DateTime date) async {
    final start = date.subtract(const Duration(days: NafsConstants.meterWindowDays - 1));
    final rows = await _history.findBetween(start, date);
    if (rows.isEmpty) return Vector4.ammarahStartup;

    final n = rows.length;
    final weights = <double>[];
    for (var i = 0; i < n; i++) {
      // Newer rows weigh more. The most recent row is at index n-1.
      final ageInDays = (n - 1) - i;
      weights.add(1.0 - (ageInDays * 0.8 / (NafsConstants.meterWindowDays - 1)));
    }
    final sumW = weights.fold<double>(0, (a, b) => a + b);
    if (sumW == 0) return Vector4.ammarahStartup;

    final v = rows
        .map((r) => r.vector * weights[rows.indexOf(r)])
        .reduce((a, b) => a + b);
    return (v * (1.0 / sumW)).normalised;
  }
}

/// Positive / regression streak detection.
class Streak {
  final NafsHistoryRepositoryInterface _history;
  Streak(this._history);

  Future<int> positiveStreakAsOf(DateTime date) async {
    final rows = await _history.findBetween(
      date.subtract(const Duration(days: 365)),
      date,
    );
    var count = 0;
    for (var i = rows.length - 1; i >= 0; i--) {
      final v = rows[i].vector;
      if (v.mulhamah + v.mutmainnah > 0.55) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }
}
