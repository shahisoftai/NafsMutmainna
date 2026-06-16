# `habits` — User-Defined Daily Habits

> The user's stable daily practices (Fajr, Quran, Dhikr, …).
> Powers the 7-day habit completion rate, which is 20% of the daily Nafs calculation.
> **Source:** `HeartOS/04_user_tables/habits.md`
> **Status:** Runtime table — empty at build, populated by user CRUD.

---

## Schema

| Col | Type | Notes |
|---|---|---|
| `Habit_ID` | INTEGER PK | autoincrement |
| `Name` | TEXT | e.g. `Fajr on time` |
| `Category` | TEXT | `Prayer` · `Quran` · `Dhikr` · `Charity` · `Exercise` · `Other` |

A unique index on `(Name)` (per user, in v2) is recommended.

---

## The Five Built-in Categories

| Category | Examples | Default weight in HabitScore |
|---|---|---|
| `Prayer` | Fajr on time, all 5 prayers, Tahajjud | 1.0 (highest) |
| `Quran` | 1 page, 1 juz, daily reflection | 1.0 |
| `Dhikr` | Morning adhkar, evening adhkar, SubhanAllah 100× | 0.8 |
| `Charity` | Daily sadaqah, helping a neighbour | 0.8 |
| `Exercise` | Walk, gym, sport | 0.5 |
| `Other` | Custom | 0.5 |

The default weights are applied in v1.0. In v1.1, the user can customise them per habit.

---

## Sample Habit Catalogue

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

---

## The "Habit Setup" Flow

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

---

## Cardinality

| Side | Cardinality |
|---|---|
| A user | 0–10 habits (typically 4–6) |
| A habit (lifetime) | 0 – 365 × N `habit_logs` rows |

The table itself is tiny. The `habit_logs` table is the one that grows.

---

## CRUD

| Operation | Allowed? | Notes |
|---|---|---|
| Create | ✅ | via the habits screen |
| Read | ✅ | the habits screen + HabitScore calc |
| Update (name, category) | ✅ | but not after `habit_logs` exist for it |
| Delete | ✅ | cascade-deletes `habit_logs` for that habit |
| Archive (soft delete) | ✅ (v1.1) | keeps history but hides from active list |

---

## How It Feeds the Nafs

The `HabitScore` is computed as the **completion rate** over the last 7 days, bucketed into 4 tiers:

| 7-day completion | Bucket | Nafs vector |
|---|---|---|
| ≥ 80% | 3 | (0, 0.10, 0.20, 0.70) |
| 50–80% | 2 | (0, 0.30, 0.50, 0.20) |
| 20–50% | 1 | (0.20, 0.60, 0.20, 0.0) |
| < 20% | 0 | (0.60, 0.40, 0.0, 0.0) |

See `HeartOS/03_nafs_engine/nafs_meter_algorithm.md` §4 for the full algorithm.

---

## Example Rows (Illustrative)

| Habit_ID | Name | Category |
|---:|---|---|
| 1 | Fajr on time | Prayer |
| 2 | Read 1 page of Quran | Quran |
| 3 | Morning adhkar | Dhikr |
| 4 | Evening adhkar | Dhikr |
| 5 | Daily walk (30 min) | Exercise |
| 6 | One act of kindness | Charity |

> **Note:** These are illustrative. The table starts empty.

---

## See also

- `HeartOS/04_user_tables/habits.md` — full spec
- `HeartOS/04_user_tables/habit_logs.md` — the daily logs
- `HeartOS/03_nafs_engine/nafs_meter_algorithm.md` §4 — HabitScore
- `HeartOS/00_root/user_flow.md` §3 — Habits screen
- `HeartOS/08_algorithms/scoring_algorithm.md` — full Nafs formula
