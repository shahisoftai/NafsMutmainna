/// Centralised, immutable tazkiya-safe copy for the app.
///
/// Every user-facing string that touches Islamic content references one of
/// the classical principles established in
/// `docs/scholar-audit-remediation-plan.md` §1:
///
/// - The Nafs Meter is an *indicator of pattern*, never a judgment.
/// - Tazkiya is practice-based, not knowledge-based.
/// - Three causes: nafs, Shaytan, hawa.
/// - Self-knowledge requires muhasabah (and ideally a sheikh).
/// - Taharah and halaal rizq are foundations.
///
/// All copy is pure-static — no Flutter or I/O — so it can be unit-tested
/// and translated via the existing `intl` machinery without breaking the
/// const invariants.
class TazkiyaCopy {
  TazkiyaCopy._();

  // ---------------------------------------------------------------------------
  // RI-5.1 — Nafs Meter banner (Home screen).
  // ---------------------------------------------------------------------------
  static const String meterBannerTitle = 'A note on this meter';

  /// English banner text shown beneath the Nafs Meter.
  /// Per Ghazali, Ihya' 3.13: the four states are *alamat muqhaṭṭa* —
  /// probable indicators, not rulings.
  static const String meterBannerBodyEn =
      'This meter reflects patterns from your recent check-ins. It is an '
      'indicator, not a judgment of your heart. The reality of your soul '
      'is known only to Allah.';

  static const String meterBannerBodyAr =
      'هذا المقياس يعكس أنماطاً من فحوصاتك الأخيرة. '
      'هو مؤشر، وليس حكماً على قلبك. حقيقة نفسك لا يعلمها إلا الله.';

  // ---------------------------------------------------------------------------
  // RI-4.7 — Intervention screen disclaimer.
  // ---------------------------------------------------------------------------
  static const String interventionDisclaimerEn =
      'These recommendations are general. For treatment specific to your '
      'state, consult a qualified scholar of tazkiya.';

  static const String interventionDisclaimerAr =
      'هذه التوصيات عامة. للعلاج الخاص بحالتك، استشر عالماً مؤهلاً في علم التزكية.';

  // ---------------------------------------------------------------------------
  // RI-5.2 — Muhasabah prompts (Reflect screen).
  //
  // Per Tirmidhi 2459 (hasan): "حاسبوا أنفسكم قبل أن تحاسبوا".
  // Al-Muhasibi's al-Ri'aya is built on these three questions.
  // ---------------------------------------------------------------------------
  static const List<String> muhasabahPromptsEn = [
    'What intention was in your heart today?',
    'Where did you see Allah\'s signs today?',
    'What was the strongest whisper — your self, your desires, or Shaytan?',
    'Which attribute of the heart did you strengthen today?',
    'Did you act from knowledge, or from habit?',
  ];

  static const List<String> muhasabahPromptsAr = [
    'ما كانت نية قلبك اليوم؟',
    'أين رأيت آيات الله اليوم؟',
    'ما كان أقوى وسواس — نفسك، أم رغباتك، أم الشيطان؟',
    'أي صفة من صفات القلب قويت اليوم؟',
    'هل عملت من علم، أم من عادة؟',
  ];

  // ---------------------------------------------------------------------------
  // RI-3.3 — Sheikh/Murabbi gentle reminder (Pathways screen).
  // ---------------------------------------------------------------------------
  static const String sheikhPanelTitleEn = 'A note on the sheikh';

  static const String sheikhPanelBodyEn =
      'Tazkiya in the Islamic tradition usually requires a sheikh — a '
      'qualified, living teacher of the path. This app is a companion, '
      'not a replacement. Consider seeking a local scholar of tazkiya '
      'for guidance on the deeper stations.';

  // Hadith reference (Bukhari 52, Muslim 1599 partial).
  static const String sheikhPanelHadithRef =
      'Abu Dawud 4033 — "الرَّجُلُ عَلَى دِينِ خَلِيلِهِ"';

  // ---------------------------------------------------------------------------
  // RI-5.6 — Suluk framing on Pathways.
  // ---------------------------------------------------------------------------
  static const String sulukPathwaysTitleEn = 'Suluk — Spiritual Pathways';

  static const String sulukPathwaysIntroEn =
      'These pathways follow the salaf al-salih and the great imams of '
      'tazkiya: Imam al-Ghazali (Ihya Ulum al-Din), Ibn al-Qayyim '
      '(Madarij al-Salikin), and al-Harith al-Muhasibi (al-Ri\'aya).';

  // ---------------------------------------------------------------------------
  // RI-3.4 — Foundational habits (Taharah, Halal Rizq, Hifz al-Lisan).
  // ---------------------------------------------------------------------------
  static const List<({String name, String category, String sourceRef})>
      foundationalHabits = [
    (
      name: 'Perform wudu before each Salah',
      category: 'Prayer',
      sourceRef: 'Quran 5:6; Tirmidhi 2860',
    ),
    (
      name: 'Earn rizq only from halal sources',
      category: 'Other',
      sourceRef: 'Bukhari 52; Muslim 1599',
    ),
    (
      name: 'Guard the tongue from ghaybah, namimah, kadhib',
      category: 'Dhikr',
      sourceRef: 'Quran 50:18; Bukhari 6475',
    ),
  ];

  // ---------------------------------------------------------------------------
  // RI-3.7 — Body-Heart category (Sunnah sleep & eating).
  // ---------------------------------------------------------------------------
  static const List<({String name, String category, String sourceRef})>
      bodyHeartHabits = [
    (
      name: 'Sleep before midnight (Sunnah)',
      category: 'Other',
      sourceRef: 'Bukhari 5683',
    ),
    (
      name: 'Eat in moderation',
      category: 'Other',
      sourceRef: 'Tirmidhi 2380',
    ),
  ];

  // ---------------------------------------------------------------------------
  // RI-5.5 — Istighfar baseline (Onboarding).
  // ---------------------------------------------------------------------------
  static const String istighfarCardTitleEn = 'Begin with Istighfar';

  static const String istighfarCardBodyEn =
      'Tazkiya in the Sunnah begins with istighfar — seeking forgiveness. '
      'Abu Dawud 1518: "Whoever persists in istighfar, Allah will grant '
      'him relief from every worry." Begin each check-in by reciting '
      '"Astaghfirullah" three times.';

  /// Path identifier for the onboarding istighfar card (consumed by the
  /// onboarding flow's card-order list).
  static const String istighfarCardId = 'istighfar_baseline';
}