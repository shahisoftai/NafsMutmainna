# `habit_logs` — Daily Habit Completion

> One row per (day × habit) marking whether the user completed the habit. Feeds the 7-day completion rate that drives the HabitScore component of the Nafs.

---

## 1 · Purpose

`habit_logs` is the **append-only daily log** of habit completion. Each row is a binary "yes/no" for a given habit on a given day. The 7-day completion rate (per habit, then aggregated) is the input to the Nafs engine.

This table is small, fast, and easy to reason about. It is the most "behavioural" of the user tables — what the user actually *does*, not what they *feel* or *plan*.

## 2 · Schema

| Col | Type | Notes |
|---|---|---|
| `Record_ID` | INTEGER PK | autoincrement |
| `Date` | DATE | |
| `Habit_ID` | INTEGER FK → `habits` | ON DELETE CASCADE |
| `Completed` | BOOLEAN | 0 = not done, 1 = done |

A unique index on `(Date, Habit_ID)` ensures one row per (day × habit).

## 3 · How rows are populated

Rows are created in **three** ways:

### 3.1 Daily reminder (manual)

The user opens the app, sees the "Today's habits" card on Home, and ticks off completed habits. Each tick creates (or updates) a row with `Completed = 1`.

### 3.2 Auto-detect (v1.1)

If a habit is "Fajr on time", the system can auto-detect the prayer time and create the row. This requires notification permissions. Not in v1.0.

### 3.3 Bulk edit

A user can tap "Mark all as done" on the Home card. This creates rows for all habits with `Completed = 1`.

## 4 · The "today's habits" view

```sql
SELECT h.Habit_ID, h.Name, h.Category,
       COALESCE(hl.Completed, 0) AS Completed
FROM habits h
LEFT JOIN habit_logs hl
  ON hl.Habit_ID = h.Habit_ID AND hl.Date = ?
ORDER BY h.Category, h.Name;
```

This is the query behind the Home card. The `LEFT JOIN` ensures habits without a log row show up as "not done" (default 0).

## 5 · The 7-day completion rate (per habit)

```sql
SELECT
  AVG(Completed) AS rate
FROM habit_logs
WHERE Habit_ID = ?
  AND Date >= date('now', '-7 day');
```

A user who has completed Fajr 5/7 days in the last week has a 71% rate for that habit.

## 6 · The 7-day completion rate (overall)

```sql
SELECT
  SUM(Completed) * 1.0 / (COUNT(*) * 1.0) AS overall_rate
FROM habit_logs
WHERE Date >= date('now', '-7 day');
```

This is the **single number** that drives the HabitScore. It is bucketed into 4 tiers (see `habits.md` §10).

## 7 · Forward-fill behaviour

Unlike `nafs_history`, `habit_logs` is **not** forward-filled. A missing row means "not logged" — which is treated as "not completed" in the rate calculation.

This is intentional: a user who doesn't open the app on a given day has not ticked off their habits. The system does not assume otherwise.

## 8 · Cardinality

| Side | Cardinality |
|---|---|
| A day | N rows where N = number of habits defined (typically 4–6) |
| A user (lifetime) | N × `days_used` rows |
| 1 year of 5-habit use | ~1 825 rows |
| 5 years of 5-habit use | ~9 125 rows |

Still small. A decade of heavy use is ~18 000 rows — trivially fast to query.

## 9 · How it is queried

### 9.1 "How am I doing on each habit over 30 days?"

```sql
SELECT h.Name, AVG(hl.Completed) AS rate
FROM habits h
LEFT JOIN habit_logs hl
  ON hl.Habit_ID = h.Habit_ID
  AND hl.Date >= date('now', '-30 day')
GROUP BY h.Habit_ID
ORDER BY rate DESC;
```

This is the "habit completion chart" on the Analytics screen (v1.1).

### 9.2 "What is my current habit streak for Fajr?"

```sql
WITH ranked AS (
  SELECT Date, Completed,
         ROW_NUMBER() OVER (ORDER BY Date DESC) AS rn
  FROM habit_logs
  WHERE Habit_ID = ?
)
SELECT MIN(Date), COUNT(*) AS streak
FROM ranked
WHERE Completed = 1
  AND rn = (
    SELECT MIN(rn) FROM ranked WHERE Completed = 0
  );
```

The result is the **current consecutive-day streak** for that habit.

### 9.3 "What habits did I skip yesterday?"

```sql
SELECT h.Name
FROM habits h
LEFT JOIN habit_logs hl
  ON hl.Habit_ID = h.Habit_ID AND hl.Date = date('now', '-1 day')
WHERE hl.Completed IS NULL OR hl.Completed = 0;
```

## 10 · Edge cases

| Situation | Handled how |
|---|---|
| User has 0 habits | The `habit_logs` table is empty. The HabitScore is bucket 0. |
| User adds a habit today | No rows exist for past days. The rate is computed over the days the habit exists. |
| User deletes a habit | Cascade delete removes all logs for it. |
| User marks a habit as "not done" explicitly | The row exists with `Completed = 0`. Counts as 0 in the rate. |
| User changes the date on their device | Future-dated rows are rejected by the app (date is clamped to `today`). |
| User has 50 habits | The denominator is capped at 10 (top 10 most-tracked). |

## 11 · Streaks and achievements

### 11.1 Per-habit streaks

A "30-day Fajr streak" means 30 consecutive days with `Completed = 1` for the Fajr habit. The system celebrates 7, 30, 100, and 365-day streaks with a small toast.

### 11.2 Combined streaks

A "perfect week" is 7 consecutive days with all habits completed. Celebrated at 4, 12, and 52-week marks.

### 11.3 v1.1 gamification

In v1.1, achievements are stored in a new `achievements` table (deferred). v1.0 only shows streak counts on the Home card.

## 13 · Implementation notes

- The table is created by `migrations/v1.dart` (deferred).
- The cascade delete is implemented as a `FOREIGN KEY ... ON DELETE CASCADE` constraint.
- The "today's habits" query is indexed by `(Date, Habit_ID)`.
- The 7-day query is indexed by `(Habit_ID, Date)`.
- The CRUD lives in `lib/src/data/datasources/local/habit_log_datasource.dart`.
- The streak calculation is a pure function in `lib/src/domain/usecases/habits/streak.dart`.

## 14 · See also

- `habits.md` — the parent table.
- `../03_nafs_engine/nafs_meter_algorithm.md` §4 — the HabitScore calculation.
- `../00_root/user_flow.md` §3 — the Habits screen.
- `../08_algorithms/scoring_algorithm.md` — the full Nafs formula.
