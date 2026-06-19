# Onboarding Flash Cards

> First-run UX that introduces the user to HeartOS in 8 swipable cards.
> v2.0 restructured with spiritual concept first (Cards 1-2) then app features (Cards 3-8).
> Implemented in v1.1.14 on 2026-06-18.

This document is the **implementation reference** for the onboarding flow. For the user's perspective on the same feature see [`00_root/user_flow.md` §4 First-run experience](user_flow.md#4--first-run-experience).

---

## 1 · Purpose

The onboarding flow is shown **once** — on the first cold start of a fresh install (or after a data reset). It exists to:

- Build **trust** before asking the user to do anything (privacy posture).
- Teach the **core 60-second interaction** (the check-in).
- Show the user the **value loop**: check-in → analysis → prescription → tracking.
- Set expectations for the **Nafs framework** without overwhelming.

The flow is **non-blocking**: a Skip button on every card and a Get-Started button on the last card both close the flow and write the `hasSeenOnboarding = true` flag. The user is then routed to Home.

---

## 2 · The 8 cards

| # | Headline | Core message |
|---|----------|-------------|
| 1 | The Battle Within | Spiritual concept: Nafs-e-Ammara, negative traits, Shaytan's gateway |
| 2 | Nafs Mutmainna Awaits | Quran 89:27-30 · the destination: soul at peace, beloved to Allah |
| 3 | Check In With Your Heart | 3-step daily check-in (emotion → intensity → note) under 60 seconds |
| 4 | See What Your Heart Reveals | 3–5 heart attributes detected per check-in · growth path through the Nafs |
| 5 | Track Your Soul's Progress | 4 stations of the soul · daily check-in moves the needle |
| 6 | A Prescription Just for You | 6 intervention types (Quran · Hadith · Dua · Allah Names · Dhikr · Action) |
| 7 | Watch Your Transformation Unfold | Trend chart · Allah Names patterns · day-by-day breakdown |
| 8 | Every Struggle Has a Map | Every struggle has a mapped path · example: Ghadab → Sabr → Hilm → Rifq → Rahmah |

**Why this order:** Cards 1–2 set the **spiritual foundation** (Nafs journey). Cards 3–6 are the **core value loop** (check-in → analysis → tracking → prescription). Cards 7–8 show depth and long-term benefits.

---

## 3 · Visual design

Each card is a full-screen vertical gradient, unique per card to keep the flow visually varied without straying from the app's calm aesthetic.

| Card | Gradient (3-stop) | Icon | Accent |
|---|---|---|---|
| 1 | `1A1A2E` → `16213E` → `0F3460` (deep indigo/purple) | `shield_outlined` | `whatshot_outlined` |
| 2 | `0D3D12` → `1B5E20` → `D4AF37` (deep green → gold) | `mosque_outlined` | `auto_awesome_outlined` |
| 3 | `1B5E20` → `388E3C` → `66BB6A` (mid greens) | `edit_note_rounded` | `timer_outlined` |
| 4 | `004D40` → `00695C` → `26A69A` (teals) | `insights_rounded` | `psychology_outlined` |
| 5 | `E53935` → `FB8C00` → `43A047` (red → gold → green — the Nafs spectrum) | `speed_rounded` | `show_chart_rounded` |
| 6 | `FF8F00` → `FFB300` → `FFCA28` (gold) | `medical_services_outlined` | `medication_outlined` |
| 7 | `1565C0` → `1976D2` → `42A5F5` (blues) | `timeline_rounded` | `calendar_today_outlined` |
| 8 | `4A148C` → `6A1B9A` → `8E24AA` (purples) | `account_tree_outlined` | `explore_outlined` |

**Card anatomy (top → bottom):**
1. Step counter (e.g. "Step 3 of 8") — top-left
2. Accent icon in a soft glass circle — top-right
3. Primary icon in a 140×140 glass circle with drop shadow — centre
4. Headline — 28pt, FontWeight.w800, white
5. Body — 15pt, 1.55 line-height, white at 92% opacity
6. Decorative 8-point Islamic star (CustomPainter, no asset dep) — bottom-right, 10% opacity watermark

**Page indicator:** animated dot bar at the bottom. The active dot is 28px wide (rounded pill), the inactive dots are 8px circles. Width/colour transitions use `Curves.easeOutCubic` over 320ms.

---

## 4 · State machine

```
SplashScreen  ──(db ready)──>  hasSeenOnboarding?
                                    │
                    ┌───────────────┴───────────────┐
                    │ false                          │ true
                    ▼                                ▼
             OnboardingScreen                     Home
                    │
              ┌─────┴──────┐
              │            │
           Skip     Get Started (last card)
              │            │
              └─────┬──────┘
                    ▼
              write hasSeenOnboarding = '1'
                    │
                    ▼
                  Home
```

The flag is stored in a dedicated `prefs` Hive box (see §5).

---

## 5 · Persistence

The "has seen onboarding" flag is stored in a dedicated Hive box, **separate from the `auth` box**, to keep concerns cleanly separated.

| Item | Value |
|---|---|
| Hive box name | `prefs` |
| Box type | `Box<String>` |
| Key | `hasSeenOnboarding` |
| Stored value | `'1'` (present) or absent (never seen) |

The box is **eagerly opened in `main()`** so the first `hasSeenOnboarding` check is instant — no async jank on the splash screen.

Defined in `lib/src/infrastructure/di/providers.dart`:

```dart
const String kPrefsBoxName = 'prefs';
const String kOnboardingSeenKey = 'hasSeenOnboarding';

final prefsBoxProvider = FutureProvider<Box<String>>((ref) async {
  if (Hive.isBoxOpen(kPrefsBoxName)) {
    return Hive.box<String>(kPrefsBoxName);
  }
  return Hive.openBox<String>(kPrefsBoxName);
});

final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final box = await ref.watch(prefsBoxProvider.future);
  return box.get(kOnboardingSeenKey) == '1';
});
```

---

## 6 · Implementation

| Layer | File | Purpose |
|---|---|---|
| Route | `lib/src/presentation/navigation/app_router.dart` | `AppRouter.onboarding = '/onboarding'` |
| Screen | `lib/src/presentation/screens/onboarding/onboarding_screen.dart` | `PageView` host + Skip / Next / Get Started buttons |
| Card UI | `lib/src/presentation/screens/onboarding/widgets/onboarding_card.dart` | Full-screen gradient card with icon, headline, body, Islamic star watermark |
| Card data | `lib/src/presentation/screens/onboarding/widgets/onboarding_data.dart` | `OnboardingCardData` model + 8-card content list |
| Indicator | `lib/src/presentation/screens/onboarding/widgets/page_indicator.dart` | Animated dot indicator |
| Splash gate | `lib/src/presentation/screens/splash/splash_screen.dart` | Reads `hasSeenOnboardingProvider` after DB init, routes accordingly |
| Boot wiring | `lib/main.dart` | Eagerly opens `prefs` Hive box |
| DI | `lib/src/infrastructure/di/providers.dart` | `prefsBoxProvider`, `hasSeenOnboardingProvider`, `kPrefsBoxName`, `kOnboardingSeenKey` |

No existing screen was structurally modified. Only minimal one-line additions:
- `splash_screen.dart`: replaced `context.go('/home')` with a check against `hasSeenOnboardingProvider`.
- `app_router.dart`: added one `GoRoute` for `/onboarding`.
- `main.dart`: added one `await Hive.openBox<String>(di.kPrefsBoxName)`.
- `providers.dart`: added the three new declarations at the end of the file.

---

## 7 · UX guardrails

- **No data lost if the flag write fails.** The `put` call is wrapped in a try/catch; on failure the user simply sees onboarding again on the next launch.
- **No jank on splash.** The `prefs` box is opened in `main()` (eagerly), not in the splash screen (lazily). The first `hasSeenOnboardingProvider.future` resolves synchronously.
- **No infinite loop.** If `hasSeenOnboardingProvider` throws (e.g. corrupted Hive), the splash screen falls back to `/home` so the user is never stranded.
- **The cards are not modal blockers of the auth path.** If the user backs out of onboarding (Android back gesture) they're still routed to Home — the `Get Started` / `Skip` handler is the only writer of the flag, and the system back button simply does nothing destructive.

---

## 8 · Reset for testing

The onboarding flag persists across `flutter clean` (Hive is on-device storage, not part of the build). To re-trigger onboarding during testing:

| Method | Effect |
|---|---|
| Uninstall + reinstall | Wipes all data including the flag |
| `flutter run --uninstall` (newer Flutter) | Same |
| `adb shell pm clear com.nafsmutmainna.nafsmutmainna` | Wipes app data only, keeps the install |
| Manually delete the prefs box | `await Hive.deleteBoxFromDisk('prefs')` from a one-off script |

---

## 9 · Future work

| Idea | Notes |
|---|---|
| Show "What's new" cards on app updates | Reuse the same `PageView` + card machinery with a different content list |
| Skip the splash check on already-onboarded users | Currently the splash always runs (DB init). Could short-circuit if `hasSeenOnboarding && !dbUpgradeNeeded` |
| Localize the card text | Card content lives in a const `List<OnboardingCardData>`; swap with a localised variant for v1.1+ |
| Animate the icon in (e.g. scale from 0.8 → 1.0) | Currently a static container; a subtle `AnimatedScale` would add polish |

---

## 10 · See also

- [`00_root/user_flow.md` §4](user_flow.md#4--first-run-experience) — the user-facing first-run description
- [`00_root/architecture.md`](architecture.md) — the four-layer model
- [`HeartOS/CHANGELOG.md`](../CHANGELOG.md) — version history
- `lib/src/presentation/screens/onboarding/` — implementation source
- `lib/src/presentation/screens/splash/splash_screen.dart` — splash → onboarding gate

---

*Implemented 2026-06-18 · v1.1.14 · 8 cards · restructured 2026-06-19 · 0 existing files structurally changed.*
