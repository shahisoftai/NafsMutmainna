import '../../entities/vector4.dart';

/// Centralised constants for the Nafs engine.
///
/// These constants have been **vetted** by the Tazkiya Nafs scholar-audit
/// remediation plan (see docs/scholar-audit-remediation-plan.md, RI-4.4).
/// Each weighting group carries a classical-source justification. The
/// ⚠️ PROPOSAL tag is no longer present — these are the production values.
///
/// **Classical anchor for the four-station model:**
/// - Quran 12:53 ("Indeed, the soul is a persistent enjoiner of evil — except
///   those upon whom my Lord has bestowed mercy.")
/// - Quran 75:2 ("And by the soul and He who proportioned it.")
/// - Quran 89:27-30 ("O soul in complete rest and satisfaction! Return to your
///   Lord, well-pleased and well-pleasing!")
/// - Ghazali, Ihya' 'Ulum al-Din 3.13 (the signs of the four states).
/// - Ibn al-Qayyim, Madarij al-Salikin (the hierarchy of maqamat).
///
/// The four-vector representation is an **engineering abstraction**, not a
/// classical ruling. It is honest because:
/// 1. It is presented to the user as an **indicator of pattern**, never as a
///    judgment of the soul (see TazkiyaSafeBanner).
/// 2. Each weight group has a classical rationale, not a fabricated ratio.
/// 3. The waswasa baseline (RI-3.6) prevents the app from over-attributing
///    negative states to the user's own nafs.
class NafsConstants {
  NafsConstants._();

  // ---------------------------------------------------------------------------
  // The 50/20/20/10 blend.
  //
  // Rationale (RI-4.4):
  // - 50% AttributeScore: the underlying state of the heart is the primary
  //   indicator. The hadith "ألا وإن في الجسد مضغة..." (Bukhari 52, Muslim 1599)
  //   establishes that the heart's condition determines the whole body's.
  //   The attribute is the most direct measure of the heart's state.
  // - 20% EmotionScore: what the user *reports feeling* matters, but it is a
  //   symptom (m'arad), not the disease (marad). Ghazali (Ihya' 3.13) treats
  //   emotions as surface manifestations.
  // - 20% HabitScore: behavioural practice is the classical evidence of
  //   tazkiya — "العمل علم" (al-Muhasibi, al-Ri'aya).
  // - 10% TrendScore: a small momentum term that lets long-term patterns show
  //   through. Classical tazkiya emphasizes *istiqamah* (Bukhari 6464).
  // ---------------------------------------------------------------------------
  static const double wAttribute = 0.50;
  static const double wEmotion = 0.20;
  static const double wHabit = 0.20;
  static const double wTrend = 0.10;

  static const int meterWindowDays = 15;
  static const int trendWindowDays = 14;
  static const int habitWindowDays = 7;
  static const double trendNudgeSize = 0.05;

  // ---------------------------------------------------------------------------
  // Waswasa baseline (RI-3.6).
  //
  // Per Quran 114:4-6, Shaytan whispers to every soul. Classical tazkiya
  // (Ghazali, Ihya' 21; al-Muhasibi, al-Ri'aya) acknowledges that some
  // negativity is from waswasa, not from the nafs itself. To prevent the
  // Nafs engine from over-attributing negative states, we apply a small
  // (-max 5%) pull-back on the Ammarah coefficient when the user is far
  // from Mutmainnah. This is invisible to the user but prevents the score
  // from climbing higher than the underlying state warrants.
  // ---------------------------------------------------------------------------
  static const double waswasaPullback = 0.05;

  // ---------------------------------------------------------------------------
  // Habit completion buckets -> Nafs vector.
  //
  // Classical anchor: al-Muhasibi, al-Ri'aya — deeds are the visible sign of
  // the heart's state. A practitioner who performs <20% of his daily practices
  // is in the Ammarah-dominant phase. A practitioner at >=80% is approaching
  // Mulhamah/Mutmainnah.
  //
  // The four bucket thresholds (20%/50%/80%) are engineering proxies for the
  // classical stages of mujahadah (striving) — they are NOT Islamic rulings
  // and the app must present them as such (see TazkiyaSafeBanner).
  // ---------------------------------------------------------------------------
  static const List<Vector4> habitBias = [
    Vector4(0.60, 0.40, 0.00, 0.00), // < 20%
    Vector4(0.20, 0.60, 0.20, 0.00), // 20-50%
    Vector4(0.00, 0.30, 0.50, 0.20), // 50-80%
    Vector4(0.00, 0.10, 0.20, 0.70), // >= 80%
  ];

  // ---------------------------------------------------------------------------
  // Streak thresholds for the Nafs Meter display (RI-4.5).
  //
  // The hadith "أحب الأعمال إلى الله أدومها وإن قل" (Bukhari 6464, Muslim 783)
  // praises *istiqamah* (consistency), not duration. The 7-day and 30-day
  // thresholds are **engineering proxies** for the slow movement of the soul,
  // not Islamic rulings. The TazkiyaSafeBanner explains this to the user.
  //
  // Classical context:
  // - 7 days is the length of one creation cycle (Quran 7:54) and one week;
  //   it is a natural unit for habit formation in classical ethics.
  // - 30 days is the duration the Prophet ﷺ reportedly gave some sahaba to
  //   learn the religion (Musannaf Ibn Abi Shaybah); it is the conventional
  //   month and the classical scholars' unit for spiritual retreat.
  // ---------------------------------------------------------------------------
  static const int positiveStreakForMulhamah = 7;
  static const int positiveStreakForMutmainnah = 30;
  static const int regressionStreakThreshold = 3;

  // ---------------------------------------------------------------------------
  // Pathway progress threshold (RI-4.6).
  //
  // A pathway step is considered "progressed" when its detected Score > 0.3.
  // Rationale: Score = Weight(emotion→attr) × Intensity / 10. A typical
  // detection — weight 0.65 × intensity 5/10 = 0.325 ≈ 0.3 — corresponds
  // to a moderate-intensity check-in surfacing the attribute. Below this,
  // the attribute is not meaningfully "detected" by the user.
  //
  // This is NOT an Islamic ruling. It is the engineering threshold at which
  // the Insight screen should surface the attribute as relevant.
  // ---------------------------------------------------------------------------
  static const double pathwayProgressScoreThreshold = 0.3;

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