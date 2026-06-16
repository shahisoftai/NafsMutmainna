# `interventions_history` — Recommendation History

> The log of every intervention the system has shown to the user. Powers the "history" view, the streak calculations, and the "what worked for you" analytics.

---

## 1 · Purpose

`interventions_history` records **every recommendation the system has surfaced to the user**. Each row is a single Quran verse, Hadith, dua, Allah Name, dhikr, or action that was shown in response to a check-in.

The table serves four purposes:

1. **Avoid repeating the same intervention** within 7 days.
2. **Track completion** — did the user mark it "Done"?
3. **Compute streaks** — consecutive days with at least one completed intervention.
4. **Power the History screen** (v1.1).

## 2 · Schema

| Col | Type | Notes |
|---|---|---|
| `Record_ID` | INTEGER PK | autoincrement |
| `Date` | DATE | |
| `Emotion_ID` | INTEGER FK → `emotions` | the check-in that triggered it |
| `Attribute_ID` | INTEGER FK → `attributes` | the attribute being addressed |
| `Intervention_Type` | TEXT | `Quran` · `Hadith` · `Dua` · `Allah_Names` · `Dhikr` · `Action` |
| `Completed` | BOOLEAN | default 0; user toggles to 1 |

## 3 · The six intervention types

| Type | Source field on `attributes` | Example |
|---|---|---|
| `Quran` | `Quran_Reference` + `Quran_Arabic` | Surah Al-Ma'un 107:4-6 (for Riya) |
| `Hadith` | `Hadith_Reference` + `Hadith_Arabic` | Sahih Muslim 91 (for Kibr) |
| `Dua` | `Quranic_Dua_*` or `Prophetic_Dua_*` | "Allahumma ihdini li ahsani al-akhlaq" |
| `Allah_Names` | `Relevant_Allah_Names` | Al-Halim, Ar-Rahim, Ar-Rafiq |
| `Dhikr` | `emotions.Recommended_Dhikr` | "SubhanAllahi wa bihamdihi" |
| `Action` | `emotions.Daily_Action` | "Remain silent and perform wudu" |

A single check-in typically surfaces **all six** — one card per type on the Intervention screen. Each card maps to one row in `interventions_history`.

## 4 · How rows are populated

When a user logs a check-in, the system:

1. Resolves the detected attributes.
2. For each detected attribute, surfaces the six interventions from the **attribute's** data fields (Quran, Hadith, Dua, Names) and the **emotion's** Dhikr and Action.
3. Filters out interventions shown in the last 7 days (no repeats).
4. Inserts a row for each surfaced intervention.

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

## 5 · The "no-repeat" rule

A Quran verse that was shown 3 days ago will not be shown again until day 10. This is enforced by the `shown_recently` check above.

The rule applies **per intervention content** (not per intervention type). So if the user logs "Anger" today and "Anger" tomorrow, the system may show *different* Quran verses for Ghadab (there are several in the seed).

## 6 · Completion semantics

The user sees the Intervention screen with 6 cards. They can:

- Read a card and mark it **Done** (sets `Completed = 1`).
- Swipe past a card (no change to `Completed`).
- Mark it as **Not now** (sets `Completed = 0` explicitly, but the row stays).

A card is "completed" if and only if the user tapped the Done button. The algorithm **does not** assume the user did the intervention just because they viewed it.

## 7 · How `Completed` affects the Nafs

The proposed v1 formula (see `../08_algorithms/scoring_algorithm.md`):

```
   intervention_completion_bonus = 0.02 × completed_count / surfaced_count
```

This adds a small bias toward Mulhamah/Mutmainnah for each completed intervention, capped at +0.05 total. The bonus is small because we want the Nafs to reflect **substance** (long-term behaviour), not just daily activity.

## 8 · Cardinality

| Side | Cardinality |
|---|---|
| A check-in | 6–18 interventions surfaced (6 types × 1–3 attributes) |
| A day | 6–18 rows (same as check-ins) |
| A user (lifetime) | ~6 × days_used rows |

A user with 365 days of consistent use will have ~2 000 rows. No scaling concerns.

## 9 · How it is queried

### 9.1 "What did the system show me today?"

```sql
SELECT *
FROM interventions_history
WHERE Date = ?
ORDER BY Intervention_Type, Attribute_ID;
```

### 9.2 "What is my 7-day completion rate?"

```sql
SELECT
  COUNT(*) AS total,
  SUM(Completed) AS done
FROM interventions_history
WHERE Date >= date('now', '-7 day');
```

### 9.3 "What intervention types am I completing most?"

```sql
SELECT Intervention_Type, AVG(Completed) AS rate
FROM interventions_history
WHERE Date >= date('now', '-30 day')
GROUP BY Intervention_Type
ORDER BY rate DESC;
```

This is the **intervention-type breakdown** chart on the Analytics screen.

### 9.4 "What attribute has been most-addressed in the last 30 days?"

```sql
SELECT a.Attribute, COUNT(*) AS n
FROM interventions_history ih
JOIN attributes a ON a.Attribute_ID = ih.Attribute_ID
WHERE ih.Date >= date('now', '-30 day')
GROUP BY ih.Attribute_ID
ORDER BY n DESC
LIMIT 10;
```

## 10 · Edge cases

| Situation | Handled how |
|---|---|
| No detected attributes (neutral check-in) | No interventions surfaced. |
| Same intervention content shown for 2 different emotions on the same day | The 7-day rule kicks in — only the first one is shown. |
| User logs a check-in, sees interventions, then deletes the check-in | Cascade delete removes the interventions. |
| User changes their reflection (Better/Same/Worse) | Does NOT change `interventions_history` — the reflection is stored separately (v1.1). |
| User has 0 completed interventions in 7 days | The streak resets. |

## 11 · Implementation notes

- The table is created by `migrations/v1.dart`.
- The 7-day "no-repeat" rule is enforced at **insert time** in the `surface_interventions` function.
- The cascade delete is implemented as a **trigger on `checkins`** (after delete).
- The `Completed` column is a `BOOLEAN` (stored as `INTEGER 0/1` in SQLite).
- For v1.1, an `Engagement_Time_Seconds` column may be added to measure how long the user spent on each card.

## 13 · See also

- `checkins.md` — the parent table.
- `detected_attributes.md` — the source of the intervention targets.
- `../01_core_tables/emotions.md` — for `Recommended_Dhikr` and `Daily_Action`.
- `../01_core_tables/attributes.md` — for Quran/Hadith/Dua/Names content.
- `../00_root/user_flow.md` §2.4 — the Intervention screen UX.
- `../08_algorithms/scoring_algorithm.md` — how `Completed` feeds into the Nafs.
