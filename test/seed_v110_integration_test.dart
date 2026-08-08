// Integration test: verify the v1.1.0 quran_ayat seed loads correctly
// through the AppDatabase, and that the recommend pipeline can resolve
// the replacement ayats (39 → 17:37, 45 → 2:256, 49 → 9:112).

import 'package:flutter_test/flutter_test.dart';
import 'package:nafsmutmainna/src/data/datasources/local/app_database.dart';
import 'package:nafsmutmainna/src/data/repositories/quran_ayat_repository_impl.dart';
import 'package:nafsmutmainna/src/data/repositories/hadees_repository_impl.dart';
import 'package:nafsmutmainna/src/data/repositories/emotion_repository_impl.dart';
import 'package:nafsmutmainna/src/data/repositories/attribute_repository_impl.dart';
import 'package:nafsmutmainna/src/data/repositories/intervention_history_repository_impl.dart';
import 'package:nafsmutmainna/src/domain/entities/intervention_card.dart';
import 'package:nafsmutmainna/src/domain/entities/intervention_history.dart';
import 'package:nafsmutmainna/src/domain/usecases/recommendations/recommend.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase appDb;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    appDb = AppDatabase();
    await appDb.openInMemory();
  });

  tearDown(() async {
    await appDb.close();
  });

  group('Seed v1.1.0', () {
    test(
      'all attributes load, including positive IDs used in prescriptions',
      () async {
        final count =
            (await appDb.db.rawQuery(
                  'SELECT COUNT(*) AS count FROM attributes',
                )).first['count']
                as int;
        expect(count, 183);
        final prescriptionAttributes = await appDb.db.query(
          'attributes',
          where: 'Attribute_ID IN (?, ?)',
          whereArgs: [74, 79],
        );
        expect(prescriptionAttributes, hasLength(2));
      },
    );

    test('all 65 quran_ayat rows present with non-empty content', () async {
      final rows = await appDb.db.query('quran_ayat');
      expect(rows, hasLength(65));
      for (final r in rows) {
        expect((r['Arabic_Text'] as String).trim(), isNotEmpty);
        expect((r['English_Translation'] as String).trim(), isNotEmpty);
        expect((r['Urdu_Translation'] as String).trim(), isNotEmpty);
      }
    });

    test(
      'replacement ayat 39 is Al-Isra 17:37, not the broken 2:102',
      () async {
        final rows = await appDb.db.query(
          'quran_ayat',
          where: 'Ayat_ID = ?',
          whereArgs: [39],
          limit: 1,
        );
        expect(rows, hasLength(1));
        final r = rows.first;
        expect(r['Surah_Name'], 'Al-Isra');
        expect(r['Verse_Number'], 37);
        expect(r['Arabic_Text'] as String, contains('مَرَحًا')); // "exultingly"
        expect(r['English_Translation'] as String, contains('exultantly'));
      },
    );

    test('replacement ayat 45 is Al-Baqarah 2:256 (no compulsion)', () async {
      final rows = await appDb.db.query(
        'quran_ayat',
        where: 'Ayat_ID = ?',
        whereArgs: [45],
        limit: 1,
      );
      expect(rows, hasLength(1));
      final r = rows.first;
      expect(r['Surah_Name'], 'Al-Baqarah');
      expect(r['Verse_Number'], 256);
      expect(r['Arabic_Text'] as String, contains('إِكْرَاهَ')); // "compulsion"
      expect(r['English_Translation'] as String, contains('compulsion'));
    });

    test(
      'replacement ayat 49 is the REAL At-Tawbah 9:112 (repentant worshippers)',
      () async {
        final rows = await appDb.db.query(
          'quran_ayat',
          where: 'Ayat_ID = ?',
          whereArgs: [49],
          limit: 1,
        );
        expect(rows, hasLength(1));
        final r = rows.first;
        expect(r['Surah_Name'], 'At-Tawbah');
        expect(r['Verse_Number'], 112);
        // The real 9:112 begins with the repentant worshippers and includes
        // the descriptive list. The unique "repentant" word in English is
        // distinctive to 9:112.
        expect(r['English_Translation'] as String, contains('repentant'));
        expect(r['English_Translation'] as String, contains('worshippers'));
        expect(r['English_Translation'] as String, contains('praisers'));
      },
    );

    test('full verses are present (no truncated fragments)', () async {
      // Previously broken ayats had very short Arabic (sometimes just a
      // clause) or were missing key sections. The v1.1.0 seed has the full
      // Uthmani text for every verse. We verify by:
      //  1. Length threshold — every previously-truncated ayat is now
      //     substantially longer (>80 chars Arabic).
      //  2. English also meets the same threshold.
      //  3. The 3 replacement ayats have the expected references.
      //
      // The previously-truncated ones (by ID) are:
      // 4, 6, 9, 10, 12, 15, 17, 19, 20, 21, 22, 24, 25, 26, 27, 28, 29,
      // 30, 31, 33, 34, 36, 37, 40, 41, 42, 47.
      final previouslyTruncated = [
        4,
        6,
        9,
        10,
        12,
        15,
        17,
        19,
        20,
        21,
        22,
        24,
        25,
        26,
        27,
        28,
        29,
        30,
        31,
        33,
        34,
        36,
        37,
        40,
        41,
        42,
        47,
      ];
      for (final aid in previouslyTruncated) {
        final rows = await appDb.db.query(
          'quran_ayat',
          where: 'Ayat_ID = ?',
          whereArgs: [aid],
          limit: 1,
        );
        expect(rows, hasLength(1), reason: 'Ayat $aid missing');
        final ar = rows.first['Arabic_Text'] as String;
        // Every previously-truncated ayat now has substantial Arabic text
        // (the v1.0.0 versions were often 30-80 chars; full verses are
        // typically 100+ chars).
        expect(
          ar.length,
          greaterThan(80),
          reason:
              'Ayat $aid Arabic too short (${ar.length} chars) — likely truncated',
        );
        final en = rows.first['English_Translation'] as String;
        expect(
          en.length,
          greaterThan(80),
          reason:
              'Ayat $aid English too short (${en.length} chars) — likely truncated',
        );
      }
    });

    test(
      'emotion_quran_links reflects the 4 removals and 1 addition',
      () async {
        final links = await appDb.db.query('emotion_quran_links');

        // Removed
        expect(
          links
              .where((l) => l['Ayat_ID'] == 12 && l['Emotion_ID'] == 37)
              .isEmpty,
          isTrue,
          reason: '8:2 → Love for People should be removed',
        );
        expect(
          links
              .where((l) => l['Ayat_ID'] == 12 && l['Emotion_ID'] == 44)
              .isEmpty,
          isTrue,
          reason: '8:2 → Certainty should be removed',
        );
        expect(
          links
              .where((l) => l['Ayat_ID'] == 37 && l['Emotion_ID'] == 18)
              .isEmpty,
          isTrue,
          reason: '16:116 → Suspicion should be removed',
        );
        expect(
          links
              .where((l) => l['Ayat_ID'] == 45 && l['Emotion_ID'] == 35)
              .isEmpty,
          isTrue,
          reason: '2:256 → Joy should be removed',
        );

        // Added
        expect(
          links
              .where((l) => l['Ayat_ID'] == 39 && l['Emotion_ID'] == 11)
              .isNotEmpty,
          isTrue,
          reason: '17:37 → Arrogance should be added',
        );
      },
    );
  });

  group('Recommend v2 with real seed', () {
    test('history accepts polymorphic Quran/Hadith reference IDs', () async {
      final foreignKeys = await appDb.db.rawQuery(
        "PRAGMA foreign_key_list('interventions_history')",
      );
      expect(foreignKeys.where((fk) => fk['from'] == 'Emotion_ID'), isNotEmpty);
      expect(
        foreignKeys.where((fk) => fk['from'] == 'Attribute_ID'),
        isEmpty,
        reason:
            'Quran/Hadith cards store their content ID in this polymorphic field',
      );

      final repo = InterventionHistoryRepositoryImpl(appDb);
      final id = await repo.insert(
        InterventionHistory(
          id: 0,
          date: DateTime(2026, 8, 8),
          emotionId: 46,
          attributeId: 999999,
          interventionType: InterventionType.hadith,
          completed: true,
        ),
      );
      expect(id, greaterThan(0));
    });

    test('Anger (emotion 1) returns 6 cards, all on-point', () async {
      final recommend = Recommend(
        AttributeRepositoryImpl(appDb),
        EmotionRepositoryImpl(appDb),
        InterventionHistoryRepositoryImpl(appDb),
        HadeesRepositoryImpl(appDb),
        QuranAyatRepositoryImpl(appDb),
      );

      final cards = await recommend(1, 7);
      expect(cards, hasLength(6));
      for (final c in cards) {
        expect(c.emotionId, 1);
        // Some card types carry the text in translation (e.g. Daily Action
        // is English-only), so we check that EITHER arabic or translation
        // is non-empty.
        final hasContent = c.arabic.isNotEmpty || c.translation.isNotEmpty;
        expect(hasContent, isTrue, reason: 'Card ${c.type} has no content');
      }
    });

    test(
      'Pride (emotion 12) at intensity 8 gets the top-weighted Quran card',
      () async {
        // Top-weighted linked ayat for Pride is ID 29 (Al-Fajr 89:15, w=0.9),
        // not the new replacement ID 39 (Al-Isra 17:37, w=0.85). The
        // algorithm correctly picks by weight DESC. We verify the new
        // replacement IS still linked to Pride for variety.
        final recommend = Recommend(
          AttributeRepositoryImpl(appDb),
          EmotionRepositoryImpl(appDb),
          InterventionHistoryRepositoryImpl(appDb),
          HadeesRepositoryImpl(appDb),
          QuranAyatRepositoryImpl(appDb),
        );

        final cards = await recommend(12, 8);
        final quranCard = cards.firstWhere(
          (c) => c.type.toString() == 'InterventionType.quran',
          orElse: () => throw StateError('No Quran card for Pride'),
        );
        // Should be the top-weighted linked ayat: 29 (Al-Fajr 89:15, w=0.9)
        expect(quranCard.attributeId, 29);
        expect(quranCard.subtitle, 'Al-Fajr 89:15');

        // Verify the new 17:37 IS linked to Pride (just not top-weighted)
        final links = await appDb.db.query(
          'emotion_quran_links',
          where: 'Ayat_ID = ? AND Emotion_ID = ?',
          whereArgs: [39, 12],
        );
        expect(
          links,
          isNotEmpty,
          reason: 'New replacement 17:37 should be linked to Pride',
        );
      },
    );
  });
}
