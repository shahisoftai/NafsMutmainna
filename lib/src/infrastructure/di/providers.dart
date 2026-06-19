import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/local/local_auth_datasource.dart';
import '../../data/datasources/remote/remote_auth_datasource.dart';
import '../../data/repositories/attribute_link_repository_impl.dart';
import '../../data/repositories/attribute_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/checkin_repository_impl.dart';
import '../../data/repositories/detected_attribute_repository_impl.dart';
import '../../data/repositories/domain_repository_impl.dart';
import '../../data/repositories/emotion_attribute_link_repository_impl.dart';
import '../../data/repositories/emotion_repository_impl.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../data/repositories/hadees_repository_impl.dart';
import '../../data/repositories/intervention_history_repository_impl.dart';
import '../../data/repositories/nafs_history_repository_impl.dart';
import '../../data/repositories/nafs_state_repository_impl.dart';
import '../../data/repositories/quran_ayat_repository_impl.dart';
import '../../domain/repositories/attribute_link_repository.dart';
import '../../domain/repositories/attribute_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/checkin_repository.dart';
import '../../domain/repositories/detected_attribute_repository.dart';
import '../../domain/repositories/domain_repository.dart';
import '../../domain/repositories/emotion_attribute_link_repository.dart';
import '../../domain/repositories/emotion_repository.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/hadees_repository.dart';
import '../../domain/repositories/intervention_history_repository.dart';
import '../../domain/repositories/quran_ayat_repository.dart';
import '../../domain/repositories/nafs_history_repository.dart';
import '../../domain/repositories/nafs_state_repository.dart';
import '../../domain/services/foundational_habits_seeder.dart';
import '../../domain/usecases/graph/detect_attributes.dart';
import '../../domain/usecases/graph/growth_path.dart';
import '../../domain/usecases/nafs/compute_daily_nafs.dart';
import '../../domain/usecases/recommendations/recommend.dart';
import '../../domain/usecases/checkin/record_feedback.dart';

// ============================================================================
// Core
// ============================================================================
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// ============================================================================
// Repositories (one per interface)
// ============================================================================
final attributeRepositoryProvider = Provider<AttributeRepositoryInterface>(
  (ref) => AttributeRepositoryImpl(ref.watch(appDatabaseProvider)),
);
final emotionRepositoryProvider = Provider<EmotionRepositoryInterface>(
  (ref) => EmotionRepositoryImpl(ref.watch(appDatabaseProvider)),
);
final emotionAttributeLinkRepositoryProvider = Provider<EmotionAttributeLinkRepositoryInterface>(
  (ref) => EmotionAttributeLinkRepositoryImpl(ref.watch(appDatabaseProvider)),
);
final attributeLinkRepositoryProvider = Provider<AttributeLinkRepositoryInterface>(
  (ref) => AttributeLinkRepositoryImpl(ref.watch(appDatabaseProvider)),
);
final domainRepositoryProvider = Provider<DomainRepositoryInterface>(
  (ref) => DomainRepositoryImpl(ref.watch(appDatabaseProvider)),
);
final nafsStateRepositoryProvider = Provider<NafsStateRepositoryInterface>(
  (ref) => NafsStateRepositoryImpl(ref.watch(appDatabaseProvider)),
);
final nafsHistoryRepositoryProvider = Provider<NafsHistoryRepositoryInterface>(
  (ref) => NafsHistoryRepositoryImpl(ref.watch(appDatabaseProvider)),
);
final checkinRepositoryProvider = Provider<CheckinRepositoryInterface>(
  (ref) => CheckinRepositoryImpl(ref.watch(appDatabaseProvider)),
);
final detectedAttributeRepositoryProvider = Provider<DetectedAttributeRepositoryInterface>(
  (ref) => DetectedAttributeRepositoryImpl(ref.watch(appDatabaseProvider)),
);
final interventionHistoryRepositoryProvider = Provider<InterventionHistoryRepositoryInterface>(
  (ref) => InterventionHistoryRepositoryImpl(ref.watch(appDatabaseProvider)),
);
final habitRepositoryProvider = Provider<HabitRepositoryInterface>(
  (ref) => HabitRepositoryImpl(ref.watch(appDatabaseProvider)),
);

/// RI-3.4 / RI-3.7: Seeds the three foundational habits (Taharah, Halal
/// Rizq, Hifz al-Lisan) plus the Body-Heart habits on first onboarding.
final foundationalHabitsSeederProvider = Provider<FoundationalHabitsSeeder>(
  (ref) => FoundationalHabitsSeeder(ref.watch(habitRepositoryProvider)),
);
final hadeesRepositoryProvider = Provider<HadeesRepository>(
  (ref) => HadeesRepositoryImpl(ref.watch(appDatabaseProvider)),
);
final quranAyatRepositoryProvider = Provider<QuranAyatRepository>(
  (ref) => QuranAyatRepositoryImpl(ref.watch(appDatabaseProvider)),
);

// ============================================================================
// Use cases
// ============================================================================
final computeDailyNafsProvider = Provider<ComputeDailyNafs>(
  (ref) => ComputeDailyNafs(
    ref.watch(checkinRepositoryProvider),
    ref.watch(detectedAttributeRepositoryProvider),
    ref.watch(habitRepositoryProvider),
    ref.watch(nafsHistoryRepositoryProvider),
    ref.watch(emotionRepositoryProvider),
    ref.watch(attributeRepositoryProvider),
  ),
);
final meter15DayProvider = Provider<Meter15Day>(
  (ref) => Meter15Day(ref.watch(nafsHistoryRepositoryProvider)),
);
final streakProvider = Provider<Streak>(
  (ref) => Streak(ref.watch(nafsHistoryRepositoryProvider)),
);
final growthPathProvider = Provider<GrowthPath>(
  (ref) => GrowthPath(
    ref.watch(attributeLinkRepositoryProvider),
    ref.watch(attributeRepositoryProvider),
  ),
);
final detectAttributesProvider = Provider<DetectAttributes>(
  (ref) => DetectAttributes(ref.watch(emotionAttributeLinkRepositoryProvider)),
);
final recommendProvider = Provider<Recommend>(
  (ref) => Recommend(
    ref.watch(attributeRepositoryProvider),
    ref.watch(emotionRepositoryProvider),
    ref.watch(interventionHistoryRepositoryProvider),
    ref.watch(hadeesRepositoryProvider),
    ref.watch(quranAyatRepositoryProvider),
  ),
);

final recordFeedbackProvider = Provider<RecordFeedback>(
  (ref) => RecordFeedback(ref.watch(interventionHistoryRepositoryProvider)),
);
final submitCheckinProvider = Provider<SubmitCheckin>(
  (ref) => SubmitCheckin(
    ref.watch(checkinRepositoryProvider),
    ref.watch(detectAttributesProvider),
    ref.watch(detectedAttributeRepositoryProvider),
    ref.watch(computeDailyNafsProvider),
    ref.watch(nafsHistoryRepositoryProvider),
    ref.watch(recommendProvider),
  ),
);

// ============================================================================
// Auth (optional in v1; deferred to v1.1).
// ============================================================================
final remoteAuthDataSourceProvider = Provider<RemoteAuthDataSource>(
  (ref) => NoopAuthDataSource(),
);
final localAuthDataSourceProvider = Provider<ILocalAuthDataSource>(
  (ref) => LocalAuthDataSource(_authBox),
);
final authRepositoryProvider = Provider<AuthRepositoryInterface>(
  (ref) => AuthRepositoryImpl(
    remote: ref.watch(remoteAuthDataSourceProvider),
    local: ref.watch(localAuthDataSourceProvider),
  ),
);

// Box reference is provided by initializeApp(); fallback to opened box.
late Box<String> _authBox;
void setAuthBox(Box<String> box) {
  _authBox = box;
}

// ============================================================================
// Onboarding / app-preferences
// ============================================================================
//
// A small Hive box used for app-level boolean flags. Currently used to
// track whether the user has completed the onboarding flow. The box is
// opened in main.dart and re-used by the provider below.
const String kPrefsBoxName = 'prefs';
const String kOnboardingSeenKey = 'hasSeenOnboarding';

/// Async provider for the app-preferences Hive box.
final prefsBoxProvider = FutureProvider<Box<String>>((ref) async {
  if (Hive.isBoxOpen(kPrefsBoxName)) {
    return Hive.box<String>(kPrefsBoxName);
  }
  return Hive.openBox<String>(kPrefsBoxName);
});

/// True when the user has completed the onboarding flow at least once.
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final box = await ref.watch(prefsBoxProvider.future);
  return box.get(kOnboardingSeenKey) == '1';
});
