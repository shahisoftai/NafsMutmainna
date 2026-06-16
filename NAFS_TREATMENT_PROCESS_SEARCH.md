# Nafs Treatment Process References in NM-flutter-copy

## Search Summary
A comprehensive search of the NM-flutter-copy codebase has identified extensive references to the Nafs treatment process, including detailed documentation, implementation code, and database configurations for the four stations of the soul.

---

## 1. FOUR NAFS STATIONS - CORE DEFINITIONS

### 1.1 Nafs Ammarah (النفس الأمّارة) — The Soul That Commands Evil

**Quranic Reference:** Qur'an 12:53
> "Indeed, the soul is a persistent enjoiner of evil — except those upon which my Lord has bestowed mercy."

**Description:** The base-desire-driven state. The self follows every whim; the whisper of Shaytan is louder than the whisper of faith.

**Characteristics:**
- Dominant emotions: Anger, jealousy, greed, hatred, lust, arrogance
- Dominant negative attributes: Kibr, Riya, Hasad, Ghadab, Hubb ad-Dunya, Tama
- Dominant positive attributes (dormant): Sabr (very low), Tawakkul (very low), Shukr (very low)
- Signs: Impulsive acts, broken promises, no regret, no intention to change
- Remedy: Struggle (mujahadah), remembrance of death, accountability to a teacher

**System Role in NM-flutter-copy:**
- Nafs_ID: 1
- Canonical position: Leftmost on the Nafs Meter (red color)
- Weight matrix representation: Disease attributes heavily skew toward Ammarah (mean ~65/100)
- Default metric: (Ammarah > 0.50) indicates regression streak

---

### 1.2 Nafs Lawwamah (النفس اللوّامة) — The Self-Reproaching Soul

**Quranic Reference:** Qur'an 75:2
> "And I swear by the self-reproaching soul."

**Description:** The believer's normal state. The self commits sin, then immediately feels guilt. The conscience is active and loud.

**Characteristics:**
- Dominant emotions: Anxiety, regret, fear (of punishment), shame, hope
- Dominant negative attributes (active): Dhann (suspicion), Waswasa, Khawf, Huzn
- Dominant positive attributes (growing): Tawbah, Inabah, Raja, Sabr
- Signs: Frequent istighfar, sincere regret, oscillations between hope and fear
- Remedy: Sustained dhikr, consistent salah, study of the Quran, a practicing community

**System Role in NM-flutter-copy:**
- Nafs_ID: 2
- Canonical position: Second from left on the Nafs Meter (amber color)
- Weight matrix representation: Middle ground — disease attributes pull here, but so do awakening virtues
- Default starting state: **Lawwamah baseline = (0.10, 0.60, 0.20, 0.10)** for new users
- System treats this as "default conscience-active" because Lawwamah is the believer's normal state
- Most system emotions are Lawwamah-skewed (24 of 40 negative emotions)

---

### 1.3 Nafs Mulhamah (النفس الملهمة) — The Inspired Soul

**Quranic Reference:** Qur'an 91:7-8
> "And [by] the soul at rest and proportioned — then He inspired it [to know] its wickedness and its righteousness."

**Description:** The soul that has been inspired to distinguish good from evil. It receives ilham from Allah. It is rare and precious.

**Characteristics:**
- Dominant emotions: Hope, gratitude, contentment, longing, insight
- Dominant positive attributes (dominant): Tawakkul, Shukr, Ikhlas, Tawadu, Muraqabah, Yaqeen
- Dominant negative attributes (residual): Waswasa (low), Dhann (low)
- Signs: Stable salah, consistent dhikr, absence of major sins, ease in giving advice
- Remedy: Continued dhikr, service to creation, sincere du'a

**System Role in NM-flutter-copy:**
- Nafs_ID: 3
- Canonical position: Second from right on the Nafs Meter (blue color)
- Weight matrix representation: Positive attributes skew here; only a few negative attributes reach this state
- Progression trigger: Requires 7 consecutive days with (Mulhamah + Mutmainnah > 0.55)
- Key metric: (Mulhamah + Mutmainnah) * 100 = positive score for the "Today's Practice" section

---

### 1.4 Nafs Mutmainnah (النفس المطمئنة) — The Tranquil Soul

**Quranic Reference:** Qur'an 89:27-30
> "O soul at peace, return to your Lord, well-pleased and well-pleasing to Him. Enter among My servants. Enter My Paradise."

**Description:** The highest station attainable in this life. The soul is at peace with Allah, with His decree, and with His creation. It is the state of the Siddiqin.

**Characteristics:**
- Dominant emotions: Tranquility, deep gratitude, love, serenity, certainty
- Dominant positive attributes (total): Sabr, Shukr, Tawakkul, Ikhlas, Mahabbah, Muraqabah, Yaqeen, Ridha, Tawadu, Hilm
- Dominant negative attributes: None of significance
- Signs: No complaint against Allah's decree, no attachment to the dunya, constant dhikr, radiant face
- Remedy: None — it is the goal itself. Sustained by the constant remembrance of death

**System Role in NM-flutter-copy:**
- Nafs_ID: 4
- Canonical position: Rightmost on the Nafs Meter (green color)
- Weight matrix representation: The "perfect" target. Most positive attributes heavily weighted here; no negative attribute reaches Mutmainnah
- Progression trigger: Requires 30 consecutive days with high positive score
- Key metric: (Mutmainnah * 0.7 + Mulhamah * 0.3) * 100 = Heart Health Score (0-100)

---

## 2. PROGRESSION & FLOW BETWEEN STAGES

### 2.1 State Transitions - Non-Discrete Progression

The system treats the four Nafs states as a **continuous spectrum**, not discrete buckets. A user is always a mix of all four:

**Typical User Examples:**
- **New user:** 30% Ammarah, 55% Lawwamah, 12% Mulhamah, 3% Mutmainnah
- **Practicing user:** 5% Ammarah, 25% Lawwamah, 50% Mulhamah, 20% Mutmainnah
- **Advanced (rare):** 2% Ammarah, 8% Lawwamah, 35% Mulhamah, 55% Mutmainnah

### 2.2 Dominant State Transition Rule

A user is considered to have "transitioned" to a new dominant state only when:
- **The dominant state changes for 7 consecutive days** (to avoid a single bad day knocking them back)

**Implementation Reference:**
- File: `/home/najeeb/Linux-Dev/NM-flutter-copy/lib/src/domain/usecases/nafs/constants.dart`
- Constant: `positiveStreakForMulhamah = 7`
- Constant: `positiveStreakForMutmainnah = 30`

### 2.3 Daily Nafs Computation - 50/20/20/10 Blend

The daily Nafs vector is computed from four weighted components:

```
Nafs_today = 0.50 × AttributeScore
           + 0.20 × EmotionScore
           + 0.20 × HabitScore
           + 0.10 × TrendScore
```

**Component Details:**

1. **AttributeScore (50%)** — The underlying state of the heart
   - Source: `attribute_nafs_weights` × `detected_attributes.Score`
   - Matrix: 200 attributes × 4 Nafs weights
   - Negative attributes mean: (65, 28, 6, 1)
   - Positive attributes mean: (2, 8, 35, 55)

2. **EmotionScore (20%)** — The surface state (what user is feeling)
   - Source: `emotion_nafs_weights` × `checkins.Intensity`
   - Matrix: 50 emotions × 4 Nafs weights
   - Negative emotions mean: (45, 42, 10, 3)
   - Positive emotions mean: (1, 6, 30, 63)

3. **HabitScore (20%)** — The behavioral state (what user is doing)
   - Source: Habit completion rate over last 7 days
   - Buckets:
     - < 20% completion → (0.60, 0.40, 0.00, 0.00)
     - 20-50% → (0.20, 0.60, 0.20, 0.00)
     - 50-80% → (0.00, 0.30, 0.50, 0.20)
     - ≥ 80% → (0.00, 0.10, 0.20, 0.70)

4. **TrendScore (10%)** — The momentum (improving or declining)
   - Source: Comparison of recent 14-day history
   - Splits history into two halves; if recent > older → nudge toward Mulhamah/Mutmainnah
   - Nudge size: ±5% (small effect due to 10% weight)

### 2.4 15-Day Weighted Moving Average Meter

The Home screen meter is NOT today's Nafs, but a **weighted moving average** of last 15 days:
- Today weighs 1.0
- 14 days ago weighs 0.2
- This ensures a single bad day doesn't collapse the meter to Ammarah

**Formula:**
```
meter_15day = (Σ(daily_nafs[i] × weight[i])) / Σ(weight[i])
where weight[i] = 1.0 - (ageInDays × 0.8 / 14)
```

### 2.5 Curated Dhikr to Move Between Stations

The system provides **progressive dhikr** tailored to move the user toward the next station:

**Ammarah → Lawwamah (Turning back to Allah):**
- Dhikr: "أَسْتَغْفِرُ اللَّهَ" (Astaghfirullah)
- Translation: "I seek forgiveness from Allah"

**Lawwamah → Mulhamah (Seeking peace in self-criticism):**
- Dhikr: "لَا إِلَهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ"
- Translation: "There is no deity except You; glory be to You; I was among the wrongdoers" (Dua of Yunus)

**Mulhamah → Mutmainnah (Gratitude as gateway to inspiration):**
- Dhikr: "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ"
- Translation: "All praise is for Allah, Lord of all worlds" (Alhamdulillah)

**Mutmainnah (Tranquil remembrance):**
- Dhikr: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ"
- Translation: "Glory be to Allah and praise be to Him" (SubhanAllahi wa bihamdihi)

**Implementation Reference:**
- File: `/home/najeeb/Linux-Dev/NM-flutter-copy/lib/src/presentation/screens/home/utils/daily_dhikr_resolver.dart` (Lines 582-624)
- Function: `nafsStateDhikr(NafsType nafs)`

---

## 3. SOURCE CODE IMPLEMENTATION FILES

### 3.1 Entity Definitions

| File | Purpose | Key Content |
|------|---------|-------------|
| `/lib/src/domain/entities/nafs_state.dart` | NafsState entity | Maps nafs_states table rows to Dart objects, includes `type` getter |
| `/lib/src/domain/entities/nafs_history.dart` | NafsHistory entity | Daily snapshot (id, date, ammarah, lawwamah, mulhamah, mutmainnah) |
| `/lib/src/domain/entities/vector4.dart` | 4-vector math | NafsType enum (ammarah, lawwamah, mulhamah, mutmainnah), Vector4 operations |

### 3.2 Algorithm & Computation

| File | Purpose | Key Content |
|------|---------|-------------|
| `/lib/src/domain/usecases/nafs/compute_daily_nafs.dart` | Daily Nafs computation | ComputeDailyNafs class (50/20/20/10 blend), Meter15Day, Streak detection |
| `/lib/src/domain/usecases/nafs/constants.dart` | Scoring constants | NafsConstants (weights, windows, habit bias, streak thresholds) |

### 3.3 Repositories

| File | Purpose |
|------|---------|
| `/lib/src/domain/repositories/nafs_state_repository.dart` | Interface for nafs_states |
| `/lib/src/domain/repositories/nafs_history_repository.dart` | Interface for nafs_history |
| `/lib/src/data/repositories/nafs_state_repository_impl.dart` | Implementation (SQLite) |
| `/lib/src/data/repositories/nafs_history_repository_impl.dart` | Implementation (SQLite) |

### 3.4 Presentation & UI

| File | Purpose | Key Content |
|------|---------|-------------|
| `/lib/src/presentation/screens/home/utils/daily_dhikr_resolver.dart` | Dhikr resolution | nafsStateDhikr(), NafsTrendData, JourneyData, curated dhikr by stage |
| `/lib/src/presentation/screens/home/utils/nafs_trend_helper.dart` | Trend calculation | NafsTrendDirection (up, down, flat) |
| `/lib/src/presentation/widgets/specific/nafs_meter.dart` | Nafs meter visualization | Renders 4-vector as visual meter |
| `/lib/src/presentation/screens/journey/journey_screen.dart` | 15-day journey | Shows Nafs progression over time |

---

## 4. DATABASE SCHEMA & SEED DATA

### 4.1 nafs_states Table (4 rows)

**Schema:**
```sql
CREATE TABLE nafs_states (
  Nafs_ID INTEGER PRIMARY KEY,        -- 1-4
  Name TEXT UNIQUE,                   -- Ammarah, Lawwamah, Mulhamah, Mutmainnah
  Arabic_Name TEXT,                   -- with diacritics
  Description TEXT                    -- full paragraph
);
```

**Seed Data Location:**
- File: `/home/najeeb/Linux-Dev/NM-flutter-copy/HeartOS/assets/seeds/nafs_states_seed.sample.json`
- Full seed: `/home/najeeb/Linux-Dev/NM-flutter-copy/assets/data/nafs_states_seed.json`

### 4.2 attribute_nafs_weights Table (200 rows)

**Schema:**
```sql
CREATE TABLE attribute_nafs_weights (
  Attribute_ID INTEGER PRIMARY KEY FK,
  Ammarah REAL,       -- 0-100
  Lawwamah REAL,      -- 0-100
  Mulhamah REAL,      -- 0-100
  Mutmainnah REAL     -- 0-100
  -- Sum must be ~100 (±5)
);
```

**Quality bar:**
- Negative attributes: Ammarah ≥ 50
- Positive attributes: (Mulhamah + Mutmainnah) ≥ 60

**Documentation:**
- File: `/home/najeeb/Linux-Dev/NM-flutter-copy/HeartOS/03_nafs_engine/attribute_nafs_weights.md`

### 4.3 emotion_nafs_weights Table (50 rows)

**Schema:**
```sql
CREATE TABLE emotion_nafs_weights (
  Emotion_ID INTEGER PRIMARY KEY FK,
  Ammarah REAL,       -- 0-100
  Lawwamah REAL,      -- 0-100
  Mulhamah REAL,      -- 0-100
  Mutmainnah REAL     -- 0-100
  -- Sum must be ~100 (±5)
);
```

**Documentation:**
- File: `/home/najeeb/Linux-Dev/NM-flutter-copy/HeartOS/03_nafs_engine/emotion_nafs_weights.md`

### 4.4 nafs_history Table (Daily snapshots)

**Schema:**
```sql
CREATE TABLE nafs_history (
  Record_ID INTEGER PRIMARY KEY,
  Date DATE UNIQUE,
  Ammarah REAL,           -- 0.0-1.0
  Lawwamah REAL,          -- 0.0-1.0
  Mulhamah REAL,          -- 0.0-1.0
  Mutmainnah REAL         -- 0.0-1.0
  -- Sum equals 1.0
);
```

**Documentation:**
- File: `/home/najeeb/Linux-Dev/NM-flutter-copy/HeartOS/04_user_tables/nafs_history.md`

---

## 5. DOCUMENTATION FILES

### 5.1 Core System Documentation

| File | Purpose |
|------|---------|
| `/HeartOS/01_core_tables/nafs_states.md` | Complete Nafs states definition (151 lines) |
| `/HeartOS/tables/04_nafs_states.md` | Quick reference format (97 lines) |
| `/HeartOS/03_nafs_engine/nafs_meter_algorithm.md` | Complete algorithm with examples (285 lines) |
| `/HeartOS/03_nafs_engine/attribute_nafs_weights.md` | Attribute matrix documentation (138 lines) |
| `/HeartOS/03_nafs_engine/emotion_nafs_weights.md` | Emotion matrix documentation (127 lines) |

### 5.2 User & History Tables

| File | Purpose |
|------|---------|
| `/HeartOS/04_user_tables/nafs_history.md` | Daily Nafs diary structure and usage |
| `/HeartOS/04_user_tables/detected_attributes.md` | Attribute detection & scoring |
| `/HeartOS/04_user_tables/checkins.md` | User check-in structure |
| `/HeartOS/04_user_tables/habits.md` | Habit tracking & scoring |

### 5.3 Advancement Pathways

| File | Purpose |
|------|---------|
| `/HeartOS/05_pathways/master_pathways.md` | Master list of disease-to-virtue pathways |
| `/HeartOS/05_pathways/pride_to_humility.md` | Kibr → Tawadu pathway |
| `/HeartOS/05_pathways/anger_to_mercy.md` | Ghadab → Mercifulness pathway |
| `/HeartOS/05_pathways/anxiety_to_peace.md` | Anxiety → Sakinah pathway |
| `/HeartOS/05_pathways/envy_to_contentment.md` | Hasad → Rida pathway |
| `/HeartOS/05_pathways/dunya_to_zuhd.md` | Worldliness → Asceticism pathway |
| `/HeartOS/05_pathways/ghaflah_to_presence.md` | Heedlessness → Presence pathway |
| `/HeartOS/05_pathways/knowledge_to_nearness.md` | Knowledge → Nearness pathway |
| `/HeartOS/05_pathways/sin_to_love.md` | Sin → Divine Love pathway |

---

## 6. KEY SYSTEM CONSTANTS

**File:** `/lib/src/domain/usecases/nafs/constants.dart`

```dart
// 50/20/20/10 blend weights
static const double wAttribute = 0.50;
static const double wEmotion = 0.20;
static const double wHabit = 0.20;
static const double wTrend = 0.10;

// Windows
static const int meterWindowDays = 15;
static const int trendWindowDays = 14;
static const int habitWindowDays = 7;

// Habit completion buckets → Nafs vector
static const List<Vector4> habitBias = [
  Vector4(0.60, 0.40, 0.00, 0.00), // < 20%
  Vector4(0.20, 0.60, 0.20, 0.00), // 20-50%
  Vector4(0.00, 0.30, 0.50, 0.20), // 50-80%
  Vector4(0.00, 0.10, 0.20, 0.70), // >= 80%
];

// Streak thresholds
static const int positiveStreakForMulhamah = 7;
static const int positiveStreakForMutmainnah = 30;
static const int regressionStreakThreshold = 3;

// Trend adjustment
static const double trendNudgeSize = 0.05;
```

---

## 7. QUICK REFERENCE - NAFS PROGRESSION FLOW

```
    Ammarah   Lawwamah   Mulhamah   Mutmainnah
        │         │          │            │
        ▼         ▼          ▼            ▼
    ░░░░░░░   ████████   ████░░░░    ██░░░░░░
    (red)     (amber)     (blue)      (green)
        │         │          │            │
        │         │          │            │
    base        default     inspired     tranquil
    desires     conscience  ilham        at peace
    
                  ↓↓↓ 7 consecutive days ↓↓↓
    
    Astaghfirullah → Dua of Yunus → Alhamdulillah → SubhanAllahi wa bihamdihi
    (forgiveness)   (peaceful cry)   (gratitude)    (tranquil remembrance)
```

---

## 8. FILE PATHS - COMPLETE REFERENCE

### Documentation
- `/home/najeeb/Linux-Dev/NM-flutter-copy/HeartOS/01_core_tables/nafs_states.md`
- `/home/najeeb/Linux-Dev/NM-flutter-copy/HeartOS/tables/04_nafs_states.md`
- `/home/najeeb/Linux-Dev/NM-flutter-copy/HeartOS/03_nafs_engine/nafs_meter_algorithm.md`
- `/home/najeeb/Linux-Dev/NM-flutter-copy/HeartOS/03_nafs_engine/attribute_nafs_weights.md`
- `/home/najeeb/Linux-Dev/NM-flutter-copy/HeartOS/03_nafs_engine/emotion_nafs_weights.md`
- `/home/najeeb/Linux-Dev/NM-flutter-copy/HeartOS/04_user_tables/nafs_history.md`

### Source Code
- `/home/najeeb/Linux-Dev/NM-flutter-copy/lib/src/domain/entities/nafs_state.dart`
- `/home/najeeb/Linux-Dev/NM-flutter-copy/lib/src/domain/entities/nafs_history.dart`
- `/home/najeeb/Linux-Dev/NM-flutter-copy/lib/src/domain/entities/vector4.dart`
- `/home/najeeb/Linux-Dev/NM-flutter-copy/lib/src/domain/usecases/nafs/compute_daily_nafs.dart`
- `/home/najeeb/Linux-Dev/NM-flutter-copy/lib/src/domain/usecases/nafs/constants.dart`
- `/home/najeeb/Linux-Dev/NM-flutter-copy/lib/src/presentation/screens/home/utils/daily_dhikr_resolver.dart`

### Seed Data
- `/home/najeeb/Linux-Dev/NM-flutter-copy/HeartOS/assets/seeds/nafs_states_seed.sample.json`
- `/home/najeeb/Linux-Dev/NM-flutter-copy/assets/data/nafs_states_seed.json`

---

## 9. MATCHES FOUND - COMPREHENSIVE COUNT

**Direct References by Stage:**
- **Nafs Ammarah:** 150+ matches across docs, code, and seed data
- **Nafs Lawwamah:** 180+ matches (most frequent - default state)
- **Nafs Mulhamah:** 140+ matches
- **Nafs Mutmainnah:** 160+ matches

**Progression/Flow References:**
- Transition logic: 20+ matches
- Streak detection: 15+ matches
- Weighted averaging: 25+ matches
- Dhikr progression: 35+ matches in daily_dhikr_resolver.dart alone

---

## 10. RELATIONSHIP TO ISLAMIC TRADITION

The system implements the classical four-station Nafs taxonomy found in Islamic spiritual literature:

- **Nafs Ammarah** — Qur'an 12:53; Ihya Uloom ad-Din (Ghazali)
- **Nafs Lawwamah** — Qur'an 75:2; Islamic spirituality tradition
- **Nafs Mulhamah** — Qur'an 91:7-8; Sufi tradition (inspired soul)
- **Nafs Mutmainnah** — Qur'an 89:27-30; Ultimate goal of spiritual development

Each stage has:
1. Quranic basis and verification
2. Islamic scholarly description
3. Practical remedies aligned with traditional guidance
4. Computational weight matrices for algorithmic treatment
5. Curated dhikr to facilitate progression

