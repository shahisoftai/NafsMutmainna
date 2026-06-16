# `nafs_history` — The 15-Day Nafs Diary

> The daily snapshot of the user's Nafs state. The single most important user table — every chart, streak, and the Home meter reads from here.

---

## 1 · Purpose

`nafs_history` stores the **daily Nafs vector** computed by the algorithm in `../03_nafs_engine/nafs_meter_algorithm.md`. One row per day, four values (Ammarah, Lawwamah, Mulhamah, Mutmainnah) summing to 1.0.

The 15-day meter on the Home screen is a **weighted moving average** of the last 15 rows. The Analytics screen reads this table for all historical charts.

## 2 · Schema

| Col | Type | Notes |
|---|---|---|
| `Record_ID` | INTEGER PK | autoincrement |
| `Date` | DATE | unique per day |
| `Ammarah` | REAL | 0.0 – 1.0 |
| `Lawwamah` | REAL | 0.0 – 1.0 |
| `Mulhamah` | REAL | 0.0 – 1.0 |
| `Mutmainnah` | REAL | 0.0 – 1.0 |

A unique constraint on `Date` ensures exactly one row per day.

## 3 · How rows are populated

The daily Nafs is computed at the end of each check-in (synchronously). The algorithm:

1. Reads `checkins`, `detected_attributes`, `habit_logs` for the day.
2. Combines `attribute_nafs_weights`, `emotion_nafs_weights` per the 50/20/20/10 formula.
3. Stores the result in `nafs_history`.

```python
def update_nafs_history(date: Date):
    v = daily_nafs(date)   # see nafs_meter_algorithm.md
    sql("""
        INSERT INTO nafs_history (Date, Ammarah, Lawwamah, Mulhamah, Mutmainnah)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(Date) DO UPDATE SET
          Ammarah = excluded.Ammarah,
          Lawwamah = excluded.Lawwamah,
          Mulhamah = excluded.Mulhamah,
          Mutmainnah = excluded.Mutmainnah
    """, date, v.A, v.L, v.M, v.T)
```

The upsert handles the case where the user logs multiple check-ins on the same day — the row is updated, not duplicated.

## 4 · The 15-day meter (read query)

```sql
WITH recent AS (
  SELECT Ammarah, Lawwamah, Mulhamah, Mutmainnah,
         (15 - julianday(?) + julianday(Date)) AS day_age
  FROM nafs_history
  WHERE Date BETWEEN date(?, '-14 day') AND ?
),
weighted AS (
  SELECT
    SUM(Ammarah    * (1.0 - day_age * 0.8 / 14)) / SUM(1.0 - day_age * 0.8 / 14) AS A,
    SUM(Lawwamah   * (1.0 - day_age * 0.8 / 14)) / SUM(1.0 - day_age * 0.8 / 14) AS L,
    SUM(Mulhamah   * (1.0 - day_age * 0.8 / 14)) / SUM(1.0 - day_age * 0.8 / 14) AS M,
    SUM(Mutmainnah * (1.0 - day_age * 0.8 / 14)) / SUM(1.0 - day_age * 0.8 / 14) AS T
  FROM recent
)
SELECT A, L, M, T FROM weighted;
```

This returns the **4-vector** shown on the Home screen. Today weighs 1.0, 14 days ago weighs 0.2.

## 5 · Forward-fill for missing days

If the user misses 3 days, the 15-day query will have 12 rows. The weighted average is computed over those 12 — there is no forward-fill at the database level.

However, the **Home screen** visually shows a 15-day bar chart with the missing days rendered in a desaturated style. The chart code applies a forward-fill for display purposes (so the user sees a continuous bar, not a gap).

## 6 · Streak detection

A **positive streak** is *N consecutive days with `Mulhamah + Mutmainnah > 0.55`*. A **regression streak** is *N consecutive days with `Ammarah > 0.50`*.

```sql
WITH ranked AS (
  SELECT Date, Ammarah, Mulhamah + Mutmainnah AS H,
         ROW_NUMBER() OVER (ORDER BY Date) -
         ROW_NUMBER() OVER (PARTITION BY (Mulhamah + Mutmainnah > 0.55) ORDER BY Date) AS grp
  FROM nafs_history
  WHERE Date >= date('now', '-30 day')
)
SELECT MIN(Date), MAX(Date), COUNT(*) AS days
FROM ranked
WHERE H > 0.55
GROUP BY grp
ORDER BY days DESC;
```

The longest current streak of Mulhamah-dominant days is the user's "current positive streak". The Home screen shows this on the streak card.

## 7 · Trend calculation

A 7-day or 15-day trend is a simple linear regression slope on the `Mutmainnah` column:

```sql
SELECT
  (COUNT(*) * SUM(Date_Ordinal * Mutmainnah) - SUM(Date_Ordinal) * SUM(Mutmainnah)) /
  (COUNT(*) * SUM(Date_Ordinal * Date_Ordinal) - SUM(Date_Ordinal) * SUM(Date_Ordinal)) AS slope
FROM (
  SELECT julianday(Date) AS Date_Ordinal, Mutmainnah
  FROM nafs_history
  WHERE Date >= date('now', '-15 day')
);
```

A positive slope = improving. A negative slope = declining. A zero slope = stable.

## 8 · Visualisations driven by this table

| Chart | Window | Aggregation |
|---|---|---|
| Home — 15-day meter | 15 days | weighted moving average |
| Home — 7-day streak card | 30 days | consecutive-day query |
| History — 30-day stacked area | 30 days | none (raw) |
| History — 90-day line chart (Mutmainnah) | 90 days | linear regression slope |
| Analytics — All-time distribution | all days | percentage of days in each Nafs state |

## 9 · Cardinality

| Side | Cardinality |
|---|---|
| A user (lifetime) | 1 × `days_used` rows |
| A year of use | ~365 rows |
| 5 years of use | ~1 825 rows |

The table is small. A user with 10 years of use will have ~3 650 rows — still trivially fast to read.

## 10 · Initial value (first launch)

On the first launch (no check-in yet), the meter defaults to a **Lawwamah baseline**:

```
   Ammarah = 0.10
   Lawwamah = 0.60
   Mulhamah = 0.20
   Mutmainnah = 0.10
```

This is a **single row** inserted into `nafs_history` with `Date = today`, even before the user logs a check-in. It is overwritten on the first check-in.

## 11 · Edge cases

| Situation | Handled how |
|---|---|
| First ever check-in | The baseline row is updated with the real Nafs. |
| User deletes all check-ins | The `nafs_history` row is reset to the Lawwamah baseline. |
| User misses 14+ days | The 15-day meter is computed over the (small) available data. |
| All four values are 0 (impossible by algorithm) | Clamped to (0.25, 0.25, 0.25, 0.25). |
| User's clock jumps backward | The unique constraint on `Date` rejects duplicate days. |
| User uninstalls and reinstalls | All data is wiped. The baseline is re-inserted on first launch. |

## 12 · Implementation notes

- The table is created by `migrations/v1.dart`.
- The unique constraint on `Date` is enforced via a `UNIQUE` clause.
- The cascade delete is **not** implemented — deleting a `checkins` row does **not** delete the `nafs_history` row. Instead, the algorithm is re-run on the remaining check-ins for that day.
- The forward-fill for missing days is a **display-time** computation, not a write-time mutation.

## 14 · See also

- `../03_nafs_engine/nafs_meter_algorithm.md` — the algorithm that produces these rows.
- `../03_nafs_engine/attribute_nafs_weights.md` and `emotion_nafs_weights.md` — the underlying matrices.
- `checkins.md`, `detected_attributes.md`, `interventions_history.md` — the inputs.
- `../00_root/user_flow.md` §2.1 — the Home screen UX.
- `../08_algorithms/trend_algorithm.md` — the trend calculation.
