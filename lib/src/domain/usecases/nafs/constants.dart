import '../../entities/vector4.dart';

/// Centralised constants for the Nafs engine.
/// Per IMPLEMENTATION_PLAN.md §8.2.
class NafsConstants {
  NafsConstants._();

  // 50/20/20/10 blend.
  static const double wAttribute = 0.50;
  static const double wEmotion = 0.20;
  static const double wHabit = 0.20;
  static const double wTrend = 0.10;

  static const int meterWindowDays = 15;
  static const int trendWindowDays = 14;
  static const int habitWindowDays = 7;
  static const double trendNudgeSize = 0.05;

  /// Habit completion buckets -> Nafs vector.
  /// 0: <20%, 1: 20-50%, 2: 50-80%, 3: >=80%
  static const List<Vector4> habitBias = [
    Vector4(0.60, 0.40, 0.00, 0.00), // < 20%
    Vector4(0.20, 0.60, 0.20, 0.00), // 20-50%
    Vector4(0.00, 0.30, 0.50, 0.20), // 50-80%
    Vector4(0.00, 0.10, 0.20, 0.70), // >= 80%
  ];

  static const int positiveStreakForMulhamah = 7;
  static const int positiveStreakForMutmainnah = 30;
  static const int regressionStreakThreshold = 3;

  /// Map habit completion rate to bucket index 0..3.
  static int habitBucket(double rate) {
    if (rate >= 0.80) return 3;
    if (rate >= 0.50) return 2;
    if (rate >= 0.20) return 1;
    return 0;
  }

  /// Get the habit-bias Vector4 for a completion rate.
  static Vector4 habitBiasFor(double rate) => habitBias[habitBucket(rate)];
}
