# HeartOS — Comprehensive Implementation Plan v2.0

> A complete, phase-by-phase plan to implement the NafsMutmainna Flutter app **exactly on the HeartOS footsteps** — the offline-first, graph-based, 16-table spiritual self-improvement system documented in `HeartOS/`.
>
> **Version:** 2.0 (updated after comprehensive codebase audit)
> **Date:** 2026-06-13
> **Sources:** `HeartOS/00_root/` (architecture, user flow, ERD, heart graph, scoring engine, roadmap), `HeartOS/01_core_tables/` … `09_future/`, `HeartOS/tables/` (16 generated table files), `HeartOS/AUDIT_CODEBASE.md` (comprehensive audit), `memory-bank/flutter-implementation-plan-comprehensive.md` (existing Flutter plan), current state of `lib/`.
>
> **Companion docs:** `OPERATIONAL_FLOW.md` (user flow) · `AUDIT_CODEBASE.md` (audit findings)

---

## Table of Contents

1. [Executive Summary](#1--executive-summary)
2. [Audit-Driven Refactor Strategy](#2--audit-driven-refactor-strategy)
3. [The 100% SOLID Architecture](#3--the-100-solid-architecture)
4. [Zero-Duplication Module Map](#4--zero-duplication-module-map)
5. [Zero-Error Build Pipeline](#5--zero-error-build-pipeline)
6. [The 16-Table HeartOS Schema](#6--the-16-table-heartos-schema)
7. [Seed Data Strategy](#7--seed-data-strategy)
8. [Core Engine: Pure-Dart Nafs + Graph](#8--core-engine-pure-dart-nafs--graph)
9. [Repository, UseCase, and State Architecture](#9--repository-usecase-and-state-architecture)
10. [The 5-Screen Loop](#10--the-5-screen-loop)
11. [HeartOS-Specific Widget Library](#11--heartos-specific-widget-library)
12. [Phase Plan (8 Phases)](#12--phase-plan-8-phases)
13. [Quality Gates](#13--quality-gates)
14. [Testing Strategy](#14--testing-strategy)
15. [Risks and Mitigations](#15--risks-and-mitigations)
16. [Appendices](#16--appendices)

---

## 1 · Executive Summary

### 1.1 What this plan achieves

A Flutter app that implements the 5-screen HeartOS loop (`OPERATIONAL_FLOW.md`) backed by:

- **16 SQLite tables** (4 layers) seeded from the canonical data in `HeartOS/tables/`
- **A pure-Dart Nafs engine** that computes the 4-vector daily Nafs from check-ins, attributes, habits, and trends
- **A graph traversal engine** that resolves any emotion to its disease, remedy, growth path, and prescription cards
- **Offline-first** — zero network calls in the critical path
- **< 3 minutes** for the user to complete the full loop
- **< 300 ms** perceived latency
- **100% SOLID principles**, **zero code duplications**, **zero compile errors**

### 1.2 What the audit revealed

`HeartOS/AUDIT_CODEBASE.md` found:

### 1.3 Seed Data Integrity Strategy

#### Critical Discovery: Seed Data Validation Mechanism

In the 2026-06-15 codebase audit, a critical weakness was discovered in the seed data initialization process. Key findings include:

1. **Stray Column Problem**
   - Seed JSON files can contain columns not in the corresponding database schema
   - These rogue columns can silently break database initialization
   - Previously undetected in manual testing due to inconsistent data loading

2. **Validation Solution**
   ```python
   # Comprehensive seed data validation script
   for seed_file, expected_schema in seed_files.items():
       # Checks for:
       # - Exact column match
       # - No extra columns
       # - No missing columns
       # - Preserves total row count
   ```

3. **Safety Mechanisms**
   - Added `onOpen` database hook to force re-seeding if any critical table is empty
   - Implemented idempotent seeding process
   - Enhanced logging for seed data insertion

4. **Future-Proofing**
   - Will prevent similar data integrity issues in future schema changes
   - Provides clear error reporting during seed data loading

#### Seed Data Integrity Principles

- **Zero Tolerance** for schema mismatches
- **Comprehensive Validation** before any database operation
- **Graceful Degradation** with clear error messages
- **Automatic Correction** where possible

5. **Technical Debt Resolution**
   - Removed manually added columns that didn't match schema
   - Created validation scripts to prevent future occurrences
   - Enhanced database initialization robustness

- **80+ compile errors** (missing imports, stale test files, wrong API references)
- **7 logic errors** (Nafs algorithm is wrong, entities are wrong, 4 NafsTypes missing Mulhamah, default baseline wrong)
- **8 SOLID violations** (SRP, OCP, ISP, DIP across the auth and nafs layers)
- **5 code duplications** (two near-identical auth providers, duplicated user construction, hard-coded assessments)
- **15+ warnings** (unused imports, unused fields, dead code)
- **50+ lint info** (`print()` in production code)

### 1.3 Non-negotiable constraints

These come from `HeartOS/00_root/roadmap.md` and `HeartOS/AUDIT_REPORT.md`:

1. **16 tables** — no more, no less (4 layers).
2. **50 emotions** — all from the seed, no custom additions.
3. **200 attributes** — all from the seed, no custom additions.
4. **8 master pathways** — these are the canonical Islamic chains.
5. **The Nafs engine is pure-Dart** — no IO, no clock, no network.
6. **No LLM, no AI, no cloud sync** in v1.
7. **All Quran / Hadith / Dua / Names content is from the seed xlsx** — no AI generation.
8. **Deterministic Nafs meter** — same input → same output.

---

## 2 · Audit-Driven Refactor Strategy

The audit (`HeartOS/AUDIT_CODEBASE.md`) is the **input** to this plan. The plan is structured to fix every audit finding before any new feature work.

### 2.1 The 4-Pass Refactor

| Pass | Name | Goal | Outcome |
|---|---|---|---|
| 0.5 | **Codebase Cleanup** | Remove 80+ errors, dead code, duplications, `print()`s | `flutter analyze` → 0 errors |
| 1 | **Schema & Seed** | Add Drift, create 16 tables, seed from JSON | A queryable SQLite DB |
| 2 | **Entities & Repos** | Rewrite 5 entities per HeartOS, add 8 repos, fix SOLID violations | Domain layer is HeartOS-compliant |
| 3 | **Core Engine** | Pure-Dart Nafs + graph + recommendation | 100% unit-testable business logic |
| 4 | **5-Screen Loop** | Replace 4 generic screens with 5 HeartOS screens | User flow matches `OPERATIONAL_FLOW.md` |
| 5 | **Heart Graph & History** | Add 2 secondary screens | Full feature parity |
| 6 | **Habits, Onboarding, Polish** | Habits module, settings, splash | v1.0 feature-complete |
| 7 | **Quality & Release** | Tests, profiling, dogfood | Ready to ship |

### 2.2 SOLID compliance per layer

| Layer | S | O | L | I | D | Audit-driven fix |
|---|---|---|---|---|---|---|
| **Domain entities** | ✅ | ✅ | ✅ | ✅ | ✅ | Rewrite 5 entities per HeartOS spec (add `mulhamah`, use `Vector4`, remove `syncStatus`) |
| **Domain use cases** | ✅ | ✅ | ✅ | ✅ | ✅ | Pure-Dart, no IO; Nafs engine is 100% testable |
| **Domain repositories** | ✅ | ✅ | ✅ | 🔴 → ✅ | ✅ | Split `NafsRepositoryInterface` into `NafsHistory` + (removed) `Assessment` |
| **Data datasources** | ✅ | 🔴 → ✅ | ✅ | ✅ | 🔴 → ✅ | Add `RemoteAuthDataSource` interface; refactor `AuthRepositoryImpl` to depend on it (not 4 function pointers) |
| **Data repositories** | ✅ | ✅ | ✅ | ✅ | ✅ | Drift-backed, single responsibility per repo |
| **Providers** | ✅ | ✅ | ✅ | ✅ | ✅ | Consolidate `authRepositoryProvider` + `googleAuthRepositoryProvider` into one |
| **Screens** | ✅ | ✅ | ✅ | ✅ | ✅ | Each screen is a `ConsumerWidget` with one ViewModel |
| **ViewModels** | ✅ | ✅ | ✅ | ✅ | ✅ | One ViewModel per screen, all logic in use cases |

### 2.3 Zero-duplication strategy

| Duplication | Fix |
|---|---|
| `authRepositoryProvider` + `googleAuthRepositoryProvider` | Consolidate. Google sign-out behaviour moves into `GoogleAuthDataSource.signOut()`. |
| `User(...)` construction duplicated in 2 places | Extract to `User.fromSupabaseUser(SupabaseUser u)` factory. |
| `NafsRepositoryImpl` has assessment questions embedded | Delete. Assessment is removed from HeartOS v1. |
| Dashboard + emotion logger have hard-coded values | Replace with data-driven widgets reading from the live Nafs meter and the 50-emotion seed. |
| `SyncStatus` vs `AuthStatus` (two unrelated enums) | Remove `SyncStatus` from all v1 entities (cloud sync deferred to v2). |
| `assessNafsState` in `NafsRepositoryImpl` vs `ComputeDailyNafs` (planned) | Delete `assessNafsState`. The 50/20/20/10 algorithm is the only Nafs computation in v1. |

### 2.4 Zero-error strategy

- **No `print()` in production code** — replace with `Logger.debug`/`Logger.error` (already exists in `lib/core/logger/`).
- **All imports explicit** — no implicit `dart:core` reliance for `Timer`, `Size`, `Widget`, etc.
- **All entities match HeartOS schema** — including `mulhamah` in `NafsType`.
- **All tests pass** — the stale test files are deleted; fresh tests are written in their place.

---

## 3 · The 100% SOLID Architecture

The CLEAN architecture from `memory-bank/flutter-implementation-plan-comprehensive.md` is **adopted unchanged**. This section adds the HeartOS-specific SOLID refinements.

### 3.1 Layer responsibilities (one-liner per file)

```
Presentation  →  renders UI, dispatches to ViewModels
ViewModel     →  holds screen state, calls 1-3 use cases
UseCase       →  business logic, pure Dart (no IO)
Repository    →  abstracts data source, returns entities
DataSource    →  raw IO (Drift / Hive / SecureStorage)
Entity        →  immutable data class
```

### 3.2 S — Single Responsibility

| Class | Responsibility (one line) |
|---|---|
| `HomeScreen` | Render Home with Nafs meter, last check-in, CTA |
| `CheckinScreen` | Let the user pick 1-2 emotions + intensity + notes |
| `InsightScreen` | Show top 3-5 detected attributes + growth path |
| `InterventionScreen` | Show 6 prescription cards (Quran/Hadith/Dua/Names/Dhikr/Action) |
| `ReflectScreen` | Capture feedback (Much better / Better / Same / Worse) |
| `HeartGraphScreen` | Show current growth path + 8 master pathways |
| `HistoryScreen` | Show 7-day Nafs chart + recent check-ins |
| `SubmitCheckinUseCase` | Insert checkin → trigger → recompute Nafs → recommend |
| `ComputeDailyNafs` | Compute 4-vector Nafs from today's inputs |
| `Meter15Day` | Compute weighted moving average of last 15 days |
| `GrowthPath` | BFS the Heart Graph for a chain starting at an attribute |
| `Recommend` | Build 6 intervention cards from top 3 attributes |
| `AttributeRepository` | Read-only CRUD on `attributes` table |
| `NafsHistoryRepository` | CRUD on `nafs_history` table |
| `CheckinRepository` | CRUD on `checkins` table |
| `DriftDatabase` | Open SQLite, run migrations, expose typed DAOs |
| `SeedLoader` | Read JSON from `assets/data/`, insert into SQLite |
| `NafsMeterWidget` | Render the 4-segment arc with dominant highlighted |

### 3.3 O — Open/Closed

Adding a new auth provider (Apple, Facebook) requires:
1. Create `AppleAuthDataSource implements RemoteAuthDataSource`
2. Create `appleAuthDataSourceProvider`
3. Update the (single) `authRepositoryProvider` to inject it
4. **Zero changes** to `AuthRepositoryImpl` or any other class

Adding a new Nafs station requires:
1. Add to `NafsType` enum (1 line)
2. Update `Vector4` to a `Vector5` (or keep `Vector4` and reserve Mulhamah-style extensions)
3. **No changes** to the algorithm (just new data)

### 3.4 L — Liskov Substitution

Every `RepositoryInterface` is implemented by exactly one `RepositoryImpl` in v1. If a second implementation is added (e.g. a `MemoryNafsHistoryRepository` for tests), it must honour the same contract: same input → same output, same error semantics.

### 3.5 I — Interface Segregation

| Interface | Methods | Used by |
|---|---|---|
| `AttributeRepositoryInterface` | `getAll`, `getById`, `getNafsWeights`, `getQuran`, `getHadith`, `getDua`, `getAllahNames` | `GrowthPath`, `Recommend`, `ComputeDailyNafs` |
| `EmotionRepositoryInterface` | `getAll`, `getById`, `getNafsWeights` | `CheckinScreen`, `Recommend`, `ComputeDailyNafs` |
| `EmotionAttributeLinkRepositoryInterface` | `findForEmotion`, `findForEmotionTop` | `DetectAttributes`, `Recommend` |
| `AttributeLinkRepositoryInterface` | `findOutgoing`, `findCure` | `GrowthPath` |
| `CheckinRepositoryInterface` | `insert`, `findForDate`, `findBetween`, `findLatest`, `watchAll` | `CheckinScreen`, `ComputeDailyNafs` |
| `DetectedAttributeRepositoryInterface` | `upsertMany`, `findForDate` | `DetectAttributes`, `ComputeDailyNafs` |
| `NafsHistoryRepositoryInterface` | `upsert`, `findForDate`, `findBetween`, `watchToday` | `ComputeDailyNafs`, `Meter15Day` |
| `InterventionHistoryRepositoryInterface` | `insert`, `findRecent`, `markCompleted`, `markFeedback` | `Recommend`, `ReflectScreen` |
| `HabitRepositoryInterface` | CRUD on `habits` + `habit_logs` | `HabitScreen`, `ComputeDailyNafs` (HabitScore) |
| `RemoteAuthDataSource` (NEW) | `signIn`, `signUp`, `signOut`, `isAuthenticated` | `AuthRepositoryImpl` |
| `ILocalAuthDataSource` | `getCachedUser`, `cacheUser`, `clearAuthData` | `AuthRepositoryImpl` |

### 3.6 D — Dependency Inversion

| High-level class | Depends on abstraction |
|---|---|
| `HomeScreen` | `meter15DayProvider` (Riverpod), not `Meter15Day` directly |
| `ComputeDailyNafs` | `AttributeRepository`, `EmotionRepository`, `CheckinRepository`, `DetectedAttributeRepository`, `HabitRepository`, `NafsHistoryRepository` (interfaces) |
| `AuthRepositoryImpl` | `RemoteAuthDataSource` (interface), not Supabase directly |
| `DriftAppDatabase` | `AppDatabase` (interface), not raw `Database` |

---

## 4 · Zero-Duplication Module Map

The full module layout, with **no file appearing twice** and **no logic duplicated**:

```
lib/
├── main.dart                                # Entry point. Initializes Drift, seeds DB, runs app.
├── app.dart                                 # MaterialApp.router + theme + locale (NEW)
│
├── core/                                    # Framework-level utilities
│   ├── error/
│   │   ├── failure.dart                     # Failure types
│   │   ├── exception.dart                   # Exception types
│   │   └── error_handler.dart               # Map exception → failure
│   ├── logger/
│   │   └── logger.dart                      # Logger (replaces all print())
│   ├── network/
│   │   ├── dio_client.dart                  # (kept for v1.1 cloud sync)
│   │   └── network_info.dart
│   ├── storage/
│   │   └── secure_storage.dart              # Auth tokens
│   └── utils/
│       ├── result.dart                      # Result<T> = Future<Either<Failure, T>>
│       ├── validators.dart
│       ├── extensions.dart
│       ├── date_utils.dart                  # NEW
│       └── localization_utils.dart
│
├── src/
│   ├── domain/                              # PURE DART, no Flutter, no IO
│   │   ├── entities/
│   │   │   ├── checkin.dart                 # HeartOS `checkins` row
│   │   │   ├── heart_attribute.dart         # HeartOS `attributes` row
│   │   │   ├── emotion.dart                 # HeartOS `emotions` row
│   │   │   ├── domain.dart                  # HeartOS `domains` row
│   │   │   ├── nafs_state.dart              # HeartOS `nafs_states` row
│   │   │   ├── emotion_attribute_link.dart  # HeartOS `emotion_attribute_links` row
│   │   │   ├── attribute_link.dart          # HeartOS `attribute_links` row
│   │   │   ├── domain_link.dart             # HeartOS `domain_*_links` row
│   │   │   ├── nafs_weights.dart            # HeartOS `attribute_/emotion_nafs_weights` row
│   │   │   ├── nafs_history.dart            # HeartOS `nafs_history` row
│   │   │   ├── intervention_card.dart       # HeartOS `interventions_history` card
│   │   │   ├── intervention_history.dart    # HeartOS `interventions_history` row
│   │   │   ├── habit.dart                   # HeartOS `habits` row
│   │   │   ├── habit_log.dart               # HeartOS `habit_logs` row
│   │   │   ├── detected_attribute.dart      # HeartOS `detected_attributes` row
│   │   │   ├── user.dart                    # Auth
│   │   │   ├── vector4.dart                 # 4-vector for Nafs scoring
│   │   │   └── intervention_feedback.dart   # enum { MuchBetter, Better, Same, Worse }
│   │   │
│   │   ├── repositories/                    # Interfaces only
│   │   │   ├── attribute_repository.dart
│   │   │   ├── emotion_repository.dart
│   │   │   ├── domain_repository.dart
│   │   │   ├── nafs_state_repository.dart
│   │   │   ├── emotion_attribute_link_repository.dart
│   │   │   ├── attribute_link_repository.dart
│   │   │   ├── domain_link_repository.dart
│   │   │   ├── nafs_weights_repository.dart
│   │   │   ├── nafs_history_repository.dart
│   │   │   ├── checkin_repository.dart
│   │   │   ├── detected_attribute_repository.dart
│   │   │   ├── intervention_history_repository.dart
│   │   │   ├── habit_repository.dart
│   │   │   └── auth_repository.dart
│   │   │
│   │   └── usecases/
│   │       ├── nafs/
│   │       │   ├── constants.dart           # NafsConstants
│   │       │   ├── compute_daily_nafs.dart  # 50/20/20/10 algorithm
│   │       │   ├── meter_15day.dart         # 15-day weighted moving average
│   │       │   └── streak.dart              # Positive/regression streak detection
│   │       ├── graph/
│   │       │   ├── growth_path.dart         # BFS the Heart Graph
│   │       │   └── detect_attributes.dart   # Resolve emotion → attributes
│   │       ├── recommendations/
│   │       │   ├── recommend.dart           # Build 6 cards
│   │       │   └── build_cards.dart         # Card builders (Quran/Hadith/Dua/Names)
│   │       ├── checkin/
│   │       │   ├── submit_checkin.dart      # Orchestrates: insert → trigger → Nafs → recommend
│   │       │   └── record_feedback.dart     # Save feedback to interventions_history
│   │       ├── habits/
│   │       │   └── toggle_habit.dart        # v1.1 (defer)
│   │       └── auth/
│   │           ├── login_usecase.dart
│   │           ├── register_usecase.dart
│   │           └── logout_usecase.dart
│   │
│   ├── data/                                # IO layer
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   ├── app_database.dart        # Drift @DriftDatabase
│   │   │   │   ├── seed_loader.dart         # JSON → SQLite
│   │   │   │   ├── tables/                  # 16 Drift table files
│   │   │   │   │   ├── attributes.dart
│   │   │   │   │   ├── emotions.dart
│   │   │   │   │   ├── domains.dart
│   │   │   │   │   ├── nafs_states.dart
│   │   │   │   │   ├── emotion_attribute_links.dart
│   │   │   │   │   ├── attribute_links.dart
│   │   │   │   │   ├── domain_attribute_links.dart
│   │   │   │   │   ├── domain_emotion_links.dart
│   │   │   │   │   ├── attribute_nafs_weights.dart
│   │   │   │   │   ├── emotion_nafs_weights.dart
│   │   │   │   │   ├── checkins.dart
│   │   │   │   │   ├── detected_attributes.dart
│   │   │   │   │   ├── nafs_history.dart
│   │   │   │   │   ├── interventions_history.dart
│   │   │   │   │   ├── habits.dart
│   │   │   │   │   └── habit_logs.dart
│   │   │   │   └── local_auth_datasource.dart  # Keep (Hive box for auth)
│   │   │   └── remote/
│   │   │       ├── remote_auth_datasource.dart  # INTERFACE (new)
│   │   │       ├── supabase_auth_datasource.dart  # impl (new)
│   │   │       └── google_auth_datasource.dart    # impl (new)
│   │   ├── repositories/                    # Impls
│   │   │   ├── attribute_repository_impl.dart
│   │   │   ├── emotion_repository_impl.dart
│   │   │   ├── domain_repository_impl.dart
│   │   │   ├── nafs_state_repository_impl.dart
│   │   │   ├── emotion_attribute_link_repository_impl.dart
│   │   │   ├── attribute_link_repository_impl.dart
│   │   │   ├── domain_link_repository_impl.dart
│   │   │   ├── nafs_weights_repository_impl.dart
│   │   │   ├── nafs_history_repository_impl.dart
│   │   │   ├── checkin_repository_impl.dart
│   │   │   ├── detected_attribute_repository_impl.dart
│   │   │   ├── intervention_history_repository_impl.dart
│   │   │   ├── habit_repository_impl.dart
│   │   │   └── auth_repository_impl.dart   # REFACTORED to use RemoteAuthDataSource
│   │   └── models/                          # JSON DTOs (if needed)
│   │       └── (none — Drift generates its own)
│   │
│   ├── infrastructure/
│   │   ├── di/
│   │   │   ├── providers.dart               # CONSOLIDATED auth provider
│   │   │   └── app_providers.dart           # NEW: HeartOS-specific providers
│   │   └── services/
│   │       └── google_auth_service.dart     # KEEP (for v1.1)
│   │
│   └── presentation/
│       ├── navigation/
│       │   └── app_router.dart              # 5 core routes + 2 secondary + onboarding
│       ├── theme/
│       │   ├── app_theme.dart
│       │   ├── colors.dart
│       │   └── typography.dart
│       ├── widgets/
│       │   ├── common/
│       │   │   ├── custom_button.dart
│       │   │   ├── custom_text_field.dart
│       │   │   ├── custom_app_bar.dart
│       │   │   ├── loading_indicator.dart
│       │   │   ├── error_widget.dart
│       │   │   └── empty_state_widget.dart
│       │   └── specific/                    # HeartOS-specific widgets
│       │       ├── nafs_meter.dart           # 4-segment arc
│       │       ├── growth_path_strip.dart    # Horizontal chain
│       │       ├── intervention_card_widget.dart  # Quran/Hadith/Dua/Names/Dhikr/Action
│       │       ├── detected_attribute_widget.dart
│       │       ├── domain_badge_widget.dart
│       │       ├── heart_health_score_widget.dart
│       │       ├── checkin_cta_widget.dart
│       │       ├── intensity_slider_widget.dart  # 1-10
│       │       ├── emotion_picker_widget.dart    # 50 emotions, grouped, searchable
│       │       ├── feedback_button_widget.dart   # 4 buttons
│       │       └── master_pathway_card_widget.dart
│       ├── viewmodels/                       # State notifiers
│       │   ├── home_view_model.dart          # 15-day meter + last checkin
│       │   ├── checkin_view_model.dart       # 50 emotions + intensity + notes
│       │   ├── insight_view_model.dart       # top 3-5 attrs + growth path
│       │   ├── intervention_view_model.dart  # 6 cards
│       │   ├── reflect_view_model.dart       # feedback
│       │   ├── heart_graph_view_model.dart
│       │   ├── history_view_model.dart
│       │   ├── habits_view_model.dart
│       │   └── auth_state_notifier.dart      # (existing — minor cleanup)
│       └── screens/
│           ├── splash/
│           │   └── splash_screen.dart
│           ├── onboarding/
│           │   ├── onboarding_screen.dart
│           │   └── onboarding_view_model.dart
│           ├── auth/                          # KEEP for v1.1
│           │   ├── login_screen.dart
│           │   ├── register_screen.dart
│           │   ├── login_view_model.dart
│           │   └── register_view_model.dart
│           ├── home/
│           │   ├── home_screen.dart           # NEW (replaces dashboard_screen)
│           │   └── home_view_model.dart
│           ├── checkin/
│           │   ├── checkin_screen.dart        # NEW (replaces emotion_logger_screen)
│           │   └── checkin_view_model.dart
│           ├── insight/
│           │   ├── insight_screen.dart        # NEW
│           │   └── insight_view_model.dart
│           ├── intervention/
│           │   ├── intervention_screen.dart   # NEW
│           │   └── intervention_view_model.dart
│           ├── reflect/
│           │   ├── reflect_screen.dart        # NEW
│           │   └── reflect_view_model.dart
│           ├── heart_graph/
│           │   ├── heart_graph_screen.dart    # NEW
│           │   └── heart_graph_view_model.dart
│           ├── history/
│           │   ├── history_screen.dart        # NEW
│           │   └── history_view_model.dart
│           ├── habits/
│           │   ├── habits_screen.dart         # NEW (v1.1, but structure ready)
│           │   └── habits_view_model.dart
│           └── profile/
│               ├── profile_screen.dart        # KEEP
│               └── settings_screen.dart       # KEEP (cleaned)
│
├── l10n/
│   ├── app_en.arb                          # English (v1)
│   └── (ur.arb deferred to v1.1)
│
├── assets/
│   ├── images/                              # (existing)
│   ├── data/                                # NEW: 10 seed JSON files
│   │   ├── attributes_seed.json
│   │   ├── emotions_seed.json
│   │   ├── domains_seed.json
│   │   ├── nafs_states_seed.json
│   │   ├── emotion_attribute_links_seed.json
│   │   ├── attribute_links_seed.json
│   │   ├── domain_attribute_links_seed.json
│   │   ├── domain_emotion_links_seed.json
│   │   ├── attribute_nafs_weights_seed.json
│   │   └── emotion_nafs_weights_seed.json
│   └── fonts/                               # (existing)
│
└── test/
    ├── unit/
    │   ├── domain/
    │   │   ├── entities/                    # Per-entity tests
    │   │   │   ├── checkin_test.dart
    │   │   │   ├── heart_attribute_test.dart
    │   │   │   ├── emotion_test.dart
    │   │   │   ├── vector4_test.dart
    │   │   │   ├── nafs_history_test.dart
    │   │   │   └── intervention_card_test.dart
    │   │   └── usecases/
    │   │       ├── nafs/
    │   │       │   ├── compute_daily_nafs_test.dart    # 4 test cases from §9 of scoring_algorithm.md
    │   │       │   ├── meter_15day_test.dart
    │   │       │   └── streak_test.dart
    │   │       ├── graph/
    │   │       │   ├── growth_path_test.dart
    │   │       │   └── detect_attributes_test.dart
    │   │       ├── recommendations/
    │   │       │   └── recommend_test.dart    # 5 test cases from §7 of recommendation_algorithm.md
    │   │       └── checkin/
    │   │           └── submit_checkin_test.dart
    │   └── data/
    │       └── repositories/                # Integration with in-memory Drift
    │           ├── attribute_repository_test.dart
    │           ├── emotion_repository_test.dart
    │           ├── nafs_history_repository_test.dart
    │           ├── checkin_repository_test.dart
    │           ├── intervention_history_repository_test.dart
    │           └── habit_repository_test.dart
    ├── widget/
    │   ├── home_screen_test.dart
    │   ├── checkin_screen_test.dart
    │   ├── insight_screen_test.dart
    │   ├── intervention_screen_test.dart
    │   ├── reflect_screen_test.dart
    │   ├── heart_graph_screen_test.dart
    │   ├── history_screen_test.dart
    │   ├── nafs_meter_widget_test.dart
    │   └── intervention_card_widget_test.dart
    └── integration/
        ├── full_loop_test.dart
        ├── offline_test.dart
        └── first_launch_test.dart

integration_test/                            # (existing — updated)
├── full_loop_test.dart                      # Updated
├── offline_test.dart                        # Updated
├── no_habits_test.dart                      # New
└── app_startup_test.dart                    # New
```

**Note on duplicates eliminated:**

- ❌ `dashboard_screen.dart` → ✅ `home_screen.dart`
- ❌ `emotion_logger_screen.dart` → ✅ `checkin_screen.dart`
- ❌ `nafs_repository_impl.dart` (with assessment) → ✅ `nafs_history_repository_impl.dart` + `ComputeDailyNafs` use case
- ❌ `trait.dart` / `trait_repository.dart` / `trait_model.dart` → ✅ `heart_attribute.dart` / `AttributeRepository`
- ❌ `journal_*.dart` → ❌ (deleted — feature removed)
- ❌ `assessment_*.dart` / `toolkit_*.dart` / `analytics_*.dart` → ❌ (deleted — not in HeartOS v1)
- ❌ `sync_*.dart` (cloud sync) → ❌ (deleted — deferred to v2)
- ❌ `notification_service.dart` / `background_task_service.dart` / `app_lifecycle_service.dart` → ❌ (deleted — not in HeartOS v1)
- ❌ `analytics_service.dart` / `crash_reporting_service.dart` → ❌ (deleted — not in HeartOS v1)
- ❌ `performance_monitor.dart` / `error_monitor.dart` / `metrics_collector.dart` → ❌ (deleted — not in HeartOS v1)
- ❌ `in_memory_cache.dart` → ❌ (deleted — graph is already in-memory by design)
- ❌ `hive_boxes.dart` (multi-box) → ✅ simplified to one auth box only (or remove entirely if Drift can do it)
- ❌ `auth_providers.dart` (duplicate) → ✅ consolidated into `providers.dart`
- ❌ `print()` everywhere → ✅ `Logger.debug` / `Logger.error`

---

## 5 · Zero-Error Build Pipeline

The audit found 80+ compile errors. The plan is to make `flutter analyze --no-pub` report **0 errors, 0 warnings, 0 lints** by the end of Phase 7.

### 5.1 The error categories and their fixes

| Category | Count | Fix |
|---|---:|---|
| Missing imports (Timer, Size, Widget, SemanticsService) | 9 | Add the right `import` directives to `accessibility_utils.dart` and `performance_utils.dart` |
| Stale test files (old EmotionEntry / JournalEntry API) | 53 | Delete the test files; rewrite in Phase 2-3 |
| Unused imports | 6 | Remove |
| Unused fields | 6 | Remove |
| Unused local variables | 2 | Remove |
| Unnecessary null comparison | 1 | Remove the null check |
| `print()` in production | 50+ | Replace with `Logger.debug`/`Logger.error` |
| `anonKey` deprecation | 1 | Rename to `publishableKey` |
| `autofillHints` on `TextFormField` | 1 | Move to `TextField` or use the correct API |
| `isOneOf` undefined | 1 | Inline the comparison or remove the test |

### 5.2 The CI gate

Add a pre-commit / CI step that runs:

```bash
flutter analyze --no-pub --fatal-warnings --fatal-infos
```

This blocks any commit that introduces a new error, warning, or lint.

### 5.3 The pre-commit checklist

Before any PR is merged:

- [ ] `flutter analyze --no-pub` reports 0 issues
- [ ] `flutter test` passes
- [ ] `flutter build apk --release` succeeds
- [ ] APK size < 50 MB
- [ ] Cold start < 1.5 s

---

## 6 · The 16-Table HeartOS Schema

The schema is defined in `HeartOS/tables/`. See `00_index.md` for the canonical overview.

```
Layer 1 — Knowledge (immutable):
  1.  attributes                 (200 rows, 23 cols)
  2.  emotions                   (50 rows, 21 cols)
  3.  domains                    (10 rows, 4 cols)
  4.  nafs_states                (4 rows, 4 cols)

Layer 2 — Graph (immutable):
  5.  emotion_attribute_links    (~285 rows, 5 cols)
  6.  attribute_links            (~218 rows, 5 cols)  ← Heart Graph
  7.  domain_attribute_links     (~229 rows, 4 cols)
  8.  domain_emotion_links       (~100 rows, 4 cols)

Layer 3 — Nafs Engine (immutable):
  9.  attribute_nafs_weights     (200 rows, 5 cols)
  10. emotion_nafs_weights       (50 rows, 5 cols)

Layer 4 — User (mutable, runtime):
  11. checkins                   (runtime, 5 cols)
  12. detected_attributes        (runtime, 4 cols)
  13. nafs_history               (runtime, 5 cols)
  14. interventions_history      (runtime, 6 cols)
  15. habits                     (runtime, 3 cols)
  16. habit_logs                 (runtime, 4 cols)
```

### 6.1 Drift implementation

Add to `pubspec.yaml`:

```yaml
dependencies:
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0       # already present
  path: ^1.9.0

dev_dependencies:
  drift_dev: ^2.14.0
```

`lib/src/data/datasources/local/app_database.dart`:

```dart
@DriftDatabase(tables: [
  Attributes, Emotions, Domains, NafsStates,
  EmotionAttributeLinks, AttributeLinks,
  DomainAttributeLinks, DomainEmotionLinks,
  AttributeNafsWeights, EmotionNafsWeights,
  Checkins, DetectedAttributes, NafsHistory,
  InterventionsHistory, Habits, HabitLogs,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await SeedLoader.seedAll(this);  // Idempotent
    },
    onUpgrade: (m, from, to) async {
      // Future migrations
    },
  );
}
```

### 6.2 Seed order

Per `HeartOS/tables/00_index.md` §"Seed Order":

```
1. nafs_states               (no deps)
2. emotions                  (no deps)
3. attributes                (no deps)
4. domains                   (no deps)
5. emotion_nafs_weights      → depends on emotions
6. attribute_nafs_weights    → depends on attributes
7. emotion_attribute_links   → depends on emotions, attributes
8. attribute_links           → depends on attributes
9. domain_attribute_links    → depends on domains, attributes
10. domain_emotion_links      → depends on domains, emotions
```

### 6.3 CHECK constraints (per `00_index.md` §"CHECK Constraints")

```sql
emotions.Category           IN ('Negative', 'Positive')
emotions.Dominant_Nafs_State IN ('Ammarah','Lawwamah','Mulhamah','Mutmainnah')
emotions.Severity_Weight    BETWEEN 1 AND 10
attributes.Nature           IN ('Positive', 'Negative')
emotion_attribute_links.Weight BETWEEN 0.0 AND 1.0
emotion_attribute_links.Role IN ('Disease', 'Treatment', 'Core', 'Strengthens')
attribute_links.Weight      BETWEEN 0.0 AND 1.0
attribute_links.Relationship IN ('Cure', 'Leads_To', 'Strengthens', 'Opposes')
attribute_links.Source_Attribute_ID <> Target_Attribute_ID
nafs_states.Name            IN ('Ammarah','Lawwamah','Mulhamah','Mutmainnah')
attribute_nafs_weights:     4 cols sum 95..105
emotion_nafs_weights:       4 cols sum 95..105
checkins.Intensity          BETWEEN 0 AND 10
detected_attributes.Score   BETWEEN 0.0 AND 1.0
interventions_history.Intervention_Type IN ('Quran','Hadith','Dua','Allah_Names','Dhikr','Action')
interventions_history.Completed IN (0,1)
nafs_history:               4 cols sum 0.99..1.01
habits.Category             IN ('Prayer','Quran','Dhikr','Charity','Exercise','Other')
habit_logs.Completed        IN (0,1)
```

---

## 7 · Seed Data Strategy

The 10 seed JSON files are extracted from the 10 source tables in `HeartOS/tables/01-10_*.md`. The runtime tables (11-16) have no seeds.

### 7.1 Asset files to generate

| Asset | Source | Rows | Approx. size |
|---|---|---:|---:|
| `assets/data/attributes_seed.json` | `HeartOS/tables/01_attributes.md` | 200 | 80 KB |
| `assets/data/emotions_seed.json` | `HeartOS/tables/02_emotions.md` | 50 | 18 KB |
| `assets/data/domains_seed.json` | `HeartOS/tables/03_domains.md` | 10 | 2 KB |
| `assets/data/nafs_states_seed.json` | `HeartOS/tables/04_nafs_states.md` | 4 | 1 KB |
| `assets/data/emotion_attribute_links_seed.json` | `HeartOS/tables/05_emotion_attribute_links.md` | 285 | 12 KB |
| `assets/data/attribute_links_seed.json` | `HeartOS/tables/06_attribute_links.md` | 218 | 9 KB |
| `assets/data/domain_attribute_links_seed.json` | `HeartOS/tables/07_domain_attribute_links.md` | 229 | 9 KB |
| `assets/data/domain_emotion_links_seed.json` | `HeartOS/tables/08_domain_emotion_links.md` | 100 | 4 KB |
| `assets/data/attribute_nafs_weights_seed.json` | `HeartOS/tables/09_attribute_nafs_weights.md` | 200 | 8 KB |
| `assets/data/emotion_nafs_weights_seed.json` | `HeartOS/tables/10_emotion_nafs_weights.md` | 50 | 2 KB |
| **Total** | | **1,346** | **~145 KB** |

### 7.2 Each JSON file

```json
{
  "_schema_version": "1.0.0",
  "_generated_at": "2026-06-13",
  "rows": [
    { "Attribute_ID": 1, "Attribute": "Riya", "Arabic_Name": "الرياء", "Nature": "Negative", ... },
    ...
  ]
}
```

### 7.3 Seeder implementation

```dart
class SeedLoader {
  static Future<void> seedAll(AppDatabase db) async {
    await _seedNafsStates(db);
    await _seedEmotions(db);
    await _seedAttributes(db);
    await _seedDomains(db);
    await _seedEmotionNafsWeights(db);
    await _seedAttributeNafsWeights(db);
    await _seedEmotionAttributeLinks(db);
    await _seedAttributeLinks(db);
    await _seedDomainAttributeLinks(db);
    await _seedDomainEmotionLinks(db);
  }

  static Future<List<Map<String, Object?>>> _load(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, Object?>;
    return (json['rows'] as List).cast<Map<String, Object?>>();
  }
}
```

### 7.4 Idempotency

```sql
INSERT OR IGNORE INTO attributes (Attribute_ID, Attribute, ...) VALUES (?, ?, ...);
```

This makes the seeder safe to run multiple times.

---

## 8 · Core Engine: Pure-Dart Nafs + Graph

The Nafs engine is the heart of the app. It must be **pure-Dart, 100% unit-testable**.

### 8.1 `Vector4`

```dart
class Vector4 {
  final double ammarah, lawwamah, mulhamah, mutmainnah;
  const Vector4(this.ammarah, this.lawwamah, this.mulhamah, this.mutmainnah);
  static const neutral = Vector4(0.25, 0.25, 0.25, 0.25);
  static const lawwamahBaseline = Vector4(0.10, 0.60, 0.20, 0.10);  // 10/60/20/10

  Vector4 operator +(Vector4 o) => Vector4(
    ammarah + o.ammarah, lawwamah + o.lawwamah,
    mulhamah + o.mulhamah, mutmainnah + o.mutmainnah,
  );
  Vector4 operator *(double s) => Vector4(
    ammarah * s, lawwamah * s, mulhamah * s, mutmainnah * s,
  );
  Vector4 get normalised {
    final s = ammarah + lawwamah + mulhamah + mutmainnah;
    return s == 0 ? neutral : (this * (1.0 / s));
  }
  NafsType get dominant {
    final vals = [ammarah, lawwamah, mulhamah, mutmainnah];
    return NafsType.values[vals.indexOf(vals.reduce((a, b) => a > b ? a : b))];
  }
  // Heart Health Score: 0-100, derived from Mutmainnah + Mulhamah
  int get heartHealthScore => ((mutmainnah + mulhamah * 0.7) * 100).round();
}
```

### 8.2 `NafsConstants`

```dart
class NafsConstants {
  static const double wAttribute = 0.50;
  static const double wEmotion   = 0.20;
  static const double wHabit     = 0.20;
  static const double wTrend     = 0.10;

  static const int meterWindowDays     = 15;
  static const int trendWindowDays     = 14;
  static const int habitWindowDays     = 7;
  static const double trendNudgeSize    = 0.05;

  static const habitBias = <Vector4>[
    Vector4(0.60, 0.40, 0.00, 0.00),  // < 20%
    Vector4(0.20, 0.60, 0.20, 0.00),  // 20-50%
    Vector4(0.00, 0.30, 0.50, 0.20),  // 50-80%
    Vector4(0.00, 0.10, 0.20, 0.70),  // >= 80%
  ];

  static const int positiveStreakForMulhamah    = 7;
  static const int positiveStreakForMutmainnah  = 30;
  static const int regressionStreakThreshold    = 3;
}
```

### 8.3 `ComputeDailyNafs`

```dart
class ComputeDailyNafs {
  final CheckinRepositoryInterface _checkins;
  final DetectedAttributeRepositoryInterface _detected;
  final HabitRepositoryInterface _habits;
  final NafsHistoryRepositoryInterface _history;
  final EmotionRepositoryInterface _emotions;
  final AttributeRepositoryInterface _attrs;

  ComputeDailyNafs(this._checkins, this._detected, this._habits, this._history, this._emotions, this._attrs);

  Future<Vector4> call(DateTime date) async {
    final a = await _attributeScore(date);
    final e = await _emotionScore(date);
    final h = await _habitScore(date);
    final t = await _trendScore(date);
    return (NafsConstants.wAttribute * a
          + NafsConstants.wEmotion   * e
          + NafsConstants.wHabit     * h
          + NafsConstants.wTrend     * t).normalised;
  }

  // Private: attribute_score, emotion_score, habit_score, trend_score
  // — see HeartOS/03_nafs_engine/nafs_meter_algorithm.md for exact formulas
}
```

### 8.4 `Meter15Day`

```dart
class Meter15Day {
  final NafsHistoryRepositoryInterface _history;
  Meter15Day(this._history);

  Future<Vector4> call(DateTime date) async {
    final rows = await _history.findBetween(
      date.subtract(Duration(days: NafsConstants.meterWindowDays - 1)),
      date,
    );
    if (rows.isEmpty) return Vector4.lawwamahBaseline;

    final weights = [for (var i = 0; i < rows.length; i++) 1.0 - (i * 0.8 / (NafsConstants.meterWindowDays - 1))];
    final weighted = rows
        .map((r) => Vector4(r.ammarah, r.lawwamah, r.mulhamah, r.mutmainnah) * weights[rows.indexOf(r)])
        .fold<Vector4>(Vector4(0, 0, 0, 0), (a, b) => a + b);
    return (weighted * (1.0 / weights.reduce((a, b) => a + b))).normalised;
  }
}
```

### 8.5 `Streak`

```dart
class Streak {
  final NafsHistoryRepositoryInterface _history;
  Streak(this._history);

  Future<int> positiveStreakAsOf(DateTime date) async {
    final rows = await _history.findBetween(date.subtract(Duration(days: 365)), date);
    var count = 0;
    for (var i = rows.length - 1; i >= 0; i--) {
      final v = Vector4(rows[i].ammarah, rows[i].lawwamah, rows[i].mulhamah, rows[i].mutmainnah);
      if (v.mulhamah + v.mutmainnah > 0.55) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }
}
```

### 8.6 `GrowthPath` (Heart Graph traversal)

```dart
class GrowthPath {
  final AttributeLinkRepositoryInterface _links;
  final AttributeRepositoryInterface _attrs;
  GrowthPath(this._links, this._attrs);

  /// BFS the Heart Graph for a chain starting at sourceId.
  /// Returns the chain following Cure → Leads_To → Strengthens.
  Future<List<HeartAttribute>> call(int sourceId, {int maxHops = 4}) async {
    final path = <HeartAttribute>[];
    var current = sourceId;
    final visited = <int>{};
    for (var i = 0; i < maxHops; i++) {
      if (visited.contains(current)) break;
      visited.add(current);
      final attr = await _attrs.getById(current);
      if (attr == null) break;
      path.add(attr);
      final edges = await _links.findOutgoing(current);
      final next = edges
          .where((e) => e.relationship == 'Cure'
              || e.relationship == 'Leads_To'
              || e.relationship == 'Strengthens')
          .reduceOrNull((a, b) => a.weight > b.weight ? a : b);
      if (next == null) break;
      current = next.targetId;
    }
    return path;
  }
}
```

### 8.7 `DetectAttributes`

```dart
class DetectAttributes {
  final EmotionAttributeLinkRepositoryInterface _links;
  DetectAttributes(this._links);

  Future<List<({int attributeId, double score, String role})>> call(
    int emotionId, int intensity) async {
    final links = await _links.findForEmotion(emotionId);
    final mult = intensity / 10.0;
    return links
        .map((l) => (
              attributeId: l.attributeId,
              score: l.weight * mult,
              role: l.role,
            ))
        .toList();
  }
}
```

### 8.8 `Recommend`

```dart
class Recommend {
  final EmotionAttributeLinkRepositoryInterface _links;
  final AttributeRepositoryInterface _attrs;
  final EmotionRepositoryInterface _emotions;
  final InterventionHistoryRepositoryInterface _history;

  Recommend(this._links, this._attrs, this._emotions, this._history);

  Future<List<InterventionCard>> call(int emotionId, int intensity) async {
    // 1. Top 3 Treatment/Core links
    final links = await _links.findForEmotionTop(emotionId, role: 'Treatment', limit: 3);
    final emotion = await _emotions.getById(emotionId);
    if (emotion == null) return [];

    // 2. Build candidates
    final candidates = <InterventionCard>[];
    for (final link in links) {
      final attr = await _attrs.getById(link.attributeId);
      if (attr == null) continue;
      candidates.addAll(_buildAttributeCards(attr, emotion, link.weight * intensity / 10.0));
    }
    candidates.add(_buildDhikrCard(emotion));
    candidates.add(_buildActionCard(emotion));

    // 3. Filter by 7-day no-repeat
    final recent = await _history.findRecent(7);
    final seen = recent.map((r) => (r.interventionType, r.attributeId, r.emotionId)).toSet();
    final filtered = candidates
        .where((c) => !seen.contains((c.type, c.attributeId, c.emotionId)))
        .toList();

    // 4. Rank
    filtered.sort((a, b) => b.score.compareTo(a.score));

    // 5. Take top 6
    return filtered.take(6).toList();
  }

  List<InterventionCard> _buildAttributeCards(HeartAttribute attr, Emotion emotion, double score) {
    final cards = <InterventionCard>[];
    if (attr.quranReference != null) {
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
    if (attr.hadithReference != null) {
      cards.add(InterventionCard(
        type: InterventionType.hadith,
        title: 'Hadith',
        subtitle: attr.hadithReference!,
        arabic: attr.hadithArabic ?? '',
        translation: '',
        urdu: attr.hadithUrdu ?? '',
        why: 'Practical guidance for ${attr.name}',
        attributeId: attr.id,
        emotionId: emotion.id,
        score: score,
      ));
    }
    if (attr.propheticDuaReference != null) {
      cards.add(InterventionCard(
        type: InterventionType.dua,
        title: 'Dua',
        subtitle: attr.propheticDuaReference!,
        arabic: attr.propheticDuaArabic ?? '',
        translation: '',
        urdu: attr.propheticDuaUrdu ?? '',
        why: 'A supplication for ${attr.name}',
        attributeId: attr.id,
        emotionId: emotion.id,
        score: score,
      ));
    }
    if (attr.relevantAllahNames != null) {
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

  InterventionCard _buildDhikrCard(Emotion emotion) => InterventionCard(
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

  InterventionCard _buildActionCard(Emotion emotion) => InterventionCard(
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
```

### 8.9 `SubmitCheckin` (orchestrator)

```dart
class SubmitCheckin {
  final CheckinRepositoryInterface _checkins;
  final DetectAttributes _detect;
  final DetectedAttributeRepositoryInterface _detectedRepo;
  final ComputeDailyNafs _nafs;
  final NafsHistoryRepositoryInterface _history;
  final Recommend _recommend;

  SubmitCheckin(this._checkins, this._detect, this._detectedRepo, this._nafs, this._history, this._recommend);

  /// The full pipeline for one check-in tap. < 300 ms.
  Future<SubmitCheckinResult> call(Checkin checkin) async {
    // 1. INSERT checkin
    await _checkins.insert(checkin);

    // 2. Detect attributes
    final detected = await _detect(checkin.emotionId, checkin.intensity);
    await _detectedRepo.upsertMany(detected
        .map((d) => (date: checkin.date, attributeId: d.attributeId, score: d.score))
        .toList());

    // 3. Compute today's Nafs
    final nafsVector = await _nafs(checkin.date);
    await _history.upsert(NafsHistory(
      date: checkin.date,
      ammarah: nafsVector.ammarah,
      lawwamah: nafsVector.lawwamah,
      mulhamah: nafsVector.mulhamah,
      mutmainnah: nafsVector.mutmainnah,
    ));

    // 4. Build recommendations
    final cards = await _recommend(checkin.emotionId, checkin.intensity);

    return SubmitCheckinResult(checkin: checkin, detected: detected, cards: cards, nafs: nafsVector);
  }
}
```

### 8.10 `RecordFeedback`

```dart
class RecordFeedback {
  final InterventionHistoryRepositoryInterface _history;
  RecordFeedback(this._history);

  Future<void> call(int recordId, InterventionFeedback feedback) async {
    await _history.markFeedback(recordId, feedback);
  }
}
```

---

## 9 · Repository, UseCase, and State Architecture

### 9.1 Domain entities (matching HeartOS schema)

```dart
// checkin.dart
class Checkin extends Equatable {
  final int id;
  final DateTime date;
  final int emotionId;          // FK to emotions
  final int intensity;          // 1-10
  final String? notes;          // max 500 chars
  const Checkin({required this.id, required this.date, required this.emotionId, required this.intensity, this.notes});
  // copyWith, props
}

// heart_attribute.dart
class HeartAttribute extends Equatable {
  final int id;
  final String name;
  final String arabicName;
  final String nature;          // Positive | Negative
  final String definition;
  final String? oppositeTrait;
  final String? oppositeArabic;
  final String keywords;
  final String? quranReference, quranArabic, quranEnglish, quranUrdu;
  final String? hadithReference, hadithArabic, hadithUrdu;
  final String? quranicDuaReference, quranicDuaArabic, quranicDuaUrdu;
  final String? propheticDuaReference, propheticDuaArabic, propheticDuaUrdu;
  final String? relevantAllahNames;
  final String? practicalUnderstanding;
  const HeartAttribute({/* all fields */});
  // copyWith, props
}

// emotion.dart
class Emotion extends Equatable {
  final int id;
  final String name;
  final String arabicName;
  final String category;        // Negative | Positive
  final String description;
  final String commonTriggers;
  final String primaryNegativeAttributes;
  final String secondaryNegativeAttributes;
  final String primaryPositiveAttributes;
  final String growthPath;
  final String dominantNafsState;
  final int severityWeight;     // 1-10
  final String recommendedAttributePriority;
  final String recommendedInterventionType;
  final String recommendedDua;
  final String recommendedAllahNames;
  final String recommendedDhikr;
  final String dailyAction;
  final String relatedEmotions;
  final String relatedAttributeIds;
  final String keywords;
  const Emotion({/* all fields */});
  // copyWith, props
}

// nafs_state.dart  — 4 TYPES
enum NafsType { ammarah, lawwamah, mulhamah, mutmainnah }
class NafsState extends Equatable {
  final int id;
  final NafsType type;          // dominant
  final double score;
  final Vector4 percentages;   // sum = 1.0
  final List<int> dominantAttributeIds;
  final DateTime assessedAt;
  // copyWith, props
}

// nafs_history.dart
class NafsHistory extends Equatable {
  final int id;
  final DateTime date;
  final double ammarah, lawwamah, mulhamah, mutmainnah;  // sum = 1.0
  const NafsHistory({/* ... */});
}

// intervention_card.dart
enum InterventionType { quran, hadith, dua, allahNames, dhikr, action }
class InterventionCard extends Equatable {
  final InterventionType type;
  final String title;
  final String subtitle;
  final String arabic;
  final String translation;
  final String urdu;
  final String why;
  final int attributeId;
  final int emotionId;
  final double score;
  const InterventionCard({/* ... */});
  // copyWith, props
}

// intervention_history.dart
class InterventionHistory extends Equatable {
  final int id;
  final DateTime date;
  final int emotionId;
  final int attributeId;
  final InterventionType interventionType;
  final bool completed;
  final InterventionFeedback? feedback;  // enum
  const InterventionHistory({/* ... */});
}
enum InterventionFeedback { muchBetter, better, same, worse }

// detected_attribute.dart
class DetectedAttribute extends Equatable {
  final int id;
  final DateTime date;
  final int attributeId;
  final double score;          // 0.0 - 1.0
  const DetectedAttribute({/* ... */});
}

// habit.dart
class Habit extends Equatable {
  final int id;
  final String name;
  final String category;        // Prayer | Quran | Dhikr | Charity | Exercise | Other
  const Habit({/* ... */});
}

// habit_log.dart
class HabitLog extends Equatable {
  final int id;
  final DateTime date;
  final int habitId;
  final bool completed;
  const HabitLog({/* ... */});
}

// emotion_attribute_link.dart
class EmotionAttributeLink extends Equatable {
  final int id;
  final int emotionId;
  final int attributeId;
  final double weight;          // 0.0 - 1.0
  final String role;            // Disease | Treatment | Core | Strengthens
  const EmotionAttributeLink({/* ... */});
}

// attribute_link.dart
class AttributeLink extends Equatable {
  final int id;
  final int sourceAttributeId;
  final int targetAttributeId;
  final double weight;
  final String relationship;    // Cure | Leads_To | Strengthens | Opposes
  const AttributeLink({/* ... */});
}
```

### 9.2 Repository interfaces (14 total)

```dart
// attribute_repository.dart
abstract class AttributeRepositoryInterface {
  Future<List<HeartAttribute>> getAll();
  Future<HeartAttribute?> getById(int id);
  Future<({double ammarah, double lawwamah, double mulhamah, double mutmainnah})> getNafsWeights(int id);
  Future<({String? reference, String? arabic, String? english, String? urdu})> getQuran(int id);
  Future<({String? reference, String? arabic, String? urdu})> getHadith(int id);
  Future<({String? reference, String? arabic, String? urdu})> getPropheticDua(int id);
  Future<String?> getAllahNames(int id);
}

// emotion_repository.dart
abstract class EmotionRepositoryInterface {
  Future<List<Emotion>> getAll();
  Future<Emotion?> getById(int id);
  Future<({double ammarah, double lawwamah, double mulhamah, double mutmainnah})> getNafsWeights(int id);
}

// emotion_attribute_link_repository.dart
abstract class EmotionAttributeLinkRepositoryInterface {
  Future<List<EmotionAttributeLink>> findForEmotion(int emotionId);
  Future<List<EmotionAttributeLink>> findForEmotionTop(int emotionId, {String? role, int limit = 3});
}

// attribute_link_repository.dart
abstract class AttributeLinkRepositoryInterface {
  Future<List<AttributeLink>> findOutgoing(int sourceId, {String? relationship});
  Future<List<AttributeLink>> findCure(int sourceId);
}

// nafs_history_repository.dart
abstract class NafsHistoryRepositoryInterface {
  Future<void> upsert(NafsHistory row);
  Future<NafsHistory?> findForDate(DateTime d);
  Future<List<NafsHistory>> findBetween(DateTime start, DateTime end);
  Stream<NafsHistory?> watchToday();
}

// checkin_repository.dart
abstract class CheckinRepositoryInterface {
  Future<int> insert(Checkin c);
  Future<List<Checkin>> findForDate(DateTime d);
  Future<List<Checkin>> findBetween(DateTime start, DateTime end);
  Future<Checkin?> findLatest();
  Stream<List<Checkin>> watchAll();
}

// detected_attribute_repository.dart
abstract class DetectedAttributeRepositoryInterface {
  Future<void> upsertMany(List<({DateTime date, int attributeId, double score})> rows);
  Future<List<DetectedAttribute>> findForDate(DateTime d);
}

// intervention_history_repository.dart
abstract class InterventionHistoryRepositoryInterface {
  Future<int> insert(InterventionHistory row);
  Future<List<InterventionHistory>> findRecent(int days);
  Future<void> markFeedback(int recordId, InterventionFeedback feedback);
  Future<void> markCompleted(int recordId, bool completed);
}

// habit_repository.dart
abstract class HabitRepositoryInterface {
  Future<int> insertHabit(Habit h);
  Future<List<Habit>> allHabits();
  Future<void> deleteHabit(int id);
  Future<void> logHabit(HabitLog log);
  Future<List<HabitLog>> logsBetween(DateTime start, DateTime end);
  Future<int> activeHabitsCount();
}

// nafs_state_repository.dart
abstract class NafsStateRepositoryInterface {
  Future<NafsState?> getCurrent();
  Future<void> setCurrent(NafsState s);
  Stream<NafsState?> watchCurrent();
}

// domain_repository.dart
abstract class DomainRepositoryInterface {
  Future<List<Domain>> getAll();
  Future<Domain?> getById(int id);
}

// domain_link_repository.dart
abstract class DomainLinkRepositoryInterface {
  Future<List<DomainAttributeLink>> findAttributesForDomain(int domainId);
  Future<List<DomainEmotionLink>> findEmotionsForDomain(int domainId);
}

// nafs_weights_repository.dart
abstract class NafsWeightsRepositoryInterface {
  Future<({double a, double l, double m, double t})> forAttribute(int id);
  Future<({double a, double l, double m, double t})> forEmotion(int id);
}

// auth_repository.dart  (existing — minor cleanups)
abstract class AuthRepositoryInterface {
  Future<Result<User>> signIn({required String email, required String password});
  Future<Result<User>> signUp({required String email, required String password, String? displayName});
  Future<Result<void>> signOut();
  Future<Result<User>> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<Result<void>> deleteAccount();
  Future<Result<void>> sendPasswordReset(String email);
}
```

### 9.3 Drift-backed implementations

Each repository has exactly one `*_impl.dart` in `lib/src/data/repositories/`. Each is a thin wrapper over a Drift DAO:

```dart
// checkin_repository_impl.dart
class CheckinRepositoryImpl implements CheckinRepositoryInterface {
  final AppDatabase _db;
  CheckinRepositoryImpl(this._db);

  @override
  Future<int> insert(Checkin c) async {
    return _db.into(_db.checkins).insert(_toCompanion(c));
  }

  @override
  Future<List<Checkin>> findForDate(DateTime d) async {
    final rows = await (_db.select(_db.checkins)
      ..where((t) => t.date.equals(_dateOnly(d))))
      .get();
    return rows.map(_fromRow).toList();
  }
  // ... etc

  static CheckinsCompanion _toCompanion(Checkin c) => CheckinsCompanion(
    id: c.id == 0 ? Value.absent() : Value(c.id),
    date: Value(_dateOnly(c.date)),
    emotionId: Value(c.emotionId),
    intensity: Value(c.intensity),
    notes: Value(c.notes),
  );

  static Checkin _fromRow(CheckinRow r) => Checkin(
    id: r.id, date: r.date, emotionId: r.emotionId, intensity: r.intensity, notes: r.notes,
  );
}
```

### 9.4 Riverpod providers

`lib/src/infrastructure/di/app_providers.dart`:

```dart
// === App database ===
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(_openConnection());
  ref.onDispose(() => db.close());
  return db);
});

// === Repositories (one per interface) ===
final attributeRepositoryProvider = Provider<AttributeRepositoryInterface>(
  (ref) => AttributeRepositoryImpl(ref.watch(appDatabaseProvider)));
// ... 13 more, all the same pattern.

// === Use cases (one per file in domain/usecases) ===
final computeDailyNafsProvider = Provider<ComputeDailyNafs>((ref) =>
  ComputeDailyNafs(
    ref.watch(checkinRepositoryProvider),
    ref.watch(detectedAttributeRepositoryProvider),
    ref.watch(habitRepositoryProvider),
    ref.watch(nafsHistoryRepositoryProvider),
    ref.watch(emotionRepositoryProvider),
    ref.watch(attributeRepositoryProvider),
  ));

final meter15DayProvider = Provider<Meter15Day>((ref) =>
  Meter15Day(ref.watch(nafsHistoryRepositoryProvider)));

final growthPathProvider = Provider<GrowthPath>((ref) =>
  GrowthPath(ref.watch(attributeLinkRepositoryProvider), ref.watch(attributeRepositoryProvider)));

final detectAttributesProvider = Provider<DetectAttributes>((ref) =>
  DetectAttributes(ref.watch(emotionAttributeLinkRepositoryProvider)));

final recommendProvider = Provider<Recommend>((ref) =>
  Recommend(
    ref.watch(emotionAttributeLinkRepositoryProvider),
    ref.watch(attributeRepositoryProvider),
    ref.watch(emotionRepositoryProvider),
    ref.watch(interventionHistoryRepositoryProvider),
  ));

final submitCheckinProvider = Provider<SubmitCheckin>((ref) =>
  SubmitCheckin(
    ref.watch(checkinRepositoryProvider),
    ref.watch(detectAttributesProvider),
    ref.watch(detectedAttributeRepositoryProvider),
    ref.watch(computeDailyNafsProvider),
    ref.watch(nafsHistoryRepositoryProvider),
    ref.watch(recommendProvider),
  ));

// === State notifiers (one per screen) ===
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, AsyncValue<HomeState>>((ref) {
  return HomeViewModel(
    meter15Day: ref.watch(meter15DayProvider),
    checkinRepo: ref.watch(checkinRepositoryProvider),
    detectAttrs: ref.watch(detectedAttributeRepositoryProvider),
  );
});
```

### 9.5 Auth refactor (SOLID compliance)

`lib/src/data/datasources/remote/remote_auth_datasource.dart`:

```dart
abstract class RemoteAuthDataSource {
  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password, String? displayName);
  Future<void> signOut();
  Future<bool> isAuthenticated();
}

class SupabaseAuthDataSource implements RemoteAuthDataSource {
  final SupabaseClient _supabase;
  SupabaseAuthDataSource(this._supabase);
  // ... implements
}

class GoogleAuthDataSource implements RemoteAuthDataSource {
  final IGoogleAuthService _google;
  final SupabaseClient _supabase;
  GoogleAuthDataSource(this._google, this._supabase);

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _google.signOutGoogle();  // Google-specific behaviour encapsulated here
  }
  // ... others
}
```

`lib/src/data/repositories/auth_repository_impl.dart`:

```dart
class AuthRepositoryImpl implements AuthRepositoryInterface {
  final RemoteAuthDataSource _remote;
  final ILocalAuthDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  // No 4 function pointers. No coupling to Supabase.
  // ...
}
```

`lib/src/infrastructure/di/providers.dart` (CONSOLIDATED):

```dart
// Auth is OPTIONAL in v1 (defer to v1.1). For now, use GoogleAuthDataSource
// (which falls through to Supabase).
final googleAuthServiceProvider = Provider<IGoogleAuthService>((ref) => GoogleAuthService());
final remoteAuthDataSourceProvider = Provider<RemoteAuthDataSource>((ref) {
  return GoogleAuthDataSource(
    ref.watch(googleAuthServiceProvider),
    ref.watch(supabaseClientProvider),
  );
});
final localAuthDataSourceProvider = Provider<ILocalAuthDataSource>((ref) =>
  LocalAuthDataSource(ref.watch(authBoxProvider)));
final authRepositoryProvider = Provider<AuthRepositoryInterface>((ref) =>
  AuthRepositoryImpl(
    ref.watch(remoteAuthDataSourceProvider),
    ref.watch(localAuthDataSourceProvider),
  ));

// auth_providers.dart is DELETED.
```

---

## 10 · The 5-Screen Loop

See `OPERATIONAL_FLOW.md` for the user-facing walkthrough. This section covers the implementation.

### 10.1 Routing

```dart
// app_router.dart
static const String splash = '/';
static const String onboarding = '/onboarding';
static const String login = '/login';
static const String register = '/register';
static const String home = '/home';
static const String checkin = '/checkin';
static const String insight = '/insight';
static const String intervention = '/intervention';
static const String reflect = '/reflect';
static const String heartGraph = '/heart-graph';
static const String history = '/history';
static const String habits = '/habits';
static const String profile = '/profile';
static const String settings = '/settings';

// Removed: assessment, journal, toolkit, analytics
```

### 10.2 Home screen

```dart
class HomeScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    return Scaffold(
      body: state.when(
        loading: () => LoadingIndicator(),
        error: (e, _) => ErrorWidget(message: 'Could not load Home'),
        data: (s) => _HomeBody(state: s),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final HomeState state;  // { Vector4 meter, NafsType dominant, Checkin? lastCheckin, int heartHealthScore, int? priorityAttrId, int? strengthAttrId }
  Widget build(BuildContext context) {
    return ListView(
      children: [
        NafsMeterWidget(meter: state.meter, dominant: state.dominant),
        HeartHealthScoreWidget(score: state.heartHealthScore),
        LastCheckinTimeWidget(checkin: state.lastCheckin),
        CheckInCTA(),  // big button "How is your heart today?"
        SecondaryActionsRow(actions: ['History', 'Heart Graph', 'Settings']),
        if (state.lastCheckin != null) ...[
          GrowthAreaWidget(attributeId: state.priorityAttrId!),
          StrengthWidget(attributeId: state.strengthAttrId!),
        ],
      ],
    );
  }
}
```

### 10.3 Check-in screen

```dart
class CheckinScreen extends ConsumerStatefulWidget {
  // Step 1: Search/typeahead for 50 emotions (grouped by Category).
  // Step 2: Single-select primary emotion, optional secondary.
  // Step 3: Intensity slider 1-10.
  // Step 4: Optional notes (max 500 chars).
  // Step 5: Continue button → call SubmitCheckin → navigate to Insight.
}
```

### 10.4 Insight screen (Heart Analysis)

```dart
class InsightScreen extends ConsumerWidget {
  final SubmitCheckinResult result;
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: 'Heart Analysis'),
      body: ListView(
        children: [
          for (final d in result.detected.take(5)) DetectedAttributeWidget(d),
          GrowthPathStrip(path: ref.watch(growthPathProvider.call(result.detected.first.attributeId))),
          DomainBadgeWidget(domainId: ref.watch(domainForAttribute(result.detected.first.attributeId))),
          ElevatedButton(
            onPressed: () => context.push('/intervention', extra: result),
            child: Text('Show me what to do'),
          ),
        ],
      ),
    );
  }
}
```

### 10.5 Intervention screen (Personal Prescription)

```dart
class InterventionScreen extends ConsumerWidget {
  final SubmitCheckinResult result;
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: 'Personal Prescription'),
      body: ListView(
        children: [
          for (final card in result.cards) InterventionCardWidget(card: card, onDone: () => _markDone(card, result.checkin)),
          ElevatedButton(
            onPressed: () => context.push('/reflect', extra: result),
            child: Text('How did this make you feel?'),
          ),
        ],
      ),
    );
  }
}
```

### 10.6 Reflect screen (User Feedback)

```dart
class ReflectScreen extends ConsumerWidget {
  final SubmitCheckinResult result;
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: 'How do you feel now?'),
      body: Column(
        children: [
          FeedbackButtonWidget(feedback: InterventionFeedback.muchBetter, onTap: () => _save(result, InterventionFeedback.muchBetter)),
          FeedbackButtonWidget(feedback: InterventionFeedback.better, onTap: () => _save(result, InterventionFeedback.better)),
          FeedbackButtonWidget(feedback: InterventionFeedback.same, onTap: () => _save(result, InterventionFeedback.same)),
          FeedbackButtonWidget(feedback: InterventionFeedback.worse, onTap: () => _save(result, InterventionFeedback.worse)),
        ],
      ),
    );
  }
  Future<void> _save(SubmitCheckinResult result, InterventionFeedback f) async {
    await ref.read(recordFeedbackProvider).call(/* recordId */, f);
    if (context.mounted) context.go('/home');  // Back to Home; the meter is already updated.
  }
}
```

### 10.7 Heart Graph screen

```dart
class HeartGraphScreen extends ConsumerWidget {
  // If user has a recent check-in: show the chain starting from its priority attribute.
  // Otherwise: show all 8 master pathways (Ghadab→Sabr→Hilm→Rifq→Rahmah, etc.)
  // Each chain: vertical or horizontal chain of attributes with Quran/Hadith/Dua cards inline.
}
```

### 10.8 History screen

```dart
class HistoryScreen extends ConsumerWidget {
  // 7-day Nafs chart (fl_chart stacked area).
  // Recent check-ins list.
  // Recent interventions list.
}
```

---

## 11 · HeartOS-Specific Widget Library

10 reusable widgets (in `lib/src/presentation/widgets/specific/`):

| Widget | Responsibility |
|---|---|
| `NafsMeterWidget` | The 4-segment arc with dominant highlighted |
| `GrowthPathStrip` | Horizontal chain of attribute chips |
| `InterventionCardWidget` | One card: Quran/Hadith/Dua/Names/Dhikr/Action |
| `DetectedAttributeWidget` | One row: attribute name + Arabic + definition + score |
| `DomainBadgeWidget` | Small chip: "Character" / "Iman" / etc. |
| `HeartHealthScoreWidget` | 0-100 number with color band |
| `CheckInCTAWidget` | Big button "How is your heart today?" |
| `IntensitySliderWidget` | 1-10 slider with haptic feedback |
| `EmotionPickerWidget` | Typeahead for 50 emotions, grouped by Category |
| `FeedbackButtonWidget` | One of 4 large buttons |
| `MasterPathwayCardWidget` | One of 8 master pathways as a card |

---

## 12 · Phase Plan (8 Phases)

### Phase 0.5 — Codebase Cleanup (1-2 days)

**Goal:** Remove 80+ errors, dead code, duplications, `print()`s.

**Tasks:**

1. **Delete the dead test files** (53 errors fixed):
   - `test/domain/entities/emotion_entry_test.dart`
   - `test/domain/entities/journal_entry_test.dart`
   - `test_auth.dart` (root)
2. **Delete the dead infrastructure services** (not in HeartOS v1):
   - `analytics_service.dart`, `crash_reporting_service.dart`, `notification_service.dart`, `background_task_service.dart`, `app_lifecycle_service.dart`
   - `performance_monitor.dart`, `error_monitor.dart`, `metrics_collector.dart`
   - `sync_manager.dart`, `sync_queue.dart`, `conflict_resolver.dart`
3. **Delete the dead screens** (not in HeartOS v1):
   - `assessment/`, `journal/`, `toolkit/`, `analytics/`
4. **Delete the dead use cases / repos / models** (feature removed):
   - `journal_*.dart`, `trait_*.dart`, `nafs_state_model.dart`
5. **Delete the dead `in_memory_cache.dart`** (graph is already in-memory)
6. **Delete `nafs_repository_impl.dart`** (replaced by Nafs engine)
7. **Consolidate the auth providers** (DIP fix):
   - Move `authRepositoryProvider` logic into `providers.dart`
   - Delete `auth_providers.dart`
8. **Add missing imports** (9 errors fixed):
   - `dart:async` to `performance_utils.dart`
   - `dart:ui` and `flutter/widgets.dart` to `performance_utils.dart`
   - `flutter/semantics.dart` to `accessibility_utils.dart`
9. **Replace all `print()` with `Logger.debug/error`** (50+ lints fixed)
10. **Remove unused imports, fields, local variables** (15 warnings fixed)
11. **Fix the `autofillHints` and `isOneOf` errors** in tests
12. **Rename `anonKey` to `publishableKey`**

**Quality gate:** `flutter analyze --no-pub` reports **0 errors, ≤ 5 warnings** (warnings are residual from infrastructure that will be removed in next phases).

---

### Phase 1 — Schema & Seed (Week 1)

**Goal:** 16 tables exist in SQLite, seeded from JSON, queryable.

**Tasks:**

1. Add `drift`, `sqlite3_flutter_libs`, `path` to `pubspec.yaml`.
2. Register `assets/data/*.json` in `pubspec.yaml`.
3. Extract 10 JSON files from `HeartOS/tables/01-10_*.md` into `assets/data/`. Each JSON: `{ "_schema_version", "rows": [...] }`.
4. Define 16 Drift table files in `lib/src/data/datasources/local/tables/`.
5. Define `AppDatabase` with `@DriftDatabase` annotation.
6. Implement `SeedLoader` with idempotent `INSERT OR IGNORE`.
7. Wire `onCreate` to seed.
8. Verify: a fresh install creates a populated DB with the expected row counts.

**Quality gate:** all 16 tables have the expected row count (200/50/10/4/285/218/229/100/200/50 + 0 for runtime tables).

---

### Phase 2 — Entities & Repos (Week 2)

**Goal:** Domain entities, repositories, and Riverpod providers are wired and unit-tested.

**Tasks:**

1. Rewrite the 5 entities per HeartOS spec:
   - `checkin.dart` (replace `emotion_entry.dart`)
   - `heart_attribute.dart` (replace `trait.dart`)
   - `emotion.dart` (new — extracted from emotion entry)
   - `nafs_state.dart` (add `mulhamah`, use `Vector4`)
   - Add 11 new entities: `nafs_history.dart`, `detected_attribute.dart`, `intervention_card.dart`, `intervention_history.dart`, `habit.dart`, `habit_log.dart`, `emotion_attribute_link.dart`, `attribute_link.dart`, `domain.dart`, `domain_link.dart`, `nafs_weights.dart`
2. Add 14 new repository interfaces.
3. Add 14 Drift-backed repository implementations.
4. Add 14 Riverpod providers.
5. Write 14 repository tests (in-memory Drift).
6. Refactor `AuthRepositoryImpl` to use `RemoteAuthDataSource` interface.
7. Consolidate the 2 auth providers into 1.

**Quality gate:** every repository test passes; no `print()` in production; `flutter analyze` → 0 errors.

---

### Phase 3 — Core Engine (Week 2-3)

**Goal:** Pure-Dart Nafs engine + graph traversal is unit-tested and working.

**Tasks:**

1. Implement `Vector4` with `normalised`, `dominant`, `heartHealthScore`.
2. Implement `NafsConstants`.
3. Implement `ComputeDailyNafs` (50/20/20/10 formula).
4. Implement `Meter15Day` (15-day weighted moving average).
5. Implement `Streak` (positive/regression streak detection).
6. Implement `GrowthPath` (BFS the Heart Graph).
7. Implement `DetectAttributes` (resolve emotion → attributes with scores).
8. Implement `Recommend` (build 6 cards).
9. Implement `SubmitCheckin` (orchestrates the full pipeline).
10. Implement `RecordFeedback`.
11. Write 20+ unit tests covering the test cases in `HeartOS/08_algorithms/scoring_algorithm.md` §9.

**Quality gate:** 100% of the test cases pass; 0 errors.

---

### Phase 4 — The 5-Screen Loop (Week 3-4)

**Goal:** Open → Log → Insight → Prescription → Feedback → Home, end-to-end.

**Tasks:**

1. Update `app_router.dart`: 6 new routes (checkin, insight, intervention, reflect, heart-graph, history).
2. Build `HomeScreen` (replace `dashboard_screen.dart`).
3. Build `CheckinScreen` (replace `emotion_logger_screen.dart`).
4. Build `InsightScreen`.
5. Build `InterventionScreen`.
6. Build `ReflectScreen`.
7. Build the 11 HeartOS-specific widgets.
8. Write 8 ViewModels.
9. Write 5 widget tests + 1 integration test for the full loop.

**Quality gate:** integration test `test/integration/full_loop_test.dart` passes; < 3 min wall clock, < 300 ms perceived latency.

---

### Phase 5 — Heart Graph & History (Week 4)

**Goal:** Secondary screens work, the user can browse their progress.

**Tasks:**

1. Build `HeartGraphScreen` (current path + 8 master pathways).
2. Build `HistoryScreen` (7-day Nafs chart + recent check-ins).
3. Write widget tests.

**Quality gate:** widget tests pass.

---

### Phase 6 — Habits, Onboarding, Polish (Week 5)

**Goal:** v1.0 feature-complete, ready for internal testing.

**Tasks:**

1. Build the `HabitsScreen` (CRUD on habits + habit_logs).
2. Build the `OnboardingScreen` (3 cards + optional seed check-in).
3. Polish the `SplashScreen` (route to onboarding or home).
4. Polish the `SettingsScreen` (language, theme, reset, export JSON).
5. Clean up `ProfileScreen` (display streak, heart health score, last check-in).

**Quality gate:** all HeartOS roadmap §1.0 quality gates pass.

---

### Phase 7 — Quality & Release (Week 6)

**Tasks:**

1. Unit tests: ≥ 80% coverage on `lib/src/domain/usecases/`.
2. Integration tests: full loop, no-network, app-cleared-data.
3. Widget tests: each of the 5 core screens.
4. Performance profiling: Nafs meter on Home must read in < 30 ms.
5. Internal dogfood.
6. Build APK and IPA, verify sizes.

**Quality gate:** APK < 50 MB; cold start < 1.5 s.

---

## 13 · Quality Gates

| Gate | Target | Phase |
|---|---|---|
| `flutter analyze --no-pub` | 0 errors, 0 warnings, 0 lints | 7 |
| `flutter test` | 100% pass | 7 |
| `flutter build apk --release` | Succeeds, < 50 MB | 7 |
| Fresh install: 16 tables created | ✅ 16 tables present in SQLite | 1 |
| Seed: row counts match | ✅ 200/50/10/4/285/218/229/100/200/50 | 1 |
| Full loop latency | ✅ < 300 ms perceived, < 3 min wall clock | 4 |
| 15-day meter on Home | ✅ < 30 ms | 3 |
| Recommendation engine latency | ✅ < 20 ms | 3 |
| No network in critical path | ✅ Zero `dio` calls during loop | 4 |
| Cold start | ✅ < 1.5 s on Pixel 5 | 7 |
| Unit test coverage on `lib/src/domain/usecases/` | ✅ ≥ 80% | 7 |
| All `HeartOS/08_algorithms/scoring_algorithm.md` §9 test cases pass | ✅ 4/4 | 3 |
| Audit report gates (per `HeartOS/AUDIT_CODEBASE.md`) | ✅ 0 errors, 0 duplications, 0 SOLID violations | 7 |
| Offline behaviour | ✅ Complete loop works with airplane mode on | 4 |

---

## 14 · Testing Strategy

### 14.1 Unit tests (pure-Dart, no Flutter)

```dart
// test/unit/domain/usecases/nafs/compute_daily_nafs_test.dart
void main() {
  group('ComputeDailyNafs', () {
    late ComputeDailyNafs useCase;
    late MockCheckins mCheckins;
    late MockDetected mDetected;
    late MockHabits mHabits;
    late MockNafsHistory mHistory;
    late MockEmotions mEmotions;
    late MockAttrs mAttrs;

    setUp(() {
      // Wire up mocks
    });

    test('§9.1 first launch: returns NEUTRAL', () async {
      when(() => mCheckins.findForDate(any())).thenAnswer((_) async => []);
      when(() => mDetected.findForDate(any())).thenAnswer((_) async => []);
      when(() => mHabits.activeHabitsCount()).thenAnswer((_) async => 0);

      final v = await useCase(DateTime(2026, 6, 13));
      expect(v.ammarah, closeTo(0.25, 0.01));
    });

    test('§9.2 Anger 7 check-in produces Ammarah-leaning', () async {
      // Per scoring_algorithm.md §9.2
    });

    test('§9.3 Habit-heavy day produces Mulhamah-dominant', () async {
      // Per §9.3
    });

    test('§9.4 Multi-day stability with positive streak', () async {
      // Per §9.4
    });
  });
}
```

### 14.2 Integration tests

```dart
// integration_test/full_loop_test.dart
testWidgets('User can complete the 5-screen loop in < 3 minutes', (tester) async {
  await tester.pumpWidget(NafsMutmainnaApp());
  await tester.pumpAndSettle();

  // Tap "How is your heart today?"
  await tester.tap(find.text('How is your heart today?'));
  await tester.pumpAndSettle();

  // Pick "Anxiety"
  await tester.tap(find.text('Anxiety'));
  await tester.pumpAndSettle();

  // Set intensity 7
  await tester.drag(find.byType(Slider), Offset(100, 0));
  await tester.pumpAndSettle();

  // Continue → Insight
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  expect(find.text('Heart Analysis'), findsOneWidget);
  expect(find.textContaining('Weak Tawakkul'), findsOneWidget);

  // → Intervention
  await tester.tap(find.text('Show me what to do'));
  await tester.pumpAndSettle();
  expect(find.byType(InterventionCardWidget), findsNWidgets(6));

  // → Reflect
  await tester.tap(find.text('How did this make you feel?'));
  await tester.pumpAndSettle();

  // Pick "Better"
  await tester.tap(find.text('Better'));
  await tester.pumpAndSettle();

  // Verify Home with updated meter
  expect(find.byType(NafsMeterWidget), findsOneWidget);
});
```

### 14.3 Widget tests

```dart
testWidgets('NafsMeterWidget renders 4 segments with dominant highlighted', (tester) async {
  // pump with a known Vector4
  // verify that the dominant segment has the saturated color
});

testWidgets('InterventionCardWidget renders Quran verse', (tester) async {
  // pump with a Quran card
  // verify Arabic + English + reference
});
```

---

## 15 · Risks and Mitigations

| Risk | Mitigation |
|---|---|
| **Scope creep** — adding AI, cloud sync, analytics. | Strict adherence to `HeartOS/00_root/roadmap.md` §1. |
| **Drift version churn** — Drift API changes between minors. | Pin to a specific Drift minor version in `pubspec.yaml`. |
| **Nafs algorithm tunability** — the 50/20/20/10 weights are **proposal**. | All weights live in `NafsConstants` (one file) and the seed JSON. v1.1 can A/B test. |
| **Performance** — 50 emotions × 200 attributes could slow typeahead. | In-memory cache for `emotions` (loaded once at first launch). Typeahead filters by `Keywords` (already indexed). |
| **Storage** — the seed JSON is ~145 KB unpacked. | Drift's lazy columns + `gzip` codec. Ship SQLite file directly if needed. |
| **i18n** — v1 is English-only. | Add `flutter_localizations` and empty `app_en.arb` from day 1, even if v1 only ships English. |
| **Content drift** — the 200 attributes are hard-coded in JSON. | Version the JSON (`_schema_version`) and re-seed on upgrade. |
| **Islamic authenticity** — every intervention must be sourced. | All Quran/Hadith/Dua/Names come from the seed xlsx; no AI generation. `HeartOS/AUDIT_REPORT.md` is the gatekeeper. |
| **Auth removal** — v1 has no login flow. | Keep the auth code (login, register, providers) but make the splash route to `/onboarding` (not `/login`). Auth becomes a v1.1 concern. |
| **Per-platform issues** — iOS / Android / Web. | Test on all three. Use `path_provider` for the DB path. |

---

## 16 · Appendices

### Appendix A — File Manifest (final)

See §4 "Zero-Duplication Module Map" for the full file layout.

### Appendix B — Pre-flight Checklist (before starting Phase 1)

- [ ] `flutter analyze --no-pub` reports 0 errors
- [ ] No `print()` in `lib/`
- [ ] No unused imports
- [ ] No duplicated auth providers
- [ ] No `dashboard_screen.dart`, `emotion_logger_screen.dart`, `nafs_repository_impl.dart`, `trait_*.dart`, `journal_*.dart`
- [ ] No `sync_*.dart`, `analytics_*.dart`, `crash_*.dart`, `notification_*.dart`, `background_*.dart`, `performance_*.dart`, `error_*.dart`, `metrics_*.dart`, `app_lifecycle_*.dart`
- [ ] No `in_memory_cache.dart`, `hive_boxes.dart` (multi-box)
- [ ] No `assessment/`, `journal/`, `toolkit/`, `analytics/` directories

### Appendix C — Cross-References

- `HeartOS/OPERATIONAL_FLOW.md` — the day-to-day user flow
- `HeartOS/AUDIT_CODEBASE.md` — the comprehensive audit (this plan's input)
- `HeartOS/AUDIT_REPORT.md` — Islamic content audit (separate concern)
- `HeartOS/00_root/architecture.md` — the 4-layer model
- `HeartOS/00_root/user_flow.md` — the original 5-screen loop
- `HeartOS/00_root/erd.md` — the 14-table ERD
- `HeartOS/00_root/heart_graph.md` — the Heart Graph
- `HeartOS/00_root/scoring_engine.md` — the Nafs meter conceptual walkthrough
- `HeartOS/00_root/roadmap.md` — v1, v1.1, v2 scope
- `HeartOS/03_nafs_engine/nafs_meter_algorithm.md` — the formal Nafs algorithm
- `HeartOS/05_pathways/master_pathways.md` — the 8 master pathways
- `HeartOS/08_algorithms/scoring_algorithm.md` — the full scoring pseudo-code + test cases
- `HeartOS/08_algorithms/recommendation_algorithm.md` — the prescription engine
- `HeartOS/tables/` — the 16 generated table files (schema + seed data)
- `memory-bank/flutter-implementation-plan-comprehensive.md` — the existing CLEAN architecture plan (adopted unchanged)
- `pubspec.yaml` — current dependencies

---

*This plan is the v2.0 definitive guide, updated after the comprehensive audit. It will be re-versioned as the implementation progresses.*
