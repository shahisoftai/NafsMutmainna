# `habit_logs` — Daily Habit Completion

> One row per (day × habit) marking whether the user completed the habit.
> Feeds the 7-day completion rate that drives the HabitScore component of the Nafs.
> **Source:** `HeartOS/04_user_tables/habit_logs.md`
> **Status:** Runtime table — empty at build, populated by user ticks.

---

## Schema

| Col | Type | Notes |
|---|---|---|
| `Record_ID` | INTEGER PK | autoincrement |
| `Date` | DATE | |
| `Habit_ID` | INTEGER FK → `habits` | ON DELETE CASCADE |
| `Completed` | BOOLEAN | 0 = not done, 1 = done |

A unique index on `(Date, Habit_ID)` ensures one row per (day × habit).

---

## How Rows Are Populated

Rows are created in **three** ways:

### 1. Daily reminder (manual)
The user opens the app, sees the "Today's habits" card on Home, and ticks off completed habits. Each tick creates (or updates) a row with `Completed = 1`.

### 2. Auto-detect (v1.1)
If a habit is "Fajr on time", the system can auto-detect the prayer time and create the row. Requires notification permissions. Not in v1.0.

### 3. Bulk edit
A user can tap "Mark all as done" on the Home card. This creates rows for all habits with `Completed = 1`.

---

## The "Today's Habits" View

```sql
SELECT h.Habit_ID, h.Name, h.Category,
       COALESCE(hl.Completed, 0) AS Completed
FROM habits h
LEFT JOIN habit_logs hl
  ON hl.Habit_ID = h.Habit_ID AND hl.Date = ?
ORDER BY h.Category, h.Name;
```

This is the query behind the Home card. The `LEFT JOIN` ensures habits without a log row show up as "not done" (default 0).

---

## The 7-Day Completion Rate (per habit)

```sql
SELECT
  AVG(Completed) AS rate
FROM habit_logs
WHERE Habit_ID = ?
  AND Date >= date('now', '-7 day');
```

A user who has completed Fajr 5/7 days in the last week has a 71% rate for that habit.

---

## The 7-Day Completion Rate (overall)

```sql
SELECT
  SUM(Completed) * 1.0 / (COUNT(*) * 1.0) AS overall_rate
FROM habit_logs
WHERE Date >= date('now', '-7 day');
```

This is the **single number** that drives the HabitScore. It is bucketed into 4 tiers (see `habits.md` §10).

---

## Forward-fill Behaviour

Unlike `nafs_history`, `habit_logs` is **not** forward-filled. A missing row means "not logged" — which is treated as "not completed" in the rate calculation.

This is intentional: a user who doesn't open the app on a given day has not ticked off their habits.

---

## Cardinality

| Side | Cardinality |
|---|---|
| A day | N rows where N = number of habits defined (typically 4–6) |
| A user (lifetime) | N × `days_used` rows |
| 1 year of 5-habit use | ~1,825 rows |
| 5 years of 5-habit use | ~9,125 rows |

A decade of heavy use is ~18,000 rows — trivially fast to query.

---

## Example Rows (Illustrative)

For a user with 4 habits on 3 consecutive days:

| Record_ID | Date | Habit_ID | Completed |
|---:|---|---:|---|
| 1 | 2026-06-12 | 1 (Fajr) | 1 |
| 2 | 2026-06-12 | 2 (Quran) | 1 |
| 3 | 2026-06-12 | 3 (Morning adhkar) | 0 |
| 4 | 2026-06-12 | 4 (Evening adhkar) | 1 |
| 5 | 2026-06-13 | 1 (Fajr) | 1 |
| 6 | 2026-06-13 | 2 (Quran) | 0 |
| 7 | 2026-06-13 | 3 (Morning adhkar) | 1 |
| 8 | 2026-06-13 | 4 (Evening adhkar) | 1 |
| 9 | 2026-06-14 | 1 (Fajr) | 0 |
| 10 | 2026-06-14 | 2 (Quran) | 1 |
| 11 | 2026-06-14 | 3 (Morning adhkar) | 1 |
| 12 | 2026-06-14 | 4 (Evening adhkar) | 0 |

7-day completion rate: Fajr 67%, Quran 67%, Morning 67%, Evening 67% → overall 67% → bucket 2 (Mulhamah-leaning)

> **Note:** These are illustrative. The table starts empty.

---

## Streaks and Achievements

### Per-habit streaks
A "30-day Fajr streak" means 30 consecutive days with `Completed = 1` for the Fajr habit. The system celebrates 7, 30, 100, and 365-day streaks with a small toast.

### Combined streaks
A "perfect week" is 7 consecutive days with all habits completed. Celebrated at 4, 12, and 52-week marks.

### v1.1 gamification
In v1.1, achievements are stored in a new `achievements` table (deferred). v1.0 only shows streak counts on the Home card.

---

## See also

- `HeartOS/04_user_tables/habit_logs.md` — full spec
- `HeartOS/04_user_tables/habits.md` — parent table
- `HeartOS/03_nafs_engine/nafs_meter_algorithm.md` §4 — HabitScore
- `HeartOS/00_root/user_flow.md` §3 — Habits screen
- `HeartOS/08_algorithms/scoring_algorithm.md` — full Nafs formula
