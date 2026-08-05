# HeartOS Production Release Notes

## Concept

HeartOS is a privacy-first spiritual self-improvement app based on Islamic principles of soul purification (Tazkiyah). It tracks emotional states, guides spiritual growth through the concept of "Nafs" (soul states), and provides personalized Quranic interventions for soul healing.

## Key Features

### Core Functionality
- **Daily Check-In**: Log emotions with intensity (1-10) and notes, deriving affected spiritual attributes
- **Nafs Meter**: 15-day visual arc tracking spiritual progression through 4 Nafs levels (Ammarah → Lawwamah → Mulhamah → Mutmainnah)
- **Heart Graph**: Relational map linking 50 emotions to 200+ attributes showing growth paths
- **Spiritual Interventions**: Quran verses, Hadith, Dua, and Allah Names as personalized treatments

### Tracking & Analysis
- **Habit Tracking**: Prayer, Quran, Dhikr, Charity, Exercise with daily logging
- **Heart History**: Charts and pattern analysis of emotional/spiritual data
- **Domain Analysis**: 10 life domains for holistic perspective

### Technical
- **Privacy-First**: 100% offline with local SQLite + Hive storage
- **Optional Cloud Sync**: Supabase integration with Google Sign-In
- **Security**: Biometric/PIN lock via flutter_secure_storage + local_auth

## Version History

### 1.1.16+12 — 2026-08-05

**Check-In UX Overhaul** ("How Do You Feel?" screen)
- Replaced `InteractiveViewer` pinch-to-zoom with A− / A+ font-size buttons (1.0–1.6x scale), scoped to the emotion picker
- Intensity slider: descriptive labels (Mild / Moderate / Strong / Severe) + emoji indicators (😌 / 😟 / 😰)
- Emotion search: added "No results" empty state with helpful hint about translating by feeling
- Notes field: added hint + helper text guiding the user to reflect on triggers
- Continue button: explanatory hint when disabled, distinct disabled background colour
- Added "Step 1 of 2" progress indicator + 50% linear progress bar at the top
- Category sections: stronger background alpha (0.06 → 0.10) + border + darker header for WCAG-friendly contrast
- Bilingual chip line: bumped font 11→12, wrapped in `Flexible` + ellipsis to prevent overflow on small screens

### 1.1.15+11 — 2026-08-04

**Nafs Scoring Engine**
- Full-spectrum ladder `heartHealthScore` using all 4 Nafs stations (Ammarah=0 → Mutmainnah=3) with weighted average, neutral baseline scores 50/100
- Canonical score unified across all views: Home meter, Journey screen, Trend chart, Daily Dhikr resolver, and NafsDetail ring
- `Vector4.average()` static helper eliminates duplication across aggregate calculations
- Weekly Nafs use case extracted to `compute_daily_nafs.dart` (SRP); `WeeklyNafs` returns 7-day average for the ring and trend meter

**15-Day Meter (gap-safe)**
- Date-based weighting: most recent days score highest; gracefully handles gaps with min 0.2 floor
- Index-based iteration avoids duplicate-row counting bugs from `rows.indexOf`
- Requires ≥14 rows for direction comparison; still renders daily scores when fewer rows exist

**Dhikr Counter**
- Default target raised to 101/day
- Full rewrite: 200×200 progress ring (CircularProgressIndicator), current/target caption inside circle, "N left today" / "Done — mashaAllah" remaining line, green check badge on completion, tap-capped at target
- Trend chart and history list now decoupled — sparse history never hides the trend chart

**Rate This App**
- Moved to top of Settings under "Enjoying HeartOS?" section
- Full SOLID separation: `StoreRatingService` interface (domain) + `PlatformStoreRatingService` (data) + `storeRatingServiceProvider` (DI) + `RateThisAppTile` (presentation)
- Platform-aware routing: Android → Play Store, iOS → App Store, other → website

**Bug Fixes**
- Calendar-bucket averaging: ≥14-row guard, present-count division, ≥5/7 day minimum per week
- `ComputeDailyNafs` now replaces the synthetic today-row placeholder with real data on first load
- Journey screen's `day.positiveScore` uses the canonical ladder score; percentage suffix now accurate

### 1.1.14+9 — Previous Release
