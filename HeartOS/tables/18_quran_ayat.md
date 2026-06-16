# `quran_ayat` — Authentic Quranic Ayat Pool

> Normalized pool of authentic Quranic verses for Heart OS v1 interventions.
> **Purpose:** Enables 3-7 random Quranic ayat per emotion with session-level deduplication.
> **Source:** Quran with authentic translations
> **Authenticity:** All verses verified against standard mushaf
> **Generated:** 2026-06-15

---

## Schema (7 columns)

| Col | Type | Notes |
|---|---|---|
| `Ayat_ID` | INTEGER PK | 1–N |
| `Arabic_Text` | TEXT | Full verse text in Arabic |
| `English_Translation` | TEXT | Authentic English translation |
| `Urdu_Translation` | TEXT | Authentic Urdu translation |
| `Surah_Name` | TEXT | e.g. `Al-Baqarah` |
| `Verse_Number` | INTEGER | e.g. `153` |
| `Full_Reference` | TEXT | e.g. `Al-Baqarah 2:153` |

---

## Translation Sources

| Language | Source | Notes |
|---|---|---|
| English | Sahih International / Pickthall / Yusuf Ali | Standard authentic translations |
| Urdu | Farooq Hamid / Abdul Qadir | Standard authentic translations |

---

## Quick Reference

| ID | Surah | Verse | Full Reference | Related Emotions |
|---:|---|---|---|---|
| 1 | Al-Baqarah | 153 | Al-Baqarah 2:153 | Patience, Perseverance |
| 2 | Ali Imran | 134 | Ali Imran 3:134 | Anger, Forbearance |
| 3 | Al-A'raf | 205 | Al-A'raf 7:205 | Remembrance, Heart |
| 4 | Az-Zumar | 53 | Az-Zumar 39:53 | Hopelessness, Hope |
| 5 | Ar-Ra'd | 28 | Ar-Ra'd 13:28 | Tranquility, Remembrance |
| 6 | Al-Fath | 4 | Al-Fath 48:4 | Tranquility, Calm |
| 7 | At-Talaq | 3 | At-Talaq 65:3 | Trust, Reliance |
| 8 | Al-Hadid | 57:20 | Al-Hadid 57:20 | Love of Dunya, Contentment |
| 9 | Al-Ma'un | 107:4-6 | Al-Ma'un 107:4-6 | Showing Off |
| 10 | Luqman | 31:18 | Luqman 31:18 | Arrogance, Pride |
| ... | ... | ... | ... | ... |

---

## Full Data

[See `assets/data/quran_ayat_data.json` for complete ayat pool]

---

## See also

- `17_hadees.md` — Hadees pool
- `19_emotion_hadees_links.md` — Emotion-to-hadees mapping
- `20_emotion_quran_links.md` — Emotion-to-ayat mapping with weights
- `IMPLEMENTATION_PLAN_HADITH_QURAN.md` — Full implementation plan

(End of file - total 50 lines)
