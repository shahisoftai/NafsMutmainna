import '../../entities/emotion.dart';
import '../../entities/heart_attribute.dart';
import '../../entities/intervention_card.dart';
import '../../entities/hadees.dart';
import '../../entities/quran_ayat.dart';
import '../../repositories/attribute_repository.dart';
import '../../repositories/emotion_attribute_link_repository.dart';
import '../../repositories/emotion_repository.dart';
import '../../repositories/hadees_repository.dart';
import '../../repositories/intervention_history_repository.dart';
import '../../repositories/quran_ayat_repository.dart';

/// Builds up to 6 intervention cards (Quran / Hadith / Dua / Names / Dhikr / Action)
/// for the given emotion and intensity.
///
/// Candidate attributes come from the top-3 Treatment+Core links (ordered by Weight
/// DESC), matching recommendation_algorithm.md §4.2:
///   WHERE Role IN ('Treatment', 'Core') ORDER BY Weight DESC LIMIT 3
///
/// Cards are ranked by the composite formula from recommendation_algorithm.md §4.6:
///   rank = 0.6 × baseScore  +  0.3 × (intensity / 10)  +  0.1 × (Mutmainnah / 100)
///
/// The Mutmainnah bias rewards cards whose source attribute sits higher on the
/// spiritual scale (more Mutmainnah weight = more virtue).  This ensures a card
/// from a high-virtue Treatment attribute (e.g. Tawakkul) outranks one from a
/// low-virtue Treatment attribute of equal Weight.
class Recommend {
  final EmotionAttributeLinkRepositoryInterface _links;
  final AttributeRepositoryInterface _attrs;
  final EmotionRepositoryInterface _emotions;
  final InterventionHistoryRepositoryInterface _history;
  final HadeesRepository _hadees;
  final QuranAyatRepository _quranAyat;

  Recommend(
    this._links,
    this._attrs,
    this._emotions,
    this._history,
    this._hadees,
    this._quranAyat,
  );

  Future<List<InterventionCard>> call(int emotionId, int intensity) async {
    // --- Step 1: Resolve the emotion ---
    final emotion = await _emotions.getById(emotionId);
    if (emotion == null) return [];

    // --- Step 2: Top 3 Treatment + Core attributes combined ---
    // Query both roles in one pass (Role IN ('Treatment','Core')).
    // This ensures the Core attribute — the single most important one — is
    // always included, even when Treatment links are present.
    final links = await _links.findForEmotionTop(
      emotionId,
      roles: const ['Treatment', 'Core'],
      limit: 3,
    );

    // --- Step 3: Build candidate cards ---
    final candidates = <InterventionCard>[];
    final attrs = <HeartAttribute>[];

    for (final link in links) {
      final attr = await _attrs.getById(link.attributeId);
      if (attr == null) continue;
      attrs.add(attr);
      final baseScore = link.weight * (intensity / 10.0);
      candidates.addAll(_buildAttributeCards(attr, emotion, baseScore));
    }

    // --- Step 4: Emotion-level cards (Dhikr + Action) ---
    candidates.add(_buildDhikrCard(emotion, attrs));
    candidates.add(_buildActionCard(emotion, attrs));

    // --- Step 5: Randomised Hadith + Quran from normalised pools ---
    final recent = await _history.findRecent(7);
    final recentHadeesIds = recent
        .where((r) => r.interventionType.name == 'hadith')
        .map((r) => r.attributeId)
        .toSet();
    final recentAyatIds = recent
        .where((r) => r.interventionType.name == 'quran')
        .map((r) => r.attributeId)
        .toSet();

    final hadees = await _fetchRandomHadees(emotionId, recentHadeesIds);
    if (hadees != null) {
      candidates.add(_buildHadeesCard(hadees, emotion, 0.85));
    }

    final ayat = await _fetchRandomAyat(emotionId, recentAyatIds);
    if (ayat != null) {
      candidates.add(_buildAyatCard(ayat, emotion, 0.85));
    }

    // --- Step 6: Apply 7-day no-repeat filter ---
    final seen = recent
        .map((r) => (r.interventionType, r.attributeId, r.emotionId))
        .toSet();
    final filtered = candidates
        .where((c) => !seen.contains((c.type, c.attributeId, c.emotionId)))
        .toList();

    // --- Step 7: Rank by composite formula ---
    // rank = 0.6 × baseScore  +  0.3 × (intensity / 10)  +  0.1 × (Mutmainnah / 100)
    // Nafs weights are on the 0–100 scale, so divide by 100 to get 0–1.
    final intensityMult = (intensity / 10.0).clamp(0.0, 1.0);
    // Build a local rank map to avoid mutable state on the use-case instance.
    final rankScores = <InterventionCard, double>{};
    for (final c in filtered) {
      if (c.attributeId > 0) {
        final nafsW = await _attrs.getNafsWeights(c.attributeId);
        rankScores[c] = 0.6 * c.score + 0.3 * intensityMult + 0.1 * (nafsW.mutmainnah / 100.0);
      } else {
        // Dhikr / Action cards have attributeId = 0; rank purely on score + intensity.
        rankScores[c] = 0.6 * c.score + 0.3 * intensityMult;
      }
    }

    filtered.sort((a, b) => (rankScores[b] ?? 0).compareTo(rankScores[a] ?? 0));

    // --- Step 8: Deduplicate by card type, take top 6 ---
    final deduped = <InterventionType, InterventionCard>{};
    for (final card in filtered) {
      deduped.putIfAbsent(card.type, () => card);
    }
    return deduped.values.take(6).toList();
  }

  // ---------------------------------------------------------------------------
  // Card builders
  // ---------------------------------------------------------------------------

  Future<Hadees?> _fetchRandomHadees(int emotionId, Set<int> excludeIds) async {
    final pool = await _hadees.findForEmotion(emotionId);
    if (pool.isEmpty) return null;
    for (int attempt = 0; attempt < 5; attempt++) {
      final hadees = await _hadees.findRandomForEmotionExcluding(
        emotionId: emotionId,
        excludeIds: excludeIds,
      );
      if (hadees != null) return hadees;
    }
    return null;
  }

  Future<QuranAyat?> _fetchRandomAyat(int emotionId, Set<int> excludeIds) async {
    final pool = await _quranAyat.findForEmotion(emotionId);
    if (pool.isEmpty) return null;
    for (int attempt = 0; attempt < 5; attempt++) {
      final ayat = await _quranAyat.findRandomForEmotionExcluding(
        emotionId: emotionId,
        excludeIds: excludeIds,
      );
      if (ayat != null) return ayat;
    }
    return null;
  }

  InterventionCard _buildHadeesCard(Hadees hadees, Emotion emotion, double score) {
    return InterventionCard(
      type: InterventionType.hadith,
      title: 'Hadith',
      subtitle: '${hadees.sourceBook} ${hadees.hadithNumber}',
      arabic: hadees.arabicText,
      translation: hadees.englishTranslation,
      urdu: hadees.urduTranslation,
      why: 'Authentic guidance for ${emotion.name}',
      attributeId: hadees.id,
      emotionId: emotion.id,
      score: score,
    );
  }

  InterventionCard _buildAyatCard(QuranAyat ayat, Emotion emotion, double score) {
    return InterventionCard(
      type: InterventionType.quran,
      title: 'Quran',
      subtitle: ayat.fullReference,
      arabic: ayat.arabicText,
      translation: ayat.englishTranslation,
      urdu: ayat.urduTranslation,
      why: 'Divine guidance for ${emotion.name}',
      attributeId: ayat.id,
      emotionId: emotion.id,
      score: score,
    );
  }

  List<InterventionCard> _buildAttributeCards(
      HeartAttribute attr, Emotion emotion, double score) {
    final cards = <InterventionCard>[];
    if ((attr.quranReference ?? '').isNotEmpty) {
      cards.add(InterventionCard(
        type: InterventionType.quran,
        title: 'Quran',
        subtitle: attr.quranReference!,
        arabic: attr.quranArabic ?? '',
        translation: attr.quranEnglish ?? '',
        urdu: attr.quranUrdu ?? '',
        why: 'Reflective guidance for ${attr.name}',
        attributeId: attr.id,
        emotionId: emotion.id,
        score: score,
      ));
    }
    if ((attr.hadithReference ?? '').isNotEmpty) {
      cards.add(InterventionCard(
        type: InterventionType.hadith,
        title: 'Hadith',
        subtitle: attr.hadithReference!,
        arabic: attr.hadithArabic ?? '',
        translation: attr.hadithUrdu ?? '',
        urdu: '',
        why: 'Practical guidance for ${attr.name}',
        attributeId: attr.id,
        emotionId: emotion.id,
        score: score,
      ));
    }
    // Prefer Quranic dua over Prophetic dua (both are valid; Quranic dua gets +0.05 bump
    // to reflect its direct Quranic source — matches recommendation_algorithm.md §4.3).
    if ((attr.quranicDuaReference ?? '').isNotEmpty) {
      cards.add(InterventionCard(
        type: InterventionType.dua,
        title: 'Dua',
        subtitle: attr.quranicDuaReference!,
        arabic: attr.quranicDuaArabic ?? '',
        translation: attr.quranicDuaUrdu ?? '',
        urdu: '',
        why: 'A Quranic supplication for ${attr.name}',
        attributeId: attr.id,
        emotionId: emotion.id,
        score: score + 0.05,
      ));
    } else if ((attr.propheticDuaReference ?? '').isNotEmpty) {
      cards.add(InterventionCard(
        type: InterventionType.dua,
        title: 'Dua',
        subtitle: attr.propheticDuaReference!,
        arabic: attr.propheticDuaArabic ?? '',
        translation: attr.propheticDuaUrdu ?? '',
        urdu: '',
        why: 'A supplication for ${attr.name}',
        attributeId: attr.id,
        emotionId: emotion.id,
        score: score,
      ));
    }
    if ((attr.relevantAllahNames ?? '').isNotEmpty) {
      cards.add(InterventionCard(
        type: InterventionType.allahNames,
        title: 'Allah Names',
        subtitle: '',
        arabic: attr.relevantAllahNames!,
        translation: '',
        urdu: '',
        why: 'Reflect on these names to cultivate ${attr.name}',
        attributeId: attr.id,
        emotionId: emotion.id,
        score: score,
      ));
    }
    return cards;
  }

  InterventionCard _buildDhikrCard(Emotion emotion, List<HeartAttribute> attrs) {
    if (emotion.recommendedDhikr.isNotEmpty) {
      return InterventionCard(
        type: InterventionType.dhikr,
        title: 'Dhikr',
        subtitle: '',
        arabic: emotion.recommendedDhikr,
        translation: '',
        urdu: '',
        why: 'Recommended dhikr for ${emotion.name}',
        attributeId: 0,
        emotionId: emotion.id,
        score: 0.5,
      );
    }
    final fallback = _fallbackAttribute(attrs, (a) => a.quranReference);
    if (fallback != null) {
      return InterventionCard(
        type: InterventionType.dhikr,
        title: 'Dhikr',
        subtitle: fallback.quranReference ?? '',
        arabic: fallback.quranArabic ?? '',
        translation: fallback.quranEnglish ?? '',
        urdu: fallback.quranUrdu ?? '',
        why: 'Reflective guidance for ${fallback.name}',
        attributeId: fallback.id,
        emotionId: emotion.id,
        score: 0.4,
      );
    }
    return InterventionCard(
      type: InterventionType.dhikr,
      title: 'Dhikr',
      subtitle: '',
      arabic: '',
      translation: '',
      urdu: '',
      why: 'Remembrance for ${emotion.name}',
      attributeId: 0,
      emotionId: emotion.id,
      score: 0.3,
    );
  }

  InterventionCard _buildActionCard(Emotion emotion, List<HeartAttribute> attrs) {
    if (emotion.dailyAction.isNotEmpty) {
      return InterventionCard(
        type: InterventionType.action,
        title: 'Daily Action',
        subtitle: '',
        arabic: '',
        translation: emotion.dailyAction,
        urdu: '',
        why: 'A practical step for ${emotion.name}',
        attributeId: 0,
        emotionId: emotion.id,
        score: 0.5,
      );
    }
    final fallback = _fallbackAttribute(attrs, (a) => a.hadithReference);
    if (fallback != null) {
      return InterventionCard(
        type: InterventionType.action,
        title: 'Daily Action',
        subtitle: fallback.hadithReference ?? '',
        arabic: fallback.hadithArabic ?? '',
        translation: fallback.hadithUrdu ?? '',
        urdu: '',
        why: 'Practical guidance from ${fallback.name}',
        attributeId: fallback.id,
        emotionId: emotion.id,
        score: 0.4,
      );
    }
    return InterventionCard(
      type: InterventionType.action,
      title: 'Daily Action',
      subtitle: '',
      arabic: '',
      translation: '',
      urdu: '',
      why: 'A step toward growth for ${emotion.name}',
      attributeId: 0,
      emotionId: emotion.id,
      score: 0.3,
    );
  }

  HeartAttribute? _fallbackAttribute(
      List<HeartAttribute> attrs, String? Function(HeartAttribute) getter) {
    for (final attr in attrs) {
      final ref = getter(attr);
      if ((ref ?? '').isNotEmpty) return attr;
    }
    return null;
  }
}
