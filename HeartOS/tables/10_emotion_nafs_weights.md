# `emotion_nafs_weights` — The Emotion Nafs-Bias Matrix

> The 50×4 matrix that tells the scoring engine how much each emotion biases the Nafs vector.
> **Source:** `HeartOS/03_nafs_engine/emotion_nafs_weights.md`, editorial pass
> **Constraint:** Each row's 4 values sum to 100 (±5)
> **Generated:** 2026-06-12

---

## Schema

| Col | Type | Notes |
|---|---|---|
| `Emotion_ID` | INTEGER PK + FK → `emotions` | 1:1 with emotions |
| `Ammarah` | REAL | 0–100 |
| `Lawwamah` | REAL | 0–100 |
| `Mulhamah` | REAL | 0–100 |
| `Mutmainnah` | REAL | 0–100 |

**Constraint:** the four values sum to **~100** (within ±5).

---

## Rules Applied

1. **Negative emotions from Ammarah** → high Ammarah (55-65), moderate Lawwamah (28-35)
2. **Negative emotions from Lawwamah** → high Lawwamah (60-70), moderate Ammarah (10-25)
3. **Positive emotions from Mulhamah** → high Mulhamah (50-55), high Mutmainnah (39-44)
4. **Positive emotions from Mutmainnah** → very high Mutmainnah (67-78), high Mulhamah (20-30)

---

## Seed Data (50 rows)

| Emotion_ID | Ammarah | Lawwamah | Mulhamah | Mutmainnah | Sum |
|---:|---:|---:|---:|---:|---:|
| 1 | 55 | 35 | 7 | 3 | 100 |
| 2 | 60 | 30 | 7 | 3 | 100 |
| 3 | 20 | 65 | 12 | 3 | 100 |
| 4 | 20 | 65 | 12 | 3 | 100 |
| 5 | 15 | 65 | 15 | 5 | 100 |
| 6 | 25 | 60 | 12 | 3 | 100 |
| 7 | 10 | 70 | 15 | 5 | 100 |
| 8 | 55 | 35 | 7 | 3 | 100 |
| 9 | 15 | 65 | 15 | 5 | 100 |
| 10 | 20 | 60 | 15 | 5 | 100 |
| 11 | 65 | 28 | 5 | 2 | 100 |
| 12 | 60 | 32 | 6 | 2 | 100 |
| 13 | 60 | 30 | 7 | 3 | 100 |
| 14 | 55 | 35 | 7 | 3 | 100 |
| 15 | 60 | 30 | 7 | 3 | 100 |
| 16 | 55 | 35 | 7 | 3 | 100 |
| 17 | 55 | 35 | 7 | 3 | 100 |
| 18 | 15 | 65 | 15 | 5 | 100 |
| 19 | 20 | 60 | 15 | 5 | 100 |
| 20 | 15 | 65 | 15 | 5 | 100 |
| 21 | 20 | 60 | 15 | 5 | 100 |
| 22 | 25 | 60 | 12 | 3 | 100 |
| 23 | 15 | 65 | 15 | 5 | 100 |
| 24 | 60 | 30 | 7 | 3 | 100 |
| 25 | 55 | 35 | 7 | 3 | 100 |
| 26 | 20 | 60 | 15 | 5 | 100 |
| 27 | 60 | 30 | 7 | 3 | 100 |
| 28 | 10 | 70 | 15 | 5 | 100 |
| 29 | 20 | 60 | 15 | 5 | 100 |
| 30 | 20 | 60 | 15 | 5 | 100 |
| 31 | 1 | 8 | 50 | 41 | 100 |
| 32 | 0 | 3 | 30 | 67 | 100 |
| 33 | 1 | 5 | 55 | 39 | 100 |
| 34 | 0 | 2 | 25 | 73 | 100 |
| 35 | 1 | 5 | 55 | 39 | 100 |
| 36 | 0 | 3 | 30 | 67 | 100 |
| 37 | 2 | 8 | 50 | 40 | 100 |
| 38 | 1 | 5 | 50 | 44 | 100 |
| 39 | 0 | 3 | 30 | 67 | 100 |
| 40 | 1 | 5 | 50 | 44 | 100 |
| 41 | 1 | 5 | 50 | 44 | 100 |
| 42 | 0 | 2 | 25 | 73 | 100 |
| 43 | 0 | 2 | 30 | 68 | 100 |
| 44 | 0 | 2 | 25 | 73 | 100 |
| 45 | 0 | 2 | 20 | 78 | 100 |
| 46 | 0 | 2 | 25 | 73 | 100 |
| 47 | 1 | 8 | 50 | 41 | 100 |
| 48 | 0 | 2 | 20 | 78 | 100 |
| 49 | 0 | 2 | 25 | 73 | 100 |
| 50 | 0 | 2 | 20 | 78 | 100 |

---

## Statistics (Heatmap Summary)

| Category | Ammarah | Lawwamah | Mulhamah | Mutmainnah |
|---|---:|---:|---:|---:|
| 30 negative emotions (mean) | 35 | 50 | 11 | 4 |
| 20 positive emotions (mean) | 0.5 | 4 | 30 | 65 |
| 12 Ammarah-dominant negatives (mean) | 60 | 32 | 6 | 2 |
| 18 Lawwamah-dominant negatives (mean) | 18 | 64 | 14 | 4 |
| 8 Mulhamah-dominant positives (mean) | 1 | 6 | 51 | 42 |
| 12 Mutmainnah-dominant positives (mean) | 0 | 2 | 26 | 72 |

---

## See also

- `HeartOS/03_nafs_engine/emotion_nafs_weights.md` — full spec
- `HeartOS/03_nafs_engine/attribute_nafs_weights.md` — parallel attribute matrix
- `HeartOS/03_nafs_engine/nafs_meter_algorithm.md` — how the matrix is used
- `HeartOS/01_core_tables/emotions.md` — the emotion list
- `HeartOS/01_core_tables/nafs_states.md` — the 4 Nafs states
