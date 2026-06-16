# Scoring Algorithm

> The full algorithm that produces a daily Nafs vector. Formal pseudo-code and test cases for the implementation in `lib/src/domain/usecases/nafs/`.

> ⚠️ **PROPOSAL — subject to tuning.** The weights below are the v1 proposal. They live in the database (`attribute_nafs_weights`, `emotion_nafs_weights`) and in `lib/src/domain/usecases/nafs/constants.dart`. They can be adjusted without a migration.

---

## 1 · Signature

```python
def daily_nafs(date: Date) -> Vector4:
    """
    Compute the daily Nafs vector for a given date.

    Returns a 4-tuple (Ammarah, Lawwamah, Mulhamah, Mutmainnah)
    that sums to 1.0.
    """
```

## 2 · The full algorithm

```python
def daily_nafs(date: Date) -> Vector4:
    a = attribute_score(date)   # 50%
    e = emotion_score(date)     # 20%
    h = habit_score(date)       # 20%
    t = trend_score(date)       # 10%

    blend = 0.50 * a + 0.20 * e + 0.20 * h + 0.10 * t
    return blend.normalise()
```

## 3 · `attribute_score`

```python
def attribute_score(date: Date) -> Vector4:
    rows = sql.query("""
        SELECT anw.Ammarah, anw.Lawwamah, anw.Mulhamah, anw.Mutmainnah, da.Score
        FROM detected_attributes da
        JOIN attribute_nafs_weights anw ON anw.Attribute_ID = da.Attribute_ID
        WHERE da.Date = ?
    """, date)

    if not rows:
        return NEUTRAL

    total = Vector4(0, 0, 0, 0)
    for r in rows:
        total += Vector4(r.Ammarah, r.Lawwamah, r.Mulhamah, r.Mutmainnah) * r.Score
    return total.normalise()
```

### 3.1 NEUTRAL constant

```python
NEUTRAL = Vector4(0.25, 0.25, 0.25, 0.25)
```

Used when:
- The user has no detected attributes for the day (neutral check-in).
- All detected attributes have score 0 (impossible in practice).
- A bug zeroes out the table (defensive default).

## 4 · `emotion_score`

```python
def emotion_score(date: Date) -> Vector4:
    rows = sql.query("""
        SELECT enw.Ammarah, enw.Lawwamah, enw.Mulhamah, enw.Mutmainnah, c.Intensity
        FROM checkins c
        JOIN emotion_nafs_weights enw ON enw.Emotion_ID = c.Emotion_ID
        WHERE c.Date = ?
    """, date)

    if not rows:
        return NEUTRAL

    total = Vector4(0, 0, 0, 0)
    for r in rows:
        mult = r.Intensity / 10.0
        total += Vector4(r.Ammarah, r.Lawwamah, r.Mulhamah, r.Mutmainnah) * mult
    return total.normalise()
```

## 5 · `habit_score`

```python
HABIT_BIAS = [
    (0.60, 0.40, 0.00, 0.00),   # bucket 0: < 20% completion
    (0.20, 0.60, 0.20, 0.00),   # bucket 1: 20–50%
    (0.00, 0.30, 0.50, 0.20),   # bucket 2: 50–80%
    (0.00, 0.10, 0.20, 0.70),   # bucket 3: ≥ 80%
]

def habit_score(date: Date) -> Vector4:
    end = date
    start = date - timedelta(days=7)
    total_habits = sql.count("SELECT COUNT(*) FROM habits")
    if total_habits == 0:
        return Vector4(*HABIT_BIAS[0])   # no habits → bucket 0

    completed = sql.count("""
        SELECT COUNT(*) FROM habit_logs
        WHERE Date BETWEEN ? AND ? AND Completed = 1
    """, start, end)

    rate = completed / (total_habits * 7)
    bucket = min(3, int(rate * 4))
    return Vector4(*HABIT_BIAS[bucket])
```

## 6 · `trend_score`

> ⚠️ **Implementation note:** The pseudo-code below reflects the implementation in
> `lib/src/domain/usecases/nafs/compute_daily_nafs.dart`.  It differs from an
> earlier draft that compared "today vs 14-day weighted average" (which is
> non-causal: it would require today's `nafs_history` row to already exist before
> the daily computation begins).  The current approach splits the *previous* window
> into two halves, which is fully causal and works correctly on sparse history.

```python
def trend_score(date: Date) -> Vector4:
    # Look at the previous trendWindowDays (14) of history — not including today.
    end   = date - timedelta(days=1)
    start = end   - timedelta(days=TREND_WINDOW_DAYS - 1)

    rows = sql.query("""
        SELECT Ammarah, Lawwamah, Mulhamah, Mutmainnah
        FROM nafs_history
        WHERE Date BETWEEN ? AND ?
        ORDER BY Date ASC
    """, start, end)

    if not rows:
        return NEUTRAL

    # Split into older half and recent half.
    half   = len(rows) // 2
    older  = rows[:half]
    recent = rows[half:]

    def avg(xs):
        if not xs:
            return NEUTRAL
        v = sum(Vector4(*r) for r in xs)
        return v * (1.0 / len(xs))

    r = avg(recent)
    o = avg(older)

    # Delta on higher Nafs stations (Mulhamah + Mutmainnah).
    deltaM = (r.Mulhamah + r.Mutmainnah) - (o.Mulhamah + o.Mutmainnah)
    nudge  = deltaM * TREND_NUDGE_SIZE   # default 0.05

    if abs(nudge) < 0.001:
        return NEUTRAL

    if nudge > 0:
        # Improving: nudge away from Ammarah/Lawwamah toward Mulhamah/Mutmainnah.
        return Vector4(0.5 - nudge / 2, 0.5 - nudge / 2, nudge / 2, nudge / 2)
    else:
        # Declining: nudge toward Ammarah/Lawwamah.
        n = abs(nudge)
        return Vector4(0.5 + n / 2, 0.5 + n / 2, 0, 0)
```

**Constants:**

| Constant | Value | Location |
|---|---|---|
| `TREND_WINDOW_DAYS` | 14 | `constants.dart` |
| `TREND_NUDGE_SIZE` | 0.05 | `constants.dart` |

## 7 · The 15-day meter (read query)

```python
def meter_15day(date: Date) -> Vector4:
    rows = sql.query("""
        SELECT Ammarah, Lawwamah, Mulhamah, Mutmainnah
        FROM nafs_history
        WHERE Date BETWEEN ? AND ?
        ORDER BY Date DESC
    """, date - timedelta(days=14), date)

    if not rows:
        return NEUTRAL

    weights = [1.0 - (i * 0.8 / 14) for i in range(len(rows))]
    total = sum(Vector4(*r) * w for r, w in zip(rows, weights))
    return (total / sum(weights)).normalise()
```

## 8 · The `Vector4` class

```python
class Vector4:
    def __init__(self, a, l, m, t):
        self.A = a
        self.L = l
        self.M = m
        self.T = t

    def __add__(self, other):
        return Vector4(self.A + other.A, self.L + other.L,
                       self.M + other.M, self.T + other.T)

    def __mul__(self, scalar):
        return Vector4(self.A * scalar, self.L * scalar,
                       self.M * scalar, self.T * scalar)

    def normalise(self):
        s = self.A + self.L + self.M + self.T
        if s == 0:
            return NEUTRAL
        return Vector4(self.A / s, self.L / s, self.M / s, self.T / s)
```

## 9 · Test cases

### 9.1 First launch (no data)

```
Given:  no check-ins, no habits, no nafs_history
When:   daily_nafs(today)
Then:   returns NEUTRAL = (0.25, 0.25, 0.25, 0.25)
```

### 9.2 Single check-in (Anger 7)

```
Given:  1 check-in (Anger, 7), 0 habits
When:   daily_nafs(today)
Then:   attribute_score ≈ (0.50, 0.40, 0.08, 0.02)
        emotion_score   ≈ (0.49, 0.25, 0.21, 0.05)
        habit_score     ≈ (0.60, 0.40, 0.00, 0.00)
        trend_score     ≈ (0, 0, 0, 0)  (no history)
        blend           ≈ (0.50, 0.34, 0.10, 0.06)
        normalised      ≈ (0.50, 0.34, 0.10, 0.06)
```

### 9.3 Habit-heavy day (5/5 habits, Gratitude 6)

```
Given:  1 check-in (Gratitude, 6), 5/5 habits completed
When:   daily_nafs(today)
Then:   attribute_score ≈ (0.02, 0.10, 0.35, 0.53)
        emotion_score   ≈ (0.01, 0.05, 0.30, 0.64)
        habit_score     ≈ (0, 0.10, 0.20, 0.70)
        trend_score     ≈ (0, 0, 0, 0)
        blend           ≈ (0.01, 0.09, 0.29, 0.61)
        normalised      ≈ (0.01, 0.09, 0.29, 0.61)
```

### 9.4 Multi-day stability

```
Given:  7 consecutive days of moderate Gratitude + 5/5 habits
When:   daily_nafs(day 7)
Then:   meter_15day returns Mulhamah-dominant vector
        streak detection reports a 7-day positive streak
```

## 10 · Performance

| Step | Time |
|---|---|
| `attribute_score` | < 5 ms |
| `emotion_score` | < 5 ms |
| `habit_score` | < 10 ms |
| `trend_score` | < 5 ms |
| `meter_15day` | < 5 ms |
| **Total** | **< 30 ms** |

Real-time on every Home screen render.

## 11 · Determinism guarantee

The algorithm is **deterministic**: given the same inputs, it always returns the same output. This is enforced by:

1. **No randomness** — no `random()` calls.
2. **No time-of-day** — only the `date` parameter.
3. **No network** — all inputs are local.
4. **No clock drift** — `date` is passed in by the caller.

This makes the algorithm **100% unit-testable** and **reproducible** for debugging.

## 12 · Tunable constants

| Constant | Value | Location |
|---|---|---|
| AttributeScore weight | 0.50 | `constants.dart` |
| EmotionScore weight | 0.20 | `constants.dart` |
| HabitScore weight | 0.20 | `constants.dart` |
| TrendScore weight | 0.10 | `constants.dart` |
| 15-day window | 15 | `constants.dart` |
| 14-day trend window | 14 | `constants.dart` |
| 7-day habit window | 7 | `constants.dart` |
| Trend nudge size | 0.05 | `constants.dart` |

## 13 · See also

- `../03_nafs_engine/nafs_meter_algorithm.md` — the conceptual walkthrough.
- `trend_algorithm.md` — the trend sub-algorithm in detail.
- `severity_algorithm.md` — the emotion severity amplifier.
- `recommendation_algorithm.md` — the recommendation side.
- `../04_user_tables/nafs_history.md` — where the result is stored.
