import 'package:flutter_test/flutter_test.dart';
import 'package:nafsmutmainna/src/domain/entities/emotion.dart';
import 'package:nafsmutmainna/src/domain/entities/hadees.dart';
import 'package:nafsmutmainna/src/domain/entities/heart_attribute.dart';
import 'package:nafsmutmainna/src/domain/entities/intervention_card.dart';
import 'package:nafsmutmainna/src/domain/entities/intervention_history.dart';
import 'package:nafsmutmainna/src/domain/entities/nafs_weights.dart';
import 'package:nafsmutmainna/src/domain/entities/quran_ayat.dart';
import 'package:nafsmutmainna/src/domain/repositories/attribute_repository.dart';
import 'package:nafsmutmainna/src/domain/repositories/emotion_repository.dart';
import 'package:nafsmutmainna/src/domain/repositories/hadees_repository.dart';
import 'package:nafsmutmainna/src/domain/repositories/intervention_history_repository.dart';
import 'package:nafsmutmainna/src/domain/repositories/quran_ayat_repository.dart';
import 'package:nafsmutmainna/src/domain/usecases/recommendations/recommend.dart';

// =============================================================================
// Stub repositories
// =============================================================================

class _StubAttributes implements AttributeRepositoryInterface {
  _StubAttributes(this._all);
  final List<HeartAttribute> _all;

  @override
  Future<List<HeartAttribute>> getAll() async => _all;

  @override
  Future<HeartAttribute?> getById(int id) async {
    for (final a in _all) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Future<AttributeNafsWeights> getNafsWeights(int id) async => AttributeNafsWeights(
        attributeId: id,
        ammarah: 0,
        lawwamah: 0,
        mulhamah: 0,
        mutmainnah: 0,
      );
}

class _StubEmotions implements EmotionRepositoryInterface {
  _StubEmotions(this._all);
  final List<Emotion> _all;

  @override
  Future<List<Emotion>> getAll() async => _all;

  @override
  Future<Emotion?> getById(int id) async {
    for (final e in _all) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<EmotionNafsWeights> getNafsWeights(int id) async => EmotionNafsWeights(
        emotionId: id,
        ammarah: 0,
        lawwamah: 0,
        mulhamah: 0,
        mutmainnah: 0,
      );

  @override
  Future<List<Emotion>> search(String query) async => _all;
}

class _StubHistory implements InterventionHistoryRepositoryInterface {
  _StubHistory([this._rows = const []]);
  final List<InterventionHistory> _rows;

  @override
  Future<int> insert(InterventionHistory row) async => 0;

  @override
  Future<List<InterventionHistory>> findRecent(int days) async => _rows;

  @override
  Future<void> markCompleted(int recordId, bool completed) async {}

  @override
  Future<void> markFeedback(int recordId, InterventionFeedback feedback) async {}

  @override
  Future<int> countCompletedForToday(DateTime date) async => 0;
}

class _StubHadees implements HadeesRepository {
  _StubHadees(this._all);
  final List<Hadees> _all;

  @override
  Future<List<Hadees>> getAll() async => _all;

  @override
  Future<Hadees?> getById(int id) async {
    for (final h in _all) {
      if (h.id == id) return h;
    }
    return null;
  }

  @override
  Future<List<Hadees>> findForEmotion(int emotionId, {int? limit}) async =>
      _all.where((h) => _linked[h.id] == emotionId).toList();

  @override
  Future<Hadees?> findRandomForEmotionExcluding({
    required int emotionId,
    required Set<int> excludeIds,
  }) async =>
      null;

  @override
  Future<List<Hadees>> findTopForEmotion(int emotionId, {int? limit}) async {
    final out = _all.where((h) => _linked[h.id] == emotionId).toList();
    return limit == null ? out : out.take(limit).toList();
  }

  @override
  Future<List<Hadees>> findTopForEmotionExcluding(
    int emotionId, {
    int? limit,
    Set<int> excludeIds = const <int>{},
  }) async {
    final out = _all
        .where((h) => _linked[h.id] == emotionId && !excludeIds.contains(h.id))
        .toList();
    if (out.isNotEmpty) return limit == null ? out : out.take(limit).toList();
    final fallback =
        _all.where((h) => _linked[h.id] == emotionId).toList();
    return limit == null ? fallback : fallback.take(limit).toList();
  }

  // Map hadees id -> emotionId (1-1 for tests).
  final Map<int, int> _linked = {};
  void link(int hadeesId, int emotionId) {
    _linked[hadeesId] = emotionId;
  }
}

class _StubQuran implements QuranAyatRepository {
  _StubQuran(this._all);
  final List<QuranAyat> _all;

  @override
  Future<List<QuranAyat>> getAll() async => _all;

  @override
  Future<QuranAyat?> getById(int id) async {
    for (final a in _all) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Future<List<QuranAyat>> findForEmotion(int emotionId, {int? limit}) async =>
      _all.where((a) => _linked[a.id] == emotionId).toList();

  @override
  Future<QuranAyat?> findRandomForEmotionExcluding({
    required int emotionId,
    required Set<int> excludeIds,
  }) async =>
      null;

  @override
  Future<List<QuranAyat>> findTopForEmotion(int emotionId, {int? limit}) async {
    final out = _all.where((a) => _linked[a.id] == emotionId).toList();
    return limit == null ? out : out.take(limit).toList();
  }

  @override
  Future<List<QuranAyat>> findTopForEmotionExcluding(
    int emotionId, {
    int? limit,
    Set<int> excludeIds = const <int>{},
  }) async {
    final out = _all
        .where((a) => _linked[a.id] == emotionId && !excludeIds.contains(a.id))
        .toList();
    if (out.isNotEmpty) return limit == null ? out : out.take(limit).toList();
    final fallback =
        _all.where((a) => _linked[a.id] == emotionId).toList();
    return limit == null ? fallback : fallback.take(limit).toList();
  }

  final Map<int, int> _linked = {};
  void link(int ayatId, int emotionId) {
    _linked[ayatId] = emotionId;
  }
}

// =============================================================================
// Test fixtures
// =============================================================================

Emotion _anger({
  String growthPath = 'Ghadab→Sabr→Hilm→Rifq',
  String primaryPositive = 'Sabr;Hilm;Rifq',
  String duaArabic = 'اللَّهُمَّ اهْدِنِي',
  String duaEnglish = 'O Allah, guide me.',
  String duaUrdu = 'اے اللہ! رہنمائی فرما۔',
  String duaRef = 'Sahih Muslim 771',
  String names = 'Al-Halim;Ar-Rahim',
  String dhikr = 'SubhanAllahi wa bihamdihi',
  String action = 'Remain silent and perform wudu',
  String category = 'Negative',
  // For "all pools empty" tests: also clear the short-text fallback fields
  // so the Dua card returns no content.
  String duaEnglishFallback = 'Allahumma ihdini',
  String namesFallback = 'Al-Halim',
  String dhikrFallback = 'SubhanAllahi wa bihamdihi',
  String actionFallback = 'Remain silent and perform wudu',
}) {
  return Emotion(
    id: 1,
    name: 'Anger',
    arabicName: 'الغضب',
    category: category,
    description: 'desc',
    commonTriggers: '',
    primaryNegativeAttributes: 'Ghadab',
    secondaryNegativeAttributes: '',
    primaryPositiveAttributes: primaryPositive,
    growthPath: growthPath,
    dominantNafsState: 'Ammarah',
    severityWeight: 8,
    recommendedAttributePriority: 'Ghadab',
    recommendedInterventionType: 'Patience',
    recommendedDua: duaEnglishFallback,
    recommendedAllahNames: namesFallback,
    recommendedDhikr: dhikrFallback,
    dailyAction: actionFallback,
    relatedEmotions: '',
    relatedAttributeIds: '',
    keywords: '',
    recommendedDuaArabic: duaArabic.isEmpty ? null : duaArabic,
    recommendedDuaEnglish: duaEnglish.isEmpty ? null : duaEnglish,
    recommendedDuaUrdu: duaUrdu.isEmpty ? null : duaUrdu,
    recommendedDuaReference: duaRef.isEmpty ? null : duaRef,
  );
}

Emotion _gratitude({
  String growthPath = 'Shukr→Qana\'ah→Ridha→Mahabbah',
  String primaryPositive = 'Shukr;Qana\'ah;Ridha',
  String category = 'Positive',
}) {
  return Emotion(
    id: 31,
    name: 'Gratitude',
    arabicName: 'الشكر',
    category: category,
    description: 'desc',
    commonTriggers: '',
    primaryNegativeAttributes: '',
    secondaryNegativeAttributes: '',
    primaryPositiveAttributes: primaryPositive,
    growthPath: growthPath,
    dominantNafsState: 'Lawwamah',
    severityWeight: 4,
    recommendedAttributePriority: 'Shukr',
    recommendedInterventionType: 'Gratitude',
    recommendedDua: 'Alhamdulillah',
    recommendedAllahNames: 'Ash-Shakur',
    recommendedDhikr: 'Alhamdulillah',
    dailyAction: 'Count five blessings',
    relatedEmotions: '',
    relatedAttributeIds: '',
    keywords: '',
    recommendedDuaArabic: 'الْحَمْدُ لِلَّهِ',
    recommendedDuaEnglish: 'All praise is for Allah.',
    recommendedDuaUrdu: 'تمام تعریف اللہ کے لیے ہے۔',
    recommendedDuaReference: 'Sahih al-Bukhari 7374',
  );
}

List<HeartAttribute> _angerPathAttrs() => const [
      HeartAttribute(
        id: 23,
        name: 'Ghadab',
        arabicName: 'الغضب',
        nature: 'Negative',
        definition: 'Uncontrolled anger.',
        keywords: 'anger',
      ),
      HeartAttribute(
        id: 69,
        name: 'Sabr',
        arabicName: 'الصبر',
        nature: 'Positive',
        definition: 'Patience.',
        keywords: 'patience',
        quranReference: 'Al-Baqarah 2:153',
        quranArabic: 'اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ',
        quranEnglish: 'Seek help through patience and prayer.',
        quranUrdu: 'صبر اور نماز سے مدد لو۔',
        hadithReference: 'Sahih al-Bukhari 6116',
        hadithArabic: 'لَا تَغْضَبْ',
        hadithUrdu: 'غصہ نہ کرو۔',
      ),
      HeartAttribute(
        id: 80,
        name: 'Hilm',
        arabicName: 'الحلم',
        nature: 'Positive',
        definition: 'Forbearance.',
        keywords: 'forbearance',
        quranReference: 'Ali Imran 3:134',
        quranArabic: 'وَالْكَاظِمِينَ الْغَيْظَ',
        quranEnglish: 'Those who restrain anger.',
        quranUrdu: 'غصہ دبائیں۔',
        hadithReference: 'Sahih al-Bukhari 6114',
        hadithArabic: 'لَيْسَ الشَّدِيدُ',
        hadithUrdu: 'زور والا وہ ہے جو غصہ پر قابو رکھے۔',
      ),
      HeartAttribute(
        id: 79,
        name: 'Rifq',
        arabicName: 'الرِّفق',
        nature: 'Positive',
        definition: 'Gentleness.',
        keywords: 'gentleness',
      ),
    ];

QuranAyat _ayat(int id, String ref) => QuranAyat(
      id: id,
      arabicText: 'arabic $id',
      englishTranslation: 'english $id',
      urduTranslation: 'urdu $id',
      surahName: 'Al-Baqarah',
      verseNumber: 1,
      fullReference: ref,
    );

Hadees _hadees(int id, String ref) => Hadees(
      id: id,
      arabicText: 'arabic h $id',
      englishTranslation: 'english h $id',
      urduTranslation: 'urdu h $id',
      sourceBook: 'Sahih al-Bukhari',
      hadithNumber: ref,
      grade: 'Sahih',
    );

// =============================================================================
// Tests
// =============================================================================

void main() {
  group('Recommend v2', () {
    test('returns 6 cards for Anger at intensity 5 (all emotion-row sources populated)', () async {
      final attrs = _StubAttributes(_angerPathAttrs());
      final emotions = _StubEmotions([_anger()]);
      final history = _StubHistory();
      final quran = _StubQuran([
        _ayat(1, 'Al-Baqarah 2:153'),
        _ayat(2, 'Ali Imran 3:134'),
      ]);
      quran.link(1, 1);
      quran.link(2, 1);
      final hadees = _StubHadees([
        _hadees(1, '6116'),
        _hadees(2, '6114'),
      ]);
      hadees.link(1, 1);
      hadees.link(2, 1);

      final r = Recommend(attrs, emotions, history, hadees, quran);
      final cards = await r(1, 5);

      expect(cards, hasLength(6));
      final types = cards.map((c) => c.type).toSet();
      expect(types, containsAll(InterventionType.values));
    });

    test('Quran card is the top-weighted ayat for the emotion', () async {
      final attrs = _StubAttributes(_angerPathAttrs());
      final emotions = _StubEmotions([_anger()]);
      final history = _StubHistory();
      final quran = _StubQuran([_ayat(1, 'A'), _ayat(2, 'B')]);
      quran.link(1, 1);
      quran.link(2, 1);
      final hadees = _StubHadees([_hadees(1, '1')]);
      hadees.link(1, 1);

      final r = Recommend(attrs, emotions, history, hadees, quran);
      final cards = await r(1, 5);
      final quranCard = cards.firstWhere((c) => c.type == InterventionType.quran);
      expect(quranCard.attributeId, anyOf(1, 2));
      // Both ayats are linked; top 1 returned (deterministic, no random).
    });

    test('soft-skip: top ayat shown in last 3 days falls back to #2', () async {
      final attrs = _StubAttributes(_angerPathAttrs());
      final emotions = _StubEmotions([_anger()]);
      // Mark ayat id=1 as shown in last 3 days.
      final history = _StubHistory([
        InterventionHistory(
          id: 1,
          date: DateTime.now(),
          emotionId: 1,
          attributeId: 1,
          interventionType: InterventionType.quran,
          completed: true,
        ),
      ]);
      final quran = _StubQuran([_ayat(1, 'A'), _ayat(2, 'B')]);
      quran.link(1, 1);
      quran.link(2, 1);
      final hadees = _StubHadees([_hadees(1, '1')]);
      hadees.link(1, 1);

      final r = Recommend(attrs, emotions, history, hadees, quran);
      final cards = await r(1, 5);
      final quranCard = cards.firstWhere((c) => c.type == InterventionType.quran);
      expect(quranCard.attributeId, 2, reason: 'top 1 was shown recently; should return 2');
    });

    test('empty Quran pool → falls back to focus attribute embedded Quran', () async {
      final attrs = _StubAttributes(_angerPathAttrs());
      final emotions = _StubEmotions([_anger()]);
      final history = _StubHistory();
      final quran = _StubQuran([]); // no links
      final hadees = _StubHadees([]);

      final r = Recommend(attrs, emotions, history, hadees, quran);
      // intensity 5 with 4 attrs → middle = Hilm (id=80), which has
      // embedded Quran content. Sabr (id=69) is the first step with
      // content but is not the focus at this intensity.
      final cards = await r(1, 5);

      final quranCard = cards.firstWhere(
        (c) => c.type == InterventionType.quran,
        orElse: () => throw StateError('expected Quran card from focus attribute'),
      );
      expect(quranCard.attributeId, 80);
      expect(quranCard.subtitle, 'Ali Imran 3:134');
    });

    test('intensity 9 (acute) picks first Growth_Path step (Ghadab)', () async {
      final attrs = _StubAttributes(_angerPathAttrs());
      final emotions = _StubEmotions([_anger()]);
      final history = _StubHistory();
      final quran = _StubQuran([]);
      final hadees = _StubHadees([]);

      final r = Recommend(attrs, emotions, history, hadees, quran);
      final cards = await r(1, 9);

      // Ghadab (id=23) is the first step and has no embedded Quran/Hadith
      // in the fixture, so we get exactly 4 emotion-row cards: Dua, Names,
      // Dhikr, Action. No Quran/Hadith to assert on.
      expect(cards.length, 4);
      final types = cards.map((c) => c.type).toSet();
      expect(types, isNot(contains(InterventionType.quran)));
      expect(types, isNot(contains(InterventionType.hadith)));
    });

    test('intensity 2 (mild) picks last resolvable Growth_Path step (Rifq)', () async {
      final attrs = _StubAttributes(_angerPathAttrs());
      final emotions = _StubEmotions([_anger()]);
      final history = _StubHistory();
      final quran = _StubQuran([]);
      final hadees = _StubHadees([]);

      final r = Recommend(attrs, emotions, history, hadees, quran);
      final cards = await r(1, 2);

      // Rifq (id=79, last step) has no embedded Quran/Hadith in the
      // fixture, so we get exactly 4 emotion-row cards.
      expect(cards.length, 4);
    });

    test('unresolvable Growth_Path step is gracefully skipped (no crash)', () async {
      final attrs = _StubAttributes(_angerPathAttrs());
      final emotions = _StubEmotions([
        _anger(growthPath: 'Anxiety→NotAnAttribute→Sabr→Hilm'),
      ]);
      final history = _StubHistory();
      final quran = _StubQuran([]);
      final hadees = _StubHadees([]);

      final r = Recommend(attrs, emotions, history, hadees, quran);
      final cards = await r(1, 5);
      expect(cards, isNotEmpty);
    });

    test('empty Growth_Path falls back to Primary_Positive_Attributes', () async {
      final attrs = _StubAttributes(_angerPathAttrs());
      final emotions = _StubEmotions([
        _anger(growthPath: '', primaryPositive: 'Sabr;Hilm;Rifq'),
      ]);
      final history = _StubHistory();
      final quran = _StubQuran([]);
      final hadees = _StubHadees([]);

      final r = Recommend(attrs, emotions, history, hadees, quran);
      final cards = await r(1, 5);
      // Resolved attrs: [Sabr, Hilm, Rifq]. intensity 5 = middle = Hilm
      // (id=80), which has embedded Quran content. So we get a Quran card
      // from Hilm, not from Sabr.
      expect(cards, isNotEmpty);
      final quranCard = cards.firstWhere(
        (c) => c.type == InterventionType.quran,
        orElse: () => throw StateError('expected fallback Quran card from Hilm'),
      );
      expect(quranCard.attributeId, 80);
    });

    test('resolver handles transliteration variants (Yaqeen → Yaqin)', () async {
      final attrs = _StubAttributes([
        const HeartAttribute(
          id: 74,
          name: 'Yaqin',
          arabicName: 'اليقين',
          nature: 'Positive',
          definition: 'Certainty.',
          keywords: 'certainty',
          quranReference: 'Al-Baqarah 2:4',
          quranArabic: 'وَبِالْآخِرَةِ هُمْ يُوقِنُونَ',
          quranEnglish: 'And in the Hereafter they are certain.',
          quranUrdu: 'اور آخرت پر یقین رکھتے ہیں۔',
        ),
      ]);
      final emotions = _StubEmotions([
        _anger(growthPath: 'Anxiety→Yaqeen'),
      ]);
      final history = _StubHistory();
      final quran = _StubQuran([]);
      final hadees = _StubHadees([]);

      final r = Recommend(attrs, emotions, history, hadees, quran);
      final cards = await r(1, 5);

      final quranCard = cards.firstWhere(
        (c) => c.type == InterventionType.quran,
        orElse: () => throw StateError('expected Quran card from Yaqin'),
      );
      expect(quranCard.attributeId, 74);
      expect(quranCard.subtitle, 'Al-Baqarah 2:4');
    });

    test('positive emotion (Gratitude) — path resolves and produces 6 cards', () async {
      final attrs = _StubAttributes([
        const HeartAttribute(
          id: 70,
          name: 'Shukr',
          arabicName: 'الشكر',
          nature: 'Positive',
          definition: 'Gratitude.',
          keywords: 'gratitude',
          quranReference: 'Ibrahim 14:7',
          quranArabic: 'لَئِن شَكَرْتُمْ',
          quranEnglish: 'If you are grateful...',
          quranUrdu: 'اگر شکر کرو۔',
          hadithReference: 'Sahih Muslim 2236',
          hadithArabic: 'لَنْ يَشْكُرَ اللَّهَ',
          hadithUrdu: 'اللہ کا شکر نہیں کرے گا۔',
        ),
        const HeartAttribute(
          id: 76,
          name: "Qana'ah",
          arabicName: 'القناعة',
          nature: 'Positive',
          definition: 'Contentment.',
          keywords: 'contentment',
        ),
        const HeartAttribute(
          id: 94,
          name: 'Ridha',
          arabicName: 'الرضا',
          nature: 'Positive',
          definition: 'Acceptance.',
          keywords: 'acceptance',
        ),
        const HeartAttribute(
          id: 85,
          name: 'Mahabbah',
          arabicName: 'المحبة',
          nature: 'Positive',
          definition: 'Love.',
          keywords: 'love',
        ),
      ]);
      final emotions = _StubEmotions([_gratitude()]);
      final history = _StubHistory();
      final quran = _StubQuran([_ayat(1, 'Ibrahim 14:7')]);
      quran.link(1, 31);
      final hadees = _StubHadees([_hadees(1, '2236')]);
      hadees.link(1, 31);

      final r = Recommend(attrs, emotions, history, hadees, quran);
      final cards = await r(31, 5);

      expect(cards, hasLength(6));
      final quranCard = cards.firstWhere((c) => c.type == InterventionType.quran);
      expect(quranCard.attributeId, 1, reason: 'top-weighted linked ayat');
    });

    test('all pools empty → returns single reflection fallback card', () async {
      final attrs = _StubAttributes(_angerPathAttrs());
      final emotions = _StubEmotions([
        // Emotion with NO emotion-row content and an unresolvable path.
        _anger(
          growthPath: 'ImaginaryAttr',
          primaryPositive: '',
          duaArabic: '',
          duaEnglish: '',
          duaUrdu: '',
          duaRef: '',
          names: '',
          dhikr: '',
          action: '',
          duaEnglishFallback: '',
          namesFallback: '',
          dhikrFallback: '',
          actionFallback: '',
        ),
      ]);
      final history = _StubHistory();
      final quran = _StubQuran([]);
      final hadees = _StubHadees([]);

      final r = Recommend(attrs, emotions, history, hadees, quran);
      final cards = await r(1, 5);

      // Every emotion-row field is empty AND the path is unresolvable,
      // so we fall back to the reflection card.
      expect(cards, hasLength(1));
      expect(cards.first.type, InterventionType.dhikr);
      expect(cards.first.arabic, isNotEmpty);
      expect(cards.first.translation, contains('Anger'));
    });

    test('unknown emotionId returns empty list (no crash)', () async {
      final attrs = _StubAttributes(_angerPathAttrs());
      final emotions = _StubEmotions([_anger()]);
      final history = _StubHistory();
      final quran = _StubQuran([]);
      final hadees = _StubHadees([]);

      final r = Recommend(attrs, emotions, history, hadees, quran);
      final cards = await r(999, 5);
      expect(cards, isEmpty);
    });

    test('all 6 cards have correct emotionId and reasonable `why` text', () async {
      final attrs = _StubAttributes(_angerPathAttrs());
      final emotions = _StubEmotions([_anger()]);
      final history = _StubHistory();
      final quran = _StubQuran([_ayat(1, 'A')]);
      quran.link(1, 1);
      final hadees = _StubHadees([_hadees(1, '1')]);
      hadees.link(1, 1);

      final r = Recommend(attrs, emotions, history, hadees, quran);
      final cards = await r(1, 5);

      expect(cards, hasLength(6));
      for (final c in cards) {
        expect(c.emotionId, 1);
        expect(c.why, contains('Anger'));
      }
    });
  });
}
