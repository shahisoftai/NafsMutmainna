# `emotion_nafs_weights` — The Emotion Nafs-Bias Matrix

> The 50×4 matrix that tells the scoring engine how much each emotion pulls the user toward each of the four Nafs states. The **counterpart** to `attribute_nafs_weights`, but for the user's *vocabulary* rather than the underlying attributes.

---

## 1 · Purpose

`emotion_nafs_weights` is a 1-to-1 mapping with `emotions`. For every emotion, it stores a 4-vector of weights (one for each Nafs state) that says *"when the user logs this emotion, how much does it bias the Nafs vector toward Ammarah / Lawwamah / Mulhamah / Mutmainnah?"*

The scoring engine reads this table when the user logs a check-in, multiplies by the emotion's `Intensity`, and combines with the attribute-level contribution (see `attribute_nafs_weights.md`) to produce the **EmotionScore** component of the daily Nafs.

## 2 · Schema

| Col | Type | Notes |
|---|---|---|
| `Emotion_ID` | INTEGER PK + FK → `emotions` | 1:1 with emotions |
| `Ammarah` | REAL | 0–100 |
| `Lawwamah` | REAL | 0–100 |
| `Mulhamah` | REAL | 0–100 |
| `Mutmainnah` | REAL | 0–100 |

**Constraint:** the four values should sum to **~100** (within ±5), like `attribute_nafs_weights`.

## 3 · Relationship to `attribute_nafs_weights`

`emotion_nafs_weights` is **derived from** but **not identical to** `attribute_nafs_weights`. A user logging "Anger" is reporting a *feeling*, not an *attribute*. The feeling is a symptom; the underlying attribute (Ghadab) is the disease. The two matrices are kept in sync by an editorial pass — the emotion's vector is roughly the **average** of its `Primary_Negative_Attributes` + `Primary_Positive_Attributes` vectors.

Scholarly illustration — **Anxiety** (Emotion_ID 3):

| Linked attribute | Nature | A | L | M | T |
|---|---|---:|---:|---:|---:|
| Weak Tawakkul | Negative | 30 | 60 | 8 | 2 |
| Weak Yaqeen | Negative | 25 | 65 | 8 | 2 |
| Fear | Negative | 10 | 75 | 12 | 3 |
| Tawakkul | Positive | 0 | 5 | 30 | 65 |
| Yaqeen | Positive | 0 | 5 | 25 | 70 |
| Sakinah | Positive | 0 | 5 | 25 | 70 |

The emotion's vector (15, 70, 12, 3) is the *negative-skewed* average of these six.

## 5 · How it is used in the scoring engine

```sql
SELECT enw.Ammarah, enw.Lawwamah, enw.Mulhamah, enw.Mutmainnah, c.Intensity
FROM checkins c
JOIN emotion_nafs_weights enw ON enw.Emotion_ID = c.Emotion_ID
WHERE c.Date = ?;
```

For each row, the four weights are multiplied by `Intensity / 10` (normalising to a 0–1 range) and summed. The result is the **EmotionScore** 4-vector.

## 6 · Intensity scaling

The user's `Intensity` (1–10) is used as a **multiplier**:

```
   contribution = emotion_weight × (intensity / 10)
```

This means:
- An emotion logged at intensity 1 contributes only 10% of its base weight.
- An emotion logged at intensity 10 contributes 100%.
- The system caps the effective contribution at 1.0 (so a stack of intense emotions cannot overflow).

## 7 · Multiple emotions per check-in

The user can log **multiple emotions** in a single check-in (e.g. "Anger" + "Anxiety"). The algorithm:

1. Looks up each emotion's vector.
2. Multiplies by `Intensity / 10`.
3. **Sums** the vectors (additive).
4. **Re-normalises** so the four values still sum to 1.0.

This means: logging two negative emotions at intensity 7 is *stronger* than logging one at intensity 10.

## 8 · Cardinality

| Side | Cardinality |
|---|---|
| An emotion | 1 row in this table (1:1 with `emotions`) |
| A Nafs state | referenced by 50 rows (one per emotion) |

The total expected row count is **50**.

## 9 · Seeding

- Seeded once from `assets/data/emotion_nafs_weights_seed.json`.
- 50 rows.
- Derived from the `emotions` seed + `attribute_nafs_weights` seed.
- The expected time to seed: < 20 ms.

## 10 · Quality bar

For every row:

1. **Sum is in [95, 105]**.
2. **All four values are ≥ 0 and ≤ 100**.
3. **Negative emotions have Ammarah + Lawwamah ≥ 60**.
4. **Positive emotions have (Mulhamah + Mutmainnah) ≥ 50**.
5. **The emotion's vector is *consistent* with its primary attribute vectors** (no emotion is "off-pattern").

A CI check enforces these rules on every seed PR.

## 11 · Heatmap

| Category | Ammarah | Lawwamah | Mulhamah | Mutmainnah |
|---|---:|---:|---:|---:|
| 40 negative emotions (mean) | 45 | 42 | 10 | 3 |
| 10 positive emotions (mean) | 1 | 6 | 30 | 63 |

The "negative emotions" mean is dominated by **Lawwamah** emotions (24 of the 40). This is healthy: most negative emotions a user logs in Heart OS are *conscience-active* feelings, not pure base desires. A user who consistently logs only **Ammarah** emotions (Hatred, Rage, Greed at intensity 9+) is in a serious state — the algorithm will not hide this.

## 12 · Implementation notes

- The 4 columns are indexed together as a composite index.
- The EmotionScore is computed **only on check-in** (not on every read).
- The result is cached in the daily Nafs vector in `nafs_history` — see `../04_user_tables/nafs_history.md`.
- The EmotionScore is one of **four** components of the daily Nafs (50% AttributeScore, 20% EmotionScore, 20% HabitScore, 10% TrendScore). See `nafs_meter_algorithm.md`.

## 13 · See also

- `attribute_nafs_weights.md` — the attribute matrix.
- `nafs_meter_algorithm.md` — the full daily Nafs algorithm.
- `../01_core_tables/emotions.md` — the 50 emotions.
- `../01_core_tables/nafs_states.md` — the four Nafs states.
- `../04_user_tables/nafs_history.md` — where the result is stored.
