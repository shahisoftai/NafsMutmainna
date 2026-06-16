# `domains` — The 10 Macro-Domains of the Heart

> The coarse categorisation of attributes and emotions. A way to ask "is the issue in my Iman, my Character, or my Relationships?" without getting lost in the 200-attribute detail.

---

## 1 · Purpose

`domains` is the **high-level navigation** of Heart OS. It groups the 200 attributes into 10 thematic buckets so that:

1. The user can browse attributes by area of life.
2. The system can compute the **dominant domain** of a check-in (the Insight screen's "domain badge").
3. Analytics can show which area of the heart needs the most attention.

## 2 · Schema

| Col | Type | Notes |
|---|---|---|
| `Domain_ID` | INTEGER PK | 1–10 |
| `Domain_Name` | TEXT | English |
| `Arabic_Name` | TEXT | |
| `Description` | TEXT | one paragraph |

## 3 · The 10 domains

| ID | Name (EN) | Arabic | Description |
|---|---|---|---|
| 1 | **Iman** | الإيمان | Faith itself — its presence, growth, and protection. Includes Tawheed, Yaqeen, and the rejection of Shirk. |
| 2 | **Tawheed & Yaqeen** | التوحيد واليقين | The oneness of Allah and the certainty of faith. Anchors the entire belief system. |
| 3 | **Worship** | العبادة | The five pillars and the voluntary acts — prayer, fasting, zakat, hajj, and the smaller sunan. |
| 4 | **Dhikr & Quran** | الذكر والقرآن | Remembrance of Allah and recitation / reflection on the Quran. The nourishment of the heart. |
| 5 | **Character** | الأخلاق | Akhlaq — patience, honesty, humility, generosity, gentleness, and their opposites. |
| 6 | **Relationships** | العلاقات | How we treat family, neighbours, spouses, the poor, the wronged, the living, and the dead. |
| 7 | **Dunya** | الدنيا | Attitude toward the material world — wealth, status, time, body, and possessions. |
| 8 | **Sabr & Tawakkul** | الصبر والتوكل | Patience in trials and reliance on Allah. The two pillars of the tested soul. |
| 9 | **Diseases of Heart** | أمراض القلب | The classical *amradh al-qalb* — Riya, Kibr, Hasad, Nifaq, Ujb, Hiqd, and their remedies. |
| 10 | **Love of Allah & Akhirah** | محبة الله والآخرة | Mahabbah — love of Allah, longing for the Akhirah, fear, hope, and tawakkul. |

> **Note on overlap.** Several domains are conceptually adjacent (e.g. Iman ↔ Tawheed & Yaqeen ↔ Love of Allah). This is intentional — the domains are *lenses*, not silos. An attribute can belong to multiple domains (weighted), and an emotion can surface in multiple domains.

## 4 · Why 10?

| # domains | Verdict |
|---|---|
| 5 | Too coarse; loses the Iman/Character/Dunya split. |
| **10** | ✅ Sweet spot — covers the major lenses without overlap dominating. |
| 20 | Too granular; user can't hold them in mind. |

This is the same conclusion as the `master_pathways` count (8) — there is a "natural grain size" for Islamic self-improvement and it is roughly 8–12 buckets.

## 5 · Relationships

| Link table | Role |
|---|---|
| `domain_attribute_links` | Maps each of the 200 attributes to 1–3 domains with a weight. |
| `domain_emotion_links` | Maps each of the 50 emotions to 1–3 domains with a weight. |

```
   domains
      │
      ├── 1 ── m ── domain_attribute_links ── m ── 1 ── attributes
      │
      └── 1 ── m ── domain_emotion_links   ── m ── 1 ── emotions
```

## 6 · How the dominant domain is computed

For a given check-in:

1. Resolve the emotion(s) and find the top 3 detected attributes.
2. Look up each attribute's domain weights (`domain_attribute_links`).
3. Sum the weights, weighted by the attribute's score.
4. The domain with the highest sum is the **dominant domain**.

Example: *Anger (intensity 7)*

- Detected attributes: Ghadab, Sabr
- Ghadab domains: Character (0.7), Sabr & Tawakkul (0.3)
- Sabr domains: Sabr & Tawakkul (0.9), Character (0.1)
- Sum: Character = 0.7×Ghadab + 0.1×Sabr = 0.71; Sabr & Tawakkul = 0.3×Ghadab + 0.9×Sabr = 0.94
- **Dominant domain**: Sabr & Tawakkul

The Insight screen shows a small badge: `🟢 Sabr & Tawakkul`.

## 7 · Implementation notes

- The table is **seeded once**.
- `Domain_ID` is a stable 1–10 integer and is the foreign key in both link tables.
- The English name is the primary display label; the Arabic name is shown on the Domain detail screen.
- A user can **pin a domain** to the Home screen (a Home-screen card) — this is a v1.1 feature.
- The Description field is rendered as the lead paragraph on the Domain detail screen.

## 8 · Why domain_attribute_links is *not* 1-to-1

Many attributes legitimately belong to multiple domains. Examples:

| Attribute | Primary domain | Secondary domain |
|---|---|---|
| Sabr (41) | Sabr & Tawakkul | Character |
| Tawakkul (60) | Sabr & Tawakkul | Iman |
| Shukr (22) | Worship | Character · Love of Allah & Akhirah |
| Kibr (2) | Diseases of Heart | Character |
| Hasad (12) | Diseases of Heart | Relationships |

The weights in `domain_attribute_links` capture this hierarchy. The sum of weights for an attribute is **not** constrained to 1.0; instead the highest-weighted domain is treated as the "primary" for the purpose of the Domain detail screen.

## 9 · Open questions (TBD)

- Should the description for each domain include a one-line Quranic anchor? (e.g. Iman → "Those who believe and do good — for them is blessing and a generous return." Qur'an 13:29)
- Should a domain be "available" to the user only after a certain number of check-ins? (No — keep it open from day 1.)
- Should there be a per-domain streak (e.g. "30-day Iman streak")? (Possibly a v1.1 feature.)

## 10 · File outputs

- The full list with descriptions is in `../07_appendices/domain_structure.md`.
- The `domain_attribute_links` and `domain_emotion_links` tables are described in `../02_relationships/`.
