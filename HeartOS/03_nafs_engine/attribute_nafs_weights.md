# `attribute_nafs_weights` — The Attribute Nafs-Bias Matrix

> The 200×4 matrix that tells the scoring engine how much each attribute pulls the user toward each of the four Nafs states. This is the **spine** of the Nafs Meter.

---

## 1 · Purpose

`attribute_nafs_weights` is a 1-to-1 mapping with `attributes`. For every attribute, it stores a 4-vector of weights (one for each Nafs state) that says *"when this attribute is active in the user, how much does it bias the Nafs vector toward Ammarah / Lawwamah / Mulhamah / Mutmainnah?"*

The scoring algorithm in `nafs_meter_algorithm.md` sums these vectors, weighted by today's `detected_attributes.Score`, to produce the **AttributeScore** component of the daily Nafs calculation.

## 2 · Schema

| Col | Type | Notes |
|---|---|---|
| `Attribute_ID` | INTEGER PK + FK → `attributes` | 1:1 with attributes |
| `Ammarah` | REAL | 0–100 |
| `Lawwamah` | REAL | 0–100 |
| `Mulhamah` | REAL | 0–100 |
| `Mutmainnah` | REAL | 0–100 |

**Constraint:** the four values should sum to **~100** (within ±5) for every row. This makes each row interpretable as a probability distribution over the four Nafs states.

## 3 · How the matrix is constructed

The four values for an attribute are assigned by an editorial pass, following three rules:

### 3.1 Rule 1 — Sum to 100

The four values are a probability distribution. The sum must equal 100 (±5 to allow for integer rounding).

### 3.2 Rule 2 — Negative attributes skew left, positive attributes skew right

| Nature | Expected skew |
|---|---|
| Negative | Mostly Ammarah, with some Lawwamah if the attribute is *accompanied by conscience*. |
| Positive | Mostly Mulhamah/Mutmainnah, with little or no Ammarah. |

### 3.3 Rule 3 — The "perfect" attribute is 0/0/0/100

The purest, highest attribute (Mahabbah) has zero weight on the three lower states and 100 on Mutmainnah. This is a soft cap — most attributes have a small (≤5) residue on the lower states to allow for human imperfection.

## 5 · Heatmap of the matrix

A high-level view (200 rows collapsed to categories):

| Category | Ammarah | Lawwamah | Mulhamah | Mutmainnah |
|---|---:|---:|---:|---:|
| 70 negative attributes (mean) | 65 | 28 | 6 | 1 |
| 130 positive attributes (mean) | 2 | 8 | 35 | 55 |
| Top 10 virtues | 0 | 3 | 25 | 72 |
| Top 10 diseases | 80 | 17 | 3 | 0 |

The **gap** between the means of negatives and positives is ~63 points on the Ammarah axis and ~54 points on the Mutmainnah axis. This is what makes the meter move: a day dominated by negative attributes will visibly tip toward Ammarah, and a day dominated by positives will tip toward Mutmainnah.

## 6 · How it is queried

### 6.1 Daily Nafs calculation

```sql
SELECT a.Nature, anw.Ammarah, anw.Lawwamah, anw.Mulhamah, anw.Mutmainnah, da.Score
FROM detected_attributes da
JOIN attribute_nafs_weights anw ON anw.Attribute_ID = da.Attribute_ID
WHERE da.Date = ?;
```

Each row is multiplied by `da.Score`, and the four columns are summed to produce the **AttributeScore** 4-vector.

### 6.2 "What Nafs state does this attribute pull toward?"

```sql
SELECT
  CASE
    WHEN Ammarah > Lawwamah AND Ammarah > Mulhamah AND Ammarah > Mutmainnah THEN 'Ammarah'
    WHEN Lawwamah > Mulhamah AND Lawwamah > Mutmainnah THEN 'Lawwamah'
    WHEN Mulhamah > Mutmainnah THEN 'Mulhamah'
    ELSE 'Mutmainnah'
  END AS dominant
FROM attribute_nafs_weights
WHERE Attribute_ID = ?;
```

This is the query behind the Attribute Detail screen's "Nafs bias" badge.

### 6.3 "Sort attributes by their Ammarah pull"

```sql
SELECT a.*, anw.Ammarah
FROM attributes a
JOIN attribute_nafs_weights anw ON anw.Attribute_ID = a.Attribute_ID
ORDER BY anw.Ammarah DESC
LIMIT 20;
```

This is the "most dangerous attributes" list shown on the Home spotlight.

## 7 · Seeding

- The table is **seeded once** from `assets/data/attribute_nafs_weights_seed.json`.
- 200 rows (one per attribute).
- Editorial pass + quality bar check (see §8).
- The expected time to seed: < 50 ms.

## 8 · Quality bar

For every row:

1. **Sum is in [95, 105]** (allowing ±5 rounding).
2. **All four values are ≥ 0 and ≤ 100**.
3. **Negative attributes have Ammarah ≥ 50**.
4. **Positive attributes have (Mulhamah + Mutmainnah) ≥ 60**.
5. **No attribute has all four values ≤ 5** (would be a no-op).

A CI check enforces these rules on every seed PR.

## 9 · How the matrix changes over time

The matrix is **immutable at runtime**. Adjusting the weights requires:

1. A new editorial pass.
2. A new app version that ships the updated JSON.
3. A user-driven app update.

In v2, an opt-in content update channel (see `../09_future/synchronization.md`) can push matrix updates without an app version bump. Even then, the matrix is **never** user-editable.

## 10 · Implementation notes

- The 4 columns are indexed together as a composite index for the daily calculation query.
- The Nafs vector is computed once per check-in and cached in `nafs_history` — the per-attribute weights are read 200 times only at the end of day, not on every screen.
- The scoring engine treats the four columns as a **probability distribution**, not a multi-dimensional value. This means the values are always renormalised to sum to 1.0 before being used.

## 11 · See also

- `emotion_nafs_weights.md` — the parallel table for emotions.
- `nafs_meter_algorithm.md` — how the four vectors are combined into a single daily Nafs score.
- `../01_core_tables/attributes.md` — the attribute list.
- `../01_core_tables/nafs_states.md` — the four Nafs states.
