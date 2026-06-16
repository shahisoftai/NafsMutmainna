# `emotion_quran_links` — Emotion to Quranic Ayat Mapping

> Many-to-many links between emotions and authentic Quranic verses.
> **Purpose:** Enable weighted random selection of ayat per emotion with session-level deduplication.
> **Weight:** 0.3–1.0, where 1.0 = most relevant
> **Generated:** 2026-06-15

---

## Schema (4 columns)

| Col | Type | Notes |
|---|---|---|
| `Link_ID` | INTEGER PK | Auto-increment |
| `Emotion_ID` | INTEGER FK | → `emotions.Emotion_ID` |
| `Ayat_ID` | INTEGER FK | → `quran_ayat.Ayat_ID` |
| `Weight` | REAL | 0.0–1.0, relevance weight |

**Constraint:** `UNIQUE (Emotion_ID, Ayat_ID)`

---

## Weight Distribution Guideline

| Weight Range | Meaning |
|---|---|
| 0.8–1.0 | Primary ayat — directly addresses the emotion |
| 0.5–0.7 | Secondary ayat — strongly related |
| 0.3–0.4 | Tertiary ayat — supporting context |

---

## Distribution

- **150-350 total links** (3-7 per emotion)
- All 50 emotions have at least 3 quran links
- Weights are independent per emotion (not constrained to sum to 1)

---

## Quick Reference

| Emotion_ID | Emotion | Ayat Count | Sample Ayat IDs |
|---:|---|---:|---|
| 1 | Anger | 5 | 12, 45, 78, 134, 167 |
| 2 | Jealousy | 4 | 23, 89, 145, 201 |
| 3 | Anxiety | 5 | 34, 67, 101, 156, 189 |
| 4 | Fear | 5 | 34, 67, 112, 145, 178 |
| 5 | Sadness | 5 | 12, 67, 123, 156, 201 |
| ... | ... | ... | ... |

---

## Full Data

[See `assets/seeds/emotion_quran_links_seed.json` for complete link data]

---

## See also

- `18_quran_ayat.md` — Quranic ayat pool (source)
- `02_emotions.md` — Emotions table (source)
- `19_emotion_hadees_links.md` — Emotion-to-hadees mapping
- `IMPLEMENTATION_PLAN_HADITH_QURAN.md` — Full implementation plan

(End of file - total 50 lines)
