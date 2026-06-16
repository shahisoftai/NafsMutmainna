import '../../domain/entities/nafs_state.dart';
import '../../domain/repositories/nafs_state_repository.dart';
import '../datasources/local/app_database.dart';

class NafsStateRepositoryImpl implements NafsStateRepositoryInterface {
  final AppDatabase _db;
  NafsStateRepositoryImpl(this._db);

  @override
  Future<NafsState?> getCurrent() async {
    final rows = await _db.db.query('nafs_states', orderBy: 'Nafs_ID ASC');
    if (rows.isEmpty) return null;
    final r = rows.first;
    return NafsState(
      id: r['Nafs_ID'] as int,
      nafsId: r['Nafs_ID'] as int,
      name: r['Name'] as String,
      arabicName: r['Arabic_Name'] as String,
      description: r['Description'] as String,
    );
  }

  @override
  Future<void> setCurrent(NafsState s) async {
    // The nafs_states table is read-only seed; nothing to persist here.
  }
}
