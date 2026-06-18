# Onboarding Flash Cards — Implementation Reference

**Date:** 2026-06-16  
**Version:** v1.1.14  
**Status:** Implemented, ready for device testing

---

## Summary
Added a 7-card swipable onboarding flow shown on first launch. The flow covers the core value loop (Check-in → Analysis → Prescription) and the key features (Nafs Meter, 15-Day Journey, Heart Graph), plus a privacy/trust card at the start.

---

## Files Created (4 new + 1 doc)

| File | Purpose | Lines |
|---|---|---|
| `lib/src/presentation/screens/onboarding/widgets/onboarding_data.dart` | Card data model + 7-card content list | ~100 |
| `lib/src/presentation/screens/onboarding/widgets/onboarding_card.dart` | Full-screen gradient card widget with Islamic-star CustomPainter | ~190 |
| `lib/src/presentation/screens/onboarding/widgets/page_indicator.dart` | Animated dot indicator (8px → 28px pill) | ~50 |
| `lib/src/presentation/screens/onboarding/onboarding_screen.dart` | PageView host with Skip/Next/Get Started buttons | ~170 |
| `HeartOS/00_root/onboarding_flash_cards.md` | Full design + persistence spec | ~200 |

## Files Modified (4, minimal/surgical)

| File | Change | Impact |
|---|---|---|
| `lib/src/infrastructure/di/providers.dart` | Added `kPrefsBoxName`, `kOnboardingSeenKey`, `prefsBoxProvider`, `hasSeenOnboardingProvider` | +20 lines, append-only |
| `lib/main.dart` | Eagerly opens the `prefs` Hive box | +2 lines |
| `lib/src/presentation/navigation/app_router.dart` | Added `AppRouter.onboarding` constant + one `GoRoute` | +3 lines |
| `lib/src/presentation/screens/splash/splash_screen.dart` | Replaced `context.go('/home')` with a check against `hasSeenOnboardingProvider` | ~10 lines changed |

**Zero existing screens were structurally modified** — only one-line or append-only additions.

## The 7 Cards

1. **Welcome to HeartOS** — privacy-first, offline, no account
2. **Check In With Your Heart** — 3-step check-in (emotion → intensity → note), <60 sec
3. **See What Your Heart Reveals** — 3–5 attributes detected, growth path
4. **A Prescription Just for You** — 6 intervention types
5. **Your Nafs Meter** — 4 stations of the soul
6. **Your 15-Day Journey** — trend, Allah Names patterns
7. **The 8 Master Pathways** — every struggle has a path

## Visual Design
- Each card has a unique 3-stop vertical gradient
- Primary icon in a 140×140 glass circle with drop shadow
- 8-point Islamic star watermark (CustomPainter, no asset dep)
- Top-left: step counter; top-right: small accent icon
- Bottom: animated dot indicator + Next/Get Started button
- Top-right: Skip button on every card

## State Machine
```
Splash → hasSeenOnboarding? → false: /onboarding → true: /home
```

The flag is stored in a dedicated `prefs` Hive box (separate from the `auth` box), opened eagerly in `main()` to avoid splash jank.

## Verification
- `dart analyze lib/` → 0 errors, 0 warnings (14 pre-existing info-level issues remain, all in untouched files)
- No existing files were structurally changed
- Onboarding is fully self-contained in its own directory

## How to Test
1. `flutter clean && flutter pub get`
2. `flutter run -d "SM A305F"`
3. First launch should show the 7 cards
4. Tap Get Started (or Skip) → routes to home
5. Re-launch the app → goes straight to home (skips onboarding)
6. To re-trigger: uninstall + reinstall, or `adb shell pm clear com.nafsmutmainna.nafsmutmainna`

## What Was NOT Changed
- No database schema or seed data changes
- No existing screens structurally modified
- No new dependencies added (uses existing Hive + flutter_riverpod)
- No breaking changes to navigation flow
- All 14 pre-existing info-level warnings unchanged (deprecated_member_use, unnecessary_underscores)

## See Also
- `HeartOS/00_root/onboarding_flash_cards.md` — full design + persistence spec
- `HeartOS/00_root/user_flow.md` §4 — user-facing first-run description
- `HeartOS/CHANGELOG.md` — v1.1.14 entry
- `HeartOS/INDEX.md` — table of contents (now 53 markdown files)
- `memory-bank/ONBOARDING-FLASH-CARDS-PLAN.md` — original plan
