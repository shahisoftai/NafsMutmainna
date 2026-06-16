# Trend Algorithm

> The sub-algorithm that computes the 7-day and 15-day trends of the Nafs meter. Used by the Home screen streak card and the Analytics screen.

---

## 1 · What is a "trend"?

A **trend** is a number that summarises the *direction* of the Nafs meter over a window:

- **Positive** — the user is improving.
- **Zero** — the user is stable.
- **Negative** — the user is declining.

The trend is computed as a **linear regression slope** on the `Mutmainnah` column of `nafs_history` over the window. Mutmainnah is chosen because it is the *target* state — improvement means Mutmainnah going up.

## 2 · Linear regression slope

Given points `(x_i, y_i)` where `x_i` is the day index and `y_i` is the Mutmainnah value:

```
   slope = (N · Σ(xy) - Σx · Σy) / (N · Σ(x²) - (Σx)²)
```

In SQL:

```sql
WITH points AS (
  SELECT julianday(Date) AS x, Mutmainnah AS y
  FROM nafs_history
  WHERE Date >= date('now', '-15 day')
)
SELECT
  (COUNT(*) * SUM(x * y) - SUM(x) * SUM(y)) /
  NULLIF(COUNT(*) * SUM(x * x) - SUM(x) * SUM(x), 0) AS slope
FROM points;
```

## 3 · Interpretation

| Slope | Interpretation | UI label |
|---|---|---|
| > +0.005 / day | Improving steadily | 📈 Improving |
| 0 to +0.005 | Slight improvement | ↗ Slight improvement |
| 0 | Stable | → Stable |
| -0.005 to 0 | Slight decline | ↘ Slight decline |
| < -0.005 / day | Declining steadily | 📉 Declining |

The thresholds are **proposed** and will be tuned.

## 4 · Streak detection

A **positive streak** is *N consecutive days with Mulhamah + Mutmainnah > 0.55*.

```sql
WITH classified AS (
  SELECT Date,
         CASE WHEN (Mulhamah + Mutmainnah) > 0.55 THEN 1 ELSE 0 END AS is_positive,
         ROW_NUMBER() OVER (ORDER BY Date) -
         ROW_NUMBER() OVER (PARTITION BY (CASE WHEN (Mulhamah + Mutmainnah) > 0.55 THEN 1 ELSE 0 END) ORDER BY Date) AS grp
  FROM nafs_history
  WHERE Date >= date('now', '-30 day')
)
SELECT MIN(Date), MAX(Date), COUNT(*) AS streak_length
FROM classified
WHERE is_positive = 1
GROUP BY grp
ORDER BY streak_length DESC
LIMIT 1;
```

The longest current positive streak is the user's "current streak".

## 5 · Regression streak

A **regression streak** is *N consecutive days with Ammarah > 0.50*.

```sql
WITH classified AS (
  SELECT Date,
         CASE WHEN Ammarah > 0.50 THEN 1 ELSE 0 END AS is_regression,
         ROW_NUMBER() OVER (ORDER BY Date) -
         ROW_NUMBER() OVER (PARTITION BY (CASE WHEN Ammarah > 0.50 THEN 1 ELSE 0 END) ORDER BY Date) AS grp
  FROM nafs_history
  WHERE Date >= date('now', '-30 day')
)
SELECT COUNT(*) AS streak_length
FROM classified
WHERE is_regression = 1
GROUP BY grp
ORDER BY streak_length DESC
LIMIT 1;
```

## 6 · The 7-day window

The Home screen streak card uses a **7-day window** (instead of 15) for the streak counter. This is because:

- A 7-day streak is the threshold for a "state transition" (Lawwamah → Mulhamah).
- 7 days is psychologically meaningful ("a week of practice").
- It updates more frequently than a 15-day window.

```sql
SELECT COUNT(*) AS seven_day_positive_streak
FROM (
  SELECT Date,
         CASE WHEN (Mulhamah + Mutmainnah) > 0.55 THEN 1 ELSE 0 END AS is_positive
  FROM nafs_history
  ORDER BY Date DESC
  LIMIT 7
)
WHERE is_positive = 1;
```

## 7 · Forward-fill for missing days

The trend algorithm **does not** forward-fill missing days. A user who logs only 3 of the last 7 days will have a 3-point trend, not a 7-point one. The slope is still meaningful (it is the slope of the available data).

For display purposes, the chart **does** forward-fill — the user sees a continuous bar, not a gap. But the underlying trend calculation is honest about the data.

## 8 · Performance

| Query | Time |
|---|---|
| 15-day slope | < 5 ms |
| 7-day positive streak | < 5 ms |
| Regression streak | < 5 ms |
| All three together | < 10 ms |

## 9 · When to show what

| UI | Window | Metric |
|---|---|---|
| Home — streak card | 7 days | positive streak count |
| Home — meter | 15 days | weighted moving average |
| Home — trend chip | 15 days | regression slope + label |
| Analytics — 30-day chart | 30 days | raw values, no aggregation |
| Analytics — 90-day chart | 90 days | raw + linear regression line |

## 10 · Edge cases

| Situation | Handled how |
|---|---|
| Less than 3 days of data | Return "Not enough data" for trend; no streak. |
| User missed 5+ days | Trend is computed over the (small) available data. |
| All values are 0 (impossible by algorithm) | Clamp to NEUTRAL. |
| User's meter has been exactly stable | Slope = 0 → "Stable" label. |
| User's meter is at the boundary (e.g. 0.55 exactly) | Use `>=` not `>` to include the boundary. |

## 11 · Tunable constants

| Constant | Value | Location |
|---|---|---|
| Streak window | 7 days | `constants.dart` |
| Trend window | 15 days | `constants.dart` |
| Positive threshold | M + T > 0.55 | `constants.dart` |
| Regression threshold | A > 0.50 | `constants.dart` |
| Trend label thresholds | ±0.005 | `constants.dart` |

## 12 · See also

- `scoring_algorithm.md` — the daily Nafs algorithm.
- `../03_nafs_engine/nafs_meter_algorithm.md` — the conceptual walkthrough.
- `../04_user_tables/nafs_history.md` — the source table.
- `../00_root/scoring_engine.md` — the home-screen view.
