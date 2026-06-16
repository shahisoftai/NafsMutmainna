# Severity Algorithm

> How the `emotions.Severity_Weight` and the user-supplied `Intensity` combine to produce the final *severity score* of a check-in. Used in the Nafs calculation, the recommendation ranking, and the streak detection.

---

## 1 · What is "severity"?

Every emotion has a **base severity** (1–10) seeded in `emotions.Severity_Weight`. The user also supplies an **intensity** (1–10) on the Check-in screen. The *effective severity* is a combination of these two.

## 2 · Why two numbers?

| Source | Captures | Example |
|---|---|---|
| **Base severity** | The *inherent* seriousness of the emotion. | Anxiety (7) is more concerning than Restlessness (5). |
| **User intensity** | The *felt* strength *right now*. | The user can feel mild anxiety (intensity 3) or severe anxiety (intensity 10). |

Multiplying them captures both dimensions.

## 3 · The formula

```
   effective_severity = (base_severity / 10) × (intensity / 10)
                      = (base_severity × intensity) / 100
```

Both inputs are in [1, 10], so the result is in [0.01, 1.00].

## 4 · How it is used

### 4.1 In the Nafs calculation

The `effective_severity` is the multiplier for the `emotion_nafs_weights` vector:

```python
contribution = emotion_nafs_weights × effective_severity
```

A high-severity check-in moves the Nafs vector more than a low-severity one.

### 4.2 In the recommendation ranking

The recommendation algorithm uses the effective severity as one of the ranking signals:

```python
rank = 0.6 * attribute_score
     + 0.3 * effective_severity   # <-- here
     + 0.1 * nafs_bias
```

A high-severity check-in gets more prominent cards.

### 4.3 In the streak detection

A high-severity check-in **does not** automatically break a streak. The streak is based on the Nafs *state*, not the emotion's severity. But a user with many high-severity check-ins in a row will see their Nafs vector tip toward Ammarah, which will then break the streak.

### 4.4 In the analytics

The "average severity" over 30 days is a useful metric:

```sql
SELECT AVG((e.Severity_Weight * 1.0 * c.Intensity) / 100) AS avg_severity
FROM checkins c
JOIN emotions e ON e.Emotion_ID = c.Emotion_ID
WHERE c.Date >= date('now', '-30 day');
```

A high average severity (>0.4) suggests the user is struggling; a low one (<0.2) suggests the user is in a good state.

## 5 · Edge cases

| Situation | Handled how |
|---|---|
| Base severity missing (NULL) | Default to 5. |
| Intensity missing (NULL) | Default to 0 — the check-in is treated as "neutral". |
| Intensity = 0 | Effective severity = 0 → no contribution to Nafs. |
| Base severity = 0 | Treated as a "tracking only" emotion (e.g. user just wants to note something). |
| Both > 10 (impossible by validation) | Clamp to 10. |

## 6 · The severity spectrum

| Effective | Label | UI colour |
|---:|---|---|
| 0.00 – 0.15 | Trace | grey |
| 0.15 – 0.30 | Mild | light blue |
| 0.30 – 0.50 | Moderate | yellow |
| 0.50 – 0.70 | Strong | orange |
| 0.70 – 1.00 | Severe | red |

These bands are **proposed** and will be tuned.

## 7 · Validation

The user-supplied intensity is validated:

- The slider has 10 stops (integer values 1–10).
- The default value is 5.
- A "no intensity" check-in is allowed (sets intensity = 0).

The base severity is **never** user-editable — it is a property of the emotion.

## 8 · Tunable constants

| Constant | Value | Location |
|---|---|---|
| Default base severity (if missing) | 5 | `constants.dart` |
| Default intensity (if missing) | 0 | `constants.dart` |
| Severity band boundaries | 0.15, 0.30, 0.50, 0.70 | `constants.dart` |

## 9 · Why not just intensity?

A user could log "Hatred at intensity 1" — but Hatred is a *serious* emotion even at low intensity (because the underlying attribute is very harmful). A user logging "Restlessness at intensity 10" — Restlessness is *less* serious even at high intensity.

Multiplying the two captures both: the **inherent** seriousness of the emotion and the **felt** strength right now.

## 10 · Performance

| Operation | Time |
|---|---|
| Compute effective severity | < 1 ms (in-memory) |
| Average severity over 30 days | < 5 ms (indexed) |
| Severity band lookup | < 1 ms |

## 11 · See also

- `../01_core_tables/emotions.md` — the `Severity_Weight` field.
- `../04_user_tables/checkins.md` — the `Intensity` field.
- `scoring_algorithm.md` — the daily Nafs algorithm (uses effective_severity).
- `recommendation_algorithm.md` — the recommendation ranking (uses effective_severity).
- `trend_algorithm.md` — the streak detection (uses Nafs state, not severity directly).
