# Heart OS — Scoring Engine (Nafs Meter)

> How a daily check-in moves the four Nafs-state dials, and how the 15-day window is summarised into the single Nafs Meter the user sees on Home.

> ⚠️ **PROPOSAL — subject to tuning.** The weights below are the v1 proposal. The algorithm is wired into the database schema (via `attribute_nafs_weights` and `emotion_nafs_weights`) so the constants can be changed without a migration. See `08_algorithms/scoring_algorithm.md` for the formal pseudo-code.

---

## 1 · The four Nafs states

| ID | Name | Arabic | Description (one line) |
|---|---|---|---|
| 1 | Ammarah | النفس الأمّارة | The soul that commands evil — base desires dominate. |
| 2 | Lawwamah | النفس اللوّامة | The self-reproaching soul — conscience is active. |
| 3 | Mulhamah | النفس الملهمة | The inspired soul — receives ilham from Allah. |
| 4 | Mutmainnah | النفس المطمئنة | The tranquil soul — at peace with Allah. |

The user is **always a mix of all four**; the meter shows the *dominant* one. The values across the four always sum to 100 (per day).

---

## 2 · The meter

```
   Ammarah      Lawwamah      Mulhamah      Mutmainnah
   ████░░       ████████      ███░░░░░      ██░░░░░░
   12%          48%           24%           16%

   ↳ Dominant today: LAWWAHAMAH  (self-reproaching — good sign, room to grow)
```

### 2.1 Visual rules

- The **dominant** state is shown in saturated colour.
- The other three are desaturated.
- The arc's pointer sits over the dominant segment.
- Numeric % is shown on tap / long-press.

### 2.2 Movement rules

- Movement is **smooth** (no day-to-day jumps larger than ±5%).
- A 7-day streak of positive emotions is required to advance from Lawwamah → Mulhamah.
- A 30-day streak is required to advance from Mulhamah → Mutmainnah.
- A single high-intensity negative check-in never drops the user more than 1 segment.

---

## 3 · Daily Nafs calculation

The v1 proposed formula blends four signals. **All weights are subject to empirical tuning.**

```
   Nafs_today = 0.50 × AttributeScore
              + 0.20 × EmotionScore
              + 0.20 × HabitScore
              + 0.10 × TrendScore
```

### 3.1 `AttributeScore` (50%)

For each attribute detected today (via `emotion_attribute_links` and the current `checkins`):

```
   contribution_attr = Weight(emotion→attr) × Intensity(checkin) × NafsBias(attr)
```

`NafsBias(attr)` is a 4-vector from `attribute_nafs_weights` (sum = 1.0). The weighted sum across all detected attributes yields a 4-vector.

### 3.2 `EmotionScore` (20%)

Directly from `emotion_nafs_weights` for the emotions logged today, weighted by `Intensity`.

### 3.3 `HabitScore` (20%)

A simple deterministic mapping:

| Habit completion rate (last 7 days) | Nafs vector bias |
|---|---|
| ≥ 80% | (+0, +0.10, +0.20, +0.70) |
| 50–80% | (+0, +0.30, +0.50, +0.20) |
| 20–50% | (+0.20, +0.60, +0.20, +0.0) |
| < 20% | (+0.60, +0.40, +0.0, +0.0) |

### 3.4 `TrendScore` (10%)

Compares today to the 14-day average:

```
   delta = Nafs_today - Nafs_14day_avg
   if delta · positiveDirection > 0:  TrendScore nudges that direction by 0.05
```

---

## 4 · The 15-day window

```
   ┌───────────────────────────────────────────────┐
   │  D-14  D-13  …   D-1   D-0                   │
   │  ░░    ▓▓    …   ██    ██                      │
   │                                               │
   │  → Nafs_meter = weighted_average(daily Nafs)  │
   │    with weights decaying linearly from 1.0     │
   │    (D-0) to 0.2 (D-14).                       │
   └───────────────────────────────────────────────┘
```

The **weighted moving average** ensures that recent days count for more, but the user is never judged on a single day.

### 4.1 Streak detection

- A **positive streak** is `N consecutive days with dominant Nafs ≥ Mulhamah`.
- A **regression streak** is `N consecutive days with dominant Nafs = Ammarah`.
- Streaks longer than 3 trigger:
  - A celebration card on Home (positive).
  - A gentle Pathway recommendation (regression).

---

## 5 · Edge cases

| Situation | Algorithm response |
|---|---|
| First ever check-in | Use 14-day average = (0, 1, 0, 0); TrendScore = 0; meter defaults to Lawwamah. |
| User missed 3 days | Use rolling 15-day window; gaps are filled with the previous day's value (forward-fill). |
| User logged 5 emotions today | Sum all `EmotionScore` contributions, then re-normalise so the four Nafs values still sum to 1. |
| All weights sum to 0 (e.g. only neutral emotion logged) | Return last known daily Nafs unchanged. |

---

## 6 · Where the algorithm lives in code

| Component | Path |
|---|---|
| Pure-Dart scoring function | `lib/src/domain/usecases/nafs/compute_daily_nafs.dart` |
| 15-day rolling window | `lib/src/domain/usecases/nafs/rolling_window.dart` |
| Nafs meter widget | `lib/src/presentation/widgets/specific/nafs_meter.dart` |
| Streak detection | `lib/src/domain/usecases/nafs/streak.dart` |
| Unit tests | `test/unit/domain/usecases/nafs/*` |

The function is **pure** — no IO, no clock. The caller injects today's date and the relevant rows; the function returns a 4-vector. This is what makes it 100% unit-testable.
