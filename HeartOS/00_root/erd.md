# Heart OS — Entity-Relationship Diagram

> The 14 core tables (plus 3 optional) of Heart OS v1, with column definitions, primary keys, foreign keys, and cardinalities.

The physical schema is implemented in SQLite (one file, one schema). Optional tables 15–17 (habits, pathways, goals, milestones) are deferred — see `09_future/`.

---

## 1 · Master diagram

```
                    ┌──────────────┐
                    │   emotions   │  (50)
                    └──────┬───────┘
                           │ 1
                           │
              many         │         many
       ┌───────────────────┼───────────────────┐
       │                   │                   │
       ▼                   ▼                   ▼
┌──────────────────┐ ┌─────────────┐  ┌────────────────────────┐
│ emotion_attribute│ │   domains   │  │  emotion_nafs_weights  │
│      _links      │ │   (10)      │  │       (50)             │
└────────┬─────────┘ └──────┬──────┘  └────────────┬───────────┘
         │ many             │ 1                    │ 1
         │                  │                      │
   many  │                  │ many         many    │
         ▼                  ▼                      │
   ┌────────────┐   ┌───────────────────┐          │
   │ attributes │◀──│ domain_attribute  │          │
   │  (200)     │   │      _links       │          │
   └────┬───────┘   └───────────────────┘          │
        │ 1                                          │
        │                                            │
        ├──── many ────► attribute_links ──── self-referencing
        │                   (Heart Graph)            │
        │                                            │
        │ many                                       │
        ▼                                            │
   ┌──────────────────────┐                          │
   │attribute_nafs_weights│                          │
   │       (200)          │                          │
   └──────────┬───────────┘                          │
              │ 1                                    │
              ▼                                      │
   ┌──────────────────────┐                          │
   │    nafs_states (4)   │◀─────────────────────────┘
   │ Ammarah · Lawwamah   │
   │ Mulhamah · Mutmainnah│
   └──────────────────────┘

        ───────  USER LAYER  ───────

   ┌────────────┐                ┌─────────────────────────┐
   │  checkins  │───1────────m──▶│  detected_attributes    │
   │  (1/day)   │                │                         │
   └─────┬──────┘                └────────────┬────────────┘
         │ 1                                  │ m
         │ m                                  │
         ▼                                    ▼
   ┌──────────────────────────┐    ┌──────────────────────────┐
   │ interventions_history    │    │     nafs_history         │
   │  (recommendations shown) │    │  (1/day, 15-day window)  │
   └──────────────────────────┘    └──────────────────────────┘

   ┌────────────┐                ┌──────────────────────────┐
   │  habits    │───1────────m──▶│      habit_logs          │
   └────────────┘                └──────────────────────────┘
```

---

## 2 · Tables in detail

### 2.1 `attributes` (200 rows · seed once)

| Col | Type | Notes |
|---|---|---|
| `Attribute_ID` | INTEGER PK | 1–200 |
| `Attribute` | TEXT | English name |
| `Arabic_Name` | TEXT | e.g. الرياء |
| `Nature` | TEXT | `Positive` or `Negative` |
| `Definition` | TEXT | One-sentence definition |
| `Opposite_Trait` | TEXT | e.g. Ikhlas |
| `Opposite_Arabic_Name` | TEXT | e.g. الإخلاص |
| `Keywords` | TEXT | comma-separated search tokens |
| `Quran_Reference` | TEXT | e.g. `Al-Ma'un 107:4-6` |
| `Quran_Arabic` | TEXT | verse text (Arabic) |
| `Quran_English` | TEXT | translation |
| `Quran_Urdu` | TEXT | translation |
| `Hadith_Reference` | TEXT | e.g. `Sahih Muslim 91` |
| `Hadith_Arabic` | TEXT | hadith text (Arabic) |
| `Hadith_Urdu` | TEXT | translation |
| `Quranic_Dua_Reference` | TEXT | optional |
| `Quranic_Dua_Arabic` | TEXT | |
| `Quranic_Dua_Urdu` | TEXT | |
| `Prophetic_Dua_Reference` | TEXT | optional |
| `Prophetic_Dua_Arabic` | TEXT | |
| `Prophetic_Dua_Urdu` | TEXT | |
| `Relevant_Allah_Names` | TEXT | comma-separated, e.g. `Al-Halim,Ar-Rahim` |
| `Practical_Understanding` | TEXT | 1–3 line practitioner note |

See `01_core_tables/attributes.md` for the full schema discussion and distribution of 70 negative / 130 positive attributes.

### 2.2 `emotions` (50 rows · seed once)

| Col | Type | Notes |
|---|---|---|
| `Emotion_ID` | INTEGER PK | 1–50 |
| `Core_Emotion` | TEXT | English name |
| `Arabic_Name` | TEXT | e.g. الغضب |
| `Category` | TEXT | `Negative` (40) or `Positive` (10) |
| `Description` | TEXT | one-sentence |
| `Common_Triggers` | TEXT | what usually triggers it |
| `Primary_Negative_Attributes` | TEXT | `;`-separated |
| `Secondary_Negative_Attributes` | TEXT | `;`-separated |
| `Primary_Positive_Attributes` | TEXT | `;`-separated |
| `Growth_Path` | TEXT | e.g. `Ghadab→Sabr→Hilm→Rifq` |
| `Dominant_Nafs_State` | TEXT | one of the 4 Nafs states |
| `Severity_Weight` | INTEGER | 1–10, default severity |
| `Recommended_Attribute_Priority` | TEXT | which attribute to address first |
| `Recommended_Intervention_Type` | TEXT | e.g. `Patience`, `Dua`, `Gratitude` |
| `Recommended_Dua` | TEXT | the dua text |
| `Recommended_Allah_Names` | TEXT | `;`-separated |
| `Recommended_Dhikr` | TEXT | e.g. `SubhanAllahi wa bihamdihi` |
| `Daily_Action` | TEXT | one micro-action |
| `Related_Emotions` | TEXT | `;`-separated IDs or names |
| `Related_Attribute_IDs` | TEXT | `;`-separated attribute IDs |
| `Keywords` | TEXT | search tokens |

### 2.3 `emotion_attribute_links` (~400 rows · seed once)

| Col | Type | Notes |
|---|---|---|
| `Link_ID` | INTEGER PK | |
| `Emotion_ID` | INTEGER FK → `emotions` | |
| `Attribute_ID` | INTEGER FK → `attributes` | |
| `Weight` | REAL | 0.0 – 1.0, used for ranking |
| `Role` | TEXT | enum: `Disease` · `Treatment` · `Core` · `Strengthens` |

Composite index: `(Emotion_ID, Attribute_ID)`.

### 2.4 `attribute_links` (~400 rows · the **Heart Graph**)

| Col | Type | Notes |
|---|---|---|
| `Link_ID` | INTEGER PK | |
| `Source_Attribute_ID` | INTEGER FK → `attributes` | |
| `Target_Attribute_ID` | INTEGER FK → `attributes` | |
| `Weight` | REAL | 0.0 – 1.0 |
| `Relationship` | TEXT | enum: `Cure` · `Leads_To` · `Strengthens` · `Opposes` |

This is a **self-referencing** many-to-many on `attributes`. The graph is treated as directed (`Source → Target`). See `heart_graph.md`.

### 2.5 `domains` (10 rows · seed once)

| Col | Type | Notes |
|---|---|---|
| `Domain_ID` | INTEGER PK | 1–10 |
| `Domain_Name` | TEXT | English |
| `Arabic_Name` | TEXT | |
| `Description` | TEXT | |

The 10 domains are: Iman · Tawheed & Yaqeen · Worship · Dhikr & Quran · Character · Relationships · Dunya · Sabr & Tawakkul · Diseases of Heart · Love of Allah & Akhirah.

### 2.6 `domain_attribute_links` (~600 rows)

| Col | Type | Notes |
|---|---|---|
| `Link_ID` | INTEGER PK | |
| `Domain_ID` | INTEGER FK | |
| `Attribute_ID` | INTEGER FK | |
| `Weight` | REAL | 0.0 – 1.0 |

### 2.7 `domain_emotion_links` (~200 rows)

| Col | Type | Notes |
|---|---|---|
| `Link_ID` | INTEGER PK | |
| `Domain_ID` | INTEGER FK | |
| `Emotion_ID` | INTEGER FK | |
| `Weight` | REAL | 0.0 – 1.0 |

### 2.8 `nafs_states` (4 rows · seed once)

| Col | Type | Notes |
|---|---|---|
| `Nafs_ID` | INTEGER PK | |
| `Name` | TEXT | `Ammarah` · `Lawwamah` · `Mulhamah` · `Mutmainnah` |
| `Arabic_Name` | TEXT | |
| `Description` | TEXT | |

### 2.9 `attribute_nafs_weights` (200 rows · seed once)

| Col | Type | Notes |
|---|---|---|
| `Attribute_ID` | INTEGER PK + FK | 1:1 with `attributes` |
| `Ammarah` | REAL | 0–100, sum of four ≈ 100 |
| `Lawwamah` | REAL | |
| `Mulhamah` | REAL | |
| `Mutmainnah` | REAL | |

Example (Kibr, the disease of arrogance): `Ammarah=90, Lawwamah=10, Mulhamah=0, Mutmainnah=0`.

### 2.10 `emotion_nafs_weights` (50 rows · seed once)

Same shape as `attribute_nafs_weights`, keyed by `Emotion_ID`.

### 2.11 `checkins` (1 per day per user)

| Col | Type | Notes |
|---|---|---|
| `Checkin_ID` | INTEGER PK | |
| `Date` | DATE | ISO 8601 |
| `Emotion_ID` | INTEGER FK | |
| `Intensity` | INTEGER | 1–10 |
| `Notes` | TEXT | optional free text |

### 2.12 `detected_attributes` (1–10 per day)

| Col | Type | Notes |
|---|---|---|
| `Record_ID` | INTEGER PK | |
| `Date` | DATE | |
| `Attribute_ID` | INTEGER FK | |
| `Score` | REAL | output of the algorithm |

### 2.13 `nafs_history` (1 per day)

| Col | Type | Notes |
|---|---|---|
| `Record_ID` | INTEGER PK | |
| `Date` | DATE | unique per day |
| `Ammarah` | REAL | 0–100 |
| `Lawwamah` | REAL | |
| `Mulhamah` | REAL | |
| `Mutmainnah` | REAL | |

The 15-day rolling window is computed from this table.

### 2.14 `interventions_history` (1 per recommendation shown)

| Col | Type | Notes |
|---|---|---|
| `Record_ID` | INTEGER PK | |
| `Date` | DATE | |
| `Emotion_ID` | INTEGER FK | |
| `Attribute_ID` | INTEGER FK | |
| `Intervention_Type` | TEXT | `Quran` · `Hadith` · `Dua` · `Allah_Names` · `Dhikr` · `Action` |
| `Completed` | BOOLEAN | did the user mark it done? |

### 2.15 `habits` *(deferred)*

| Col | Type | Notes |
|---|---|---|
| `Habit_ID` | INTEGER PK | |
| `Name` | TEXT | e.g. `Fajr`, `Quran page` |
| `Category` | TEXT | `Prayer` · `Quran` · `Dhikr` · `Charity` · `Exercise` |

### 2.16 `habit_logs` *(deferred)*

| Col | Type | Notes |
|---|---|---|
| `Record_ID` | INTEGER PK | |
| `Date` | DATE | |
| `Habit_ID` | INTEGER FK | |
| `Completed` | BOOLEAN | |

### 2.17 `master_pathways` *(deferred)*

| Col | Type | Notes |
|---|---|---|
| `Pathway_ID` | INTEGER PK | |
| `Name` | TEXT | e.g. `Anger → Mercy` |
| `Start_Attribute_ID` | INTEGER FK | |
| `End_Attribute_ID` | INTEGER FK | |

See `05_pathways/` for the 8 master pathways.

---

## 3 · Cardinality summary

| Parent | Child | Cardinality |
|---|---|---|
| `emotions` | `emotion_attribute_links` | 1 → m |
| `attributes` | `emotion_attribute_links` | 1 → m |
| `attributes` | `attribute_links` (source) | 1 → m |
| `attributes` | `attribute_links` (target) | 1 → m |
| `domains` | `domain_attribute_links` | 1 → m |
| `attributes` | `domain_attribute_links` | 1 → m |
| `domains` | `domain_emotion_links` | 1 → m |
| `emotions` | `domain_emotion_links` | 1 → m |
| `attributes` | `attribute_nafs_weights` | 1 → 1 |
| `emotions` | `emotion_nafs_weights` | 1 → 1 |
| `emotions` | `checkins` | 1 → m |
| `checkins` | `detected_attributes` | 1 → m |
| `checkins` | `interventions_history` | 1 → m |
| `emotions` | `interventions_history` | 1 → m |
| `attributes` | `interventions_history` | 1 → m |
| `habits` | `habit_logs` | 1 → m |

---

## 4 · Implementation note

The schema is implemented in SQLite via Drift (or raw `sqflite`). The full DDL is generated by `lib/src/data/datasources/local/migrations/v1.dart` and runs once on first launch. Re-running migrations on a populated database is a no-op.
