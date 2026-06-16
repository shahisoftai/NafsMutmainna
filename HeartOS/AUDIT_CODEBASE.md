# HeartOS — Codebase Audit Report

> Comprehensive audit of the current Flutter codebase against the HeartOS specification.
> **Audit date:** 2026-06-13
> **Scope:** `lib/**/*.dart`, `test/**/*.dart`, `pubspec.yaml`
> **Method:** `flutter analyze --no-pub` (160 issues), full read of all 84 Dart files, cross-reference with `HeartOS/` specs.
>
> **Companion to:** `IMPLEMENTATION_PLAN.md` (this audit drives the refactoring and rewrite plan).

---

## Executive Summary

| Category | Count | Severity |
|---|---:|---|
| **Compile errors** | **80+** | 🔴 Blocker — code does not compile |
| **Logic errors** (contradicts HeartOS spec) | **7** | 🔴 Blocker — wrong implementation |
| **SOLID violations** | **8** | 🟠 Major — design must be refactored |
| **Code duplications** | **5** | 🟠 Major |
| **Warnings** (unused imports/fields, dead code) | **15** | 🟡 Minor |
| **Lint info** (`avoid_print` in production) | **50+** | 🟡 Minor |

**The codebase is not in a runnable state.** It will not compile due to 80+ errors. The Nafs engine is entirely missing. The 16-table schema has not been built. The current `NafsRepositoryImpl` implements an 8-question assessment that contradicts the HeartOS spec.

---

## 1 · Compile Errors (🔴 Blockers)

### 1.1 `lib/core/utils/accessibility_utils.dart` — 2 errors

| Line | Error | Cause | Fix |
|---:|---|---|---|
| 35 | `Undefined name 'SemanticsService'` | Missing `import 'package:flutter/semantics.dart';` | Add the import |
| 175 | `The named parameter 'error' isn't defined` | The `onError` callback signature has changed in Flutter SDK | Update to current API: `onError: (FlutterErrorDetails details) { ... }` |

### 1.2 `lib/core/utils/performance_utils.dart` — 7 errors

| Line | Error | Cause | Fix |
|---:|---|---|---|
| 24 | `Undefined class 'Timer'` | Missing `import 'dart:async';` | Add the import |
| 30 | `The method 'Timer' isn't defined` | Same as above | Same as above |
| 107-108 | `Undefined class 'Size'` | Missing `import 'dart:ui';` (or flutter material) | Add the import |
| 120 | `The method 'Size' isn't defined` | Same as above | Same as above |
| 145 | `Undefined class 'Widget'` | Missing `import 'package:flutter/widgets.dart';` | Add the import |
| 147 | `The method 'RepaintBoundary' isn't defined` | Same as above | Same as above |

**Root cause:** This file is meant to be a Flutter utility but only imports `dart:core`. It needs proper Flutter imports.

### 1.3 `test/domain/entities/emotion_entry_test.dart` — 50 errors

All test cases reference an **old API** that no longer exists:

```dart
// OLD API (what the tests expect):
EmotionEntry(type: EmotionType.anger, recordedAt: ..., notes: ..., triggers: ...)
emotion.isHighIntensity

// CURRENT API (what the entity has):
EmotionEntry(emotionName: 'Anger', intensity: EmotionIntensity.moderate, note: null, relatedTraits: [], loggedAt: ...)
```

The test file was never updated to match the current `EmotionEntry` class. It references a class `EmotionType` that doesn't exist.

**Fix options:**
- **Option A** (preferred): Delete this test file entirely. The current `EmotionEntry` is itself a temporary scaffold; both the entity and the test will be replaced in Phase 2 of the implementation plan.
- **Option B**: Rewrite the test file to match the current API.

**Decision:** **Delete** (Option A). It will be rewritten in Phase 2.

### 1.4 `test/domain/entities/journal_entry_test.dart` — 2 errors

```dart
// Line 53-54: 'isRecent' isn't defined for the type 'JournalEntry'
```

The `isRecent` getter was never implemented on `JournalEntry`.

**Fix:** Delete the test (the journal feature is being removed from HeartOS v1).

### 1.5 `test/presentation/screens/auth_screen_test.dart` — 1 error

```dart
// Line 36: 'autofillHints' isn't defined for the type 'TextFormField'
```

**Fix:** Use the correct Flutter API: `TextFormField(autofillHints: const [AutofillHints.email])` (note: `autofillHints` is on `TextField`, not `TextFormField`; or use the correct parameter).

### 1.6 `test/presentation/theme/app_theme_test.dart` — 1 error

```dart
// Line 25: 'isOneOf' isn't defined
```

A helper function that doesn't exist.

**Fix:** Inline the comparison or remove the test.

### 1.7 `test/presentation/navigation/app_router_test.dart` — 2 unused imports

Fix: Remove unused imports.

### 1.8 `test_auth.dart` — 1 unused import, 1 unused variable

Fix: Remove unused import + variable.

---

## 2 · Logic Errors (🔴 Blockers — contradict HeartOS spec)

### 2.1 `NafsRepositoryImpl` implements the wrong algorithm

**File:** `lib/src/data/repositories/nafs_repository_impl.dart` (260 lines)

**Current behaviour:** Uses an 8-question assessment where each question contributes weighted points to a 3-NafsType score map (ammarah, lawwamah, mutmainna). Returns the dominant type.

**What HeartOS requires:** The `0.50 × AttributeScore + 0.20 × EmotionScore + 0.20 × HabitScore + 0.10 × TrendScore` formula based on the last 15 days of `checkins`, `detected_attributes`, `habit_logs`, `nafs_history`. Must use 4 NafsTypes.

**Additional errors in this file:**
- `_calculateScores` only produces 3 NafsTypes (no Mulhamah)
- The 8 questions are hard-coded with no Islamic source attribution (violates `HeartOS/AUDIT_REPORT.md`)
- `_getDefaultNafsState` returns `33.3/33.3/33.4` (uniform) — HeartOS specifies `10/60/20/10` Lawwamah baseline
- The repository has no connection to `nafs_history` — it returns a hard-coded default instead of querying the database

**Action:** **Delete this entire file** in Phase 2 of the implementation plan. Replace with `NafsHistoryRepositoryImpl` and the pure-Dart `ComputeDailyNafs` use case.

### 2.2 `NafsState` entity is missing Mulhamah

**File:** `lib/src/domain/entities/nafs_state.dart`

**Current:** `enum NafsType { ammarah, lawwamah, mutmainna }` — 3 values.

**HeartOS requires:** 4 NafsTypes: `ammarah, lawwamah, mulhamah, mutmainnah` (per `HeartOS/01_core_tables/nafs_states.md`).

**Action:** Add `mulhamah` to the enum. Update `NafsState.percentages` to use `Map<NafsType, double>` with 4 entries.

### 2.3 `NafsRepositoryImpl._getDefaultNafsState` returns wrong baseline

**Current:** `ammarah: 33.3, lawwamah: 33.3, mutmainna: 33.4`

**HeartOS spec (`HeartOS/04_user_tables/nafs_history.md` §"Initial value"):**
```
Ammarah:     0.10
Lawwamah:    0.60
Mulhamah:    0.20
Mutmainnah:  0.10
```

**Action:** Replace with the correct 4-vector baseline.

### 2.4 `EmotionEntry` entity doesn't match HeartOS schema

**File:** `lib/src/domain/entities/emotion_entry.dart`

| Current | HeartOS spec (`HeartOS/04_user_tables/checkins.md`) |
|---|---|
| `id: String` | `Checkin_ID: INTEGER` |
| `emotionName: String` (free text) | `Emotion_ID: INTEGER` (FK to `emotions` table — 50 entries) |
| `intensity: EmotionIntensity` (4-level enum) | `Intensity: INTEGER 1-10` |
| `note: String?` | `Notes: TEXT` (max 500 chars) |
| `relatedTraits: List<String>` (free text) | (none — derived via `emotion_attribute_links`) |
| `loggedAt: DateTime` | `Date: DATE` |
| `syncStatus: SyncStatus` (deferred to v2) | (none in v1) |
| `EmotionIntensity { mild, moderate, intense, overwhelming }` | (none — intensity is integer 1-10) |

**Action:** Rename file to `checkin.dart`. Replace with the HeartOS-compliant entity. Remove the `syncStatus` field (deferred to v2).

### 2.5 `Trait` entity doesn't match HeartOS `attributes` table

**File:** `lib/src/domain/entities/trait.dart`

| Current | HeartOS spec (`HeartOS/01_core_tables/attributes.md`) |
|---|---|
| `id, name, description, relatedNafsTypes, tools, practices, priority` (7 fields) | 23 fields: `Attribute_ID, Attribute, Arabic_Name, Nature, Definition, Opposite_Trait, Opposite_Arabic_Name, Keywords, Quran_Reference, Quran_Arabic, Quran_English, Quran_Urdu, Hadith_Reference, Hadith_Arabic, Hadith_Urdu, Quranic_Dua_*, Prophetic_Dua_*, Relevant_Allah_Names, Practical_Understanding` |

**Action:** Rename file to `heart_attribute.dart`. Replace with the 23-field entity matching the schema.

### 2.6 Dashboard has hard-coded values

**File:** `lib/src/presentation/screens/home/dashboard_screen.dart` (305 lines)

**Issues:**
- Line 112: `Text('Nafs al-Lawwamah')` — hard-coded dominant type
- Line 129: `value: 0.65` — hard-coded 65% value
- Line 135: `Text('65% - Needs regular reflection and correction')` — hard-coded description
- Lines 22-31: 4 hard-coded quick-action cards pointing to `assessment`, `journal`, `toolkit`, `analytics` — none of which are in HeartOS v1

**Action:** Replace entire file with `HomeScreen` that uses the live Nafs meter (per `OPERATIONAL_FLOW.md` §2.1).

### 2.7 Emotion logger has hard-coded emotions

**File:** `lib/src/presentation/screens/emotions/emotion_logger_screen.dart` (433 lines)

**Issues:**
- Lines 22-31: 8 hard-coded emotions (Happy, Calm, Anxious, Sad, Angry, Grateful, Hopeful, Confused)
- Line 17: `EmotionIntensity.moderate` (4-level enum) — HeartOS uses 1-10 integer
- No Arabic name displayed
- No growth path / attribute detection

**Action:** Replace entire file with `CheckinScreen` (per `OPERATIONAL_FLOW.md` §2.2).

---

## 3 · SOLID Violations (🟠 Major)

### 3.1 Single Responsibility (SRP)

| File | Class | Violation |
|---|---|---|
| `lib/src/data/repositories/nafs_repository_impl.dart` | `NafsRepositoryImpl` | Knows about: assessment algorithm, question generation, score calculation, default values, percentage normalisation. **Five responsibilities**. |
| `lib/src/data/repositories/auth_repository_impl.dart` | `AuthRepositoryImpl` | 4 function-pointer dependencies injected via constructor. Mixes remote auth (Supabase) with local cache. |
| `lib/src/infrastructure/di/providers.dart` | `authRepositoryProvider` | Builds the entire auth wiring inline, including the 4 function pointers. **Should be a factory in a data source.** |

### 3.2 Open/Closed (OCP)

| File | Class | Violation |
|---|---|---|
| `lib/src/data/repositories/auth_repository_impl.dart` | `AuthRepositoryImpl` | The constructor takes 4 specific function pointers (`signInFn`, `signUpFn`, `signOutFn`, `isAuthenticatedFn`). Adding a new auth provider (Apple, Facebook) requires modifying the constructor. **Should depend on a `RemoteAuthDataSource` interface.** |

**Refactor:**

```dart
// GOOD — Dependency Inversion
abstract class RemoteAuthDataSource {
  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password, String? displayName);
  Future<void> signOut();
  Future<bool> isAuthenticated();
}

class SupabaseAuthDataSource implements RemoteAuthDataSource { /* ... */ }
class GoogleAuthDataSource implements RemoteAuthDataSource { /* ... */ }

class AuthRepositoryImpl implements AuthRepositoryInterface {
  final RemoteAuthDataSource _remote;
  final ILocalAuthDataSource _local;
  AuthRepositoryImpl(this._remote, this._local);
  // No constructor changes for new auth providers
}
```

### 3.3 Liskov Substitution (LSP)

| File | Class | Violation |
|---|---|---|
| `lib/src/infrastructure/di/auth_providers.dart` | `googleAuthRepositoryProvider` | Returns `AuthRepositoryInterface` but the instance is configured for Google sign-out (`googleAuthService.signOutGoogle()`) — **a behaviour not in the base contract**. |

**Refactor:** Both providers should return the same implementation. The Google-specific behaviour (signing out of Google on user-initiated sign-out) should be encapsulated in `GoogleAuthDataSource.signOut()`.

### 3.4 Interface Segregation (ISP)

| File | Interface | Violation |
|---|---|---|
| `lib/src/domain/repositories/nafs_repository.dart` | `NafsRepositoryInterface` | Mixes one-time computation (`assessNafsState`) with state reads (`getNafsState`, `watchNafsState`). These are different use cases. |

**Refactor:** Split into two interfaces:

```dart
abstract class NafsHistoryRepositoryInterface {
  Future<void> upsert(NafsHistory row);
  Future<NafsHistory?> findForDate(DateTime d);
  Future<List<NafsHistory>> findBetween(DateTime start, DateTime end);
  Stream<NafsHistory?> watchToday();
}

abstract class NafsAssessmentRepositoryInterface {
  // For the (deprecated) 8-question self-assessment
  Future<Result<NafsState>> assess(List<AssessmentAnswer> answers);
  Future<Result<List<AssessmentQuestion>>> getQuestions();
}
```

**Decision:** In v1, the **assessment is removed entirely** (it's not in the HeartOS spec). Only `NafsHistoryRepositoryInterface` is kept.

### 3.5 Dependency Inversion (DIP)

| File | Class | Violation |
|---|---|---|
| `lib/src/infrastructure/di/providers.dart` | `authRepositoryProvider` | Constructs `AuthRepositoryImpl` with **concrete Supabase SDK calls inline** in the provider body. Provider knows about remote API details. |
| `lib/src/infrastructure/di/auth_providers.dart` | `googleAuthRepositoryProvider` | Same — re-implements the entire signIn/signUp wiring. **Duplicates `providers.dart`.** |

**Refactor:** Create `lib/src/data/datasources/remote/supabase_auth_datasource.dart` and `google_auth_datasource.dart`. The providers just `new Up(...)`.

---

## 4 · Code Duplications (🟠 Major)

### 4.1 Two auth providers, near-identical code

**Files:**
- `lib/src/infrastructure/di/providers.dart` (lines 174-215): `authRepositoryProvider`
- `lib/src/infrastructure/di/auth_providers.dart` (lines 25-68): `googleAuthRepositoryProvider`

Both build `AuthRepositoryImpl` with the same `signInFn` / `signUpFn` / `signOutFn` / `isAuthenticatedFn` logic. The only difference is the Google `signOut` also calls `googleAuthService.signOutGoogle()`.

**Action:** Consolidate into a single `authRepositoryProvider`. The Google-specific sign-out logic moves into `GoogleAuthDataSource.signOut()`.

### 4.2 Auth user-creation code duplicated in two places

**Files:** Same as above.

Both inline-lambdas do:

```dart
return User(
  id: response.user!.id,
  email: response.user!.email!,
  displayName: response.user!.userMetadata?['display_name'] as String?,
  createdAt: DateTime.parse(response.user!.createdAt),
  lastLoginAt: DateTime.now(),
);
```

**Action:** Extract to a `User.fromSupabaseUser(SupabaseUser u)` factory.

### 4.3 NafsRepositoryImpl has assessment questions embedded

**File:** `lib/src/data/repositories/nafs_repository_impl.dart` (lines 162-259)

8 hard-coded assessment questions with no Islamic source attribution. This is a violation of `HeartOS/AUDIT_REPORT.md` (Islamic authenticity).

**Action:** **Delete** the assessment entirely. It is not in HeartOS v1.

### 4.4 Dashboard and emotion logger duplicate the "Nafs state" pattern

Both files have hard-coded Nafs state values (dashboard: "Lawwamah 65%", logger: no Nafs state but hard-coded emotions).

**Action:** Replace both with data-driven widgets that read from the `NafsMeterWidget` and `CheckinScreen` respectively.

### 4.5 Two `AuthState` enums (status + sync)

**Files:**
- `lib/src/domain/entities/sync_status.dart`: `enum SyncStatus { pending, synced, failed }`
- `lib/src/presentation/viewmodels/auth_state_notifier.dart`: `enum AuthStatus { initial, loading, authenticated, unauthenticated, error }`

These are different domains — the first is about offline-first sync (deferred to v2), the second is about auth state. They have **no duplication**, but `SyncStatus` should be removed entirely from v1 entities since cloud sync is deferred to v2.

**Action:** Remove `syncStatus` from `EmotionEntry` and `JournalEntry` in Phase 2.

---

## 5 · Warnings (🟡 Minor)

### 5.1 Unused imports

| File | Line | Unused import |
|---|---:|---|
| `lib/src/infrastructure/di/auth_providers.dart` | 7 | `local_auth_datasource.dart` |
| `lib/src/infrastructure/di/providers.dart` | 2 | `flutter/foundation.dart` |
| `lib/src/infrastructure/monitoring/performance_monitor.dart` | 2 | `flutter/foundation.dart` |
| `lib/src/infrastructure/services/google_auth_service.dart` | 1 | `flutter/foundation.dart` |
| `lib/src/presentation/viewmodels/auth_state_notifier.dart` | 2 | `dartz/dartz.dart` |
| `lib/src/presentation/viewmodels/auth_state_notifier.dart` | 4 | `core/error/failure.dart` |

**Action:** Remove all unused imports.

### 5.2 Unused fields

| File | Field | Reason |
|---|---|---|
| `lib/src/data/sync/sync_queue.dart` | `_storageKey` | Never used |
| `lib/src/infrastructure/services/analytics_service.dart` | `_userId` | Never used |
| `lib/src/infrastructure/services/crash_reporting_service.dart` | `_userId` | Never used |
| `lib/src/infrastructure/services/google_auth_service.dart` | `_clientSecret`, `_isGoogleSigningIn` | Never used |
| `lib/src/presentation/screens/auth/login_screen.dart` | `_isGoogleSigningIn` | Never used |
| `lib/src/presentation/viewmodels/analytics_view_model.dart` | `_performanceMonitor` | Never used |

**Action:** Remove all unused fields. Many are remnants of features that were never fully implemented.

### 5.3 Unused local variables

| File | Line | Variable |
|---|---:|---|
| `lib/src/data/cache/in_memory_cache.dart` | 164 | `now` |
| `test_auth.dart` | 70 | `clientSecret` |

**Action:** Remove.

### 5.4 Unnecessary null comparison

`lib/src/data/sync/conflict_resolver.dart:103` — `if (something != null)` where `something` is already non-nullable. Fix: remove the null check.

### 5.5 `print()` in production code (50+ instances)

The codebase uses `print('DEBUG: ...')` throughout `main.dart`, `providers.dart`, `auth_state_notifier.dart`, `splash_screen.dart`, and `test_auth.dart`. This violates the linter rule `avoid_print`.

**Action:** Replace all `print('DEBUG: ...')` calls with the existing `Logger` (`lib/core/logger/logger.dart`).

### 5.6 Deprecated `anonKey` parameter

`lib/src/infrastructure/di/providers.dart:296` — `Supabase.initialize` uses `anonKey`, which is deprecated. Replace with `publishableKey`.

---

## 6 · Architecture Issues (🟠 Major)

### 6.1 The 16-table HeartOS schema has not been built

**No `database.dart`, no `seed_loader.dart`, no tables.** The HeartOS schema in `HeartOS/SCHEMA.sql` and `HeartOS/tables/` is the source of truth but is not yet implemented.

**Action:** Phase 1 of the implementation plan.

### 6.2 The Nafs engine has not been built

**No `Vector4` type, no `ComputeDailyNafs` use case, no Nafs constants.** The current `NafsRepositoryImpl` implements a different algorithm entirely (the 8-question assessment).

**Action:** Phase 1 of the implementation plan.

### 6.3 The graph engine has not been built

**No `GrowthPath`, no `DetectAttributes`, no `Recommend` use cases.** The Heart Graph (`attribute_links` table) is not queryable from Dart.

**Action:** Phase 1 of the implementation plan.

### 6.4 The 5-screen loop has not been built

The 3 secondary screens (`assessment`, `journal`, `toolkit`, `analytics`) do not correspond to HeartOS. The Heart Analysis, Personal Prescription, and User Feedback screens do not exist.

**Action:** Phase 3 of the implementation plan.

### 6.5 Cloud sync, analytics, crash reporting, notifications, monitoring are stubbed

All 8 infrastructure services are placeholders that just `print('DEBUG: ...')` and return. They are not in HeartOS v1 scope.

**Action:** **Delete** in Phase 7 of the implementation plan. Cloud sync is deferred to v2. Analytics, crash reporting, notifications, monitoring are not in `HeartOS/00_root/roadmap.md` v1 scope at all.

### 6.6 `Hive` boxes are over-engineered for v1

The current `hive_boxes.dart` has boxes for `nafs`, `emotions`, `journal`, `traits`, `cache`, `sync_queue`. For HeartOS v1, **the only thing that needs local persistence** is:
- Auth state (current `auth` box) — keep
- The 16 tables (use Drift, not Hive)

**The other Hive boxes should be removed.**

---

## 7 · Test File Issues (🟠 Major)

### 7.1 Stale tests

All tests in `test/domain/entities/` reference an old API:

- `test/domain/entities/emotion_entry_test.dart` — references `EmotionType`, `emotionName`, `loggedAt`, `recordedAt`, `notes`, `triggers`, `isHighIntensity`. **All undefined.** 50 compile errors.
- `test/domain/entities/journal_entry_test.dart` — references `isRecent` getter. **Undefined.** 2 compile errors.

### 7.2 Broken test in auth screen

- `test/presentation/screens/auth_screen_test.dart:36` — `autofillHints` not on `TextFormField`.

### 7.3 Missing test infrastructure

- No tests exist for the HeartOS Nafs engine (it doesn't exist yet)
- No tests exist for the graph traversal (it doesn't exist yet)
- No tests exist for the recommendation engine (it doesn't exist yet)
- No integration tests for the 5-screen loop (it doesn't exist yet)
- No tests for the seed data (it doesn't exist yet)

**Action:** Write fresh tests in each phase, with the test cases specified in `IMPLEMENTATION_PLAN.md`.

---

## 8 · Concrete Refactor Plan (drives the implementation plan)

This audit is the input to `IMPLEMENTATION_PLAN.md`. The plan has been updated to include a new **Phase 0.5 — Codebase Cleanup** that must happen before any new feature work.

### Phase 0.5 — Codebase Cleanup (1-2 days)

**Goal:** Remove the 80+ compile errors, all unused code, and all duplicated code.

| Action | Files | Outcome |
|---|---|---|
| **Delete** all `print()` in `main.dart`, `providers.dart`, `splash_screen.dart`, `auth_state_notifier.dart` | Replace with `Logger.debug` | No `avoid_print` lints |
| **Add missing imports** to `accessibility_utils.dart` and `performance_utils.dart` | 2 files | 9 errors fixed |
| **Delete** `test/domain/entities/emotion_entry_test.dart` | 1 file | 50 errors fixed |
| **Delete** `test/domain/entities/journal_entry_test.dart` | 1 file | 2 errors fixed |
| **Fix** `auth_screen_test.dart` autofillHints | 1 file | 1 error fixed |
| **Fix** `app_theme_test.dart` isOneOf | 1 file | 1 error fixed |
| **Remove unused imports** | 6 files | 6 warnings fixed |
| **Remove unused fields** | 6 files | 6 warnings fixed |
| **Remove unused local variables** | 2 files | 2 warnings fixed |
| **Remove unnecessary null comparison** | `conflict_resolver.dart` | 1 warning fixed |
| **Replace `anonKey` with `publishableKey`** | `providers.dart` | 1 deprecation fixed |
| **Delete** `test_auth.dart` (root-level dev test, not part of test suite) | 1 file | Multiple warnings fixed |

**Quality gate:** `flutter analyze --no-pub` reports **0 errors** (warnings may remain for the new code to come).

### Phase 1 onwards — per `IMPLEMENTATION_PLAN.md` v2

The plan has been updated to account for the audit findings:

- **Phase 1 (Schema & Seed)**: Add Drift; create 16 tables; generate seed JSON from `HeartOS/tables/`.
- **Phase 2 (Entities & Repos)**: Rewrite the 5 entities per HeartOS spec; delete `NafsRepositoryImpl` and replace with `NafsHistoryRepositoryImpl` + the pure-Dart Nafs engine. Delete `JournalRepository` and `TraitRepository` (not in HeartOS v1).
- **Phase 3 (Core Engine)**: Implement `Vector4`, `ComputeDailyNafs`, `Meter15Day`, `GrowthPath`, `DetectAttributes`, `Recommend`. All pure-Dart.
- **Phase 4 (Riverpod & 5-Screen Loop)**: Consolidate `authRepositoryProvider` and `googleAuthRepositoryProvider` into one. Replace the 4 secondary screens with the 3 HeartOS screens (Heart Analysis, Personal Prescription, User Feedback).
- **Phase 5 (Heart Graph & History)**: New screens.
- **Phase 6 (Habits, Onboarding, Polish)**: Habits module, Settings cleanup.
- **Phase 7 (Cleanup)**: Delete all infrastructure services (analytics, crash reporting, monitoring) and `sync_*` files — not in HeartOS v1.

---

## 9 · Detailed File-by-File Action List

### Files to DELETE in Phase 0.5

| File | Reason |
|---|---|
| `test/domain/entities/emotion_entry_test.dart` | Stale API (50 errors) |
| `test/domain/entities/journal_entry_test.dart` | Stale API, feature removed |
| `test_auth.dart` | Root-level dev file with print() and errors |
| `lib/src/data/sync/sync_manager.dart` | Cloud sync deferred to v2 |
| `lib/src/data/sync/sync_queue.dart` | Same |
| `lib/src/data/sync/conflict_resolver.dart` | Same |
| `lib/src/infrastructure/services/analytics_service.dart` | Not in HeartOS v1 |
| `lib/src/infrastructure/services/crash_reporting_service.dart` | Not in HeartOS v1 |
| `lib/src/infrastructure/services/notification_service.dart` | Not in HeartOS v1 (deferred to v1.1) |
| `lib/src/infrastructure/services/background_task_service.dart` | Not in HeartOS v1 |
| `lib/src/infrastructure/services/app_lifecycle_service.dart` | Not in HeartOS v1 |
| `lib/src/infrastructure/monitoring/performance_monitor.dart` | Not in HeartOS v1 |
| `lib/src/infrastructure/monitoring/error_monitor.dart` | Not in HeartOS v1 |
| `lib/src/infrastructure/monitoring/metrics_collector.dart` | Not in HeartOS v1 |
| `lib/src/presentation/screens/assessment/` | Not in HeartOS v1 |
| `lib/src/presentation/screens/journal/` | Not in HeartOS v1 |
| `lib/src/presentation/screens/toolkit/` | Not in HeartOS v1 |
| `lib/src/presentation/screens/analytics/` | Not in HeartOS v1 |
| `lib/src/domain/usecases/journal/journal_usecase.dart` | Feature removed |
| `lib/src/domain/repositories/journal_repository.dart` | Feature removed |
| `lib/src/domain/repositories/trait_repository.dart` | Replaced by `AttributeRepository` |
| `lib/src/domain/usecases/auth/login_usecase.dart` | Keep (deferred) |
| `lib/src/domain/entities/trait.dart` | Replaced by `heart_attribute.dart` |
| `lib/src/data/repositories/nafs_repository_impl.dart` | Replaced by Nafs engine + history repo |
| `lib/src/data/models/trait_model.dart` | Replaced |
| `lib/src/data/models/nafs_state_model.dart` | Replaced |
| `lib/src/data/datasources/local/hive_boxes.dart` | Replaced by Drift (keep `auth` box only) |
| `lib/src/data/cache/in_memory_cache.dart` | Not in HeartOS v1 (graph is in-memory by design) |

### Files to REWRITE in Phase 1-4

| File | Current state | Target state |
|---|---|---|
| `lib/src/domain/entities/nafs_state.dart` | 3 NafsTypes, hard-coded defaults | 4 NafsTypes, Vector4 percentages, 10/60/20/10 baseline |
| `lib/src/domain/entities/emotion_entry.dart` | Free-text emotionName, 4-level enum intensity | → renamed to `checkin.dart` with `emotionId: int`, `intensity: int 1-10` |
| `lib/src/domain/entities/journal_entry.dart` | 7 fields | **Delete** (not in HeartOS v1) |
| `lib/src/domain/entities/trait.dart` | 7 fields | **Delete** (replaced by `heart_attribute.dart`) |
| `lib/src/data/repositories/auth_repository_impl.dart` | 4 function-pointer deps | **Refactor** to use `RemoteAuthDataSource` interface |
| `lib/src/infrastructure/di/providers.dart` | 200+ lines, 30+ providers, hard-coded | Reduce to core providers; remove infrastructure service providers |
| `lib/src/infrastructure/di/auth_providers.dart` | Duplicates providers.dart | **Delete** (consolidate) |
| `lib/src/presentation/screens/home/dashboard_screen.dart` | Hard-coded values | Replace with `home_screen.dart` (live meter) |
| `lib/src/presentation/screens/emotions/emotion_logger_screen.dart` | 8 hard-coded emotions | Replace with `checkin_screen.dart` (50 emotions) |
| `lib/main.dart` | 25+ print() statements | Remove prints, use Logger |
| `lib/core/utils/accessibility_utils.dart` | Missing imports | Add imports |
| `lib/core/utils/performance_utils.dart` | Missing imports | Add imports |
| `test/presentation/screens/auth_screen_test.dart` | 1 error | Fix autofillHints |
| `test/presentation/theme/app_theme_test.dart` | 1 error | Fix or delete |
| `test/presentation/navigation/app_router_test.dart` | Unused imports | Remove |

### Files to KEEP unchanged

- All auth code (`lib/src/presentation/screens/auth/`, `lib/src/domain/usecases/auth/`, `lib/src/domain/entities/user.dart`, `lib/src/domain/repositories/auth_repository.dart`, `lib/src/data/datasources/local/local_auth_datasource.dart`, `lib/src/infrastructure/services/google_auth_service.dart`)
- Onboarding, Profile, Settings screens (deferred to Phase 5-6 but the existing skeletons are OK)
- Common widgets (`lib/src/presentation/widgets/common/`)
- Theme (`lib/src/presentation/theme/`)
- Core utilities (`lib/src/core/`)
- `lib/src/presentation/navigation/app_router.dart` (will be modified in Phase 3 to add new routes, but the structure is fine)

### Files to CREATE in Phase 1-4

| File | Source | From audit |
|---|---|---|
| `lib/src/data/datasources/local/database.dart` | Drift | New |
| 16 Drift table files | `HeartOS/tables/00_index.md` | New |
| `lib/src/data/datasources/local/seed_loader.dart` | `HeartOS/tables/01-10_*.md` | New |
| `lib/src/domain/entities/heart_attribute.dart` | `HeartOS/tables/01_attributes.md` | Replaces `trait.dart` |
| `lib/src/domain/entities/checkin.dart` | `HeartOS/tables/11_checkins.md` | Replaces `emotion_entry.dart` |
| `lib/src/domain/entities/vector4.dart` | Pure-Dart | New |
| `lib/src/domain/entities/emotion_attribute_link.dart` | `HeartOS/tables/05_*.md` | New |
| `lib/src/domain/entities/attribute_link.dart` | `HeartOS/tables/06_*.md` | New |
| `lib/src/domain/entities/nafs_history.dart` | `HeartOS/tables/13_nafs_history.md` | New |
| `lib/src/domain/entities/intervention_card.dart` | `HeartOS/08_algorithms/recommendation_algorithm.md` | New |
| `lib/src/domain/usecases/nafs/vector4.dart` | | New |
| `lib/src/domain/usecases/nafs/constants.dart` | | New |
| `lib/src/domain/usecases/nafs/compute_daily_nafs.dart` | `HeartOS/03_nafs_engine/nafs_meter_algorithm.md` | New |
| `lib/src/domain/usecases/nafs/meter_15day.dart` | Same | New |
| `lib/src/domain/usecases/nafs/streak.dart` | Same | New |
| `lib/src/domain/usecases/graph/growth_path.dart` | `HeartOS/00_root/heart_graph.md` | New |
| `lib/src/domain/usecases/graph/detect_attributes.dart` | `HeartOS/02_relationships/emotion_attribute_links.md` | New |
| `lib/src/domain/usecases/recommendations/recommend.dart` | `HeartOS/08_algorithms/recommendation_algorithm.md` | New |
| 8 new repository interfaces | `HeartOS/04_user_tables/` | New |
| 8 new repository implementations (Drift-backed) | | New |
| 5 new screens | `OPERATIONAL_FLOW.md` | New |
| 10 new widget files | | New |
| 10 seed JSON files in `assets/data/` | Extracted from `HeartOS/tables/` | New |
| 20+ unit tests | `HeartOS/08_algorithms/scoring_algorithm.md` §9 | New |
| 5 widget tests | | New |
| 3 integration tests | | New |

---

## 10 · Updated `flutter analyze` Targets

| Phase | Target |
|---|---|
| After Phase 0.5 | 0 errors, ≤ 5 warnings |
| After Phase 1 | 0 errors, 0 warnings (Drift-generated code excluded) |
| After Phase 4 | 0 errors, 0 warnings, 0 lints |
| v1.0 release | 0 errors, 0 warnings, 0 lints, 80%+ test coverage on `lib/src/domain/usecases/` |

---

## 11 · Cross-References

- `HeartOS/IMPLEMENTATION_PLAN.md` — the plan, now updated with this audit
- `HeartOS/OPERATIONAL_FLOW.md` — the 5-screen loop
- `HeartOS/00_root/roadmap.md` — v1.0 quality gates
- `HeartOS/AUDIT_REPORT.md` — Islamic content audit
- `HeartOS/tables/` — the 16 generated table files
- `memory-bank/flutter-implementation-plan-comprehensive.md` — the existing CLEAN architecture plan

---

## 12 · Audit Sign-off

| Area | Status |
|---|---|
| Compile errors | 🔴 80+ — must fix in Phase 0.5 |
| Logic correctness | 🔴 7 — Nafs engine is wrong, entities are wrong |
| SOLID principles | 🟠 8 violations — must refactor in Phase 2 |
| Code duplications | 🟠 5 — must dedupe in Phase 0.5 + 2 |
| Warnings | 🟡 15 — must clean in Phase 0.5 |
| Lint info (avoid_print) | 🟡 50+ — must fix in Phase 0.5 |
| Test files | 🔴 53+ errors — must fix in Phase 0.5 |
| **Overall verdict** | **🔴 Codebase not in runnable state. Phase 0.5 is mandatory before any feature work.** |

This audit is the **input** to the implementation plan. The plan has been updated to reflect these findings.
