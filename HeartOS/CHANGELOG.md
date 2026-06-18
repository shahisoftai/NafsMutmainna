# HeartOS Database Changelog

## [2026-06-18] v1.1.14

### Changes
- Updated app version to 1.1.14 across all project files

## [2026-06-16] Onboarding Flash Cards

### New feature
- Added a 7-card swipable onboarding flow shown on first launch only.
- Cards cover: Welcome · Check-in · Heart Analysis · Prescription · Nafs Meter · 15-Day Journey · Heart Graph.
- Each card has a unique gradient + 8-point Islamic-star watermark (drawn via CustomPainter, no asset dep).
- Skip and Get-Started buttons write a `hasSeenOnboarding` flag to a dedicated `prefs` Hive box.
- Splash screen reads the flag and routes to `/onboarding` or `/home` accordingly.

### Files added
- `lib/src/presentation/screens/onboarding/onboarding_screen.dart`
- `lib/src/presentation/screens/onboarding/widgets/onboarding_card.dart`
- `lib/src/presentation/screens/onboarding/widgets/onboarding_data.dart`
- `lib/src/presentation/screens/onboarding/widgets/page_indicator.dart`
- `HeartOS/00_root/onboarding_flash_cards.md` (full design + persistence spec)

### Files modified (minimal, surgical)
- `lib/src/infrastructure/di/providers.dart` — added `prefsBoxProvider` and `hasSeenOnboardingProvider`
- `lib/main.dart` — eagerly opens the `prefs` Hive box at startup
- `lib/src/presentation/navigation/app_router.dart` — added `/onboarding` route
- `lib/src/presentation/screens/splash/splash_screen.dart` — checks the flag after DB init
- `HeartOS/00_root/user_flow.md` §4 — updated first-run flow description
- `HeartOS/INDEX.md` — added the new doc to the table of contents

### Validation
- `dart analyze lib/` reports 0 errors and 0 warnings
- 14 pre-existing info-level issues remain (all in untouched files)
- No existing screen was structurally modified

## [2026-06-15] Database Seeding and Initialization Improvements

### Bug Fixes
- Fixed critical seed data issue where rogue column in `attributes_seed.json` was preventing database initialization
- Added comprehensive seed file validation to prevent similar issues in future
- Implemented robust database re-seeding mechanism for existing installations

### Improvements
- Enhanced database open and migration process to handle edge cases
- Added logging for database initialization and seeding processes
- Improved error handling during seed data insertion

### Validation Steps
- All 14 seed files now validated against their respective schema
- Removed stray columns that could cause database initialization failures
- Implemented safety checks to ensure complete data seeding

### Next Steps
- Conduct thorough testing of database initialization across different app versions
- Consider implementing more granular logging and error reporting
- Review seed data generation process to prevent similar issues