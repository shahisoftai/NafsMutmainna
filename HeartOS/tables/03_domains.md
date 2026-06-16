# `domains` — 10 Macro-Domains of the Heart

> The 10 macro-domains that group the 200 attributes and 50 emotions into thematic buckets.
> **Source:** `HeartOS/01_core_tables/domains.md`, `HeartOS/07_appendices/domain_structure.md`, `assets/seeds/domains_seed.sample.json`

---

## Schema

| Col | Type | Notes |
|---|---|---|
| `Domain_ID` | INTEGER PK | 1–10 |
| `Domain_Name` | TEXT | English |
| `Arabic_Name` | TEXT | |
| `Description` | TEXT | one paragraph |

---

## Seed Data (10 rows)

| Domain_ID | Domain_Name | Arabic_Name | Description |
|---:|---|---|---|
| 1 | Iman | الإيمان | Faith itself — its presence, growth, and protection. Includes Tawheed, Yaqeen, and the rejection of Shirk. |
| 2 | Tawheed & Yaqeen | التوحيد واليقين | The oneness of Allah and the certainty of faith. Anchors the entire belief system. |
| 3 | Worship | العبادة | The five pillars and the voluntary acts — prayer, fasting, zakat, hajj, and the smaller sunan. |
| 4 | Dhikr & Quran | الذكر والقرآن | Remembrance of Allah and recitation / reflection on the Quran. The nourishment of the heart. |
| 5 | Character | الأخلاق | Akhlaq — patience, honesty, humility, generosity, gentleness, and their opposites. |
| 6 | Relationships | العلاقات | How we treat family, neighbours, spouses, the poor, the wronged, the living, and the dead. |
| 7 | Dunya | الدنيا | Attitude toward the material world — wealth, status, time, body, and possessions. |
| 8 | Sabr & Tawakkul | الصبر والتوكل | Patience in trials and reliance on Allah. The two pillars of the tested soul. |
| 9 | Diseases of Heart | أمراض القلب | The classical *amradh al-qalb* — Riya, Kibr, Hasad, Nifaq, Ujb, Hiqd, and their remedies. |
| 10 | Love of Allah & Akhirah | محبة الله والآخرة | Mahabbah — love of Allah, longing for the Akhirah, fear, hope, and tawakkul. |

---

## Notes

- Several domains are conceptually adjacent (e.g. Iman ↔ Tawheed & Yaqeen ↔ Love of Allah). This is intentional — the domains are *lenses*, not silos.
- An attribute can belong to multiple domains (weighted), and an emotion can surface in multiple domains.
- The 5 narrative macro-domains in `NafsMutmainna-200-Attributes.docx` (Core Spiritual Vices · Emotional Vulnerabilities · Social Dynamics · Cognitive Traps · Behavioral Habits) are *coarser* and used for documentation only. The 10 domains above are the canonical runtime split.

---

## See also

- `HeartOS/01_core_tables/domains.md` — full prose
- `HeartOS/07_appendices/domain_structure.md` — appendix C
- `HeartOS/02_relationships/domain_attribute_links.md` — attribute mapping
- `HeartOS/02_relationships/domain_emotion_links.md` — emotion mapping
- `HeartOS/assets/seeds/domains_seed.sample.json` — JSON seed (full data)
