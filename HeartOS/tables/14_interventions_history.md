# `interventions_history` — Recommendation History

> The log of every intervention the system has shown to the user.
> Powers the "history" view, streak calculations, and "what worked" analytics.
> **Source:** `HeartOS/04_user_tables/interventions_history.md`
> **Status:** Runtime table — empty at build, populated by check-in pipeline.

---

## Schema

| Col | Type | Notes |
|---|---|---|
| `Record_ID` | INTEGER PK | autoincrement |
| `Date` | DATE | |
| `Emotion_ID` | INTEGER FK → `emotions` | the check-in that triggered it |
| `Attribute_ID` | INTEGER FK → `attributes` | the attribute being addressed |
| `Intervention_Type` | TEXT | `Quran` · `Hadith` · `Dua` · `Allah_Names` · `Dhikr` · `Action` |
| `Completed` | BOOLEAN | default 0; user toggles to 1 |

---

## The Six Intervention Types

| Type | Source field on `attributes` | Example |
|---|---|---|
| `Quran` | `Quran_Reference` + `Quran_Arabic` | Surah Al-Ma'un 107:4-6 (for Riya) |
| `Hadith` | `Hadith_Reference` + `Hadith_Arabic` | Sahih Muslim 91 (for Kibr) |
| `Dua` | `Quranic_Dua_*` or `Prophetic_Dua_*` | "Allahumma ihdini li ahsani al-akhlaq" |
| `Allah_Names` | `Relevant_Allah_Names` | Al-Halim, Ar-Rahim, Ar-Rafiq |
| `Dhikr` | `emotions.Recommended_Dhikr` | "SubhanAllahi wa bihamdihi" |
| `Action` | `emotions.Daily_Action` | "Remain silent and perform wudu" |

A single check-in typically surfaces **all six** — one card per type on the Intervention screen.

---

## How Rows Are Populated

```python
def surface_interventions(checkin: Checkin):
    detected = get_detected_attributes(checkin.Date)
    rows = []
    for attr in detected[:3]:    # top 3 attributes only
        for type, content in intervention_payloads(attr, checkin.Emotion_ID):
            if not shown_recently(content, days=7):
                rows.append((checkin.Date, checkin.Emotion_ID, attr.ID, type, False))
    insert_many("interventions_history", rows)
```

---

## The "No-Repeat" Rule

A Quran verse that was shown 3 days ago will not be shown again until day 10. This is enforced by the `shown_recently` check above.

The rule applies **per intervention content** (not per intervention type). So if the user logs "Anger" today and "Anger" tomorrow, the system may show *different* Quran verses for Ghadab (there are several in the seed).

---

## Completion Semantics

The user sees the Intervention screen with 6 cards. They can:
- Read a card and mark it **Done** (sets `Completed = 1`)
- Swipe past a card (no change to `Completed`)
- Mark it as **Not now** (sets `Completed = 0` explicitly, but the row stays)

A card is "completed" if and only if the user tapped the Done button. The algorithm **does not** assume the user did the intervention just because they viewed it.

---

## How `Completed` Affects the Nafs

The proposed v1 formula (see `HeartOS/08_algorithms/scoring_algorithm.md`):

```
intervention_completion_bonus = 0.02 × completed_count / surfaced_count
```

This adds a small bias toward Mulhamah/Mutmainnah for each completed intervention, capped at +0.05 total.

---

## Cardinality

| Side | Cardinality |
|---|---|
| A check-in | 6–18 interventions surfaced (6 types × 1–3 attributes) |
| A day | 6–18 rows (same as check-ins) |
| A user (lifetime) | ~6 × `days_used` rows |

A user with 365 days of consistent use will have ~2,000 rows.

---

## Example Rows (Illustrative)

For a check-in logging `Anger` (Emotion_ID=1) at intensity 7 on 2026-06-12, top 3 detected attrs: Ghadab(23), Sabr(75), Hilm(86):

| Record_ID | Date | Emotion_ID | Attribute_ID | Intervention_Type | Completed |
|---:|---|---:|---:|---|---|
| 1 | 2026-06-12 | 1 | 23 (Ghadab) | Quran | 1 |
| 2 | 2026-06-12 | 1 | 23 (Ghadab) | Hadith | 0 |
| 3 | 2026-06-12 | 1 | 23 (Ghadab) | Dua | 0 |
| 4 | 2026-06-12 | 1 | 23 (Ghadab) | Allah_Names | 1 |
| 5 | 2026-06-12 | 1 | 23 (Ghadab) | Dhikr | 0 |
| 6 | 2026-06-12 | 1 | 23 (Ghadab) | Action | 0 |
| 7 | 2026-06-12 | 1 | 75 (Sabr) | Quran | 0 |
| ... | ... | ... | ... | ... | ... |
| 18 | 2026-06-12 | 1 | 86 (Hilm) | Action | 0 |

> **Note:** These are illustrative. The table starts empty.

---

## See also

- `HeartOS/04_user_tables/interventions_history.md` — full spec
- `HeartOS/04_user_tables/checkins.md` — parent table
- `HeartOS/04_user_tables/detected_attributes.md` — source of targets
- `HeartOS/01_core_tables/attributes.md` — for Quran/Hadith/Dua/Names content
- `HeartOS/01_core_tables/emotions.md` — for `Recommended_Dhikr` and `Daily_Action`
- `HeartOS/00_root/user_flow.md` §2.4 — Intervention screen UX
- `HeartOS/08_algorithms/scoring_algorithm.md` — how `Completed` feeds into the Nafs
