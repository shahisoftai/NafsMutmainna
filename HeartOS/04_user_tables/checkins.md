# `checkins` — The Daily Emotional Log

> The user's daily entry into the system. One row per day per logged emotion.

---

## 1 · Purpose

`checkins` is the **primary input** to Heart OS. Every day, the user logs the emotions they felt. The check-in drives:

- `detected_attributes` (what underlying attributes are active).
- `interventions_history` (what recommendations are shown).
- `nafs_history` (the daily Nafs vector).
- The 15-day meter (the visualised score on Home).

Without check-ins, the system has no data. Every other user-table is derived from this one.

## 2 · Schema

| Col | Type | Notes |
|---|---|---|
| `Checkin_ID` | INTEGER PK | autoincrement |
| `Date` | DATE | ISO 8601 (YYYY-MM-DD) |
| `Emotion_ID` | INTEGER FK → `emotions` | |
| `Intensity` | INTEGER | 1–10 |
| `Notes` | TEXT | optional free text, max 500 chars |

A unique index on `(Date, Emotion_ID)` prevents duplicate check-ins for the same emotion on the same day.

## 3 · Cardinality

| Side | Cardinality |
|---|---|
| A day | 1–5 check-ins (typically 1–2) |
| A user (lifetime) | 1 × `days_used` rows on average |

A user with 365 days of consistent use will have ~365–730 rows.

## 4 · The check-in flow

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

## 5 · Intensity semantics

| Intensity | Meaning | Default `Score` multiplier |
|---|---|---|
| 1 | Barely felt | 0.1 |
| 3 | Mild | 0.3 |
| 5 | Moderate | 0.5 |
| 7 | Strong | 0.7 |
| 10 | Overwhelming | 1.0 |

The slider has 10 stops, evenly distributed. The default value is 5 (moderate).

## 6 · Notes field

`Notes` is a free-text field, max 500 characters. It is **never** used in the scoring algorithm — it is stored for the user's own reflection.

The user can:

- Search notes by keyword (e.g. "work", "family").
- Export notes as a journal (JSON or text).
- Delete individual check-ins (which cascades to `detected_attributes` and `interventions_history`).

The notes are **not** sent to the cloud sync layer in v1 — they stay on the device.

## 7 · Multiple check-ins per day

The user can log **multiple emotions** in a single day. There are two patterns:

1. **Single check-in, multiple emotions** — the user picks "Anger" and "Anxiety" in one go, both with their own intensities. The app inserts **two rows** into `checkins`, both with the same `Date`.
2. **Multiple check-ins, single emotion each** — the user logs "Anger" in the morning and "Gratitude" in the evening. The app inserts **two rows** with the same `Date` but different `Emotion_ID`s and `Notes`.

Both patterns are supported and produce the same downstream effect (the rows are summed in the daily Nafs algorithm).

## 8 · Edge cases

| Situation | Handled how |
|---|---|
| User logs the same emotion twice on the same day | Allowed — both rows are stored. The downstream algorithm sums their intensities (capped at 10). |
| User logs no emotion (just notes) | Treated as a "neutral" check-in: `Emotion_ID = NULL`, `Intensity = 0`. The downstream pipeline is a no-op. |
| User deletes a check-in | Cascade delete removes the corresponding `detected_attributes` and `interventions_history` rows. The `nafs_history` row is **not** deleted — it is re-computed from the remaining check-ins. |
| User changes timezone mid-day | All timestamps are stored as local date strings, not UTC instants. The app uses the device's current timezone for "today". |
| User goes back in time (changes device clock) | Check-ins are validated against the device's monotonic clock — no future-dated check-ins. |
| User clears app data | All check-ins are wiped. On next launch, the user starts fresh with a Lawwamah baseline. |

## 9 · Performance

| Operation | Time | Notes |
|---|---|---|
| Insert | < 5 ms | single row |
| Fetch last 15 days | < 10 ms | indexed by `Date` |
| Fetch a single day | < 5 ms | composite index on `(Date, Emotion_ID)` |
| Fetch all (for export) | < 100 ms | 1 year of daily check-ins = ~500 rows |

The table is small and fast. No scaling concerns.

## 11 · Implementation notes

- The table is **created on first launch** by `migrations/v1.dart`.
- The `Date` column is stored as a `TEXT` in ISO 8601 format (`YYYY-MM-DD`) — SQLite's recommended way to store dates.
- The unique index on `(Date, Emotion_ID)` is enforced via a `UNIQUE` constraint.
- A **trigger** deletes the corresponding `detected_attributes` and `interventions_history` rows when a `checkin` is deleted. `nafs_history` is **not** cascaded; the next read recomputes it.
- The check-in screen reads from the **typeahead** in the `emotions` table (filtered by `Keywords`).

## 12 · See also

- `detected_attributes.md` — the output of the check-in pipeline.
- `interventions_history.md` — the recommendations shown after a check-in.
- `nafs_history.md` — the daily Nafs vector.
- `../01_core_tables/emotions.md` — the 50 emotions the user can log.
- `../00_root/user_flow.md` §2.2 — the Check-in screen UX.
- `../08_algorithms/severity_algorithm.md` — how intensity is used in scoring.
