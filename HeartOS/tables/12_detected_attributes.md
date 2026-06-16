# `detected_attributes` — Inferred Attributes from a Check-in

> The bridge between what the user *felt* (an emotion) and what the heart *actually has* (an attribute).
> Populated automatically by the check-in pipeline via SQLite trigger.
> **Source:** `HeartOS/04_user_tables/detected_attributes.md`
> **Status:** Runtime table — empty at build, populated by check-in triggers.

---

## Schema

| Col | Type | Notes |
|---|---|---|
| `Record_ID` | INTEGER PK | autoincrement |
| `Date` | DATE | matches the parent `checkins.Date` |
| `Attribute_ID` | INTEGER FK → `attributes` | |
| `Score` | REAL | 0.0 – 1.0 |

A unique index on `(Date, Attribute_ID)` ensures one row per attribute per day.

---

## How Rows Are Populated

```python
def detect_attributes(checkin: Checkin):
    links = sql("""
        SELECT Attribute_ID, Weight, Role
        FROM emotion_attribute_links
        WHERE Emotion_ID = ?
    """, checkin.Emotion_ID)

    intensity_mult = checkin.Intensity / 10.0
    rows = []
    for link in links:
        score = link.Weight * intensity_mult
        rows.append((checkin.Date, link.Attribute_ID, score))

    # Upsert: if (Date, Attribute_ID) already exists, add the scores
    for date, attr_id, score in rows:
        sql("""
            INSERT INTO detected_attributes (Date, Attribute_ID, Score)
            VALUES (?, ?, ?)
            ON CONFLICT(Date, Attribute_ID) DO UPDATE
            SET Score = Score + excluded.Score
        """, date, attr_id, score)
```

The cascade is triggered by the **insertion** of a `checkins` row — there is a SQLite trigger that calls this function.

---

## The `Score` Field — Semantics

`Score` is **not** a probability. It is a weighted intensity, in the range [0, 1]:

- `Score = 0` means the attribute is not active.
- `Score = 1` means the attribute is fully active (impossible in practice; the max in v1 is ~0.95).
- The score is **additive**: if two emotions surface the same attribute, the scores are summed (capped at 1.0).

The score is used as a **multiplier** in the AttributeScore calculation:

```python
contribution = attribute_nafs_weights × score
```

So a `Score = 0.665` for Ghadab contributes 66.5% of Ghadab's Nafs-weight vector to the daily total.

---

## Cardinality

| Side | Cardinality |
|---|---|
| A check-in | 3–10 detected attributes (one per `emotion_attribute_links` row) |
| A day | 5–20 unique detected attributes (across all check-ins) |
| An attribute (lifetime) | 0 – 365 × 5 rows = up to 1,825 rows |

A heavy user (5 emotions/day × 365 days) will have ~5,000 rows after a year.

---

## Example Rows (Illustrative)

For a check-in logging `Anger` (Emotion_ID=1) at intensity 7 on 2026-06-12:

| Record_ID | Date | Attribute_ID | Score | Source |
|---:|---|---:|---:|---|
| 1 | 2026-06-12 | 23 (Ghadab) | 0.665 | Disease role, weight 0.95 × 0.7 |
| 2 | 2026-06-12 | 75 (Sabr) | 0.63 | Treatment role, weight 0.9 × 0.7 |
| 3 | 2026-06-12 | 86 (Hilm) | 0.595 | Treatment role, weight 0.85 × 0.7 |
| 4 | 2026-06-12 | 85 (Rifq) | 0.56 | Treatment role, weight 0.8 × 0.7 |
| 5 | 2026-06-12 | 22 (Hiqd) | 0.455 | Secondary Disease, weight 0.65 × 0.7 |

> **Note:** These are illustrative. The table starts empty and is populated by the check-in trigger.

---

## See also

- `HeartOS/04_user_tables/detected_attributes.md` — full spec
- `HeartOS/04_user_tables/checkins.md` — parent table
- `HeartOS/02_relationships/emotion_attribute_links.md` — source of detection
- `HeartOS/03_nafs_engine/attribute_nafs_weights.md` — applied to scores
- `HeartOS/03_nafs_engine/nafs_meter_algorithm.md` §2 — AttributeScore calculation
- `HeartOS/04_user_tables/interventions_history.md` — next step in pipeline
