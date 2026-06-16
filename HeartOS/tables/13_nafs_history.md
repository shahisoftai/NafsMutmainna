# `nafs_history` — The 15-Day Nafs Diary

> The daily snapshot of the user's Nafs state. One row per day, four values (Ammarah, Lawwamah, Mulhamah, Mutmainnah) summing to 1.0.
> **Source:** `HeartOS/04_user_tables/nafs_history.md`
> **Status:** Runtime table — empty at build, populated by the daily Nafs algorithm.

---

## Schema

| Col | Type | Notes |
|---|---|---|
| `Record_ID` | INTEGER PK | autoincrement |
| `Date` | DATE | unique per day |
| `Ammarah` | REAL | 0.0 – 1.0 |
| `Lawwamah` | REAL | 0.0 – 1.0 |
| `Mulhamah` | REAL | 0.0 – 1.0 |
| `Mutmainnah` | REAL | 0.0 – 1.0 |

A unique constraint on `Date` ensures exactly one row per day.

---

## How Rows Are Populated

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

---

## The 50/20/20/10 Formula

| Component | Weight | Source |
|---|---:|---|
| AttributeScore | 50% | `detected_attributes` × `attribute_nafs_weights` |
| EmotionScore | 20% | `checkins` × `emotion_nafs_weights` × (Intensity/10) |
| HabitScore | 20% | `habit_logs` 7-day completion rate → bucketed Nafs vector |
| TrendScore | 10% | Linear regression slope of past 7 days |

The final vector is normalised to sum to 1.0.

---

## The 15-Day Meter (read query)

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

---

## Initial Value (first launch)

On the first launch (no check-in yet), the meter defaults to a **Lawwamah baseline**:

```
Ammarah = 0.10
Lawwamah = 0.60
Mulhamah = 0.20
Mutmainnah = 0.10
```

This is a **single row** inserted into `nafs_history` with `Date = today`, even before the user logs a check-in. It is overwritten on the first check-in.

---

## Example Rows (Illustrative)

| Record_ID | Date | Ammarah | Lawwamah | Mulhamah | Mutmainnah |
|---:|---|---:|---:|---:|---:|
| 1 | 2026-06-10 | 0.10 | 0.60 | 0.20 | 0.10 | (baseline, no check-in)
| 2 | 2026-06-11 | 0.18 | 0.55 | 0.20 | 0.07 | (logged Anxiety + Sadness)
| 3 | 2026-06-12 | 0.12 | 0.48 | 0.28 | 0.12 | (logged Gratitude + mild Sadness)
| 4 | 2026-06-13 | 0.08 | 0.35 | 0.37 | 0.20 | (good day: Patience + Tranquility)

> **Note:** These are illustrative. The table starts empty (except the baseline row on first launch).

---

## Streak Detection

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

---

## Visualisations Driven by This Table

| Chart | Window | Aggregation |
|---|---|---|
| Home — 15-day meter | 15 days | weighted moving average |
| Home — 7-day streak card | 30 days | consecutive-day query |
| History — 30-day stacked area | 30 days | none (raw) |
| History — 90-day line chart | 90 days | linear regression slope |
| Analytics — All-time distribution | all days | percentage of days in each state |

---

## See also

- `HeartOS/04_user_tables/nafs_history.md` — full spec
- `HeartOS/03_nafs_engine/nafs_meter_algorithm.md` — the algorithm
- `HeartOS/03_nafs_engine/attribute_nafs_weights.md` and `emotion_nafs_weights.md`
- `HeartOS/04_user_tables/checkins.md` · `detected_attributes.md` · `habit_logs.md` — inputs
- `HeartOS/00_root/user_flow.md` §2.1 — Home screen UX
- `HeartOS/08_algorithms/trend_algorithm.md` — trend calculation
