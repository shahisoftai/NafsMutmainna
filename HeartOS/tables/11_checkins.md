# `checkins` — The Daily Emotional Log

> The user's daily entry into the system. One row per day per logged emotion.
> **Source:** `HeartOS/04_user_tables/checkins.md`
> **Status:** Runtime table — empty at build, populated by user activity.

---

## Schema

| Col | Type | Notes |
|---|---|---|
| `Checkin_ID` | INTEGER PK | autoincrement |
| `Date` | DATE | ISO 8601 (YYYY-MM-DD) |
| `Emotion_ID` | INTEGER FK → `emotions` | |
| `Intensity` | INTEGER | 1–10 |
| `Notes` | TEXT | optional free text, max 500 chars |

A unique index on `(Date, Emotion_ID)` prevents duplicate check-ins for the same emotion on the same day.

---

## Cardinality

| Side | Cardinality |
|---|---|
| A day | 1–5 check-ins (typically 1–2) |
| A user (lifetime) | 1 × `days_used` rows on average |

A user with 365 days of consistent use will have ~365–730 rows.

---

## The Check-in Flow

```
User opens app
    │
    ▼
Home screen ──────────────── "How is your heart today?" CTA
    │
    ▼
Pick one or more emotions (50 options)
    │
    ▼
Adjust intensity slider (1–10)
    │
    ▼
Optionally write notes
    │
    ▼
Tap "Continue"
    │
    ▼
INSERT INTO checkins ...
    │
    ▼
Trigger downstream pipeline:
    ├── INSERT INTO detected_attributes ...
    ├── Recommend interventions → INSERT INTO interventions_history ...
    └── Run daily Nafs algorithm → INSERT INTO nafs_history ...
```

The check-in is **synchronous** — the user sees the Insight screen within 500 ms of tapping Continue.

---

## Intensity Semantics

| Intensity | Meaning | Default `Score` multiplier |
|---|---|---|
| 1 | Barely felt | 0.1 |
| 3 | Mild | 0.3 |
| 5 | Moderate | 0.5 |
| 7 | Strong | 0.7 |
| 10 | Overwhelming | 1.0 |

The slider has 10 stops, evenly distributed. The default value is 5 (moderate).

---

## Edge Cases

| Situation | Handled how |
|---|---|
| User logs the same emotion twice on the same day | Allowed — both rows are stored. The downstream algorithm sums their intensities (capped at 10). |
| User logs no emotion (just notes) | Treated as a "neutral" check-in: `Emotion_ID = NULL`, `Intensity = 0`. |
| User deletes a check-in | Cascade delete removes the corresponding `detected_attributes` and `interventions_history` rows. The `nafs_history` row is **not** deleted — it is re-computed. |
| User changes timezone mid-day | All timestamps are stored as local date strings, not UTC instants. |
| User goes back in time (changes device clock) | Check-ins are validated against the device's monotonic clock — no future-dated check-ins. |
| User clears app data | All check-ins are wiped. On next launch, the user starts fresh with a Lawwamah baseline. |

---

## Implementation Notes

- Created on first launch by `migrations/v1.dart`
- `Date` stored as `TEXT` in ISO 8601 format (SQLite recommended)
- Unique index on `(Date, Emotion_ID)` enforced via `UNIQUE` constraint
- **Trigger** deletes corresponding `detected_attributes` and `interventions_history` rows on cascade delete
- Check-in screen reads from the **typeahead** in the `emotions` table (filtered by `Keywords`)

---

## Example Rows (Illustrative)

| Checkin_ID | Date | Emotion_ID | Intensity | Notes |
|---:|---|---:|---:|---|
| 1 | 2026-06-12 | 1 | 7 | Work deadline stress |
| 2 | 2026-06-12 | 3 | 5 | Worry about family |
| 3 | 2026-06-13 | 32 | 6 | Alhamdulillah for blessings |
| 4 | 2026-06-13 | 1 | 4 | Calmer today |

> **Note:** These are illustrative only. The table starts empty and is populated by user activity.

---

## See also

- `HeartOS/04_user_tables/checkins.md` — full spec
- `HeartOS/04_user_tables/detected_attributes.md` — cascade output
- `HeartOS/04_user_tables/interventions_history.md` — recommendations
- `HeartOS/04_user_tables/nafs_history.md` — daily Nafs vector
- `HeartOS/01_core_tables/emotions.md` — the 50 emotions
- `HeartOS/00_root/user_flow.md` §2.2 — Check-in screen UX
- `HeartOS/08_algorithms/severity_algorithm.md` — intensity usage in scoring
