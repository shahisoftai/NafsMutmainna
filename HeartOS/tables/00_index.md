# HeartOS Tables — Complete Database Reference

> All 16 tables of the Heart OS v1 database, with full schemas, seed data, and source references.
> **Source of truth:** `200-Attributes.xlsx`, `50-cores.xlsx`, `NafsMutmainna-200-Attributes.docx` (parent directory)
> **Documentation source:** `HeartOS/00_root/erd.md`, `HeartOS/SCHEMA.sql`, `HeartOS/07_appendices/`
> **Generated:** 2026-06-12

---

## Table Index

| # | Table | Rows | Type | File |
|---:|---|---:|---|---|
| 1 | `attributes` | 200 | Seed (Knowledge) | [01_attributes.md](01_attributes.md) |
| 2 | `emotions` | 50 | Seed (Knowledge) | [02_emotions.md](02_emotions.md) |
| 3 | `domains` | 10 | Seed (Knowledge) | [03_domains.md](03_domains.md) |
| 4 | `nafs_states` | 4 | Seed (Knowledge) | [04_nafs_states.md](04_nafs_states.md) |
| 5 | `emotion_attribute_links` | ~400 | Seed (Graph) | [05_emotion_attribute_links.md](05_emotion_attribute_links.md) |
| 6 | `attribute_links` | ~400 | Seed (Graph) | [06_attribute_links.md](06_attribute_links.md) |
| 7 | `domain_attribute_links` | ~250 | Seed (Graph) | [07_domain_attribute_links.md](07_domain_attribute_links.md) |
| 8 | `domain_emotion_links` | ~80 | Seed (Graph) | [08_domain_emotion_links.md](08_domain_emotion_links.md) |
| 9 | `attribute_nafs_weights` | 200 | Seed (Scoring) | [09_attribute_nafs_weights.md](09_attribute_nafs_weights.md) |
| 10 | `emotion_nafs_weights` | 50 | Seed (Scoring) | [10_emotion_nafs_weights.md](10_emotion_nafs_weights.md) |
| 11 | `checkins` | runtime | User | [11_checkins.md](11_checkins.md) |
| 12 | `detected_attributes` | runtime | User | [12_detected_attributes.md](12_detected_attributes.md) |
| 13 | `nafs_history` | runtime | User | [13_nafs_history.md](13_nafs_history.md) |
| 14 | `interventions_history` | runtime | User | [14_interventions_history.md](14_interventions_history.md) |
| 15 | `habits` | runtime | User | [15_habits.md](15_habits.md) |
| 16 | `habit_logs` | runtime | User | [16_habit_logs.md](16_habit_logs.md) |
| 17 | `hadees` | ~250 | Seed (Knowledge) | [17_hadees.md](17_hadees.md) |
| 18 | `quran_ayat` | ~250 | Seed (Knowledge) | [18_quran_ayat.md](18_quran_ayat.md) |
| 19 | `emotion_hadees_links` | ~250 | Seed (Graph) | [19_emotion_hadees_links.md](19_emotion_hadees_links.md) |
| 20 | `emotion_quran_links` | ~250 | Seed (Graph) | [20_emotion_quran_links.md](20_emotion_quran_links.md) |

---

## Schema Summary (from `SCHEMA.sql`)

```sql
-- Layer 1: Knowledge (immutable, seed once)
emotions                  (50 rows, 21 cols)
attributes                (200 rows, 23 cols)
domains                   (10 rows, 4 cols)
nafs_states               (4 rows, 4 cols)
hadees                    (~250 rows, 7 cols)    -- Authentic hadees pool
quran_ayat                (~250 rows, 7 cols)   -- Authentic Quranic verses pool

-- Layer 2: Graph (immutable, seed once)
emotion_attribute_links   (~400 rows, 5 cols)
attribute_links           (~400 rows, 5 cols) -- Heart Graph
domain_attribute_links    (~250 rows, 4 cols)
domain_emotion_links      (~80 rows, 4 cols)
emotion_hadees_links     (~250 rows, 4 cols)   -- Emotion→Hadees M:N
emotion_quran_links       (~250 rows, 4 cols)   -- Emotion→Ayat M:N

-- Layer 3: Nafs Engine (immutable, seed once)
attribute_nafs_weights    (200 rows, 5 cols)
emotion_nafs_weights      (50 rows, 5 cols)

-- Layer 4: User (mutable, runtime only)
checkins                  (runtime, 5 cols)
detected_attributes       (runtime, 4 cols)
nafs_history              (runtime, 5 cols)
interventions_history     (runtime, 6 cols)
habits                    (runtime, 3 cols)
habit_logs                (runtime, 4 cols)
```

---

## Seed Data Status

| Table | Data Source | Status |
|---|---|---|
| `attributes` | `200-Attributes.xlsx` | ✅ Complete (200 rows) |
| `emotions` | `50-cores.xlsx` | ✅ Complete (50 rows) |
| `domains` | `01_core_tables/domains.md` | ✅ Complete (10 rows) |
| `nafs_states` | `01_core_tables/nafs_states.md` | ✅ Complete (4 rows) |
| `emotion_attribute_links` | Derived from `emotions` + `attributes` | ✅ Generated (~400 rows) |
| `attribute_links` | Heart Graph (pathways + opposites) | ✅ Generated (~400 rows) |
| `domain_attribute_links` | Derived from attributes by domain | ✅ Generated (~250 rows) |
| `domain_emotion_links` | Derived from emotions by domain | ✅ Generated (~80 rows) |
| `attribute_nafs_weights` | Editorial 4-vector per attribute | ✅ Generated (200 rows) |
| `emotion_nafs_weights` | Editorial 4-vector per emotion | ✅ Generated (50 rows) |
| User tables | Runtime | Empty at build |

---

## Cardinality & Cardinality Rules

See `HeartOS/00_root/erd.md` §3 for the full cardinality table.

Key relationships:
- `emotions` → `emotion_attribute_links` → `attributes` (1:m:m)
- `attributes` → `attribute_links` → `attributes` (self-referencing, 1:m:1)
- `domains` → `domain_*_links` → `attributes`/`emotions` (1:m:m)
- `attributes` → `attribute_nafs_weights` (1:1)
- `emotions` → `emotion_nafs_weights` (1:1)
- `emotions` → `checkins` (1:m)
- `checkins` → `detected_attributes` (1:m, via trigger)
- `checkins` → `interventions_history` (1:m)
- `nafs_states` ← referenced by weight tables and `nafs_history`
- `habits` → `habit_logs` (1:m, CASCADE)
- `emotions` → `emotion_hadees_links` → `hadees` (1:m:m)
- `emotions` → `emotion_quran_links` → `quran_ayat` (1:m:m)

---

## Foreign Key Constraints

```sql
emotion_attribute_links.Emotion_ID    → emotions.Emotion_ID
emotion_attribute_links.Attribute_ID  → attributes.Attribute_ID
attribute_links.Source_Attribute_ID   → attributes.Attribute_ID
attribute_links.Target_Attribute_ID   → attributes.Attribute_ID
domain_attribute_links.Domain_ID      → domains.Domain_ID
domain_attribute_links.Attribute_ID   → attributes.Attribute_ID
domain_emotion_links.Domain_ID        → domains.Domain_ID
domain_emotion_links.Emotion_ID       → emotions.Emotion_ID
attribute_nafs_weights.Attribute_ID   → attributes.Attribute_ID
emotion_nafs_weights.Emotion_ID       → emotions.Emotion_ID
checkins.Emotion_ID                   → emotions.Emotion_ID
detected_attributes.Attribute_ID      → attributes.Attribute_ID
interventions_history.Emotion_ID      → emotions.Emotion_ID
interventions_history.Attribute_ID    → attributes.Attribute_ID
habit_logs.Habit_ID                   → habits.Habit_ID (ON DELETE CASCADE)
emotion_hadees_links.Emotion_ID        → emotions.Emotion_ID
emotion_hadees_links.Hadees_ID        → hadees.Hadees_ID
emotion_quran_links.Emotion_ID         → emotions.Emotion_ID
emotion_quran_links.Ayat_ID            → quran_ayat.Ayat_ID
interventions_history.Session_ID        → (for randomization)
interventions_history.Hadees_ID        → hadees.Hadees_ID
interventions_history.Ayat_ID          → quran_ayat.Ayat_ID
```

---

## CHECK Constraints

| Table | Constraint |
|---|---|
| `emotions` | `Category IN ('Negative', 'Positive')` |
| `emotions` | `Dominant_Nafs_State IN ('Ammarah','Lawwamah','Mulhamah','Mutmainnah')` |
| `emotions` | `Severity_Weight BETWEEN 1 AND 10` |
| `attributes` | `Nature IN ('Positive', 'Negative')` |
| `emotion_attribute_links` | `Weight BETWEEN 0.0 AND 1.0` |
| `emotion_attribute_links` | `Role IN ('Disease', 'Treatment', 'Core', 'Strengthens')` |
| `attribute_links` | `Weight BETWEEN 0.0 AND 1.0` |
| `attribute_links` | `Relationship IN ('Cure', 'Leads_To', 'Strengthens', 'Opposes')` |
| `attribute_links` | `Source_Attribute_ID <> Target_Attribute_ID` |
| `domain_*_links` | `Weight BETWEEN 0.0 AND 1.0` |
| `nafs_states` | `Name IN ('Ammarah','Lawwamah','Mulhamah','Mutmainnah')` |
| `attribute_nafs_weights` | Each col BETWEEN 0 AND 100; sum BETWEEN 95 AND 105 |
| `emotion_nafs_weights` | Each col BETWEEN 0 AND 100; sum BETWEEN 95 AND 105 |
| `checkins` | `Intensity BETWEEN 0 AND 10` |
| `detected_attributes` | `Score BETWEEN 0.0 AND 1.0` |
| `interventions_history` | `Intervention_Type IN ('Quran','Hadith','Dua','Allah_Names','Dhikr','Action')` |
| `interventions_history` | `Completed IN (0,1)` |
| `nafs_history` | Sum of 4 cols BETWEEN 0.99 AND 1.01 |
| `habits` | `Category IN ('Prayer','Quran','Dhikr','Charity','Exercise','Other')` |
| `habit_logs` | `Completed IN (0,1)` |

---

## Triggers

```sql
-- When a checkin is inserted → recompute detected_attributes
CREATE TRIGGER trg_checkin_insert AFTER INSERT ON checkins ...

-- When a checkin is deleted → recompute detected_attributes
CREATE TRIGGER trg_checkin_delete AFTER DELETE ON checkins ...
```

---

## Views

```sql
v_meter_15day         -- The 15-day Nafs weighted average
v_top_attributes_today -- Top detected attributes for today
```

---

## Seed Order (per `SCHEMA.sql` §10)

1. `nafs_states` (no dependencies)
2. `emotions` (no dependencies)
3. `attributes` (no dependencies)
4. `domains` (no dependencies)
5. `emotion_nafs_weights` (depends on `emotions`)
6. `attribute_nafs_weights` (depends on `attributes`)
7. `emotion_attribute_links` (depends on `emotions`, `attributes`)
8. `attribute_links` (depends on `attributes`)
9. `domain_attribute_links` (depends on `domains`, `attributes`)
10. `domain_emotion_links` (depends on `domains`, `emotions`)
11. `hadees` (no dependencies)
12. `quran_ayat` (no dependencies)
13. `emotion_hadees_links` (depends on `emotions`, `hadees`)
14. `emotion_quran_links` (depends on `emotions`, `quran_ayat`)
