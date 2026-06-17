# Plan: Nafs Meter Redesign (Home + Detail Page)

> **Status**: Draft — pending approval
> **Scope**: Replace the 4-bar Nafs Meter on the Home page with a gradient arc (Option A).
> Add a new detail page that opens when the user taps the meter, showing the original bar meter (Option present), the Journey card (Option B), and the Weekly progress ring (Option C).
> **Constraints**: No duplication, no logic corruption, no errors. New code is purely additive; existing widget stays a public export.

---

## 1. Decisions Locked

| Question | Decision |
|---|---|
| Home page meter scope | Arc only. Trend chip and sparkline are removed from home and move to the detail page. |
| Navigation to detail page | `context.push` via a new `GoRoute` (back-arrow navigation, matches every other detail screen). |
| Chart library | `fl_chart ^0.69.0` (already in `pubspec.yaml`; no new dependencies). |
| Existing `NafsMeterWidget` | **Kept** as a public widget. Reused unchanged on the detail page. |
| Data model | **No changes**. Same `Vector4`, `NafsHistory`, `Meter15Day`, `NafsTrend` — all read-only consumers. |

---

## 2. Files to Add (purely additive)

| New file | Purpose |
|---|---|
| `lib/src/presentation/widgets/specific/nafs_arc_meter.dart` | New home-page arc meter (Option A). Self-contained `StatelessWidget`. |
| `lib/src/presentation/widgets/specific/nafs_journey_card.dart` | Journey card (Option B). One card per dominant station with a 1-line reflection. |
| `lib/src/presentation/widgets/specific/nafs_weekly_ring.dart` | Weekly progress ring (Option C) using `fl_chart`'s `PieChart`. |
| `lib/src/presentation/widgets/specific/nafs_station_reflections.dart` | Pure-data map: dominant station → `{label, reflection, descriptor}`. |
| `lib/src/presentation/screens/nafs_detail/nafs_detail_screen.dart` | New detail page (`Scaffold` + `ListView` of the three visualisations). |

**No deletions, no renames, no signature changes** to anything existing.

---

## 3. Files to Edit (minimal, surgical)

| File | Edit |
|---|---|
| `lib/src/presentation/screens/home/home_screen.dart` | Replace lines 74-81 (the `NafsMeterWidget` call) with a tappable `NafsArcMeter` wrapped in `InkWell` that pushes the new route. Drop `trend` and `sparkline` props (moved to detail page). |
| `lib/src/presentation/navigation/app_router.dart` | Add one new route constant `nafsDetail = '/nafs-detail'`, one `GoRoute` block pointing to `NafsDetailScreen` with the same `null-extra` fallback pattern used by `intervention` and `insight` (defensive — the detail page is parameterless, but a null extra gracefully redirects to `HomeScreen` as a safety net, mirroring the existing pattern). |

That is **2 files touched, 0 logic files touched**. No entity, no repository, no use-case, no DB, no theme file is modified.

---

## 4. New Widget Specs

### 4.1 `NafsArcMeter` (home page, Option A)
- Single `StatelessWidget`, props: `Vector4 vector`, `NafsType dominant`, `VoidCallback? onTap`, `double size = 220`.
- Visual: a 180°-arc custom painter with 4 color bands (Ammarah red → Lawwamah orange → Mulhamah teal → Mutmainnah green) using the existing `AppColors.nafsAmmarah / nafsLawwamah / nafsMutmainna / secondary` palette so the design is consistent.
- Composite-position needle computed as a weighted blend: `pos = 0*Ammarah + 0.25*Lawwamah + 0.5*Mulhamah + 0.75*Mutmainnah` clamped to `[0, 1]`. Renders as a small filled circle on the arc + a soft glowing dot.
- Center label: dominant station name (e.g. "Lawwamah") with a single-line reflection from `nafs_station_reflections.dart`.
- Bottom: an optional small caption "Tap for details".
- Whole card is wrapped in `InkWell` to enable `onTap`; ripple handled by the card background.
- Zero new dependencies.

### 4.2 `NafsJourneyCard` (detail page, Option B)
- Card with a 4-stop journey trail (4 small dot/label pairs: Ammarah → Lawwamah → Mulhamah → Mutmainnah). The current dominant station's dot is filled with its color and slightly larger; the others are muted.
- Beneath the trail: a 1-line reflection for the dominant station + a "current station" label.
- Below: a small history bar — for each of the last 7 days (from existing `state.sparkline`), plot a 4-pixel-tall tick at the day's heart-health-score height. Done via `CustomPainter` to avoid pulling in fl_chart for a 28px chart.
- Props: `Vector4 vector`, `NafsType dominant`, `List<int> sparkline`.

### 4.3 `NafsWeeklyRing` (detail page, Option C)
- `fl_chart` `PieChart` (already in pubspec) with 4 sectors matching the 4 stations; `centerSpaceRadius ≈ 55%` to leave a clean center.
- Center text: dominant station name + heart-health score (large) + a small "+/-" delta if `trend != null && trend != flat`.
- Sector colors: same as the arc for visual continuity.
- Props: `Vector4 vector`, `NafsType dominant`, `NafsTrend? trend`, `int heartHealthScore`.

### 4.4 `NafsDetailScreen` (new page)
- `ConsumerStatefulWidget`, mirrors the pattern of `HistoryScreen` / `InsightScreen`.
- `initState` → reads `homeViewModelProvider` (already loaded) for the current `meter`, `dominant`, `trend`, `sparkline`, `heartHealthScore`. If `hasLoaded` is false, force `load()` (mirrors the `InsightScreen` defensive pattern).
- Layout (top-down in a `ListView`):
  1. **Section: Today** — heading + `NafsArcMeter` (the same one used on home, full-size 280px).
  2. **Section: Detailed breakdown** — heading + existing `NafsMeterWidget` (the original 4-bar meter).
  3. **Section: Your journey** — heading + `NafsJourneyCard`.
  4. **Section: 7-day progress** — heading + `NafsWeeklyRing` + a small `fl_chart` `LineChart` (reuse the same pattern as `HistoryScreen._buildChart` for the 7-day heart-health sparkline) with a soft area fill in the primary color.
- Back arrow in `AppBar` (default `Scaffold` behavior).
- The detail page is a **consumer** of the same `homeViewModelProvider` — no new state, no new providers, no DB calls. Refresh pulls from the existing `HomeViewModel.load()`.

---

## 5. Navigation Wiring

```dart
// app_router.dart — additive only
static const String nafsDetail = '/nafs-detail';

// inside GoRouter.routes:
GoRoute(
  path: nafsDetail,
  name: 'nafsDetail',
  builder: (_, __) => const NafsDetailScreen(),
),
```

`home_screen.dart` — replace lines 74-81 with:

```dart
NafsArcMeter(
  vector: state.meter,
  dominant: state.dominant,
  onTap: () => context.push(AppRouter.nafsDetail),
),
```

Trend and sparkline props are **dropped** from the home call (user confirmed they move to the detail page). The `state.trend` and `state.sparkline` are still computed by the same `HomeViewModel.load()` — zero change to view-model logic.

---

## 6. Risk Analysis

| Risk | Mitigation |
|---|---|
| Touching `home_screen.dart` breaks layout | Edit is line-precise replacement of the existing `NafsMeterWidget(...)` block. The surrounding `SizedBox(height: 14)` spacers stay. |
| `fl_chart` `PieChart` crashes on edge cases (sum=0) | `PieChart` is constructed only with `vector.normalised` (already handles `sum==0` by returning neutral). All 4 sectors always non-zero in practice; defensive `_isEmpty` guard added in the widget. |
| New route breaks deep-link / back-stack | `context.push` is stack-based; back button returns to Home. Matches every other detail screen. |
| Theme/colors drift | All new widgets use existing `AppColors` constants. No new color values introduced. |
| New widgets get duplicated later | All three visualisations live in `widgets/specific/` (existing convention) with a one-line doc comment pointing to the design plan. |
| Tests break | The existing `test/detect_attributes_test.dart` doesn't touch these widgets. New widgets are pure presentation; we add minimal golden-free smoke checks for `NafsArcMeter` to lock the composite-position math (1 test file, 3 cases). |

---

## 7. Verification Plan

1. `flutter analyze` → must be **0 new issues** (existing 14 pre-existing info-level warnings stay the same).
2. `flutter test` → existing 8 tests pass + 3 new arc-meter math tests pass = **11/11 green**.
3. Manual: `flutter run -d 192.168.1.7:40927` and confirm:
   - Home shows the new arc (no trend chip, no sparkline).
   - Tap the arc → detail page opens.
   - Detail page shows all 4 sections (arc, bars, journey, ring) and the line chart.
   - Back arrow returns to Home.
   - No frame drops / no error overlay.

---

## 8. Out of Scope (Explicit)

- No change to `Vector4`, `NafsHistory`, `NafsType`, `Meter15Day`, `HomeViewModel`, `NafsTrend`.
- No change to DB schema, seed data, or migrations.
- No change to Insight/Reflect/Intervention flows.
- No i18n / RTL handling changes.
- No new dependencies.
- No light-mode vs dark-mode split (existing app uses one palette; we follow that).
