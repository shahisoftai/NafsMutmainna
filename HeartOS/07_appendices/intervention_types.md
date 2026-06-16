# Appendix D — Intervention Types

> The 6 types of intervention the system can show on the Intervention screen.

| # | Type | Source field | Example |
|---:|---|---|---|
| 1 | **Quran** | `attributes.Quran_Reference` + `Quran_Arabic` | Surah Al-Ma'un 107:4-6 (for Riya) |
| 2 | **Hadith** | `attributes.Hadith_Reference` + `Hadith_Arabic` | Sahih Muslim 91 (for Kibr) |
| 3 | **Dua** | `attributes.Quranic_Dua_*` or `Prophetic_Dua_*` | "Allahumma ihdini li ahsani al-akhlaq" |
| 4 | **Allah Names** | `attributes.Relevant_Allah_Names` | Al-Halim, Ar-Rahim, Ar-Rafiq |
| 5 | **Dhikr** | `emotions.Recommended_Dhikr` | "SubhanAllahi wa bihamdihi" |
| 6 | **Action** | `emotions.Daily_Action` | "Remain silent and perform wudu" |

---

## D.1 · Selection rules

- A single check-in surfaces up to **6 cards per top-3 attributes** = 18 cards max.
- The Intervention screen shows the top **6** by rank.
- The 7-day no-repeat filter ensures variety.

## D.2 · Card UI structure

Each card on the Intervention screen has the same 4-line structure:

```
[Type]              <-- chip in top-left (Quran / Hadith / ...)
[Arabic content]    <-- primary text, RTL
[Reference]         <-- small text below
[Done] [Skip]       <-- action buttons
```

## D.3 · Completion semantics

A card is "completed" only when the user taps **Done**. The algorithm does not assume the user did the intervention just because they viewed it.

## D.4 · Why 6 types

| Type | Need addressed |
|---|---|
| Quran | Source of guidance and the highest authority. |
| Hadith | The Prophet's ﷺ practical example. |
| Dua | Direct conversation with Allah. |
| Allah Names | A focus for meditation. |
| Dhikr | A repeatable practice that builds the virtue. |
| Action | A concrete micro-task that the user can do *today*. |

Together they cover the heart (Names), the mind (Quran/Hadith), the tongue (Dhikr/Dua), and the hands (Action).
