# `detected_attributes` — Inferred Attributes from a Check-in

> The bridge between what the user *felt* (an emotion) and what the heart *actually has* (an attribute). Populated automatically by the check-in pipeline.

---

## 1 · Purpose

`detected_attributes` records the **inferred attributes** for each check-in. When a user logs an emotion, the system uses `emotion_attribute_links` to translate that emotion into a list of underlying attributes, with a `Score` capturing how strongly each one applies.

This table is the **input** to the `AttributeScore` component of the daily Nafs calculation (see `../03_nafs_engine/nafs_meter_algorithm.md` §2).

## 2 · Schema

| Col | Type | Notes |
|---|---|---|
| `Record_ID` | INTEGER PK | autoincrement |
| `Date` | DATE | matches the parent `checkins.Date` |
| `Attribute_ID` | INTEGER FK → `attributes` | |
| `Score` | REAL | 0.0 – 1.0 |
| `Role` | TEXT | enum: `Disease` · `Treatment` · `Core` · `Strengthens` |

A unique index on `(Date, Attribute_ID, Role)` ensures one row per (attribute, role) per day.
The same attribute may appear up to four times per day — once per role — so the Insight screen
can distinguish "this attribute is a disease you are experiencing" (Disease/Core) from "this
attribute is a remedy to cultivate" (Treatment/Strengthens).

## 3 · How rows are populated

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
        rows.append((checkin.Date, link.Attribute_ID, score, link.Role))

    # Upsert keyed on (Date, Attribute_ID, Role).
    # Scores for the same (date, attribute, role) are ADDITIVE and capped at 1.0.
    # This means logging the same emotion twice on one day accumulates scores.
    for date, attr_id, score, role in rows:
        sql("""
            INSERT INTO detected_attributes (Date, Attribute_ID, Score, Role)
            VALUES (?, ?, ?, ?)
            ON CONFLICT(Date, Attribute_ID, Role) DO UPDATE
            SET Score = MIN(Score + excluded.Score, 1.0)
        """, date, attr_id, score, role)
```

## 4 · The `Score` field — semantics

`Score` is **not** a probability. It is a weighted intensity, in the range [0, 1]:

- `Score = 0` means the attribute is not active.
- `Score = 1` means the attribute is fully active (impossible in practice; the max in v1 is ~0.95).
- The score is **additive**: if two emotions surface the same attribute, the scores are summed (capped at 1.0).

The score is used as a **multiplier** in the AttributeScore calculation:

```python
contribution = attribute_nafs_weights × score
```

So a `Score = 0.665` for Ghadab contributes 66.5% of Ghadab's Nafs-weight vector to the daily total.

## 6 · Cardinality

| Side | Cardinality |
|---|---|
| A check-in | 3–10 detected attributes (one per `emotion_attribute_links` row) |
| A day | 5–20 unique detected attributes (across all check-ins) |
| An attribute (lifetime) | 0 – 365 × 5 rows = up to 1 825 rows |

The table grows linearly with usage. A heavy user (5 emotions/day × 365 days) will have ~5 000 rows after a year. No scaling concerns.

## 7 · How it is queried

### 7.1 "What attributes were detected today?"

```sql
SELECT a.*, da.Score
FROM detected_attributes da
JOIN attributes a ON a.Attribute_ID = da.Attribute_ID
WHERE da.Date = ?
ORDER BY da.Score DESC;
```

This is the query behind the **Insight screen**.

### 7.2 "What is the AttributeScore for today?"

```sql
SELECT
  SUM(anw.Ammarah   * da.Score) / SUM(da.Score) AS A,
  SUM(anw.Lawwamah  * da.Score) / SUM(da.Score) AS L,
  SUM(anw.Mulhamah  * da.Score) / SUM(da.Score) AS M,
  SUM(anw.Mutmainnah* da.Score) / SUM(da.Score) AS T
FROM detected_attributes da
JOIN attribute_nafs_weights anw ON anw.Attribute_ID = da.Attribute_ID
WHERE da.Date = ?;
```

This is the **AttributeScore** 4-vector.

### 7.3 "What is the most-detected attribute in the last 30 days?"

```sql
SELECT a.Attribute, SUM(da.Score) AS total
FROM detected_attributes da
JOIN attributes a ON a.Attribute_ID = da.Attribute_ID
WHERE da.Date >= date('now', '-30 day')
GROUP BY da.Attribute_ID
ORDER BY total DESC
LIMIT 10;
```

This is the **Top-10 Detected Attributes** card on the Analytics screen (v1.1).

## 8 · Decay (v1.1)

In v1.0, `detected_attributes` is a **flat log** — a row once written is never modified except by cascade delete.

In v1.1, a **decay** mechanism may be added: each `Score` is multiplied by a decay factor of 0.95 per day, so a detected attribute loses 5% of its influence per day. This would make the system more responsive to recent check-ins.

This is a **read-time computation**, not a write-time mutation — the table is not updated nightly.

## 9 · Edge cases

| Situation | Handled how |
|---|---|
| User logs the same emotion twice in one day | The detected attributes are upserted — scores for the same (attribute, role) are added and capped at 1.0. |
| User logs two different emotions that surface the same attribute in the same role | The scores are summed for that (attribute, role) pair, capped at 1.0. |
| Same attribute appears as both Disease and Core for one emotion | They produce two separate rows: one with Role='Disease' and one with Role='Core'. |
| User deletes a check-in | The corresponding `detected_attributes` rows are cascade-deleted. |
| User changes their check-in (intensity, notes) | The detected attributes are recomputed. |
| Attribute is linked to emotion with Weight > 1.0 | Impossible — the seed validation rejects this. |
| Score overflow (sum > 1.0) | Capped at 1.0 in the upsert via `MIN(Score + excluded.Score, 1.0)`. |

## 10 · Implementation notes

- The table is created by `migrations/v1.dart`.
- The cascade insert is implemented as a **SQLite trigger** on `checkins` (after insert) — this guarantees that a check-in can never exist without its detected attributes.
- The cascade delete is implemented as a **trigger on checkins** (after delete).
- The `Score` column uses `REAL` (8-byte float) — sufficient precision for the 0–1 range.
- The unique index on `(Date, Attribute_ID)` is critical for the upsert performance.

## 11 · See also

- `checkins.md` — the parent table.
- `../02_relationships/emotion_attribute_links.md` — the source of the detection.
- `../03_nafs_engine/attribute_nafs_weights.md` — the Nafs weights applied to the scores.
- `../03_nafs_engine/nafs_meter_algorithm.md` §2 — the AttributeScore calculation.
- `interventions_history.md` — the next step in the pipeline.
