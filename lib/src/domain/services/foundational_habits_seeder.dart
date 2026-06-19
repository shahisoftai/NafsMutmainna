import '../../domain/entities/habit.dart';
import '../../domain/services/tazkiya_copy.dart';
import '../../domain/repositories/habit_repository.dart';

/// Seeds the three foundational habits required by classical tazkiya.
///
/// Per RI-3.4 (Scholar Audit Remediation §3.4), every user starts with three
/// default habits that establish the foundations of the heart's health:
///   1. Taharah (wudu before Salah) — Quran 5:6, Tirmidhi 2860
///   2. Halal Rizq — Bukhari 52, Muslim 1599
///   3. Hifz al-Lisan — Quran 50:18, Bukhari 6475
///
/// Plus, per RI-3.7, the Body-Heart category habits are also seeded:
///   4. Sleep before midnight — Bukhari 5683
///   5. Eat in moderation — Tirmidhi 2380
///
/// The service is idempotent: running it on a user who already has these
/// habits is a no-op (the habit names are unique).
class FoundationalHabitsSeeder {
  final HabitRepositoryInterface _habits;

  FoundationalHabitsSeeder(this._habits);

  /// Returns the number of *new* habits added (0 if all already present).
  Future<int> seedIfMissing() async {
    final existing = await _habits.allHabits();
    final existingNames = existing.map((h) => h.name).toSet();
    var added = 0;
    final defaults = <(String, String, String)>[
      ...TazkiyaCopy.foundationalHabits.map(
        (h) => (h.name, h.category, h.sourceRef),
      ),
      ...TazkiyaCopy.bodyHeartHabits.map(
        (h) => (h.name, h.category, h.sourceRef),
      ),
    ];
    for (final d in defaults) {
      if (existingNames.contains(d.$1)) continue;
      await _habits.insertHabit(
        Habit(id: 0, name: d.$1, category: d.$2),
      );
      added++;
    }
    return added;
  }
}