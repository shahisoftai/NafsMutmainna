# `emotion_hadees_links` — Emotion to Hadees Mapping

> Many-to-many links between emotions and authentic hadees.
> **Purpose:** Enable weighted random selection of hadees per emotion with session-level deduplication.
> **Weight:** 0.3–1.0, where 1.0 = most relevant
> **Generated:** 2026-06-15

---

## Schema (4 columns)

| Col | Type | Notes |
|---|---|---|
| `Link_ID` | INTEGER PK | Auto-increment |
| `Emotion_ID` | INTEGER FK | → `emotions.Emotion_ID` |
| `Hadees_ID` | INTEGER FK | → `hadees.Hadees_ID` |
| `Weight` | REAL | 0.0–1.0, relevance weight |

**Constraint:** `UNIQUE (Emotion_ID, Hadees_ID)`

---

## Weight Distribution Guideline

| Weight Range | Meaning |
|---|---|
| 0.8–1.0 | Primary hadees — directly addresses the emotion |
| 0.5–0.7 | Secondary hadees — strongly related |
| 0.3–0.4 | Tertiary hadees — supporting context |

---

## Distribution

- **150-350 total links** (3-7 per emotion)
- All 50 emotions have at least 3 hadees links
- Weights sum across links is not constrained (not a probability distribution)

---

## Quick Reference

| Emotion_ID | Emotion | Hadees Count | Sample Hadees IDs |
|---:|---|---:|---|
| 1 | Anger | 5 | 2, 15, 23, 45, 78 |
| 2 | Jealousy | 5 | 3, 56, 89, 112, 145 |
| 3 | Anxiety | 6 | 34, 67, 89, 123, 156, 189 |
| 4 | Fear | 5 | 34, 67, 101, 134, 167 |
| 5 | Sadness | 5 | 23, 78, 134, 167, 201 |
| ... | ... | ... | ... |

---

## Full Data

[See `assets/seeds/emotion_hadees_links_seed.json` for complete link data]

---

## See also

- `17_hadees.md` — Hadees pool (source)
- `02_emotions.md` — Emotions table (source)
- `20_emotion_quran_links.md` — Emotion-to-Quran mapping
- `IMPLEMENTATION_PLAN_HADITH_QURAN.md` — Full implementation plan

(End of file - total 50 lines)
