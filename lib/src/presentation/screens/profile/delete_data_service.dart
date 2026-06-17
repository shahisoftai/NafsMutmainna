import 'package:hive/hive.dart';

import '../../../data/datasources/local/app_database.dart';

/// Service for clearing all user-generated runtime data from the app.
///
/// This deletes:
///   * User runtime tables in SQLite (checkins, nafs_history,
///     detected_attributes, interventions_history, habits, habit_logs)
///   * Auth cache (Hive `auth` box)
///   * App preferences (Hive `prefs` box — onboarding flag, theme mode, etc.)
///
/// Knowledge-layer tables (attributes, emotions, hadees, quran_ayat, etc.)
/// are intentionally NOT cleared — they are seeded from bundled JSON and
/// will be re-seeded automatically on the next cold start by the existing
/// `onOpen` re-seed safety net in [AppDatabase].
class DeleteDataService {
  DeleteDataService(this._db);

  final AppDatabase _db;

  /// Tables owned by the user. Knowledge tables are excluded.
  static const List<String> _userTables = [
    'checkins',
    'nafs_history',
    'detected_attributes',
    'interventions_history',
    'habit_logs',
    'habits',
  ];

  static const String _authBoxName = 'auth';
  static const String _prefsBoxName = 'prefs';

  Future<void> deleteAllUserData() async {
    final db = await _db.open();

    // 1. Clear user runtime SQLite tables in a single transaction.
    await db.transaction((txn) async {
      for (final table in _userTables) {
        await txn.delete(table);
      }
    });

    // 2. Clear the auth cache.
    if (Hive.isBoxOpen(_authBoxName)) {
      await Hive.box<String>(_authBoxName).clear();
    }

    // 3. Clear the prefs box (onboarding flag, theme, etc.).
    if (Hive.isBoxOpen(_prefsBoxName)) {
      await Hive.box<String>(_prefsBoxName).clear();
    }
  }
}
