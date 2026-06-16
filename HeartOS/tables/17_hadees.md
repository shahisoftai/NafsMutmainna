# `hadees` — Authentic Hadees Pool

> Normalized pool of authentic hadees for Heart OS v1 interventions.
> **Purpose:** Enables 3-7 random hadees per emotion with session-level deduplication.
> **Source:** Sahih al-Bukhari, Sahih Muslim, Jami' at-Tirmidhi, Sunan Abu Dawud, Sunan Ibn Majah
> **Authenticity:** Sahih and Hasan grades only; Da'if excluded
> **Generated:** 2026-06-15

---

## Schema (7 columns)

| Col | Type | Notes |
|---|---|---|
| `Hadees_ID` | INTEGER PK | 1–N |
| `Arabic_Text` | TEXT | Full hadees text in Arabic |
| `English_Translation` | TEXT | Authentic English translation |
| `Urdu_Translation` | TEXT | Authentic Urdu translation |
| `Source_Book` | TEXT | e.g. `Sahih Muslim` |
| `Hadith_Number` | TEXT | e.g. `91` |
| `Grade` | TEXT | `Sahih`, `Hasan`, or `Hasan li-ghayrihi` |

---

## Grade Key

| Grade | Arabic | Meaning |
|---|---|---|
| `Sahih` | صحيح | Authentic — highest reliability |
| `Hasan` | حسن | Good — supported narrator chain |
| `Hasan li-ghayrihi` | حسن لغيره | Hasan due to supporting narrators |

---

## Source Collections

| Collection | Abbreviation | Status |
|---|---|---|
| Sahih al-Bukhari | Bukhari | Primary |
| Sahih Muslim | Muslim | Primary |
| Jami' at-Tirmidhi | Tirmidhi | Secondary (mark grade) |
| Sunan Abu Dawud | Abu Dawud | Secondary (mark grade) |
| Sunan Ibn Majah | Ibn Majah | Secondary (mark grade) |

---

## Quick Reference (all hadees in pool)

| ID | Source | Number | Grade | Related Emotions |
|---:|---|---|---|---|
| 1 | Sahih Muslim | 91 | Sahih | Arrogance, Pride |
| 2 | Sahih al-Bukhari | 6116 | Sahih | Anger |
| 3 | Sahih Muslim | 2564 | Sahih | Jealousy, Envy |
| 4 | Sahih Muslim | 1053 | Sahih | Patience, Impatience |
| 5 | Sahih al-Bukhari | 6470 | Sahih | Trust, Reliance |
| 6 | Sahih Muslim | 2755 | Sahih | Hopelessness |
| 7 | Sahih Muslim | 2749 | Sahih | Pride, Self-admiration |
| 8 | Sahih Muslim | 2985 | Sahih | Showing Off |
| 9 | Sahih Muslim | 1021 | Sahih | Stinginess |
| 10 | Sahih Muslim | 2956 | Sahih | Love of Dunya |
| ... | ... | ... | ... | ... |

---

## Full Data

[See `assets/data/hadees_data.json` for complete hadees pool]

---

## See also

- `18_quran_ayat.md` — Quranic ayat pool
- `19_emotion_hadees_links.md` — Emotion-to-hadees mapping with weights
- `20_emotion_quran_links.md` — Emotion-to-ayat mapping with weights
- `IMPLEMENTATION_PLAN_HADITH_QURAN.md` — Full implementation plan
- `GLOSSARY.md` §"Hadith authentication" — Authentication standard

(End of file - total 50 lines)
