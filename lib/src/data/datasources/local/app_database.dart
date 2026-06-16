import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/logger/logger.dart';
import 'seed_loader.dart';

/// The 16-table HeartOS database.
class AppDatabase {
  static const _dbName = 'heartos.db';
  static const _schemaVersion = 8;

  Database? _db;

  Database get db {
    final d = _db;
    if (d == null) throw StateError('AppDatabase not opened. Call open() first.');
    return d;
  }

  Future<Database> open() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    Logger.info('Opening HeartOS database at $path');
    _db = await openDatabase(
      path,
      version: _schemaVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        // Safety net: runs on every cold start (including when no migration fires).
        // If any critical table is empty the seed is re-applied idempotently.
        try {
          if (await _needsReseed(db)) {
            Logger.info('[DB] onOpen: critical table(s) empty — re-seeding');
            await SeedLoader.seedAll(db);
          } else {
            Logger.info('[DB] onOpen: seed check passed, all critical tables populated');
          }
        } catch (e) {
          Logger.error('[DB] onOpen re-seed failed: $e');
        }
      },
    );
    return _db!;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Logger.info('Upgrading HeartOS schema from v$oldVersion to v$newVersion');
    // v1 -> v2: add UNIQUE(Date, Attribute_ID) constraint to detected_attributes
    // so that ON CONFLICT(Date, Attribute_ID) clauses work.
    if (oldVersion < 2) {
      // Recreate the table with the new constraint, preserving existing rows.
      await db.execute('''
        CREATE TABLE detected_attributes_new (
          Record_ID INTEGER PRIMARY KEY AUTOINCREMENT,
          Date TEXT NOT NULL,
          Attribute_ID INTEGER NOT NULL REFERENCES attributes(Attribute_ID),
          Score REAL NOT NULL CHECK (Score BETWEEN 0.0 AND 1.0),
          UNIQUE(Date, Attribute_ID)
        )
      ''');
      await db.execute('''
        INSERT OR IGNORE INTO detected_attributes_new
          (Record_ID, Date, Attribute_ID, Score)
        SELECT Record_ID, Date, Attribute_ID, Score FROM detected_attributes
      ''');
      await db.execute('DROP TABLE detected_attributes');
      await db.execute('ALTER TABLE detected_attributes_new RENAME TO detected_attributes');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_detected_date ON detected_attributes(Date)',
      );
    }
    // v2 -> v3: add Feedback column to interventions_history
    if (oldVersion < 3) {
      try {
        await db.execute(
          "ALTER TABLE interventions_history ADD COLUMN Feedback TEXT DEFAULT NULL",
        );
        Logger.info('Added Feedback column to interventions_history');
      } catch (e) {
        Logger.error('Failed to add Feedback column: $e');
      }
    }
    // v3 -> v4: make Attribute_ID nullable for Dhikr/Action cards
    if (oldVersion < 4) {
      try {
        // First, set rows with Attribute_ID = 0 to NULL (those are Dhikr/Action from old data)
        await db.rawUpdate(
          'UPDATE interventions_history SET Attribute_ID = NULL WHERE Attribute_ID = 0',
        );
        // Then alter the column to be nullable
        await db.execute(
          'ALTER TABLE interventions_history ADD COLUMN Attribute_ID_new INTEGER DEFAULT NULL REFERENCES attributes(Attribute_ID)',
        );
        await db.rawUpdate('''
          UPDATE interventions_history SET Attribute_ID_new = Attribute_ID
        ''');
        await db.execute('DROP TABLE interventions_history');
        await db.execute('ALTER TABLE interventions_history_new RENAME TO interventions_history');
        Logger.info('Made Attribute_ID nullable in interventions_history');
      } catch (e) {
        Logger.error('Failed to make Attribute_ID nullable: $e');
      }
    }
    // v4 -> v5: add hadees and quran_ayat normalized tables
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS hadees (
          Hadees_ID INTEGER PRIMARY KEY,
          Arabic_Text TEXT NOT NULL,
          English_Translation TEXT NOT NULL,
          Urdu_Translation TEXT NOT NULL,
          Source_Book TEXT NOT NULL,
          Hadith_Number TEXT NOT NULL,
          Grade TEXT NOT NULL CHECK (Grade IN ('Sahih','Hasan','Hasan li-ghayrihi'))
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS quran_ayat (
          Ayat_ID INTEGER PRIMARY KEY,
          Arabic_Text TEXT NOT NULL,
          English_Translation TEXT NOT NULL,
          Urdu_Translation TEXT NOT NULL,
          Surah_Name TEXT NOT NULL,
          Verse_Number INTEGER NOT NULL,
          Full_Reference TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS emotion_hadees_links (
          Link_ID INTEGER PRIMARY KEY,
          Emotion_ID INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
          Hadees_ID INTEGER NOT NULL REFERENCES hadees(Hadees_ID),
          Weight REAL NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0)
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS emotion_quran_links (
          Link_ID INTEGER PRIMARY KEY,
          Emotion_ID INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
          Ayat_ID INTEGER NOT NULL REFERENCES quran_ayat(Ayat_ID),
          Weight REAL NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0)
        )
      ''');
      Logger.info('Created hadees, quran_ayat, and link tables');
    }
    // v5 -> v6: add multilingual dua columns to emotions (aligns seed JSON with schema)
    if (oldVersion < 6) {
      try {
        await db.execute("ALTER TABLE emotions ADD COLUMN Recommended_Dua_Arabic TEXT DEFAULT NULL");
        await db.execute("ALTER TABLE emotions ADD COLUMN Recommended_Dua_Reference TEXT DEFAULT NULL");
        await db.execute("ALTER TABLE emotions ADD COLUMN Recommended_Dua_English TEXT DEFAULT NULL");
        await db.execute("ALTER TABLE emotions ADD COLUMN Recommended_Dua_Urdu TEXT DEFAULT NULL");
        Logger.info('Added multilingual dua columns to emotions');
      } catch (e) {
        Logger.error('Failed to add dua columns to emotions: $e');
      }
    }
    // v6 -> v7: ensure emotions table is seeded (may have been missed by a prior migration)
    // No DDL changes — columns were added in v6.
    // Re-seed runs unconditionally if empty (catch-up for databases that reached v6
    // before the re-seed logic was added).
    // v7 -> v8: add Role column to detected_attributes so the Disease/Treatment/Core/Strengthens
    // context that was previously discarded on persist is now stored alongside the score.
    // Existing rows get 'Disease' as a conservative default (an unknown role implies the
    // attribute was detected as active/surfaced, which is the Disease semantic).
    if (oldVersion < 8) {
      try {
        // Recreate detected_attributes with the new Role column.
        // UNIQUE constraint now covers (Date, Attribute_ID, Role) so the same attribute
        // can be stored once per role per day — e.g., Ghadab as both Disease and Core.
        await db.execute('''
          CREATE TABLE detected_attributes_v8 (
            Record_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            Date      TEXT    NOT NULL,
            Attribute_ID INTEGER NOT NULL REFERENCES attributes(Attribute_ID),
            Score     REAL    NOT NULL CHECK (Score BETWEEN 0.0 AND 1.0),
            Role      TEXT    NOT NULL DEFAULT 'Disease'
                              CHECK (Role IN ('Disease','Treatment','Core','Strengthens')),
            UNIQUE(Date, Attribute_ID, Role)
          )
        ''');
        await db.execute('''
          INSERT OR IGNORE INTO detected_attributes_v8 (Record_ID, Date, Attribute_ID, Score, Role)
          SELECT Record_ID, Date, Attribute_ID, Score, 'Disease' FROM detected_attributes
        ''');
        await db.execute('DROP TABLE detected_attributes');
        await db.execute('ALTER TABLE detected_attributes_v8 RENAME TO detected_attributes');
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_detected_date ON detected_attributes(Date)',
        );
        Logger.info('v8: added Role column to detected_attributes');
      } catch (e) {
        Logger.error('v8 migration failed: $e');
      }
    }
    // ===========================================================================
    // UNIVERSAL RE-SEED (runs after all version-specific migrations)
    // Checks ALL critical tables — if ANY is empty, re-seed.
    // Catches databases that reached a version before re-seed logic was added,
    // or where a prior seedAll failed partway through.
    // ===========================================================================
    try {
      if (await _needsReseed(db)) {
        Logger.info('One or more critical tables empty — re-seeding from JSON');
        await SeedLoader.seedAll(db);
      }
    } catch (e) {
      Logger.error('Re-seed failed (non-fatal, will retry on next launch): $e');
    }
  }

  /// Returns true if any of the critical tables are empty OR if the emotions
  /// table has rows with an empty [Recommended_Allah_Names] column.
  ///
  /// The second check catches databases that were seeded from an older version
  /// of [emotions_seed.json] that did not contain the Allah Names data. Since
  /// [SeedLoader._insertBatch] uses [ConflictAlgorithm.replace], running
  /// seedAll again will UPDATE those rows with the current seed values.
  Future<bool> _needsReseed(Database db) async {
    for (final table in ['emotions', 'attributes', 'emotion_attribute_links']) {
      final c = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
      if (c == null || c == 0) return true;
    }
    // Check for stale seed data: any emotion missing its Allah Names.
    try {
      final emptyNames = Sqflite.firstIntValue(
        await db.rawQuery(
          "SELECT COUNT(*) FROM emotions WHERE Recommended_Allah_Names IS NULL OR Recommended_Allah_Names = ''",
        ),
      );
      if (emptyNames != null && emptyNames > 0) {
        Logger.info('[DB] Found $emptyNames emotion(s) with empty Recommended_Allah_Names — triggering re-seed');
        return true;
      }
    } catch (e) {
      Logger.error('[DB] Could not check Recommended_Allah_Names: $e');
    }
    return false;
  }

  Future<void> _onCreate(Database db, int version) async {
    Logger.info('Creating HeartOS schema v$version');
    final batch = db.batch();
    for (final stmt in _schema) {
      batch.execute(stmt);
    }
    await batch.commit(noResult: true);

    // Seed knowledge-layer tables from bundled JSON.
    try {
      await SeedLoader.seedAll(db);
    } catch (e) {
      Logger.error('Initial seedAll failed: $e');
    }
    // Safety net: if ANY critical table is still empty, retry seedAll once.
    try {
      if (await _needsReseed(db)) {
        Logger.info('Critical tables empty after initial seed — retrying');
        await SeedLoader.seedAll(db);
      }
    } catch (e) {
      Logger.error('Safety re-seed failed (non-fatal): $e');
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  /// Open an in-memory database for tests.
  Future<Database> openInMemory({String? path}) async {
    final dbPath = path ?? inMemoryDatabasePath;
    return openDatabase(
      dbPath,
      version: _schemaVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  /// DDL for the 16 HeartOS tables.
  static const List<String> _schema = [
    // Knowledge
    '''CREATE TABLE nafs_states (
      Nafs_ID INTEGER PRIMARY KEY,
      Name TEXT NOT NULL,
      Arabic_Name TEXT NOT NULL,
      Description TEXT NOT NULL
    )''',
    '''CREATE TABLE domains (
      Domain_ID INTEGER PRIMARY KEY,
      Domain_Name TEXT NOT NULL,
      Arabic_Name TEXT NOT NULL,
      Description TEXT NOT NULL
    )''',
    '''CREATE TABLE attributes (
      Attribute_ID INTEGER PRIMARY KEY,
      Attribute TEXT NOT NULL,
      Arabic_Name TEXT NOT NULL,
      Nature TEXT NOT NULL CHECK (Nature IN ('Positive','Negative')),
      Definition TEXT NOT NULL,
      Opposite_Trait TEXT,
      Opposite_Arabic_Name TEXT,
      Keywords TEXT NOT NULL,
      Quran_Reference TEXT,
      Quran_Arabic TEXT,
      Quran_English TEXT,
      Quran_Urdu TEXT,
      Hadith_Reference TEXT,
      Hadith_Arabic TEXT,
      Hadith_Urdu TEXT,
      Quranic_Dua_Reference TEXT,
      Quranic_Dua_Arabic TEXT,
      Quranic_Dua_Urdu TEXT,
      Prophetic_Dua_Reference TEXT,
      Prophetic_Dua_Arabic TEXT,
      Prophetic_Dua_Urdu TEXT,
      Relevant_Allah_Names TEXT,
      Practical_Understanding TEXT
    )''',
    '''CREATE TABLE emotions (
      Emotion_ID INTEGER PRIMARY KEY,
      Core_Emotion TEXT NOT NULL,
      Arabic_Name TEXT NOT NULL,
      Category TEXT NOT NULL CHECK (Category IN ('Negative','Positive')),
      Description TEXT NOT NULL,
      Common_Triggers TEXT NOT NULL,
      Primary_Negative_Attributes TEXT NOT NULL,
      Secondary_Negative_Attributes TEXT NOT NULL,
      Primary_Positive_Attributes TEXT NOT NULL,
      Growth_Path TEXT NOT NULL,
      Dominant_Nafs_State TEXT NOT NULL CHECK (Dominant_Nafs_State IN ('Ammarah','Lawwamah','Mulhamah','Mutmainnah')),
      Severity_Weight INTEGER NOT NULL CHECK (Severity_Weight BETWEEN 1 AND 10),
      Recommended_Attribute_Priority TEXT NOT NULL,
      Recommended_Intervention_Type TEXT NOT NULL,
      Recommended_Dua TEXT NOT NULL,
      Recommended_Allah_Names TEXT NOT NULL,
      Recommended_Dhikr TEXT NOT NULL,
      Daily_Action TEXT NOT NULL,
      Related_Emotions TEXT NOT NULL,
      Related_Attribute_IDs TEXT NOT NULL,
      Keywords TEXT NOT NULL,
      Recommended_Dua_Arabic TEXT,
      Recommended_Dua_Reference TEXT,
      Recommended_Dua_English TEXT,
      Recommended_Dua_Urdu TEXT
    )''',
    // Graph
    '''CREATE TABLE emotion_attribute_links (
      Link_ID INTEGER PRIMARY KEY,
      Emotion_ID INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
      Attribute_ID INTEGER NOT NULL REFERENCES attributes(Attribute_ID),
      Weight REAL NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0),
      Role TEXT NOT NULL CHECK (Role IN ('Disease','Treatment','Core','Strengthens'))
    )''',
    '''CREATE TABLE attribute_links (
      Link_ID INTEGER PRIMARY KEY,
      Source_Attribute_ID INTEGER NOT NULL REFERENCES attributes(Attribute_ID),
      Target_Attribute_ID INTEGER NOT NULL REFERENCES attributes(Attribute_ID),
      Weight REAL NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0),
      Relationship TEXT NOT NULL CHECK (Relationship IN ('Cure','Leads_To','Strengthens','Opposes')),
      CHECK (Source_Attribute_ID <> Target_Attribute_ID)
    )''',
    '''CREATE TABLE domain_attribute_links (
      Link_ID INTEGER PRIMARY KEY,
      Domain_ID INTEGER NOT NULL REFERENCES domains(Domain_ID),
      Attribute_ID INTEGER NOT NULL REFERENCES attributes(Attribute_ID),
      Weight REAL NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0)
    )''',
    '''CREATE TABLE domain_emotion_links (
      Link_ID INTEGER PRIMARY KEY,
      Domain_ID INTEGER NOT NULL REFERENCES domains(Domain_ID),
      Emotion_ID INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
      Weight REAL NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0)
    )''',
    // Nafs Engine
    '''CREATE TABLE attribute_nafs_weights (
      Attribute_ID INTEGER PRIMARY KEY REFERENCES attributes(Attribute_ID),
      Ammarah REAL NOT NULL,
      Lawwamah REAL NOT NULL,
      Mulhamah REAL NOT NULL,
      Mutmainnah REAL NOT NULL,
      CHECK (Ammarah + Lawwamah + Mulhamah + Mutmainnah BETWEEN 95 AND 105)
    )''',
    '''CREATE TABLE emotion_nafs_weights (
      Emotion_ID INTEGER PRIMARY KEY REFERENCES emotions(Emotion_ID),
      Ammarah REAL NOT NULL,
      Lawwamah REAL NOT NULL,
      Mulhamah REAL NOT NULL,
      Mutmainnah REAL NOT NULL,
      CHECK (Ammarah + Lawwamah + Mulhamah + Mutmainnah BETWEEN 95 AND 105)
    )''',
    // User runtime
    '''CREATE TABLE checkins (
      Checkin_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      Date TEXT NOT NULL,
      Emotion_ID INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
      Intensity INTEGER NOT NULL CHECK (Intensity BETWEEN 0 AND 10),
      Notes TEXT
    )''',
    '''CREATE TABLE detected_attributes (
      Record_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      Date TEXT NOT NULL,
      Attribute_ID INTEGER NOT NULL REFERENCES attributes(Attribute_ID),
      Score REAL NOT NULL CHECK (Score BETWEEN 0.0 AND 1.0),
      Role TEXT NOT NULL DEFAULT 'Disease'
           CHECK (Role IN ('Disease','Treatment','Core','Strengthens')),
      UNIQUE(Date, Attribute_ID, Role)
    )''',
    '''CREATE TABLE nafs_history (
      Record_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      Date TEXT NOT NULL UNIQUE,
      Ammarah REAL NOT NULL,
      Lawwamah REAL NOT NULL,
      Mulhamah REAL NOT NULL,
      Mutmainnah REAL NOT NULL,
      CHECK (Ammarah + Lawwamah + Mulhamah + Mutmainnah BETWEEN 0.99 AND 1.01)
    )''',
    '''CREATE TABLE interventions_history (
      Record_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      Date TEXT NOT NULL,
      Emotion_ID INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
      Attribute_ID INTEGER DEFAULT NULL REFERENCES attributes(Attribute_ID),
      Intervention_Type TEXT NOT NULL CHECK (Intervention_Type IN ('Quran','Hadith','Dua','Allah_Names','Dhikr','Action')),
      Completed INTEGER NOT NULL DEFAULT 0 CHECK (Completed IN (0,1)),
      Feedback TEXT
    )''',
    '''CREATE TABLE habits (
      Habit_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      Name TEXT NOT NULL,
      Category TEXT NOT NULL CHECK (Category IN ('Prayer','Quran','Dhikr','Charity','Exercise','Other'))
    )''',
    '''CREATE TABLE habit_logs (
      Record_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      Date TEXT NOT NULL,
      Habit_ID INTEGER NOT NULL REFERENCES habits(Habit_ID) ON DELETE CASCADE,
      Completed INTEGER NOT NULL CHECK (Completed IN (0,1)),
      UNIQUE (Date, Habit_ID)
    )''',
    '''CREATE TABLE hadees (
      Hadees_ID INTEGER PRIMARY KEY,
      Arabic_Text TEXT NOT NULL,
      English_Translation TEXT NOT NULL,
      Urdu_Translation TEXT NOT NULL,
      Source_Book TEXT NOT NULL,
      Hadith_Number TEXT NOT NULL,
      Grade TEXT NOT NULL CHECK (Grade IN ('Sahih','Hasan','Hasan li-ghayrihi'))
    )''',
    '''CREATE TABLE quran_ayat (
      Ayat_ID INTEGER PRIMARY KEY,
      Arabic_Text TEXT NOT NULL,
      English_Translation TEXT NOT NULL,
      Urdu_Translation TEXT NOT NULL,
      Surah_Name TEXT NOT NULL,
      Verse_Number INTEGER NOT NULL,
      Full_Reference TEXT NOT NULL
    )''',
    '''CREATE TABLE emotion_hadees_links (
      Link_ID INTEGER PRIMARY KEY,
      Emotion_ID INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
      Hadees_ID INTEGER NOT NULL REFERENCES hadees(Hadees_ID),
      Weight REAL NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0)
    )''',
    '''CREATE TABLE emotion_quran_links (
      Link_ID INTEGER PRIMARY KEY,
      Emotion_ID INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
      Ayat_ID INTEGER NOT NULL REFERENCES quran_ayat(Ayat_ID),
      Weight REAL NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0)
    )''',
  ];
}

/// Helper to parse DateTime to ISO date string (YYYY-MM-DD).
String isoDate(DateTime d) {
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// Helper to parse an ISO date string to DateTime.
DateTime parseIsoDate(String s) {
  final parts = s.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

/// Map a Database row to a typed map.
Map<String, Object?> rowAsMap(Map<String, Object?> row) {
  return Map<String, Object?>.from(row);
}

/// Decode JSON value (the JSON columns in seed are stored as TEXT).
dynamic decodeJson(Object? v) {
  if (v == null) return null;
  if (v is String && v.isNotEmpty && (v.startsWith('[') || v.startsWith('{'))) {
    try {
      return jsonDecode(v);
    } catch (_) {
      return v;
    }
  }
  return v;
}
