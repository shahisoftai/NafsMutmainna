# HeartOS — Hadees & Quranic Ayat Implementation Plan

> Comprehensive plan to normalize hadees and Quranic ayat into dedicated tables, enabling 3-7 random authentic references per emotion with session-level deduplication.
> **Generated:** 2026-06-15
> **Status:** Implementation Ready

---

## 1 · Executive Summary

**Problem:** Currently, each `attribute` carries at most 1 embedded hadees reference and 1 embedded Quran reference. With 3 treatment/core attributes per emotion, users see the same content when they re-select the same emotion.

**Solution:** Extract all hadees and Quranic ayat into normalized pools (`hadees`, `quran_ayat`) with M:N link tables to emotions, enabling:
- 3-7 authentic hadees per emotion
- 3-7 authentic Quranic ayat per emotion
- Session-level randomization (same emotion → different content on re-selection)
- Proper source attribution (Sahih Bukhari, Sahih Muslim, etc.)

**Scale:**
- 50 emotions × 5 hadees avg = ~250 hadees entries
- 50 emotions × 5 ayat avg = ~250 Quranic ayat entries
- All authentically sourced (Sahih Bukhari, Sahih Muslim, Jami' at-Tirmidhi, Sunan Abu Dawud, Sunan Ibn Majah)

---

## 2 · Authenticity Standard

Per the 2026-06-12 HeartOS audit (`AUDIT_REPORT.md` §3.5):

| Collection | Grade | Usage |
|---|---|---|
| Sahih al-Bukhari | Muttafaqun 'Alayh (highest) | Primary source |
| Sahih Muslim | Muttafaqun 'Alayh (highest) | Primary source |
| Jami' at-Tirmidhi | Sahih / Hasan | Mark explicitly |
| Sunan Abu Dawud | Sahih / Hasan | Mark explicitly |
| Sunan Ibn Majah | Sahih / Hasan | Mark explicitly |
| Musnad Ahmad | Mixed | Use only well-supported |
| Riyad as-Salihin (Imam an-Nawawi) | Hasan / Daif | Verify each |

**Rule:** Only Sahih and Hasan hadees are included. Da'if hadees are excluded unless they have Hasan support.

---

## 3 · Schema Design

### 3.1 `hadees` Table

```sql
CREATE TABLE hadees (
    Hadees_ID           INTEGER PRIMARY KEY,
    Arabic_Text         TEXT NOT NULL,
    English_Translation TEXT NOT NULL,
    Urdu_Translation    TEXT NOT NULL,
    Source_Book         TEXT NOT NULL,
    Hadith_Number       TEXT NOT NULL,
    Grade               TEXT NOT NULL CHECK (Grade IN ('Sahih', 'Hasan', 'Hasan li-ghayrihi'))
);
CREATE INDEX IF NOT EXISTS idx_hadees_source ON hadees(Source_Book);
CREATE INDEX IF NOT EXISTS idx_hadees_grade ON hadees(Grade);
```

### 3.2 `quran_ayat` Table

```sql
CREATE TABLE quran_ayat (
    Ayat_ID             INTEGER PRIMARY KEY,
    Arabic_Text         TEXT NOT NULL,
    English_Translation TEXT NOT NULL,
    Urdu_Translation    TEXT NOT NULL,
    Surah_Name         TEXT NOT NULL,
    Verse_Number       INTEGER NOT NULL,
    Full_Reference     TEXT NOT NULL  -- e.g. "Al-Baqarah 2:153"
);
CREATE INDEX IF NOT EXISTS idx_quran_surah ON quran_ayat(Surah_Name);
```

### 3.3 `emotion_hadees_links` Table

```sql
CREATE TABLE emotion_hadees_links (
    Link_ID             INTEGER PRIMARY KEY,
    Emotion_ID          INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
    Hadees_ID          INTEGER NOT NULL REFERENCES hadees(Hadees_ID),
    Weight              REAL NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0),
    UNIQUE (Emotion_ID, Hadees_ID)
);
CREATE INDEX IF NOT EXISTS idx_ehl_emotion ON emotion_hadees_links(Emotion_ID);
CREATE INDEX IF NOT EXISTS idx_ehl_hadees ON emotion_hadees_links(Hadees_ID);
```

### 3.4 `emotion_quran_links` Table

```sql
CREATE TABLE emotion_quran_links (
    Link_ID             INTEGER PRIMARY KEY,
    Emotion_ID          INTEGER NOT NULL REFERENCES emotions(Emotion_ID),
    Ayat_ID             INTEGER NOT NULL REFERENCES quran_ayat(Ayat_ID),
    Weight              REAL NOT NULL CHECK (Weight BETWEEN 0.0 AND 1.0),
    UNIQUE (Emotion_ID, Ayat_ID)
);
CREATE INDEX IF NOT EXISTS idx_eql_emotion ON emotion_quran_links(Emotion_ID);
CREATE INDEX IF NOT EXISTS idx_eql_ayat ON emotion_quran_links(Ayat_ID);
```

### 3.5 `interventions_history` Extension

```sql
ALTER TABLE interventions_history ADD COLUMN Session_ID TEXT NOT NULL DEFAULT '';
ALTER TABLE interventions_history ADD COLUMN Hadees_ID INTEGER REFERENCES hadees(Hadees_ID);
ALTER TABLE interventions_history ADD COLUMN Ayat_ID INTEGER REFERENCES quran_ayat(Ayat_ID);
```

---

## 4 · Randomization Strategy

### 4.1 Session-Level Non-Repeat

Each check-in session generates a UUID (`Session_ID`). When fetching hadees/ayat for an emotion:

```sql
-- Fetch random hadees for emotion, excluding already-shown this session
SELECT h.* FROM hadees h
JOIN emotion_hadees_links ehl ON h.Hadees_ID = ehl.Hadees_ID
WHERE ehl.Emotion_ID = :emotionId
  AND h.Hadees_ID NOT IN (
      SELECT Hadees_ID FROM interventions_history
      WHERE Emotion_ID = :emotionId
        AND Session_ID = :sessionId
        AND Hadees_ID IS NOT NULL
  )
ORDER BY ehl.Weight DESC, RANDOM()
LIMIT 1;
```

### 4.2 7-Day Global No-Repeat (Existing)

```sql
-- Extend existing 7-day filter to use specific IDs
SELECT Hadees_ID, Ayat_ID FROM interventions_history
WHERE Date >= date('now', '-7 day');
```

### 4.3 Emotion Re-Selection

When user selects the same emotion again in a new session:
- New `Session_ID` generated
- All hadees/ayat for that emotion are eligible again
- Weighted random selection ensures variety

---

## 5 · Content Plan by Emotion

### 5.1 Negative Emotions (1-30) — Priority Order

| ID | Emotion | Hadees Count | Quran Count | Primary Sources |
|---|---|---|---|---|
| 1 | Anger | 5 | 5 | Sahih Muslim, Abu Dawud |
| 2 | Jealousy | 5 | 4 | Sahih Muslim, Tirmidhi |
| 3 | Anxiety | 6 | 5 | Sahih Muslim, Abu Dawud |
| 4 | Fear | 5 | 5 | Sahih Muslim, Bukhari |
| 5 | Sadness | 5 | 5 | Sahih Muslim, Tirmidhi |
| 6 | Hopelessness | 5 | 6 | Sahih Muslim, Ibn Majah |
| 7 | Guilt | 5 | 4 | Sahih Muslim, Abu Dawud |
| 8 | Laziness | 5 | 4 | Bukhari, Abu Dawud |
| 9 | Loneliness | 5 | 5 | Sahih Muslim, Tirmidhi |
| 10 | Emptiness | 5 | 5 | Sahih Muslim, Bukhari |
| 11 | Arrogance | 5 | 5 | Sahih Muslim, Bukhari |
| 12 | Pride | 5 | 4 | Sahih Muslim, Tirmidhi |
| 13 | Showing Off | 5 | 4 | Sahih Muslim, Abu Dawud |
| 14 | Greed | 5 | 4 | Sahih Muslim, Ibn Majah |
| 15 | Love of Dunya | 5 | 6 | Sahih Muslim, Bukhari |
| 16 | Hatred | 5 | 4 | Sahih Muslim, Tirmidhi |
| 17 | Desire for Revenge | 5 | 4 | Sahih Muslim, Abu Dawud |
| 18 | Suspicion | 4 | 4 | Sahih Muslim, Bukhari |
| 19 | Doubt | 5 | 5 | Sahih Muslim, Tirmidhi |
| 20 | Confusion | 4 | 4 | Sahih Muslim, Abu Dawud |
| 21 | Distractedness | 5 | 5 | Sahih Muslim, Bukhari |
| 22 | Weak Faith | 5 | 6 | Sahih Muslim, Tirmidhi |
| 23 | Impatience | 5 | 5 | Sahih Muslim, Abu Dawud |
| 24 | Hard-heartedness | 5 | 5 | Sahih Muslim, Bukhari |
| 25 | Stinginess | 5 | 4 | Sahih Muslim, Ibn Majah |
| 26 | Excessive Attachment | 5 | 5 | Sahih Muslim, Tirmidhi |
| 27 | Envy of Status | 5 | 4 | Sahih Muslim, Abu Dawud |
| 28 | Shame after Sin | 5 | 4 | Sahih Muslim, Bukhari |
| 29 | Overthinking | 4 | 4 | Sahih Muslim, Tirmidhi |
| 30 | Restlessness | 5 | 5 | Sahih Muslim, Abu Dawud |

### 5.2 Positive Emotions (31-50)

| ID | Emotion | Hadees Count | Quran Count | Primary Sources |
|---|---|---|---|---|
| 31 | Hope | 5 | 5 | Sahih Muslim, Bukhari |
| 32 | Gratitude | 5 | 5 | Sahih Muslim, Ibn Majah |
| 33 | Patience | 6 | 6 | Sahih Muslim, Bukhari |
| 34 | Love for the Prophet | 5 | 4 | Sahih Bukhari, Muslim |
| 35 | Love for Knowledge | 5 | 4 | Sahih Muslim, Tirmidhi |
| 36 | Generosity | 5 | 5 | Sahih Muslim, Bukhari |
| 37 | Courage | 5 | 4 | Sahih Muslim, Abu Dawud |
| 38 | Justice | 5 | 5 | Sahih Muslim, Tirmidhi |
| 39 | Contentment | 5 | 5 | Sahih Muslim, Ibn Majah |
| 40 | Devotion | 5 | 4 | Sahih Muslim, Bukhari |
| 41 | Humility | 5 | 5 | Sahih Muslim, Tirmidhi |
| 42 | Sincerity | 5 | 4 | Sahih Bukhari, Muslim |
| 43 | Trust | 5 | 5 | Sahih Muslim, Abu Dawud |
| 44 | Certainty | 5 | 5 | Sahih Muslim, Bukhari |
| 45 | Reverence | 5 | 5 | Sahih Muslim, Tirmidhi |
| 46 | Tranquility | 5 | 5 | Sahih Muslim, Bukhari |
| 47 | Repentance | 6 | 5 | Sahih Muslim, Abu Dawud |
| 48 | Spiritual Longing | 5 | 5 | Sahih Bukhari, Muslim |
| 49 | Happiness in Worship | 5 | 4 | Sahih Muslim, Tirmidhi |
| 50 | Nearness to Allah | 5 | 5 | Sahih Muslim, Bukhari |

**Total:** ~250 hadees + ~250 ayat

---

## 6 · Implementation Phases

### Phase 1: Documentation & Schema
- [x] Create this implementation plan
- [ ] Create table schema files (17-20)
- [ ] Update SCHEMA.sql
- [ ] Update 00_index.md
- [ ] Update ERD and architecture docs

### Phase 2: Content Compilation
- [ ] Compile authentic hadees for emotions 1-25
- [ ] Compile authentic hadees for emotions 26-50
- [ ] Compile authentic Quranic ayat for emotions 1-25
- [ ] Compile authentic Quranic ayat for emotions 26-50
- [ ] Verify all references against source collections

### Phase 3: Seed Data
- [ ] Create hadees_seed.json
- [ ] Create quran_ayat_seed.json
- [ ] Create emotion_hadees_links_seed.json
- [ ] Create emotion_quran_links_seed.json

### Phase 4: Code Integration
- [ ] Update Flutter data sources (content_seeds.dart)
- [ ] Update recommendation algorithm for randomization
- [ ] Update interventions_history model with new columns
- [ ] Test session-level deduplication

---

## 7 · Seed Order

Updated order for database initialization:

```
1. nafs_states
2. emotions
3. attributes
4. domains
5. emotion_nafs_weights
6. attribute_nafs_weights
7. emotion_attribute_links
8. attribute_links
9. domain_attribute_links
10. domain_emotion_links
11. hadees                    (NEW)
12. quran_ayat               (NEW)
13. emotion_hadees_links     (NEW)
14. emotion_quran_links      (NEW)
```

---

## 8 · File Structure

```
HeartOS/
├── tables/
│   ├── 17_hadees.md              # Hadees pool schema + content
│   ├── 18_quran_ayat.md          # Quranic ayat pool schema + content
│   ├── 19_emotion_hadees_links.md # Emotion→Hadees mapping
│   └── 20_emotion_quran_links.md  # Emotion→Ayat mapping
├── assets/
│   ├── seeds/
│   │   ├── hadees_seed.json       # Full hadees data
│   │   ├── quran_ayat_seed.json   # Full quran data
│   │   ├── emotion_hadees_links_seed.json
│   │   └── emotion_quran_links_seed.json
│   └── data/
│       ├── hadees_data.json
│       └── quran_ayat_data.json
├── SCHEMA.sql                     # Updated with new tables
├── 00_root/
│   └── erd.md                    # Updated ERD
└── 00_index.md                   # Updated table index
```

---

## 9 · Key Implementation Notes

### 9.1 Translation Standards
- **English:** Use canonical translations (Muhammad Pickthall, Abdullah Yusuf Ali, or Sahih International)
- **Urdu:** Use authentic Urdu translations (Farooq Hamid, Abdul Qadir, or similar)
- Preserve Arabic text exactly as in mashq

### 9.2 Hadees Numbering
- Use standard numbering: Bukhari (#), Muslim (#), Tirmidhi (#), Abu Dawud (#), Ibn Majah (#)
- Example: `Sahih Muslim 91` — not `HR Muslim 91` or `Muslim, No. 91`

### 9.3 Quran Reference Format
- Format: `Surah_Name Chapter:Verse`
- Example: `Al-Baqarah 2:153`
- Include full Arabic reference: `سورة البقرة ٢:١٥٣`

### 9.4 Grade Marking
- `Sahih` — Authentic (no qualification needed)
- `Hasan` — Good (well-supported narrator chain)
- `Hasan li-ghayrihi` — Hasan due to supporting narrators

### 9.5 Weight Assignment
- Primary hadees/ayat (most relevant): Weight 0.8-1.0
- Secondary hadees/ayat (supporting): Weight 0.5-0.7
- Tertiary hadees/ayat (related): Weight 0.3-0.4

---

## 10 · See Also

- `HeartOS/tables/00_index.md` — Table index (update to include 17-20)
- `HeartOS/SCHEMA.sql` — DDL for all tables
- `HeartOS/AUDIT_REPORT.md` §3.5 — Hadith authentication standard
- `HeartOS/GLOSSARY.md` §Hadith authentication — Authentication documentation
- `HeartOS/08_algorithms/recommendation_algorithm.md` — Recommendation pipeline
- `HeartOS/IMPLEMENTATION_PLAN.md` — Flutter implementation details

---

*Last updated: 2026-06-15*
