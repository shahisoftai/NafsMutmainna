# `habits` — User-Defined Daily Habits

> The user's stable daily practices (Fajr, Quran, Dhikr, …). Powers the 7-day habit completion rate, which is 20% of the daily Nafs calculation.

---

## 1 · Purpose

`habits` is the user's **catalogue of daily practices**. A habit is a small, repeatable action that the user wants to track. The system uses the completion rate to compute the `HabitScore` component of the Nafs Meter (see `../03_nafs_engine/nafs_meter_algorithm.md` §4).

This table is **optional in v1.0** — a user can opt out of habits entirely. The system then defaults to the "no habits" behaviour described in §10 of the Nafs algorithm.

## 2 · Schema

| Col | Type | Notes |
|---|---|---|
| `Habit_ID` | INTEGER PK | autoincrement |
| `Name` | TEXT | e.g. `Fajr on time` |
| `Category` | TEXT | `Prayer` · `Quran` · `Dhikr` · `Charity` · `Exercise` · `Other` |

A unique index on `(Name)` (per user, in v2) is recommended.

## 3 · The five built-in categories

| Category | Examples | Default weight in HabitScore |
|---|---|---|
| `Prayer` | Fajr on time, all 5 prayers, Tahajjud | 1.0 (highest) |
| `Quran` | 1 page, 1 juz, daily reflection | 1.0 |
| `Dhikr` | Morning adhkar, evening adhkar, SubhanAllah 100× | 0.8 |
| `Charity` | Daily sadaqah, helping a neighbour | 0.8 |
| `Exercise` | Walk, gym, sport | 0.5 |
| `Other` | Custom | 0.5 |

The default weights are applied in v1.0. In v1.1, the user can customise them per habit.

## 4 · Sample habit catalogue

A typical user will start with 4–6 habits:

| Name | Category |
|---|---|
| Fajr on time | Prayer |
| Read 1 page of Quran | Quran |
| Morning adhkar | Dhikr |
| Evening adhkar | Dhikr |
| Daily walk (30 min) | Exercise |
| One act of kindness | Charity |

The system **does not** ship with a default catalogue — the user adds habits on first launch (or skips entirely).

## 5 · The "habit setup" flow

```
   First launch
        │
        ▼
   "Would you like to track daily habits?" (Yes / No)
        │
        ├── No → habits table is empty; HabitScore = bucket 0 (Ammarah-leaning)
        │
        └── Yes → habit setup wizard
                    │
                    ├── Pick from 10 suggestions
                    │
                    ├── Add custom
                    │
                    └── Confirm
```

In v1.0, the wizard offers 10 suggested habits (2 per category). The user can also add a custom one.

## 6 · Cardinality

| Side | Cardinality |
|---|---|
| A user | 0–10 habits (typically 4–6) |
| A habit (lifetime) | 0 – 365 × N `habit_logs` rows |

The table itself is tiny. The `habit_logs` table is the one that grows.

## 7 · CRUD

| Operation | Allowed? | Notes |
|---|---|---|
| Create | ✅ | via the habits screen |
| Read | ✅ | the habits screen + HabitScore calc |
| Update (name, category) | ✅ | but not after `habit_logs` exist for it (to keep history clean) |
| Delete | ✅ | cascade-deletes `habit_logs` for that habit |
| Archive (soft delete) | ✅ (v1.1) | keeps the history but hides from active list |

## 8 · The "weight" concept (v1.1)

In v1.0, every habit counts equally. In v1.1, each habit can have a **weight** (0.5–1.0) that reflects its importance to the user. The `HabitScore` then becomes a weighted average.

This requires a `Weight` column — not in v1.0.

## 9 · Habit presets (v1.1)

In v1.1, the system may ship **5–10 preset habit packs** for common user profiles:

- **New Muslim** — 5 prayers, morning/evening adhkar, 1 Quran page.
- **Student** — Fajr + Isha on time, 1 Quran page, daily reflection.
- **Parent** — Fajr on time, evening adhkar, family Quran time.
- **Working professional** — Dhuhr + Asr on time, lunch-break dhikr, evening walk.
- **Traveller** — Simplified set (1 prayer, 1 dhikr).

The user picks a preset and customises it. This is a UI feature; the data model is unchanged.

## 10 · How it feeds the Nafs

The `HabitScore` is computed as the **completion rate** over the last 7 days, bucketed into 4 tiers:

| 7-day completion | Bucket | Nafs vector |
|---|---|---|
| ≥ 80% | 3 | (0, 0.10, 0.20, 0.70) |
| 50–80% | 2 | (0, 0.30, 0.50, 0.20) |
| 20–50% | 1 | (0.20, 0.60, 0.20, 0.0) |
| < 20% | 0 | (0.60, 0.40, 0.0, 0.0) |

See `../03_nafs_engine/nafs_meter_algorithm.md` §4 for the full algorithm.

## 11 · Edge cases

| Situation | Handled how |
|---|---|
| User has 0 habits | HabitScore = bucket 0 (Ammarah-leaning). |
| User has 1 habit and completes it every day | 100% completion → bucket 3. |
| User adds a habit mid-week | Counts for the days it exists. The completion rate is normalised. |
| User deletes a habit | `habit_logs` are cascade-deleted. The completion rate is recomputed. |
| User has 50 habits | The completion rate denominator gets large — a 50-habit user will rarely hit bucket 3. The system caps the denominator at 10 (top 10 most-tracked habits). |

## 12 · Implementation notes

- The table is created by `migrations/v1.dart` (the deferred migration `v1.1.dart` will add the `Weight` column).
- The cascade delete is implemented as a **FOREIGN KEY** constraint: `habit_logs.Habit_ID REFERENCES habits.Habit_ID ON DELETE CASCADE`.
- The CRUD lives in `lib/src/data/datasources/local/habit_datasource.dart`.
- The HabitScore computation lives in `lib/src/domain/usecases/nafs/habit_score.dart` — a pure function.

## 14 · See also

- `habit_logs.md` — the daily logs.
- `../03_nafs_engine/nafs_meter_algorithm.md` §4 — the HabitScore calculation.
- `../00_root/user_flow.md` §3 — the Habits screen.
- `../08_algorithms/scoring_algorithm.md` — the full Nafs formula.
