import '../../entities/emotion.dart';
import '../../entities/hadees.dart';
import '../../entities/heart_attribute.dart';
import '../../entities/intervention_card.dart';
import '../../entities/quran_ayat.dart';
import '../../repositories/attribute_repository.dart';
import '../../repositories/emotion_repository.dart';
import '../../repositories/hadees_repository.dart';
import '../../repositories/intervention_history_repository.dart';
import '../../repositories/quran_ayat_repository.dart';
import 'attribute_resolver.dart';

/// Recommend v2 — produces up to 6 intervention cards for a check-in.
///
/// Design principles (see `HeartOS/08_algorithms/recommendation_algorithm.md`):
///
/// 1. **Hand-curated first, derived second.** The Emotion row carries
///    per-emotion `Recommended_Dua*`, `Recommended_Allah_Names`,
///    `Recommended_Dhikr`, `Daily_Action`. These are the first source
///    for the Dua, Names, Dhikr, Action cards. Only when the Emotion
///    row has nothing in a field do we fall back to the resolved
///    attribute's embedded content.
///
/// 2. **Growth_Path drives depth.** Each Emotion has a `Growth_Path`
///    (e.g. "Ghadab→Sabr→Hilm→Rifq"). The path always ends at a
///    high-Mutmainnah attribute. Intensity picks WHICH step on the
///    path to feature:
///       - intensity 1-3 (mild) → later step (aspirational)
///       - intensity 4-6 (moderate) → middle step
///       - intensity 7-10 (acute) → early step (immediate, practical)
///    The terminal step is always included as the "aspiration" anchor.
///
/// 3. **Deterministic Quran/Hadith.** The `emotion_quran_links` and
///    `emotion_hadees_links` tables are hand-curated against the
///    emotion's theme. We pick the top by `Weight DESC` (NOT random).
///    A soft 3-day skip prefers variety but never blocks.
///
/// 4. **No magic scoring.** No 0.6/0.3/0.1 weighted sums. The card
///    order is deterministic and explainable.
///
/// 5. **Failproof.** Missing fields produce empty card text, never
///    exceptions. Unresolvable Growth_Path steps are logged and
///    skipped. An Emotion with zero usable content still produces a
///    single Dhikr-style reflection card so the screen is never empty.
class Recommend {
  final EmotionRepositoryInterface _emotions;
  final InterventionHistoryRepositoryInterface _history;
  final HadeesRepository _hadees;
  final QuranAyatRepository _quranAyat;
  final AttributeResolver _resolver;

  /// The number of days to soft-skip when picking top Quran/Hadith.
  /// Short enough that the user is not starved, long enough to give
  /// the same emotion a different feel across consecutive days.
  static const int softSkipDays = 3;

  /// Maximum number of cards to return.
  static const int maxCards = 6;

  /// Default constructor. Builds the [AttributeResolver] internally.
  Recommend(
    AttributeRepositoryInterface attrs,
    this._emotions,
    this._history,
    this._hadees,
    this._quranAyat,
  ) : _resolver = AttributeResolver(attrs);

  /// Convenience constructor that accepts pre-built [resolver] (for tests
  /// that want to stub out attribute resolution).
  Recommend.withResolver(
    this._emotions,
    this._history,
    this._hadees,
    this._quranAyat,
    this._resolver,
  );

  Future<List<InterventionCard>> call(int emotionId, int intensity) async {
    final emotion = await _emotions.getById(emotionId);
    if (emotion == null) return [];

    final clampedIntensity = intensity.clamp(1, 10);

    // --- Step 1: Resolve the growth path to attribute IDs. ---
    final resolvedAttrs = await _resolveGrowthPath(emotion);

    // --- Step 2: Pick the focus attribute by intensity. ---
    final focusAttr = _pickFocus(resolvedAttrs, clampedIntensity);

    // --- Step 3: Collect recent IDs for soft-skip. ---
    final recent = await _history.findRecent(softSkipDays);
    final recentQuranIds = recent
        .where((r) => r.interventionType == InterventionType.quran)
        .map((r) => r.attributeId)
        .where((id) => id > 0)
        .toSet();
    final recentHadeesIds = recent
        .where((r) => r.interventionType == InterventionType.hadith)
        .map((r) => r.attributeId)
        .where((id) => id > 0)
        .toSet();

    // --- Step 4: Build the 6 cards. ---
    final cards = <InterventionCard>[];

    // (a) Quran — top from emotion_quran_links by Weight DESC.
    final quran = await _pickTopQuran(emotionId, recentQuranIds);
    if (quran != null) {
      cards.add(_buildAyatCard(quran, emotion));
    } else if (focusAttr != null) {
      // Fallback: attribute's embedded Quran_Reference.
      final fb = _buildAttributeQuranCard(focusAttr, emotion);
      if (fb != null) cards.add(fb);
    }

    // (b) Hadith — top from emotion_hadees_links by Weight DESC.
    final hadees = await _pickTopHadees(emotionId, recentHadeesIds);
    if (hadees != null) {
      cards.add(_buildHadeesCard(hadees, emotion));
    } else if (focusAttr != null) {
      final fb = _buildAttributeHadithCard(focusAttr, emotion);
      if (fb != null) cards.add(fb);
    }

    // (c) Dua — from Emotion row, if any content is present.
    final dua = _buildDuaCard(emotion);
    if (dua != null) cards.add(dua);

    // (d) Names — from Emotion row.
    final names = _buildNamesCard(emotion);
    if (names != null) cards.add(names);

    // (e) Dhikr — from Emotion row.
    final dhikr = _buildDhikrCard(emotion);
    if (dhikr != null) cards.add(dhikr);

    // (f) Action — from Emotion row.
    final action = _buildActionCard(emotion);
    if (action != null) cards.add(action);

    // --- Step 5: Trim and guarantee at least 1 card. ---
    final trimmed = cards.take(maxCards).toList();
    if (trimmed.isEmpty) {
      trimmed.add(_buildReflectionFallback(emotion));
    }
    return trimmed;
  }

  // ===========================================================================
  // Path resolution
  // ===========================================================================

  /// Resolves the Emotion's `Growth_Path` to a list of [HeartAttribute]s.
  ///
  /// For negative emotions, the first step is often the disease attribute
  /// (e.g. "Ghadab") or the emotion name itself (e.g. "Anxiety"). We still
  /// keep it in the list — the focus picker will skip to the next step for
  /// acute intensity — but the resolver gracefully returns null for names
  /// that don't match an attribute, in which case the step is dropped.
  ///
  /// If the Growth_Path is empty or yields nothing resolvable, falls back
  /// to `Primary_Positive_Attributes` (e.g. "Sabr;Hilm;Rifq" for Anger).
  Future<List<HeartAttribute>> _resolveGrowthPath(Emotion emotion) async {
    final fromPath = await _resolver.resolveAll(emotion.growthPathSteps);
    if (fromPath.isNotEmpty) return fromPath;
    return _resolver.resolveAll(emotion.primaryPositiveAttributeNames);
  }

  /// Picks the index in [attrs] that matches the intensity profile.
  ///
  /// - `intensity 1-3` → last index (mild → aspirational)
  /// - `intensity 4-6` → middle index
  /// - `intensity 7-10` → first index (acute → immediate)
  HeartAttribute? _pickFocus(List<HeartAttribute> attrs, int intensity) {
    if (attrs.isEmpty) return null;
    final n = attrs.length;
    if (n == 1) return attrs.first;
    final last = n - 1;
    if (intensity <= 3) return attrs[last];
    if (intensity >= 7) return attrs[0];
    return attrs[(n / 2).floor().clamp(0, last)];
  }

  // ===========================================================================
  // Top-N pickers (deterministic by Weight DESC, soft-skip)
  // ===========================================================================

  Future<QuranAyat?> _pickTopQuran(int emotionId, Set<int> exclude) async {
    final top = await _quranAyat.findTopForEmotionExcluding(
      emotionId,
      limit: 1,
      excludeIds: exclude,
    );
    return top.isNotEmpty ? top.first : null;
  }

  Future<Hadees?> _pickTopHadees(int emotionId, Set<int> exclude) async {
    final top = await _hadees.findTopForEmotionExcluding(
      emotionId,
      limit: 1,
      excludeIds: exclude,
    );
    return top.isNotEmpty ? top.first : null;
  }

  // ===========================================================================
  // Card builders — Emotion-row-sourced (preferred)
  // ===========================================================================

  InterventionCard? _buildDuaCard(Emotion emotion) {
    final arabic = emotion.recommendedDuaArabicOrFallback;
    final english = emotion.recommendedDuaEnglishOrFallback;
    final urdu = emotion.recommendedDuaUrduOrFallback;
    final ref = emotion.recommendedDuaReferenceOrFallback;
    // Drop the card if the emotion row carries no content for it.
    if (arabic.isEmpty && english.isEmpty && urdu.isEmpty && ref.isEmpty) {
      return null;
    }
    return InterventionCard(
      type: InterventionType.dua,
      title: 'Dua',
      subtitle: ref,
      arabic: arabic,
      translation: english,
      urdu: urdu,
      why: 'Recommended supplication for ${emotion.name}',
      attributeId: 0,
      emotionId: emotion.id,
      score: 0.0,
    );
  }

  InterventionCard? _buildNamesCard(Emotion emotion) {
    final raw = emotion.recommendedAllahNames.trim();
    if (raw.isEmpty) return null;
    return InterventionCard(
      type: InterventionType.allahNames,
      title: 'Allah Names',
      subtitle: '',
      arabic: raw,
      translation: '',
      urdu: '',
      why: 'Names of Allah to reflect on for ${emotion.name}',
      attributeId: 0,
      emotionId: emotion.id,
      score: 0.0,
    );
  }

  InterventionCard? _buildDhikrCard(Emotion emotion) {
    final raw = emotion.recommendedDhikr.trim();
    if (raw.isEmpty) return null;
    return InterventionCard(
      type: InterventionType.dhikr,
      title: 'Dhikr',
      subtitle: '',
      arabic: raw,
      translation: '',
      urdu: '',
      why: 'Recommended remembrance for ${emotion.name}',
      attributeId: 0,
      emotionId: emotion.id,
      score: 0.0,
    );
  }

  InterventionCard? _buildActionCard(Emotion emotion) {
    final raw = emotion.dailyAction.trim();
    if (raw.isEmpty) return null;
    return InterventionCard(
      type: InterventionType.action,
      title: 'Daily Action',
      subtitle: '',
      arabic: '',
      translation: raw,
      urdu: '',
      why: 'A practical step for ${emotion.name}',
      attributeId: 0,
      emotionId: emotion.id,
      score: 0.0,
    );
  }

  // ===========================================================================
  // Card builders — emotion_quran_links / emotion_hadees_links sourced
  // ===========================================================================

  InterventionCard _buildAyatCard(QuranAyat ayat, Emotion emotion) {
    return InterventionCard(
      type: InterventionType.quran,
      title: 'Quran',
      subtitle: ayat.fullReference,
      arabic: ayat.arabicText,
      translation: ayat.englishTranslation,
      urdu: ayat.urduTranslation,
      why: 'Hand-picked for ${emotion.name}',
      attributeId: ayat.id,
      emotionId: emotion.id,
      score: 0.0,
    );
  }

  InterventionCard _buildHadeesCard(Hadees hadees, Emotion emotion) {
    return InterventionCard(
      type: InterventionType.hadith,
      title: 'Hadith',
      subtitle: '${hadees.sourceBook} ${hadees.hadithNumber}',
      arabic: hadees.arabicText,
      translation: hadees.englishTranslation,
      urdu: hadees.urduTranslation,
      why: 'Hand-picked for ${emotion.name}',
      attributeId: hadees.id,
      emotionId: emotion.id,
      score: 0.0,
    );
  }

  // ===========================================================================
  // Card builders — attribute-embedded fallback
  // ===========================================================================

  InterventionCard? _buildAttributeQuranCard(HeartAttribute a, Emotion emotion) {
    final ref = a.quranReference?.trim() ?? '';
    final arabic = a.quranArabic?.trim() ?? '';
    if (ref.isEmpty && arabic.isEmpty) return null;
    return InterventionCard(
      type: InterventionType.quran,
      title: 'Quran',
      subtitle: ref,
      arabic: arabic,
      translation: a.quranEnglish ?? '',
      urdu: a.quranUrdu ?? '',
      why: 'From the attribute ${a.name}, on the path of ${emotion.name}',
      attributeId: a.id,
      emotionId: emotion.id,
      score: 0.0,
    );
  }

  InterventionCard? _buildAttributeHadithCard(HeartAttribute a, Emotion emotion) {
    final ref = a.hadithReference?.trim() ?? '';
    final arabic = a.hadithArabic?.trim() ?? '';
    if (ref.isEmpty && arabic.isEmpty) return null;
    return InterventionCard(
      type: InterventionType.hadith,
      title: 'Hadith',
      subtitle: ref,
      arabic: arabic,
      translation: '',
      urdu: a.hadithUrdu ?? '',
      why: 'From the attribute ${a.name}, on the path of ${emotion.name}',
      attributeId: a.id,
      emotionId: emotion.id,
      score: 0.0,
    );
  }

  // ===========================================================================
  // Last-resort card
  // ===========================================================================

  InterventionCard _buildReflectionFallback(Emotion emotion) {
    return InterventionCard(
      type: InterventionType.dhikr,
      title: 'Reflection',
      subtitle: '',
      arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      translation:
          'Take a moment to pause, recall that you are in the presence of '
          'Allah, and gently bring your attention back to Him. Your state of '
          '${emotion.name} is a doorway to knowing Him better.',
      urdu: '',
      why: 'A reflection for ${emotion.name}',
      attributeId: 0,
      emotionId: emotion.id,
      score: 0.0,
    );
  }
}
