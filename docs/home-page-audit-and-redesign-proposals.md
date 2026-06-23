# NafsMutmainna / HeartOS — Home Page Audit & Two New Design Proposals

> **Audit-only deliverable. No code changes proposed.**
> **Date:** 2026-06-20
> **Scope:** Home screen (`lib/src/presentation/screens/home/`) and its supporting widgets in `lib/src/presentation/widgets/`.
> **Out of scope:** every other screen, the data layer, the Nafs engine math.

---

## Part 1 — Thorough Audit of the Current Home Page

### 1.1 What's currently on the home (`home_screen.dart`, 207 lines)

Top-to-bottom, rendered as a single `ListView` inside a `Scaffold` with an `AppBar` (title "NafsMutmainna" + 3 icon actions: Heart Graph, History, Settings):

| # | Element | File | Notes |
|---|---|---|---|
| 1 | Personalized greeting (السلام عليكم + name + time-of-day + Hijri + Gregorian) | `home_greeting_widget.dart` | Good. But `name` is **hardcoded `null`** on Home — the greeting never shows a name in practice. |
| 2 | Big primary CTA "Begin check-in" | inline in `home_screen.dart` | Full-width green button, 54 px tall, heart icon. |
| 3 | **Nafs Arc Meter** (the IP of the app) | `widgets/specific/nafs_arc_meter.dart` (370 lines, custom painter) | 180° gradient arc, needle, station labels, dominant chip, descriptor, "Tap for details". Beautiful. |
| 4 | **Tazkiya-safe banner** (RI-5.1) | `widgets/specific/tazkiya_safe_banner.dart` | Static info card reminding the user the meter is *pattern, not judgment*. |
| 5 | **Heart Health Score** widget | `widgets/specific/heart_health_score_widget.dart` | 0–100 ring, label band, description, **optional** 7-day trend chip and tip. |
| 6 | **Quran of the Day** card (RI-5.3) | `widgets/specific/quran_of_the_day_card.dart` | Arabic + English + reference + reflection. Loads from `assets/data/quran_of_the_day.json`, deterministic rotation by day-of-year. |
| 7 | **Today's Habits Strip** | `screens/home/widgets/today_habits_strip.dart` | Horizontal scrollable pills, "X/Y done" header, "Manage habits →" link, dedicated `HomeHabitsViewModel`. |
| 8 | **Daily Dhikr Section** | `screens/home/widgets/daily_dhikr_section.dart` (558 lines) | Hero dhikr card + 15-day aggregated Allah Names + custom-painted 15-day Nafs trend chart + "See full journey →". |
| 9 | Last check-in row (small grey bar) | inline `home_screen.dart` | `DateFormat.yMMMd().add_jm()` — date + time. |
| 10 | Streak row (small orange bar) | inline `home_screen.dart` | Fire icon + "$n-day positive streak". |
| 11 | The Next Action card (`next_action_card.dart`) | **defined but NOT rendered in `home_screen.dart`** | A grep for `NextActionCard` in `home_screen.dart` finds **zero** references. Shipped, tested, but invisible on Home. **Dead code on the home.** |

### 1.2 UX / UI problems found

#### A. Information density & hierarchy

- **11 sections** above the fold on a typical phone. Each is its own visual block. The eye has nowhere to land.
- The **Nafs Meter** is the app's unique IP and is correctly placed high — but the **Quran of the Day** is placed *below* the **Heart Health Score**, which feels like a generic dashboard order ("metrics → verse") rather than a Nafs-training flow ("where you are → what to read → what to do").
- **Last-checkin and streak rows are bare 12-px grey text rows.** The streak — a key motivator in every modern habit app — gets no celebration.
- **The "Begin check-in" CTA at the top is duplicated in spirit by the (currently-unrendered) Next-Action card.** If both are wired in, the user gets two competing primary actions.

#### B. Navigation

- **No bottom navigation bar.** All deep navigation is buried in 3 `AppBar` icons (Heart Graph / History / Settings). On a phone with one thumb, reaching those is awkward.
- The **Heart Graph icon** is `Icons.account_tree_outlined` — cryptic; doesn't read as "graph of the heart".
- The **Settings icon** competes for attention with content (it sits in the AppBar alongside title).

#### C. Missing Islamic-app essentials

| Missing on Home | Why it matters for an Islamic Nafs app |
|---|---|
| **Prayer times** | Every top Islamic app surfaces the next prayer prominently (WeMuslim, Muslim Pro, Sadiq, Dhikr & Dua). HeartOS tracks habits but doesn't tell the user *which salah is next*. |
| **Hijri event awareness** (Ramadan countdown, Jumu'ah, Ashura, Mon/Thu fasting, Dhul Hijjah) | The Hijri date is shown but no semantic awareness of *where in the Islamic calendar* we are. |
| **Audio of the day's dhikr/verse** | `Dhikr & Dua` (1M+ downloads, 4.7★) and Tarteel AI made this table-stakes. |
| **Quick-log emotion FAB** | No way to log a feeling in <5 seconds without opening the full check-in flow. |
| **Sheikh/Murabbi panel** | RI-3.3 specifies this *on the Pathways screen only* — but a one-line whisper on Home is also classical-aligned (Hadith: "الرَّجُلُ عَلَى دِينِ خَلِيلِهِ" Abu Dawud 4033). |

#### D. Visual / theme

- **Palette is monochromatic dark green** (`#1B5E20`, `#4CAF50`, `#0D3D12`). Modern spiritual apps use **warmer, dual-tone** palettes — cream + emerald + gold, or charcoal + saffron.
- **Dark mode is defined in `colors.dart` but never wired** in `main.dart` / `MaterialApp.themeMode`. The app ships light-only today.
- **No logo / brand mark** in the AppBar. Just the text "NafsMutmainna" — feels utilitarian.
- **Greeting is small (20 pt)** for what is the user's emotional entry point.
- **No micro-illustrations / geometric Islamic patterns** to evoke the heritage-modern genre.

#### E. Personalization & identity

- The `HomeGreetingWidget` accepts `displayName`, but `home_screen.dart` **always passes `null`**:
  ```dart
  HomeGreetingWidget(displayName: null, now: DateTime.now()),
  ```
  So the "Add your name →" affordance is unreachable from the home.
- No avatar / identity element.

#### F. State / refresh

- `ensureLoaded()` is well-implemented (prevents spinner flash on warm starts). ✅
- `RefreshIndicator` is wired. ✅
- But there is **no offline-state hint** when the network is unavailable — and HeartOS is privacy-first with mostly local data, so a "your data is local, safe, and private" cue would reassure users.

#### G. Accessibility / RTL / tap targets

- `HeartHealthScoreWidget` mixes English numerals with Arabic-looking content but isn't fully RTL-aware.
- Most decorative `Text(...)` strings have no `Semantics` labels — only `Tooltip` on IconButtons.
- `TodayHabitsStrip` is a horizontal scroll at 78 px height — long habit names clip.

#### H. Latent dead code

- `next_action_card.dart` exists with a resolver, but is **not referenced in `home_screen.dart`**. Either remove it or surface it. (Recommendation: surface it, but redesign per Option A or B.)

### 1.3 Strengths to preserve (do NOT lose in any redesign)

1. **The Nafs Arc Meter itself.** Genuinely the most distinctive spiritual-app UI element I audited. Keep as the hero.
2. **The 4-station Nafs framework is the app's IP.** Any redesign must keep the arc + 4 stations visible at the top.
3. **Tazkiya-safe banner under the meter** is a load-bearing scholarly-anchoring pattern — keep.
4. **Daily Dhikr's Nafs-state-based fallback** (Astaghfirullah / Dua of Yunus / Alhamdulillah / SubhanAllah) is excellent and authenticated. Keep the *content*, reshape the *presentation*.
5. **15-day Allah-Name aggregation** is unique. It's the strongest pattern-recognition feature in the niche.
6. **`ensureLoaded()` pattern** — clean, idempotent. Keep.
7. **The custom-painted arc + sparkline** (no `fl_chart` dep for these) — lightweight, on-brand.

---

## Part 2 — Competitor Landscape (Islamic spiritual guidance)

### 2.1 Closest comparators (web + Google Play)

| App | Downloads | Stars | Positioning | Home-page pattern |
|---|---|---|---|---|
| **Dhikr & Dua — Life With Allah** | 1M+ | 4.7★ (121K reviews) | Daily dhikr/dua library with audio, emotion browse, articles, reminders | Category-based home (Morning / Evening / After Salah / Sleep); counter sheet; "Emotions" entry; card-based, soft cream palette |
| **Muslima 365 — Habit Building** | 50K+ | 4.8★ (433 reviews) | Habit tracker for Muslim women, Iman-boosters, badges | Streak hero card, vertical habit list with rings, badges grid, daily Quran page counter |
| **WeMuslim** (Metaverse) | large | 4.6★ | Prayer/Qibla/Quran — full suite | Next-prayer hero card, Quran ayah card, daily hadith card, athan player |
| **Sadiq** (Greentech) | — | 4.9★ | Prayer/Quran/Qibla | Clean white+green, prayer-time countdown hero, today's ayah card |
| **Tarteel: AI Quran Memorization** | very large | 4.4★ | Recitation + AI feedback | Single primary CTA "Start reciting", recent sessions list, streak |
| **Growing Spiritually** | 100+ | — | Devotional content app (Christian) — *genre twin* | Daily verse hero, reading plan progress, bookmarks, dark mode, theme toggle |
| **Soulshine / Islamic Quotes** | medium | 4.3★ | Quote feed | Card-swipe feed; Quran+Hadith quote cards; no tracking |

### 2.2 Patterns common to *all* top apps (table-stakes checklist)

1. **Hero greeting + personalized name** at the very top.
2. **Next-prayer / today-in-Islam** prominent (time-to-next-prayer is the most-tapped element in this genre).
3. **Today's content card** (ayah, hadith, or dhikr) — one card, large.
4. **Streak / progress hero** with celebratory color when active.
5. **Quick action grid** (4–6 large tiles: Quran / Qibla / Tracker / Dhikr counter / Library / Reflect).
6. **Bottom navigation** — Home + 4 sibling tabs.
7. **Light + dark themes** both shipped and toggleable.
8. **Audio** for verse/dhikr.
9. **Push notification reminders** paired with home cards ("Tap to start your morning adhkar").
10. **Personalization**: name, language, madhab, theme.

### 2.3 Gaps in the market that HeartOS can uniquely own

- **No competitor offers the 4-station Nafs journey as a continuous visual metaphor.** Most apps are *content libraries* (Dhikr & Dua) or *habit trackers* (Muslima 365). None frame the user's spiritual state on an arc and prescribe a Nafs-aware intervention. **This is HeartOS's IP — must remain the visual hero.**
- **No competitor offers Nafs-calibrated Dhikr.** HeartOS maps today's prescribed dhikr to the user's *current* dominant station. Unique and under-marketed.
- **No competitor surfaces the 15-day Allah-Name pattern** ("Allah has been calling you to Al-Samee' 4 times this fortnight"). HeartOS does — should be the second-most-prominent surface on Home.
- **Privacy-first / local-first.** HeartOS already is. Modern Muslim users increasingly value this (per Dhikr & Dua's data-safety section: "no data collected"). Promote this as a hero trust badge on the new Home.

---

## Part 3 — Two New Home-Page Designs

Both designs are **state-of-the-art**, **modern**, and **user-friendly**, while keeping the 4-station Nafs framework as the hero (non-negotiable per HeartOS positioning).

---

## Option A — *"Suluk: The Tazkiya Journey"*

> **Aesthetic:** heritage-modern. Deep emerald + gold + parchment cream. Geometric Islamic-pattern micro-ornaments. Long-form, story-driven cards.
> **Tone:** "A wise companion walks with you along the path of the Salaf."
> **Best for:** users who want depth, ritual, and the feeling of a *kitab* (book) in their pocket.

### A.1 Wireframe

```
┌──────────────────────────────────────────────────────────────────┐
│ ◆ NafsMutmainna                                  🔍  🌳  👤   │  AppBar (logo+name, search, graph, profile)
├──────────────────────────────────────────────────────────────────┤
│  السلام عليكم, Ahmad                                          │  A1. Hero greeting
│  Good evening · 14 Rajab 1447 AH · 20 Jun 2026                │      (name from auth; Hijri+Greg)
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 🌙  Ramadan begins in 12 days  ·  Jumu'ah tomorrow       │  │  A2. Hijri event chip strip
│  └──────────────────────────────────────────────────────────┘  │      (Ramadan / Jumu'ah / Ashura / Mon-Thu)
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │      ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄                                 │  │
│  │    ╱                     ╲                               │  │  A3. NAFS JOURNEY (the hero)
│  │   │   ❋ needle            │                              │  │      • Arc meter (existing, gold-rimmed)
│  │    ╲   pointing here     ╱                               │  │      • 4-station track below the arc
│  │      ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀                                 │  │      • "You stand at Lawwamah — conscience
│  │   Ammarah ─ Lawwamah ─ Mulhamah ─ Mutmainnah            │  │         is alive. One dhikr moves you."
│  │   ●───────●─────────○──────────○                        │  │
│  │   ⓘ This is a pattern, not a judgment of your soul.    │  │  A4. Inline tazkiya-safe whisper (RI-5.1
│  └──────────────────────────────────────────────────────────┘  │      condensed to one line under the meter)
│                                                                  │
│  TODAY'S PRESCRIPTION                                            │  A5. Tabbed content card (Ayah/Hadith/Dhikr)
│  ┌────────┬────────┬────────┐                                  │      • 3 tabs, swipeable
│  │  Ayah  │ Hadith │ Dhikr  │                                  │      • Today's most-relevant per tab
│  └────────┴────────┴────────┘                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │        إِنَّ مَعَ الْعُسْرِ يُسْرًا                          │  │
│  │  "Indeed, with hardship comes ease."  — Qur'an 94:6       │  │
│  │  For Lawwamah: patience + trust. Tap to reflect →        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  TODAY'S ANCHORS                                       2/4 done │  A6. Habits (vertical, not horizontal)
│  ─────────────────────────────────────                          │      • Vertical list, each row = ring + name
│  ○ Fajr        05:12 ✓                                          │      • Time-stamped for prayers
│  ○ Dhuhr       13:00 ✓                                          │
│  ○ Asr         16:45 ○                                          │
│  ○ Quran       1 page  ○                                        │
│                                                                  │
│  ╭──────────────────────────────────────────────────────────╮  │
│  │  📿  Your Daily Dhikr                                   │  │  A7. Daily Dhikr (compressed)
│  │  لَا إِلَهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ   │  │      • Single hero card with Arabic
│  │     الظَّالِمِينَ   — Dua of Yunus    [Count 0/100]      │  │      • Inline counter (tap = +1, hold = reset)
│  │  ↳ Suggested 6× in last 15 days for Lawwamah             │  │      • Frequency whisper below
│  │  See Allah Names guiding you →  Al-Samee' · Al-Qarib    │  │      • 15-day Names become a horizontal
│  └──────────────────────────────────────────────────────────╯  │        chip row, not a card stack
│                                                                  │
│  ◌ Reflection — check in (last: 2h ago)        [ Begin → ]    │  A8. Reflection CTA
│                                                                  │      • Replaces Next-Action card
│                                                                  │      • Shows time since last check-in
│                                                                  │      • Single primary action
│                                                                  │
│  🔥 7-day positive streak        ░░░░░░░░▓▓▓▓▓ streak history │  A9. Streak celebrated
│                                                                  │      • Micro sparkline of past 30 days
│                                                                  │
│  ⓘ Tazkiya traditionally requires a living teacher. This app   │  A10. Sheikh/Murabbi whisper (RI-3.3)
│    is a companion, not a replacement.                             │      • One line, dismissible
└──────────────────────────────────────────────────────────────────┘
│  [ Home ]  [ 📖 Quran ]  [ 📿 Dhikr ]  [ 📈 Insights ]  [ 👤 ]  │  BOTTOM NAV (new — 5 tabs)
└──────────────────────────────────────────────────────────────────┘
```

### A.2 Design principles applied

| Principle | How it shows up |
|---|---|
| **Heritage-modern** | Geometric arabesque dividers between sections; gold (`#C9A227`) accent for ornaments; parchment cream (`#FAF7F0`) surface variant |
| **Story-driven** | Each section tells one beat of the day: *where you are* → *what to read* → *what to do* → *what you've done* |
| **Scholar-anchored** | One-line Tazkiya-safe whisper under the meter; Sheikh/Murabbi whisper at the bottom; "For Lawwamah" station descriptors on every prescription |
| **Privacy trust badge** | A small 🔒 *"Your data stays on this device"* footer line in the AppBar overflow |
| **Personalization** | Name from auth (after a profile PR) wired into the greeting |

### A.3 Color & type

```
Primary:        #1B5E20  (existing deep emerald — keeps brand)
Primary gold:   #C9A227  (new — for arc rim, ornaments, streak)
Parchment:      #FAF7F0  (new — for surface variant)
Ink:            #1F2421  (deep ink for body text on parchment)
Soft gold tint: #F4E9C8  (new — for chip backgrounds)
```

- Type: **Amiri** for Arabic (existing), **Plus Jakarta Sans** for English UI, **Source Serif** for the long reflection card (new). Type scale: greeting 26 pt / section headers 18 pt / body 14 pt / whisper 12 pt.
- Hero arc rim changes from current white to **gold** to evoke an antique instrument.

### A.4 New components needed (listed, not coded)

1. `HijriEventChipStrip` — fetches next Hijri event (Ramadan/Jumu'ah/Ashura/Mon-Thu fasting/Dhul Hijjah) and renders a slim horizontal chip row.
2. `NafsJourneyCard` — wraps the existing `NafsArcMeter` with a 4-station track visualization below it (small dots, current filled, others outlined) plus an inline tazkiya whisper.
3. `PrescriptionTabsCard` — 3-tab widget (Ayah / Hadith / Dhikr), each pulling from a curated JSON, active tab determined by today's dominant Nafs.
4. `HabitVerticalList` — replaces horizontal strip; each row = category icon + name + time + circular ring completion.
5. `DhikrCompactCard` — single hero with inline counter (was a bottom sheet).
6. `StreakHistorySparkline` — 30-day micro-sparkline on the streak row.
7. `BottomNavBar` — 5 tabs: Home / Quran / Dhikr / Insights / Profile.
8. `SheikhWhisperPanel` — single-line dismissible whisper near the bottom (RI-3.3 carried onto Home).

### A.5 Strengths of Option A

- **Maximum depth:** every Islamic-app table-stakes feature (prayer awareness, hijri events, prescription tabs, streak history, sheikh whisper) is on the home, woven into the narrative.
- **Strongest "kitab / spiritual companion" feel** — differentiates HeartOS from the Muslim-Pro genre.
- **Top-of-fold clarity:** Hero → Prescription → Action → Done → Streak. Five beats, top-to-bottom.

### A.6 Trade-offs of Option A

- **Densest option** — users with low-literacy or screen fatigue may scroll past the prescription card.
- **Most new components** (~8 new) — biggest implementation cost.
- **Risk of ornament overload** if gold + parchment go too far; needs a careful design pass.

---

## Option B — *"Qalb: The Calm Dashboard"*

> **Aesthetic:** modern, calm, data-forward. Soft cream surface + deep teal accent + saffron highlight. Generous whitespace. Thin lines, big numerals, no ornaments.
> **Tone:** "A precise, quiet instrument — like the dial of a stethoscope for the soul."
> **Best for:** users who want glanceability, speed, and a clean iOS-/Linear-style modern aesthetic.

### B.1 Wireframe

```
┌──────────────────────────────────────────────────────────────────┐
│  السلام عليكم, Ahmad                              🔍  ⚙       │  B1. Slim greeting bar
│  14 Rajab 1447  ·  Good evening                                 │      (name + Hijri + time-of-day inline)
│                                                                  │
│   ─────────────────────────────────────────────────────────     │  thin divider
│                                                                  │
│  Today  |  Week  |  Month                          [Q]         │  B2. Time-window segmented control
│                                                                  │      • "Today" tab default
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ┌──────────┐                                             │  │
│  │  │  72      │   Your Nafs is at                ▲ +4 (7d) │  │  B3. NAFS RADIAL (the hero)
│  │  │  /100    │   LAWWAMAH                              →   │  │      • Circular radial chart (not arc)
│  │  │  ▓▓▓░░░  │   Conscience is alive. Keep going.        │  │      • Center = score, ring = 4-station sweep
│  │  └──────────┘   One dhikr moves you.                      │  │      • Color sweep matches station colors
│  │                                                          │  │
│  │   ○─────●──────○──────○    Ammarah · Lawwamah · Mulhamah · Mutmainnah │  B4. 4-station track (compact, under)
│  │                                                          │  │
│  │   ⓘ Pattern indicator, not a judgment of your soul.       │  │  B5. Tazkiya whisper (single line)
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  NEXT PRAYER                                                     │  B6. Prayer strip (new — the killer
│  ┌──────────┬──────────┬──────────┬──────────┬──────────┐       │      feature of this option)
│  │  Fajr    │  Dhuhr   │  Asr     │  Maghrib │  Isha    │       │      • 5 columns, current salah highlighted
│  │  05:12 ✓ │  13:00 ✓ │  16:45 ○ │  19:08   │  20:32   │       │      • Done = filled circle, pending = hollow
│  └──────────┴──────────┴──────────┴──────────┴──────────┘       │      • Tappable → opens Adhkar for that prayer
│                                                                  │
│  TODAY'S PRESCRIPTION                          For Lawwamah     │  B7. Prescription card
│  ┌──────────────────────────────────────────────────────────┐  │      • Single card, no tabs
│  │   سُبْحَانَ اللَّهِ وَبِحَمْدِهِ                                  │  │      • Always shows the most-relevant piece
│  │   "Glory be to Allah and praise be to Him"                │  │        (Ayah / Hadith / Dhikr) chosen by Nafs
│  │   SubhanAllahi wa bihamdihi        [ + ]  0/100 today     │  │      • Inline counter (single tap = +1)
│  │   ↳ "Allah has guided you to this dhikr 6× in 15 days."  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌─────────────────────────┐  ┌─────────────────────────┐     │  B8. Quick-log grid (two-up)
│  │  ◌  Check in            │  │  📖  Quran of the day   │     │
│  │     2h ago · tap to log │  │     Al-Inshirah 94:6    │     │
│  └─────────────────────────┘  └─────────────────────────┘     │
│                                                                  │
│  ANCHORS                                  Manage →              │  B9. Habits (compact row)
│  ○ Fajr ✓   ○ Dhuhr ✓   ○ Asr ○   ○ Quran ○      2/4 done       │      • Inline, no scroll
│                                                                  │
│  🔥 7-day streak            ▁▂▃▄▅▆▇  ▲ +3 vs last week          │  B10. Streak bar (compact)
│                                                                  │
│                                                                  │      FAB (floating, bottom-right)
│                                                          [ + ]   │  B11. Quick-log FAB
│                                                                  │      • Taps → mini sheet (emotion / dhikr / note)
└──────────────────────────────────────────────────────────────────┘
│  [ Home ]  [ 📖 ]  [ 📿 ]  [ 📈 ]  [ 👤 ]                       │  BOTTOM NAV (5 tabs, same)
└──────────────────────────────────────────────────────────────────┘
```

### B.2 Design principles applied

| Principle | How it shows up |
|---|---|
| **Calm / glanceable** | One card per beat. Big numerals (the score is the largest number on the screen). |
| **Modern / iOS-like** | Segmented control for time window; radial chart instead of arc; thin dividers. |
| **Prayer-first** | The next-prayer strip is a new, top-tier surface — directly answers the #1 competitor pattern. |
| **Action-oriented** | Quick-log FAB reduces check-in friction to a single tap. |
| **Scholar-anchored** | Single-line tazkiya whisper; "For Lawwamah" station label on every prescription. |
| **Privacy trust** | Small 🔒 icon in the AppBar overflow. |

### B.3 Color & type

```
Surface:       #FAFAF7  (soft cream)
Card:          #FFFFFF  (pure white on cream)
Ink:           #1F2421  (deep ink)
Muted:         #6B7280  (slate grey for secondary text)
Accent:        #0F766E  (deep teal — replaces the dark green)
Highlight:     #F59E0B  (saffron — for streak, "current" prayer)
Station colors: existing (red/orange/green/dark-green) preserved
```

- Type: **Inter** for everything (existing system font fallback acceptable). Numeral display uses tabular figures (`fontFeatures: [FontFeature.tabularFigures()]`) so the score never jiggles.
- The radial chart is a `CustomPaint` (similar effort to the existing arc) — a circular sweep with 4 colored arcs and a needle.

### B.4 New components needed (listed, not coded)

1. `NafsRadialChart` — `CustomPaint` circular chart (replaces the arc meter *visually*; same `compositePosition(Vector4)` math). Center = score numeral, ring = 4-station sweep.
2. `TimeWindowSegmented` — Cupertino-style segmented control: Today | Week | Month. Drives the data displayed in B3 + B7 + B10.
3. `NextPrayerStrip` — 5-column prayer row with the current salah highlighted and the next one pulsing softly.
4. `PrescriptionCard` — single-card, content chosen by dominant Nafs (no tabs).
5. `QuickLogGrid` — 2-up card grid (Check-in, Quran of the day).
6. `QuickLogFab` — bottom-right `FloatingActionButton` with a 3-option mini sheet (Emotion / Dhikr / Note).
7. `BottomNavBar` — 5 tabs.
8. `StreakBarCompact` — single-row streak with mini sparkline.

### B.5 Strengths of Option B

- **Prayer strip is the killer feature** — directly competes with WeMuslim/Sadiq/Muslim Pro on glanceability without losing the Nafs framework.
- **Tabbed time-window control** (Today / Week / Month) gives the user agency to switch contexts without leaving the home.
- **Quick-log FAB** dramatically lowers the friction for capturing an emotion or note — a known UX lever in habit-tracker retention.
- **Cleanest visual hierarchy** — fewer competing cards = faster comprehension.

### B.6 Trade-offs of Option B

- **Circular radial chart is a re-build of the existing arc** — not a drop-in. The arc meter (the existing IP) is replaced; this is a meaningful aesthetic shift away from "antique instrument" toward "modern dial".
- **Hijri event chip strip** is absent — replaced by the prayer strip. Ramadan / Ashura awareness moves to the Insights screen.
- **Sheikh/Murabbi whisper** moves to the Insights screen (less prominent than Option A).
- **No tabs on Prescription** — the user sees one piece (Ayah *or* Hadith *or* Dhikr) chosen by algorithm, not all three.

---

## Part 4 — Side-by-Side Comparison

| Dimension | Current | Option A — Suluk | Option B — Qalb |
|---|---|---|---|
| **Aesthetic** | Functional green dashboard | Heritage-modern (emerald + gold + parchment) | Modern minimal (cream + teal + saffron) |
| **Primary hero** | Nafs Arc Meter | Nafs Arc Meter (gold-rimmed) + 4-station track | Nafs Radial Chart + score numeral |
| **Prescription** | Single Quran of the Day card | 3-tab (Ayah / Hadith / Dhikr) | 1-card auto-selected by Nafs |
| **Dhikr** | Section with hero + 15-day chart + Allah-Name cards | Compact hero + inline counter + chip row | Compact hero + inline counter |
| **Habits** | Horizontal scroll strip | Vertical list | Compact row |
| **Prayer times** | ❌ | Slim chip strip (event-aware, not time-aware) | Full 5-column prayer strip (killer feature) |
| **Hijri events** | Date only | Chip strip (Ramadan / Jumu'ah / Ashura / Mon-Thu) | Removed (moved to Insights) |
| **Quran of the Day** | Always shown | Inside Prescription tabs | Inside Quick-log grid |
| **Streak** | Plain grey row | Celebrated + 30-day sparkline | Compact + 7-day sparkline |
| **Sheikh/Murabbi** | ❌ | Inline whisper on Home | Moved to Insights |
| **Quick-log FAB** | ❌ | ❌ | ✅ (emotion / dhikr / note) |
| **Time-window control** | ❌ | ❌ | ✅ (Today / Week / Month) |
| **Bottom nav** | ❌ (AppBar icons only) | ✅ (5 tabs) | ✅ (5 tabs) |
| **Dark mode** | Defined, not wired | Wired (alongside parchment) | Wired (alongside teal) |
| **New components** | n/a | ~8 new | ~8 new |
| **Implementation cost** | n/a | High | Medium-high |
| **Best for** | n/a | Depth-seeking user | Speed-seeking user |
| **Differentiates from** | Muslim Pro genre | Dhikr & Dua + Tarteel | Muslim Pro + WeMuslim |

---

## Part 5 — Common Decisions Required Before Implementation

Regardless of which option (or hybrid) is chosen, these decisions must be locked first:

1. **Auth + display-name source.** Currently the greeting never shows a name. Either ship a "Set your name" onboarding step or accept anonymous.
2. **Dark mode wire-up.** `MaterialApp.themeMode: ThemeMode.system` is one-line. Pick a dark palette (parchment→deep ink for A; cream→charcoal for B).
3. **Prayer-time integration.** Add `adhan` / `adhan_dart` package? Or link to OS calendar? Or stick with the existing habit-tracker for prayers?
4. **Audio for the day's dhikr/verse.** New `assets/audio/` directory; ship with a few sample clips.
5. **Quick-log data model.** A `QuickLog` entity (emotion / dhikr / note) needs to be added to the schema if the FAB ships.
6. **Bottom nav routes.** Which 5 screens? (Current 7 routes: home, heart-graph, history, settings, checkin, nafs-detail, habits, journey, intervention, reflect, pathways.) Pick the canonical 5.
7. **Hijri-event JSON.** `assets/data/hijri_events.json` (or a `HijriEvent` resolver) — Ramadan/Jumu'ah/Ashura/Mon-Thu/Dhul Hijjah rule set.
8. **Scholar review.** Both options touch user-facing copy. Both need RI-style sign-off before shipping.

---

## Part 6 — Recommendation

If forced to pick **one** for v1.1:

> **Go with Option B (Qalb) as the primary redesign, with Option A's Hijri event chip strip and Sheikh whisper folded in.**

Reasoning:
- Option B directly addresses the #1 competitive gap (no prayer-time surface) and #2 competitive gap (no quick-log) — both proven retention levers.
- Option B's clean visual hierarchy matches modern Muslim-user expectations (WeMuslim / Tarteel / Sadiq) while still centering the Nafs IP.
- Option A's Hijri event chip and Sheikh whisper are small additions (~2 widgets) that fit cleanly on top of Option B.
- Option A's 3-tab prescription card and gold ornament are *nice-to-have* depth; they can ship in v1.2 once the data is curated.

Hybrid sketch:

```
[ Top: greeting + Hijri event chip (from A) ]
[ Hero: Nafs Radial Chart (from B) + station track ]
[ Next Prayer strip (from B — killer feature) ]
[ Today's Prescription (single card from B, but expanded to 3 mini-cards inline) ]
[ Quick-log grid (from B) ]
[ Anchors row (from B) ]
[ Streak bar (from B) ]
[ Sheikh whisper at bottom (from A) ]
[ Bottom nav (5 tabs) ]
[ FAB (from B) ]
```

---

## Part 7 — Out of Scope for This Audit

- No code changes were made.
- No implementation tickets were filed.
- No Figma mocks were generated.
- All wireframes are ASCII; visual specs are textual.
- The two options are mutually exclusive at the component level but a hybrid is sketched in §6.

---

## Appendix — Files referenced during the audit

- `lib/src/presentation/screens/home/home_screen.dart`
- `lib/src/presentation/screens/home/widgets/home_greeting_widget.dart`
- `lib/src/presentation/screens/home/widgets/today_habits_strip.dart`
- `lib/src/presentation/screens/home/widgets/daily_dhikr_section.dart`
- `lib/src/presentation/widgets/specific/nafs_arc_meter.dart`
- `lib/src/presentation/widgets/specific/heart_health_score_widget.dart`
- `lib/src/presentation/widgets/specific/quran_of_the_day_card.dart`
- `lib/src/presentation/widgets/specific/tazkiya_safe_banner.dart`
- `lib/src/presentation/screens/home/widgets/next_action_card.dart`  ← shipped but unused on Home
- `lib/src/presentation/viewmodels/home_view_model.dart`
- `lib/src/presentation/viewmodels/home_habits_view_model.dart`
- `lib/src/presentation/theme/colors.dart`
- `HeartOS/HOME_PAGE_IMPROVEMENT_PLAN.md`  (existing, mostly delivered)
- `docs/scholar-audit-remediation-plan.md`  (RI-5.1, RI-5.3, RI-3.3 referenced)