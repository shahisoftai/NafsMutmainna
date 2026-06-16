# HeartOS Home Page — Enhancement Plan

**App:** NafsMutmainna / HeartOS — Islamic Nafs (self) training guide and tool
**Scope:** Home page only (no other screens touched)
**Status:** ✅ **Implementation complete** (June 14, 2026)
**Positioning:** HeartOS is **purely a Nafs training guide and tool** — not a generic content app. Every element on the home page should serve the user's journey along the 4 Nafs stations (Ammarah → Lawwamah → Mulhamah → Mutmainnah).

---

## 1. Current State Audit

### What's on the home page today (`home_screen.dart`)

1. AppBar: "HeartOS" title + 3 icons (Heart Graph, History, Settings)
2. `Salam` greeting
3. `How is your heart today?` subheading
4. `NafsMeterWidget` — 4-segment bar (Ammarah / Lawwamah / Mulhamah / Mutmainnah)
5. `HeartHealthScoreWidget` — 0-100 score with label and description
6. Last checkin row (date + time)
7. Positive streak row (fire icon + day count)
8. `CheckInCTAWidget` — big primary button with same copy as subheading
9. Two secondary icon buttons (Heart Graph / History) — duplicates the app bar

### Data already in the system but NOT surfaced on home

| Data | Source | Why it's wasted |
|---|---|---|
| `Habit` + `HabitLog` (Prayer, Quran, Dhikr, Charity, Exercise, Other) | `habitRepository` | No widget on home — habits are the *daily training reps* of Nafs work |
| `Emotion.recommendedDhikr` + `Emotion.recommendedAllahNames` (50 emotions) | `emotionRepository` | No aggregation of "what Allah has been guiding you to" |
| 15-day historical checkins | `checkinRepository.findBetween()` | No "last 15 days" reflection anywhere — and reflection is core to Nafs training |
| Yesterday's Nafs vector (for trend) | `nafsHistoryRepository.findForDate(yesterday)` | No ▲/▼ on the Nafs meter — the user can't see if they're moving toward Mutmainnah |
| `intl` package with `islamic-umalqura` Hijri support | `pubspec.yaml` | No Hijri date in the greeting — breaks the Islamic temporal frame |
| 200 `HeartAttribute` records with Quran/Hadith/Dua | `attributeRepository.getAll()` | Available but **intentionally not surfaced** — HeartOS is not a verse-of-the-day app; it's a Nafs training tool |

### Key UX problems

1. **The phrase "How is your heart today?" appears TWICE** (subheading + button) — confusing
2. **The bottom icon row is dead weight** — duplicates the app bar icons
3. **No reason to open the app on non-check-in days** — home is a metrics dashboard, not a training companion
4. **No daily prescription** — the user logs an emotion, gets one intervention, and the home shows no follow-up
5. **Generic greeting** — no time-of-day, no name, no Hijri date
6. **No pattern recognition** — user has no way to see "Allah has been guiding me to Ya Samee' this week"
7. **The Nafs framework is the app's IP** but the home doesn't teach it or guide the user along it
8. **Hardcoded default `Vector4(0.10, 0.60, 0.20, 0.10)`** shows "Lawwamah 60%" to brand-new users with no context

---

## 2. Target User Experience (After Plan)

A user opens the app. The home page feels like a *wise, gentle Nafs training companion* — not a dashboard. It:

- Greets them by name and time (Islamic temporal frame: Arabic greeting + Hijri date)
- Surfaces **today's dhikr prescription** calibrated to their current Nafs state
- Shows which **Allah Names have been guiding them** over the last 15 days (pattern recognition — core to Nafs work)
- Displays their **Nafs meter with trend** so they can see if they're moving toward Mutmainnah
- Offers a **contextual next action** tailored to where they are on the 4-station journey
- Anchors **daily training reps** (habits) as the engine of movement between stations

---

## 3. New Home Page Layout (Wireframe)

```
┌─────────────────────────────────────────────┐
│  HeartOS                       🌳  📜  ⚙   │   AppBar (unchanged)
├─────────────────────────────────────────────┤
│  السلام عليكم, Ahmad                        │   A. Greeting (time-aware)
│  Good evening · 14 Rajab 1447 AH            │      + Hijri + name
│                                              │
│  ┌──────────────────────────────────────┐  │
│  │  ✅  Today's anchors                 │  │   C. Habits strip
│  │  [Fajr ✓] [Quran ✓] [Dhikr ○]        │  │      (user-created)
│  │  [Walk ○]   2/4 done                 │  │      = daily training reps
│  └──────────────────────────────────────┘  │
│                                              │
│  ┌──────────────────────────────────────┐  │
│  │  🌙  Your Daily Dhikr                │  │   E. NEW: Daily Dhikr section
│  │  ┌─ TODAY'S PRACTICE ──────────────┐ │  │      (hero + 15-day history)
│  │  │  سُبْحَانَ اللَّهِ وَبِحَمْدِهِ   │ │  │      = Nafs-calibrated
│  │  │  SubhanAllahi wa bihamdihi       │ │  │        prescription
│  │  │  For Mutmainnah       [Count]   │ │  │
│  │  └──────────────────────────────────┘ │  │
│  │  From your last 15 days              │  │
│  │  ┌──────┐ ┌──────┐ ┌──────┐         │  │
│  │  │ يَا  │ │ يَا  │ │ يَا  │         │  │
│  │  │ رَبِّ │ │سَمِيعُ│ │ هُوَ │         │  │
│  │  │  4×  │ │  3×  │ │  2×  │         │  │
│  │  └──────┘ └──────┘ └──────┘         │  │
│  │  See full 15-day journey →           │  │
│  └──────────────────────────────────────┘  │
│                                              │
│  Nafs Meter                          ▲ +3%  │   F. Nafs Meter + trend
│  [Ammarah  ][Lawwamah   ][Mulhamah  ]        │      = the core training
│  [Mutmainnah ] ← dominant: Lawwamah         │        indicator
│  ▁▃▅▆▇▆▅  (7-day sparkline)                 │
│                                              │
│  ┌──────────────────────────────────────┐  │
│  │  ♥ 67  Strong          ▲ +4 (7d)    │  │   G. Heart Health + tip + trend
│  │  Mulhamah — walking the path         │  │      = outcome metric
│  │  "Try a 5-min Quran reflection"      │  │
│  └──────────────────────────────────────┘  │
│                                              │
│  ┌──────────────────────────────────────┐  │
│  │  🕊  It's been 2 days.              │  │   D. Contextual Next Action
│  │  Take a moment to check in.          │  │      = Nafs-aware
│  │                            Begin →  │  │        prescription
│  └──────────────────────────────────────┘  │
│                                              │
│  🔥 7-day positive streak                    │   Streak (kept)
│  Last check-in: 2h ago                       │   Last checkin (kept)
│                                              │
│  [   Begin check-in   ]                       │   H. CTA (renamed, no
│                                              │      redundancy)
│                                              │
│  (REMOVED: duplicate Heart Graph /           │
│   History button row)                        │
└─────────────────────────────────────────────┘
```

**Note on what's NOT on the home (intentional):**
- **No "verse of the day" / hadith-of-the-day card** — HeartOS is a Nafs training tool, not a content app. Verses appear as *interventions* (prescribed based on detected Nafs state) on the intervention screen, not as a daily rotation on home.
- **No prayer-time banner** — prayer is a habit, surfaced via the Habits strip.
- **No emotion frequency chart on home** — belongs in History/Analytics screens.

---

## 4. Per-Widget Detailed Plans

### A. Personalized Time-Aware Greeting with Hijri Date

**Files**
- `lib/src/presentation/screens/home/widgets/home_greeting_widget.dart` (new)
- `lib/src/presentation/screens/home/utils/greeting_helper.dart` (new) — pure functions for time-of-day and Hijri date formatting
- `lib/src/presentation/screens/home/widgets/empty_state_widget.dart` (new, reused) — generic empty state

**Pure helpers (unit-testable)**
```dart
String timeOfDayGreeting(DateTime now) {
  if (now.hour < 5)  return 'Good night';
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  if (now.hour < 21) return 'Good evening';
  return 'Good night';
}

String hijriDate(DateTime d) =>
    DateFormat('d MMMM yyyy AH', 'en').format(
      HijriDates.fromGregorian(d),  // intl islamic-umalqura
    );
```

**Widget contract**
- Props: `displayName: String?`, `now: DateTime`
- Renders:
  - Arabic: `السلام عليكم, $name` (falls back to `السلام عليكم` if name is null)
  - English: `${timeOfDayGreeting(now)} · ${hijriDate(now)}`
- Edge cases: first launch (no name) → render Arabic only + a small "Add your name" subtle inline link that opens settings

**Testing**
- Unit: `timeOfDayGreeting` for hours 0, 5, 12, 17, 21, 23
- Unit: `hijriDate` for known Gregorian → Hijri reference dates
- Widget: renders correctly with and without name

---

### C. Today's Habits Strip (User-Created, with Empty State)

**Files**
- `lib/src/presentation/screens/home/widgets/today_habits_strip.dart` (new)
- `lib/src/presentation/screens/home/widgets/habit_pill.dart` (new) — single pill
- `lib/src/presentation/viewmodels/home_habits_view_model.dart` (new, separate from main home view model)
- `lib/src/presentation/screens/home/widgets/empty_state_widget.dart` (new, reused)

**Rationale for separate view model**
- Toggling a habit should NOT rebuild the whole dashboard
- Habits can update independently of the Nafs vector

**Why habits are central to Nafs training**
- The classical Nafs framework holds that movement between stations comes from *consistent, small acts* (mujahadah) — not one-off check-ins
- Prayer, Quran, Dhikr, charity, exercise — all are the *training reps* that move you from Ammarah toward Mutmainnah
- The home page must make these the most visible, tappable thing

**Data shape**
```dart
class HabitWithStatus {
  final Habit habit;
  final bool completedToday;
  final IconData icon;       // derived from category
  final Color color;         // derived from category
}

class HomeHabitsState {
  final List<HabitWithStatus> habits;
  final bool isLoading;
  final int doneCount;
  final int totalCount;
}
```

**View model behavior**
- `load()`: `habitRepository.allHabits()` + `habitRepository.logsBetween(today, today)` → merge
- `toggle(HabitWithStatus h)`: optimistic update + `habitRepository.logHabit(HabitLog(date: today, habitId: h.habit.id, completed: !h.completedToday))`
- On error: revert + show snackbar

**Category → icon/color mapping**
| Category   | Icon              | Color                |
|------------|-------------------|----------------------|
| Prayer     | Icons.mosque      | AppColors.primary    |
| Quran      | Icons.menu_book   | AppColors.nafsMutmainna |
| Dhikr      | Icons.spa         | AppColors.secondary  |
| Charity    | Icons.volunteer_activism | AppColors.accent |
| Exercise   | Icons.directions_run | AppColors.primaryLight |
| Other      | Icons.task_alt    | AppColors.textSecondary |

**Widget contract — strip**
- Props: `state: HomeHabitsState`, `onToggle: (HabitWithStatus) => void`, `onSeeAll: VoidCallback`
- Renders:
  - Header: "Today's anchors" + "X/Y done"
  - Horizontal scrollable row of `HabitPill`s
  - "Manage habits" link → habits screen
- Empty state (no habits): render `EmptyStateWidget` with copy "Add your first training anchor" + CTA → habits screen

**Widget contract — pill**
- Props: `habit: HabitWithStatus`, `onTap: VoidCallback`
- Renders: rounded card with icon, name, ✓/○ indicator, subtle category color

**Tap behavior**
- Tapping pill → toggle today's log
- Long-press pill → bottom sheet "Edit habit" / "Delete habit" (optional, defer to Tier 3)

**Testing**
- Unit: view model `toggle` calls `logHabit` with correct args
- Unit: view model `load` merges habits + logs correctly (handles missing logs)
- Widget: empty state shows when `habits.isEmpty`
- Widget: pill toggles visually on tap

---

### D. Contextual Next Action Card (Nafs-Aware)

**Files**
- `lib/src/presentation/screens/home/widgets/next_action_card.dart` (new)
- `lib/src/presentation/screens/home/utils/next_action_resolver.dart` (new) — pure function, easy to test

**Data shape**
```dart
enum NextActionKind { checkin, intervention, habits, reflect }

class NextAction {
  final String emoji;        // '🕊' | '📿' | '✅' | '💭'
  final String title;        // 'Take a moment to check in'
  final String subtitle;     // 'It's been 2 days since your last one'
  final NextActionKind kind;
  final String? deepLink;    // route name to push
}
```

**Pure resolver (rules, in priority order — Nafs-aware)**
```dart
NextAction resolveNextAction({
  required NafsType dominant,
  required DateTime? lastCheckin,
  required int positiveStreak,
  required HabitWithStatusCount habits,
  required DateTime now,
}) {
  // 1. No check-in today AND dominant is Ammarah → Istighfar break
  //    (Ammarah = heedlessness; need to be called back)
  if (lastCheckin == null || _daysSince(lastCheckin, now) >= 1) {
    if (dominant == NafsType.ammarah) {
      return NextAction(
        emoji: '📿',
        title: 'A moment of stillness',
        subtitle: 'Try a 2-minute Istighfar break',
        kind: NextActionKind.intervention,
        deepLink: AppRouter.intervention,
      );
    }
  }
  // 2. No check-in in > 24h
  if (lastCheckin == null || _daysSince(lastCheckin, now) >= 1) {
    return NextAction(
      emoji: '🕊',
      title: "It's been a while",
      subtitle: 'How is your heart now?',
      kind: NextActionKind.checkin,
      deepLink: AppRouter.checkin,
    );
  }
  // 3. Streak ≥ 7 → reflect (consolidate the gains)
  if (positiveStreak >= 7) {
    return NextAction(
      emoji: '💭',
      title: '$positiveStreak-day streak',
      subtitle: 'Reflect on what is working',
      kind: NextActionKind.reflect,
      deepLink: AppRouter.history,
    );
  }
  // 4. Habits < 50% done and after midday → anchor the day
  if (habits.totalCount > 0 && habits.doneCount / habits.totalCount < 0.5 && now.hour >= 12) {
    return NextAction(
      emoji: '✅',
      title: 'Anchor your day',
      subtitle: '${habits.doneCount}/${habits.totalCount} habits complete',
      kind: NextActionKind.habits,
      deepLink: AppRouter.habits,
    );
  }
  // 5. Default
  return NextAction(
    emoji: '🕊',
    title: 'Begin check-in',
    subtitle: 'A few breaths, a moment of honesty',
    kind: NextActionKind.checkin,
    deepLink: AppRouter.checkin,
  );
}
```

**Widget contract**
- Props: `action: NextAction`, `onTap: VoidCallback`
- Renders: card with emoji, title, subtitle, "Begin →" CTA
- Tap → navigates to `action.deepLink`

**Testing**
- Unit: each rule fires for its precondition
- Unit: priority order is respected (Ammarah+stale beats stale)
- Unit: default fires when no rule matches

---

### E. Your Daily Dhikr Section (NEW — Highest-Impact Addition)

**Files**
- `lib/src/presentation/screens/home/widgets/daily_dhikr_section.dart` (new)
- `lib/src/presentation/screens/home/widgets/dhikr_hero_card.dart` (new)
- `lib/src/presentation/screens/home/widgets/dhikr_history_pill.dart` (new)
- `lib/src/presentation/screens/home/utils/daily_dhikr_resolver.dart` (new) — pure function
- `lib/src/presentation/viewmodels/daily_dhikr_view_model.dart` (new)

**Why this fits HeartOS as a Nafs training tool**
- Dhikr is the **primary training tool** in the Islamic tradition for moving between Nafs stations
- The Nafs framework is rooted in the Quranic verse: *"Indeed, with hardship comes ease. So when you have finished, strive in worship"* (94:6-7) — the "strive" is dhikr/remembrance
- Showing the user *which Names of Allah have been calling them* over 15 days is pattern recognition that **directly serves Nafs training** (it shows where their heart keeps returning)

**Data shape**
```dart
class DhikrItem {
  final String arabic;
  final String transliteration;
  final String meaning;
  final DhikrSource source;     // todayCheckin | nafsStateBased
  final String sourceLabel;      // "From anxiety" or "For Mutmainnah"
}

class DhikrHistoryItem {
  final String arabic;
  final String transliteration;
  final String meaning;
  final int timesSuggested;     // frequency in 15 days
  final DateTime lastSuggested;
  final String lastEmotionContext;
}

class DailyDhikr {
  final DhikrItem? today;
  final List<DhikrHistoryItem> history;    // 0-5 items, freq-sorted desc
  final bool hasAnyCheckins;
}
```

**Resolver logic (pure, unit-tested)**

```dart
Future<DailyDhikr> resolveDailyDhikr({
  required CheckinRepositoryInterface checkins,
  required EmotionRepositoryInterface emotions,
  required NafsType dominantNafs,
  required DateTime today,
}) async {
  // 1. TODAY: from today's most recent checkin emotion
  DhikrItem? todayItem;
  final todayCheckins = await checkins.findForDate(today);
  if (todayCheckins.isNotEmpty) {
    final emotion = await emotions.getById(todayCheckins.last.emotionId);
    if (emotion != null && emotion.recommendedDhikr.isNotEmpty) {
      todayItem = DhikrItem(
        arabic: emotion.recommendedDhikr,
        transliteration: _transliterate(emotion.recommendedDhikr),
        meaning: _buildMeaning(emotion),
        source: DhikrSource.todayCheckin,
        sourceLabel: 'From ${emotion.name.toLowerCase()}',
      );
    }
  } else {
    // 2. FALLBACK: from dominant Nafs state
    todayItem = _nafsStateBasedDhikr(dominantNafs);
  }

  // 3. HISTORY: aggregate Allah Names from last 15 days of checkins
  final start = today.subtract(const Duration(days: 15));
  final recent = await checkins.findBetween(start, today);
  final Map<String, _HistAcc> acc = {};
  for (final c in recent) {
    final emotion = await emotions.getById(c.emotionId);
    if (emotion == null) continue;
    final names = _parseAllahNames(emotion.recommendedAllahNames);
    for (final n in names) {
      final key = n.arabic;
      acc.putIfAbsent(key, () => _HistAcc(name: n, count: 0, last: c.date, lastEmotion: emotion.name));
      acc[key]!.count++;
      if (c.date.isAfter(acc[key]!.last)) {
        acc[key]!.last = c.date;
        acc[key]!.lastEmotion = emotion.name;
      }
    }
  }
  final history = acc.values
      .toList()
    ..sort((a, b) => b.count.compareTo(a.count))
      .take(5)
      .map((a) => DhikrHistoryItem(
            arabic: a.name.arabic,
            transliteration: a.name.transliteration,
            meaning: a.name.meaning,
            timesSuggested: a.count,
            lastSuggested: a.last,
            lastEmotionContext: a.lastEmotion,
          ))
      .toList();

  return DailyDhikr(
    today: todayItem,
    history: history,
    hasAnyCheckins: recent.isNotEmpty,
  );
}
```

**Helper: Nafs state → curated dhikr** (the user-approved fallback)
```dart
DhikrItem _nafsStateBasedDhikr(NafsType nafs) {
  switch (nafs) {
    case NafsType.ammarah:
      // Base desires dominant → turn to Allah in repentance
      return DhikrItem(
        arabic: 'أَسْتَغْفِرُ اللَّهَ',
        transliteration: 'Astaghfirullah',
        meaning: 'I seek forgiveness from Allah',
        source: DhikrSource.nafsStateBased,
        sourceLabel: 'For Ammarah (turning back)',
      );
    case NafsType.lawwamah:
      // Self-critical / conscience alive → seek peace (Dua of Yunus)
      return DhikrItem(
        arabic: 'لَا إِلَهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
        transliteration: "La ilaha illa Anta, Subhanaka, inni kuntu min adh-dhalimin",
        meaning: 'There is no deity except You; glory be to You; I was among the wrongdoers',
        source: DhikrSource.nafsStateBased,
        sourceLabel: 'For Lawwamah (Dua of Yunus)',
      );
    case NafsType.mulhamah:
      // Inspired / intuitive → gratitude
      return DhikrItem(
        arabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        transliteration: 'Alhamdulillah rabbil alameen',
        meaning: 'All praise is for Allah, Lord of all worlds',
        source: DhikrSource.nafsStateBased,
        sourceLabel: 'For Mulhamah (gratitude)',
      );
    case NafsType.mutmainnah:
      // Tranquil → remembrance (the goal state)
      return DhikrItem(
        arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        transliteration: 'SubhanAllahi wa bihamdihi',
        meaning: 'Glory be to Allah and praise be to Him',
        source: DhikrSource.nafsStateBased,
        sourceLabel: 'For Mutmainnah (tranquility)',
      );
  }
}
```

**Helper: parse `recommendedAllahNames` string**
The field is a delimited string in the DB. Likely comma-separated or semicolon-separated. Implementation will handle both and skip empty entries.

**Widget contract — section**
- Props: `dhikr: DailyDhikr`, `onCount: (DhikrItem) => void`, `onPillTap: (DhikrHistoryItem) => void`, `onSeeAll: VoidCallback`
- Renders:
  - Header: "🌙 Your Daily Dhikr"
  - If `dhikr.today != null`: render `DhikrHeroCard`
  - If `dhikr.history.isNotEmpty`: header "From your last 15 days" + horizontal scroll of pills
  - If `dhikr.history.isEmpty` AND has checkins: subtle "Start building your dhikr pattern" message
  - If `!dhikr.hasAnyCheckins` AND no today: empty state "Your dhikr journey begins with your first check-in"
  - "See full 15-day journey →" link (only if history > 0)

**Widget contract — hero card**
- Props: `dhikr: DhikrItem`, `onCount: VoidCallback`
- Renders: large card with Arabic (large RTL), transliteration, meaning, "Count" button (tap → opens counter bottom sheet)
- Tappable card → opens a counter bottom sheet (tap-to-increment, long-press to reset, count persists in memory only)

**Widget contract — history pill**
- Props: `item: DhikrHistoryItem`, `onTap: VoidCallback`
- Renders: compact pill with Arabic (small RTL), transliteration, "N×" frequency badge
- Tap → bottom sheet showing timeline of when it was suggested

**Testing**
- Unit: resolver returns today's dhikr from today's emotion
- Unit: resolver falls back to Nafs-state dhikr when no check-in today
- Unit: resolver aggregates and dedupes Allah Names across 15 days
- Unit: resolver sorts by frequency desc
- Unit: resolver caps history at 5 items
- Unit: `hasAnyCheckins` is `false` when 15 days are empty
- Widget: empty states render correctly
- Widget: hero card renders Arabic RTL

---

### F. Nafs Meter with Trend Chip + 7-Day Sparkline

**Files**
- `lib/src/presentation/widgets/specific/nafs_meter.dart` (modify) — add `trend` and `sparklineData` params
- `lib/src/presentation/widgets/specific/sparkline_widget.dart` (new, tiny)

**Changes to `NafsMeterWidget`**
- Add `trend: NafsTrend?` (null = don't show)
- Add `sparklineData: List<int>?` (last 7 days of heart health scores; null = don't show)
- Render trend chip next to the dominant badge
- Render sparkline at the bottom of the card (use `CustomPaint` to avoid pulling `fl_chart` for a single tiny chart; saves bundle size)

**Data shape**
```dart
class NafsTrend {
  final int deltaPercent;     // +3 means +3 percentage points in (mutmainnah+mulhamah)
  final TrendDirection direction;  // up | down | flat
}
```

**Computation in `HomeViewModel.load()`**
- Get yesterday's NafsHistory (if exists)
- `delta = (today.mutmainnah + today.mulhamah) - (yesterday.mutmainnah + yesterday.mulhamah)`
- `direction = delta > 0.005 ? up : delta < -0.005 ? down : flat`
- Sparkline = last 7 days of `heartHealthScore` from `nafsHistoryRepository.findBetween(today-7, today)`

**Trend chip visual**
- ▲ green for up (moving toward Mutmainnah)
- ▼ red for down (drifting toward Ammarah)
- → grey for flat
- Format: `▲ +3%` vs yesterday

**Testing**
- Unit: trend direction calculation for positive/negative/zero deltas
- Widget: trend chip renders correct arrow and color
- Widget: sparkline renders without data (no crash)

---

### G. Heart Health Score with Tip + Trend

**Files**
- `lib/src/presentation/widgets/specific/heart_health_score_widget.dart` (modify)
- Add `trend: NafsTrend?` and `tip: String?` params

**Tip mapping** (one-liner per band — explicitly tied to the Nafs station)
| Score | Nafs station | Tip |
|---|---|---|
| 0–19  | Ammarah       | "Ammarah — heedlessness. Start with one small dhikr." |
| 20–39 | Lawwamah (low) | "Awakening. Try a 5-min Quran reflection." |
| 40–59 | Lawwamah      | "Lawwamah — conscience is alive. Keep going." |
| 60–79 | Mulhamah      | "Mulhamah — walking the inspired path." |
| 80–100 | Mutmainnah    | "Mutmainnah — inner peace and trust in Allah." |

**Visual addition**
- Trend arrow + delta vs 7-day average (right side, opposite the score circle)
- Tip below the existing description (in `textHint` color, 11pt)

**Testing**
- Unit: tip mapping covers all 5 bands
- Widget: tip renders only when provided

---

### H. CTA Fix + Remove Bottom Icon Row

**Files**
- `lib/src/presentation/screens/home/home_screen.dart` (modify)

**Changes**
- Remove the duplicate `Text('How is your heart today?')` from the greeting area (move it into the new `HomeGreetingWidget` and rename based on time-of-day)
- Change the `CheckInCTAWidget` button copy from `'How is your heart today?'` to `'Begin check-in'` (or similar action-oriented)
- DELETE the bottom row (`Row` with Heart Graph + History outlined buttons) — the actions are already in the app bar and they waste ~80px of vertical space

**No new files; pure cleanup.**

---

### I. `ensureLoaded()` Pattern in HomeViewModel

**Files**
- `lib/src/presentation/viewmodels/home_view_model.dart` (modify)

**Changes**
- Change initial state from `isLoading: true` to a non-loading "empty" state
- Add `bool hasLoaded` to `HomeState`
- Add `ensureLoaded()` method: if `hasLoaded` is true, return immediately; else call `load()`
- Call `ensureLoaded()` from `HomeScreen.initState` (instead of always calling `load()`)
- Keep the existing `RefreshIndicator.onRefresh` calling `load()` for manual refresh

**This complements the prior fix** (pre-loading from reflect screen) — together they ensure the home is never in a loading state when the user lands on it.

**Testing**
- Unit: `ensureLoaded` does not call `load()` twice
- Unit: `ensureLoaded` calls `load()` once on first call

---

## 5. View Model Architecture (Summary)

**Option A: One big `HomeViewModel` (simpler)**
- Add `dailyDhikr`, `todayHabits`, `previousNafs`, `sparkline` to `HomeState`
- Compute all in `load()`
- Pro: less provider sprawl
- Con: toggling a habit rebuilds the whole dashboard

**Option B: Split providers (cleaner, recommended)**
- `homeViewModelProvider` — owns Nafs vector, heart health, streak, last checkin, trend, sparkline
- `homeHabitsViewModelProvider` — owns habits (separate so toggles don't rebuild dashboard)
- `dailyDhikrProvider` (FutureProvider) — own load
- Pro: granular rebuilds, easier to test each in isolation
- Con: more providers

**Recommendation: Option B.** Each section is independently testable, and toggling a habit doesn't trigger a full dashboard rebuild. The slight provider sprawl is worth the performance and clarity win.

**Composite `HomeDashboard` object (for the screen to consume)**
```dart
class HomeDashboard {
  final NafsSnapshot nafs;
  final HeartHealth health;
  final DailyDhikr? dhikr;
  final HomeHabitsState habits;
  final ConsistencyStats consistency;  // streak + last checkin
  final NextAction nextAction;
}
```

---

## 6. Folder Structure (After Implementation)

```
lib/src/presentation/screens/home/
├── home_screen.dart                       (slim, pure composition)
└── widgets/
    ├── home_greeting_widget.dart          (A)
    ├── today_habits_strip.dart            (C)
    ├── habit_pill.dart                    (C)
    ├── daily_dhikr_section.dart           (E)
    ├── dhikr_hero_card.dart               (E)
    ├── dhikr_history_pill.dart            (E)
    ├── next_action_card.dart              (D)
    ├── nafs_meter_with_trend.dart         (F — wraps existing NafsMeterWidget)
    ├── heart_health_with_tip.dart         (G — wraps existing HeartHealthScoreWidget)
    ├── sparkline_widget.dart              (F)
    ├── empty_state_widget.dart            (reused by C, E, etc.)
    └── bottom_sheets/
        ├── dhikr_counter_sheet.dart       (E)
        └── dhikr_timeline_sheet.dart      (E)
└── utils/
    ├── greeting_helper.dart               (A)
    ├── daily_dhikr_resolver.dart          (E)
    └── next_action_resolver.dart          (D)
```

---

## 7. Implementation Rollout

| Phase | Scope | Effort | Impact | Risk | Status |
|---|---|---|---|---|---|
| **0** | Refactor `home_screen.dart` into widget files (no behavior change); fix CTA copy; remove bottom row; add `ensureLoaded()` | 1 day | Polish | Low | ✅ Done |
| **1** | **C — Habits strip** + separate view model | 2 days | **Highest** (anchors daily training reps) | Low (existing entities) | ✅ Done |
| **2** | **E — Daily Dhikr section** (hero + 15-day history, Nafs-calibrated) | 3 days | **Highest** (the primary Nafs training tool) | Medium (new view model + parsing logic) | ✅ Done |
| **3** | **D — Next Action card** (Nafs-aware rules engine) | 2 days | **High** (feels alive, Nafs-aware) | Low (pure function) | ✅ Done |
| **4** | **A — Greeting** + Hijri date | 1 day | Medium | Low | ✅ Done |
| **5** | **F — Nafs trend + sparkline** | 1 day | Medium (the core Nafs indicator) | Low | ✅ Done |
| **6** | **G — Heart Health tip + trend** | 0.5 day | Medium | Low | ✅ Done |

**Total:** ~10–11 days for all features. ✅ All phases complete.

---

## 8. Testing Strategy

| Layer | Test type | Coverage target |
|---|---|---|
| Pure resolvers (greeting, daily dhikr, next action) | Unit | 100% |
| View models (home, habits, dhikr) | Unit | All public methods, all state transitions |
| Widgets (rendering, empty states, interactions) | Widget | One happy path + all empty states + one error state per widget |
| Integration (full home screen with all providers) | Widget | One full render with mocked providers, one empty-user render |
| Golden tests (pixel-perfect layouts) | Widget | Optional — only after design is locked |

---

## 9. Out of Scope (Tier 3, Future PRs)

- 7-day streak heatmap (replaces single streak number)
- Quick-log emotion bottom sheet (FAB)
- Prayer-time banner
- Daily reminder notification
- Share progress image
- Arabic + Urdu UI localization
- Dark mode wiring
- Counter bottom sheet persistence (currently in-memory only)
- **Daily Wisdom / verse-of-the-day card** (intentionally excluded — HeartOS is a Nafs training tool, not a content app)

---

## 10. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| `recommendedAllahNames` string format is inconsistent in seed data | Robust parser: split on `,`, `;`, `\|`, newlines; trim; skip empty |
| Habit toggle rebuilds the whole home (if not separated) | Use a separate `homeHabitsViewModelProvider` |
| Nafs state fallback for dhikr might feel generic | Use authentic, well-known adhkar (Istighfar, Dua of Yunus, SubhanAllah) — not made up |
| Hijri date off-by-one (Hijri day starts at sunset) | Acceptable for an MVP; document and iterate later |
| Removing the bottom icon row may regress users who use those buttons | App bar still has them; primary user research question before shipping (defer) |
| 15-day history is empty for new users | Friendly empty state with CTA — not a failure case |

---

## 11. Success Metrics (Post-Launch)

| Metric | Target |
|---|---|
| Daily active users (DAU) | +20% within 4 weeks |
| Check-in completion rate | +15% within 4 weeks |
| Home → check-in tap-through | +25% (via Next Action card) |
| Home → habits tap-through | +30% (via Habits strip + Next Action) |
| 7-day retention | +10% within 8 weeks |
| Average session time on home | +40% (more content to engage with) |
| Nafs-meter trend (▲ from below baseline to above) | Proxy for genuine Nafs movement |

---

## 12. Open Questions (Awaiting Your Decision)

1. **Confirm scope:** all of (A+C+D+E+F+G+H+I)? Or a subset?
2. **Provider architecture:** Option A (one big view model) or Option B (split providers, recommended)?
3. **Counter bottom sheet (E):** should taps persist across sessions (local DB) or stay in-memory for the session?
4. **Dhikr counter semantics:** simple increment only, or also track date/total counts for future stats?
5. **Nafs-based dhikr wording:** the 4 adhkar I proposed (Astaghfirullah, Dua of Yunus, Alhamdulillah, SubhanAllah) — approve, or do you want different choices?
6. **Dhikr pill frequency cap:** cap at top 5, or show all (with a "See more" link)?
7. **Hijri date library:** `intl`'s built-in `islamic-umalqura` (no extra dep) is what I'd use. OK?
8. **Display name source:** do you have user names available from auth/Hive, or is the user anonymous for now? (Affects whether the greeting can be personalized immediately or needs to wait for a future auth PR)
9. **Visual polish:** do you want me to also do a design pass on the existing NafsMeter / HeartHealth widgets (colors, spacing, typography) or keep their current look?

---

## 13. Bottom Line

The data, the architecture, the content DB, and the spiritual framework are all genuinely strong. The home page just needs to *use* them.

**HeartOS positioning (per your direction):** purely a Nafs training guide and tool — not a content app. Every element on the home page should serve the user's journey along the 4 Nafs stations. That's why we **removed the Daily Wisdom card** from this plan (verses surface as *interventions* on the intervention screen, prescribed by Nafs state, not as a daily rotation on home).

**Single biggest unlock:** the "Your Daily Dhikr" section, calibrated to the user's dominant Nafs state and showing the 15-day pattern of Allah Names they've been guided to. This is the kind of feature that makes a Muslim user open the app at Fajr, not just after they feel something — and it directly serves Nafs training.

**Single biggest risk:** scope. Recommend shipping in 4 focused PRs (Phase 0 → 1 → 2 → 3) rather than one mega-PR.

**Files to be added (new):** ~13 new files
**Files to be modified:** ~4 (home_screen, home_view_model, nafs_meter, heart_health_score_widget)
**Files to be deleted:** 0
**Estimated total LoC:** ~1,300–1,800 new code, ~200 modified

**Next step:** once you approve this plan, I'll begin with Phase 0 (refactor + cleanup) and Phase 1 (Habits strip) as the first PR.

---

## 14. Implementation Summary (Delivered)

All 7 phases were implemented in a single comprehensive pass. Per your direction, the **Nafs Meter is at the top** of the home page (right after the greeting). Zero errors in `flutter analyze`.

### Files added (16 new files)

**Utils (pure, testable):**
- `lib/src/presentation/screens/home/utils/greeting_helper.dart` — time-of-day greeting + Hijri date (Kuwaiti algorithm) + Gregorian date
- `lib/src/presentation/screens/home/utils/daily_dhikr_resolver.dart` — today's dhikr + 15-day Allah Name aggregation + Nafs-state fallback
- `lib/src/presentation/screens/home/utils/next_action_resolver.dart` — Nafs-aware rules engine for the contextual CTA
- `lib/src/presentation/screens/home/utils/nafs_trend_helper.dart` — trend computation + sparkline scores
- `lib/src/presentation/screens/home/utils/habit_category_resolver.dart` — category → icon/color mapping

**Widgets (presentation):**
- `lib/src/presentation/screens/home/widgets/home_greeting_widget.dart` (A)
- `lib/src/presentation/screens/home/widgets/today_habits_strip.dart` (C)
- `lib/src/presentation/screens/home/widgets/habit_pill.dart` (C)
- `lib/src/presentation/screens/home/widgets/daily_dhikr_section.dart` (E)
- `lib/src/presentation/screens/home/widgets/dhikr_hero_card.dart` (E)
- `lib/src/presentation/screens/home/widgets/dhikr_history_pill.dart` (E)
- `lib/src/presentation/screens/home/widgets/dhikr_counter_sheet.dart` (E)
- `lib/src/presentation/screens/home/widgets/dhikr_timeline_sheet.dart` (E)
- `lib/src/presentation/screens/home/widgets/next_action_card.dart` (D)
- `lib/src/presentation/screens/home/widgets/empty_state_widget.dart` (reused)
- `lib/src/presentation/screens/home/widgets/sparkline_widget.dart` (F)

**View models:**
- `lib/src/presentation/viewmodels/home_habits_view_model.dart` (C)
- `lib/src/presentation/viewmodels/daily_dhikr_view_model.dart` (E)

### Files modified (4 files)

- `lib/src/presentation/screens/home/home_screen.dart` — refactored to pure composition; **Nafs Meter is now at the top**; CTA renamed to "Begin check-in"; bottom icon row removed
- `lib/src/presentation/viewmodels/home_view_model.dart` — added `ensureLoaded()`, `trend`, `sparkline`, `nextAction()` method, `hasLoaded` flag
- `lib/src/presentation/widgets/specific/nafs_meter.dart` — added optional `trend` chip + `sparkline` (backward-compatible)
- `lib/src/presentation/widgets/specific/heart_health_score_widget.dart` — added optional `trend` + `tip` (backward-compatible)

### SOLID compliance

| Principle | How it's applied |
|---|---|
| **Single Responsibility** | Each view model owns one section. Each resolver has one purpose. Each widget renders one thing. |
| **Open/Closed** | NafsMeter / HeartHealth accept optional new params (trend, sparkline, tip) — old call sites unchanged. |
| **Liskov Substitution** | All resolvers accept repository interfaces (abstractions), not concrete impls. |
| **Interface Segregation** | View models expose only the methods their widget needs (`toggle`, `load`, `nextAction`). |
| **Dependency Inversion** | All resolvers + view models depend on `*RepositoryInterface` abstractions, wired through Riverpod providers. |

### Validation

```bash
$ flutter analyze
# 13 info-level issues (all pre-existing in unrelated files)
# 0 errors, 0 warnings in the new code
```

### Feature preservation

All original home page features retained:
- ✅ Nafs Meter (now at the top, with trend + sparkline)
- ✅ Heart Health Score (with trend + tip)
- ✅ Last check-in row
- ✅ Positive streak row
- ✅ Check-in CTA (renamed to "Begin check-in", no more redundancy with greeting)
- ✅ App bar with Heart Graph / History / Settings
- ✅ Pull-to-refresh
- ✅ Loading state on first cold load

### New features

- ✅ Personalized time-aware greeting (السلام عليكم + time-of-day + Hijri + Gregorian date)
- ✅ Today's Habits strip with optimistic toggle
- ✅ Your Daily Dhikr section (hero card + 15-day aggregated Allah Names pills)
- ✅ Dhikr counter bottom sheet (tap to count, long-press to reset, haptic feedback)
- ✅ Dhikr timeline bottom sheet (full Arabic + transliteration + meaning)
- ✅ Contextual Next Action card (Nafs-aware rules engine)
- ✅ Nafs trend chip (▲ +3% vs yesterday)
- ✅ 7-day heart health sparkline on the Nafs meter
- ✅ Heart Health tip per score band
- ✅ `ensureLoaded()` pattern (no spinner flash on warm starts)
- ✅ Empty states for first-time users (no habits, no check-ins)
