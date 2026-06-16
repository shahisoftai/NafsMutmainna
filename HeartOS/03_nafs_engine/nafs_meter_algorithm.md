# Nafs Meter Algorithm

> The complete algorithm that takes a day's check-ins, attributes, and habits and produces a 4-vector of Nafs weights. Stored in `nafs_history` and visualised on the Home screen as the Nafs Meter.

> ⚠️ **PROPOSAL — subject to tuning.** The constants below are the v1 proposal. They live in the database (`attribute_nafs_weights`, `emotion_nafs_weights`) and can be adjusted without a migration. See `../08_algorithms/scoring_algorithm.md` for the formal pseudo-code and unit tests.

---

## 1 · High-level shape

```
   Nafs_today  =  0.50 × AttributeScore
               +  0.20 × EmotionScore
               +  0.20 × HabitScore
               +  0.10 × TrendScore
```

Each of the four component scores is a **4-vector** (Ammarah · Lawwamah · Mulhamah · Mutmainnah) that sums to 1.0. The blend is element-wise and is re-normalised to sum to 1.0 at the end.

| Component | Source | What it captures |
|---|---|---|
| `AttributeScore` (50%) | `attribute_nafs_weights` × `detected_attributes.Score` | The *underlying* state of the heart. |
| `EmotionScore` (20%) | `emotion_nafs_weights` × `checkins.Intensity` | The *surface* state — what the user is feeling. |
| `HabitScore` (20%) | `habit_logs` over last 7 days | The *behavioural* state — what the user is *doing*. |
| `TrendScore` (10%) | `nafs_history` last 14 days | The *momentum* — is the user improving or declining? |

## 2 · `AttributeScore` — 50%

This is the **dominant** component because the underlying attribute is what the recommendation engine works with. The emotion is a *symptom*; the attribute is the *cause*.

### 2.1 Algorithm

```python
def attribute_score(date: Date) -> Vector4:
    rows = sql("""
        SELECT anw.Ammarah, anw.Lawwamah, anw.Mulhamah, anw.Mutmainnah, da.Score
        FROM detected_attributes da
        JOIN attribute_nafs_weights anw ON anw.Attribute_ID = da.Attribute_ID
        WHERE da.Date = ?
    """, date)

    if not rows:
        return NEUTRAL  # (0.25, 0.25, 0.25, 0.25)

    # Multiply each row's vector by its score, then sum
    total = Vector4(0, 0, 0, 0)
    for r in rows:
        weight = r.Score
        total += Vector4(r.Ammarah, r.Lawwamah, r.Mulhamah, r.Mutmainnah) * weight
    return total.normalise()
```

### 2.2 The `Score` field

`detected_attributes.Score` is set when the row is inserted (see `../04_user_tables/detected_attributes.md`). The proposed formula:

```
   Score = emotion_weight × checkin_intensity / 10
```

So a `Weight=0.9` link logged at `Intensity=7` produces a `Score=0.63`. A `Weight=0.4` link at `Intensity=5` produces `Score=0.20`.

### 2.3 Behaviour

- If the user logs *Anger* (intensity 7), the system finds Ghadab (Disease, weight 0.95) and Sabr (Treatment, weight 0.95). Both are added to `detected_attributes`:
  - Ghadab: score = 0.95 × 0.7 = **0.665**
  - Sabr: score = 0.95 × 0.7 = **0.665**
- The AttributeScore is a weighted sum of these two vectors, then normalised.
- A day with **only** Ghadab detected (no Sabr logged) will tip toward Ammarah.
- A day with **only** Sabr detected (no Ghadab) — unusual, but possible if the user is reflecting — will tip toward Mutmainnah.

## 3 · `EmotionScore` — 20%

This is the **surface** component — what the user actually wrote in the check-in.

### 3.1 Algorithm

```python
def emotion_score(date: Date) -> Vector4:
    rows = sql("""
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

### 3.2 Multiple emotions

When the user logs two or more emotions in a day (e.g. "Anxiety" + "Regret"), the vectors are **summed** (additive). The user is *stronger* in their state than a single emotion would suggest.

## 4 · `HabitScore` — 20%

This is the **behavioural** component. A user who is doing the right things should see their Nafs vector move toward Mutmainnah even if they had a bad day emotionally.

### 4.1 Algorithm

```python
HABIT_BIAS = [
    # (Ammarah, Lawwamah, Mulhamah, Mutmainnah)
    (0.60, 0.40, 0.00, 0.00),   # < 20% completion
    (0.20, 0.60, 0.20, 0.00),   # 20–50%
    (0.00, 0.30, 0.50, 0.20),   # 50–80%
    (0.00, 0.10, 0.20, 0.70),   # ≥ 80%
]

def habit_score(user_id: int) -> Vector4:
    end = today()
    start = end - 7 days
    total_habits = sql_count("SELECT COUNT(*) FROM habits WHERE user_id = ?", user_id)
    completed = sql_count("""
        SELECT COUNT(*) FROM habit_logs hl
        JOIN habits h ON h.Habit_ID = hl.Habit_ID
        WHERE hl.Date BETWEEN ? AND ? AND hl.Completed = 1
    """, start, end)
    rate = completed / (total_habits * 7) if total_habits else 0
    bucket = int(min(3, rate * 4))   # 0..3
    return Vector4(*HABIT_BIAS[bucket])
```

### 4.2 Edge case — no habits defined

If the user has zero habits defined, `total_habits = 0` and the rate is 0 → bucket 0 → Ammarah-leaning. This is **deliberately conservative**: a user who hasn't set up habits gets the "you're not doing enough" baseline.

In v1.1 this may be softened to return NEUTRAL instead.

## 5 · `TrendScore` — 10%

This is the **momentum** component. A user who has been improving for two weeks should see a small bonus toward Mutmainnah.

### 5.1 Algorithm

```python
def trend_score(date: Date) -> Vector4:
    recent = sql("""
        SELECT Ammarah, Lawwamah, Mulhamah, Mutmainnah, Date
        FROM nafs_history
        WHERE Date BETWEEN ? AND ?
        ORDER BY Date DESC
    """, date - 14, date - 1)

    if len(recent) < 7:
        return NEUTRAL  # not enough history

    # Weighted moving average (recent days weigh more)
    weights = [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.1, 0.1, 0.1, 0.1]
    weighted = sum(Vector4(*r[:4]) * w for r, w in zip(recent, weights))
    avg_14 = weighted / sum(weights)

    # Compare to today
    today = sql("SELECT * FROM nafs_history WHERE Date = ?", date)
    if not today:
        return NEUTRAL
    today_v = Vector4(*today[0][:4])

    # Compute the "direction" of change
    delta = today_v - avg_14

    # Convert to a 4-vector nudge
    nudge = Vector4(0, 0, 0, 0)
    if delta.Mutmainnah - delta.Ammarah > 0.05:
        nudge = Vector4(-0.05, 0, +0.02, +0.03)   # moving toward Mutmainnah
    elif delta.Ammarah - delta.Mutmainnah > 0.05:
        nudge = Vector4(+0.03, +0.02, 0, -0.05)   # moving toward Ammarah
    return nudge
```

### 5.2 Behaviour

- A user with stable behaviour gets `nudge ≈ 0`. The TrendScore is approximately NEUTRAL.
- A user who has been improving for 14 days gets a small bonus toward Mutmainnah.
- A user who has been declining gets a small pull toward Ammarah.

The effect is **deliberately small** (±5%) because this is the 10% component.

## 6 · Blending

```python
def daily_nafs(date: Date) -> Vector4:
    a = attribute_score(date)  # 50%
    e = emotion_score(date)    # 20%
    h = habit_score(date)      # 20%
    t = trend_score(date)      # 10%

    blend = 0.50 * a + 0.20 * e + 0.20 * h + 0.10 * t
    return blend.normalise()
```

The result is stored in `nafs_history`:

```sql
INSERT INTO nafs_history (Date, Ammarah, Lawwamah, Mulhamah, Mutmainnah)
VALUES (?, ?, ?, ?, ?);
```

## 7 · The 15-day meter

The **Home screen meter** is *not* today's Nafs — it is a **weighted moving average** of the last 15 days.

```python
def meter_15day(date: Date) -> Vector4:
    rows = sql("""
        SELECT Ammarah, Lawwamah, Mulhamah, Mutmainnah
        FROM nafs_history
        WHERE Date BETWEEN ? AND ?
        ORDER BY Date DESC
    """, date - 14, date)

    if not rows:
        return NEUTRAL

    # Linear weights: today = 1.0, 14 days ago = 0.2
    weights = [1.0 - (i * 0.8 / 14) for i in range(len(rows))]
    total = sum(Vector4(*r) * w for r, w in zip(rows, weights))
    return (total / sum(weights)).normalise()
```

### 7.1 Why a moving average, not today

A user who logs "Anger at intensity 10" should not see the meter collapse to Ammarah 90%. The meter is a **trend**, not a mood. The 15-day window with decaying weights ensures:

- Recent days matter more.
- A single bad day is visible but not dominant.
- A 7-day positive streak is required to *cross* a major threshold (e.g. Lawwamah → Mulhamah).

## 8 · Edge cases

| Situation | Algorithm response |
|---|---|
| First ever check-in | Use 14-day average = (0, 1, 0, 0); TrendScore = 0; meter defaults to Lawwamah. |
| User missed 3 days | Forward-fill the missing days with the last known daily Nafs. |
| User logged 5 emotions today | Sum all EmotionScore contributions, re-normalise. |
| All weights sum to 0 | Return last known daily Nafs unchanged. |
| User deletes all habits | HabitScore = bucket 0 (Ammarah-leaning) — see §4.2. |
| User's 14-day average is identical to today | TrendScore returns NEUTRAL. |

## 9 · Performance

| Step | Time | Notes |
|---|---|---|
| `attribute_score` | < 5 ms | reads 1–10 rows from `detected_attributes` |
| `emotion_score` | < 5 ms | reads 1–5 rows from `checkins` |
| `habit_score` | < 10 ms | reads 7 × N rows from `habit_logs` |
| `trend_score` | < 5 ms | reads 14 rows from `nafs_history` |
| 15-day meter | < 5 ms | reads 15 rows from `nafs_history` |
| **Total** | **< 30 ms** | comfortably real-time on every Home screen render |

The function is **pure** (no IO except the SQL reads). It is unit-testable without Flutter or SQLite.

## 10 · Tunable constants

The following are **proposal** values in v1.0 and will be tuned in v1.1 based on real usage data:

| Constant | Current value | Where it lives |
|---|---|---|
| AttributeScore weight | 0.50 | hard-coded in the algorithm |
| EmotionScore weight | 0.20 | hard-coded |
| HabitScore weight | 0.20 | hard-coded |
| TrendScore weight | 0.10 | hard-coded |
| 15-day window | 15 | hard-coded |
| 14-day trend window | 14 | hard-coded |
| 7-day habit window | 7 | hard-coded |
| Trend nudge size | 0.05 | hard-coded |
| Streak duration for state transition | 7 | hard-coded |

These constants are **not** in the database in v1.0 — they are in `lib/src/domain/usecases/nafs/constants.dart`. A v1.1 follow-up may move them to a `scoring_config` table to allow per-user tuning.

## 11 · See also

- `attribute_nafs_weights.md` and `emotion_nafs_weights.md` — the underlying matrices.
- `../04_user_tables/nafs_history.md` — where the result is stored.
- `../04_user_tables/checkins.md` — the input.
- `../04_user_tables/detected_attributes.md` — the intermediate.
- `../04_user_tables/habits.md` and `habit_logs.md` — the habit inputs.
- `../08_algorithms/scoring_algorithm.md` — formal pseudo-code and test cases.
- `../08_algorithms/trend_algorithm.md` — the trend sub-algorithm in detail.
