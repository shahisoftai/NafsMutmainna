# `domain_emotion_links` — How Emotions Belong to Domains

> The many-to-many between the 10 macro-domains and the 50 emotions. Analogous to `domain_attribute_links`, but for the user-facing vocabulary.

---

## 1 · Purpose

`domain_emotion_links` lets the system answer:

- *"Which emotions are Iman-related?"*
- *"What domain does this emotion primarily belong to?"*
- *"If the user logs 3 emotions in 3 days, which domain is the common thread?"*

This table is what lets the **Domain detail screen** show emotions (not just attributes) and what drives the **emotion-domain colour coding** in the Check-in screen.

## 2 · Schema

| Col | Type | Notes |
|---|---|---|
| `Link_ID` | INTEGER PK | |
| `Domain_ID` | INTEGER FK → `domains` | |
| `Emotion_ID` | INTEGER FK → `emotions` | |
| `Weight` | REAL | 0.0 – 1.0 |

Composite index: `(Domain_ID, Emotion_ID)`.

## 3 · Cardinality

| Side | Cardinality |
|---|---|
| An emotion | 1–3 domains (typically 1 primary) |
| A domain | 5–12 emotions |

The total expected row count is **~80** (≈ 1.6 domains per emotion, on average).

## 4 · How it is queried

### 5.1 "Show me all emotions in a domain"

```sql
SELECT e.*, l.Weight
FROM emotions e
JOIN domain_emotion_links l ON l.Emotion_ID = e.Emotion_ID
WHERE l.Domain_ID = ?
ORDER BY l.Weight DESC;
```

### 5.2 "What is the dominant domain for this check-in?"

```sql
SELECT d.Domain_Name, SUM(del.Weight) AS score
FROM checkins c
JOIN domain_emotion_links del ON del.Emotion_ID = c.Emotion_ID
JOIN domains d ON d.Domain_ID = del.Domain_ID
WHERE c.Date = ?
GROUP BY d.Domain_ID
ORDER BY score DESC
LIMIT 1;
```

This is the "domain badge" computation at the **emotion** level (vs. the `domain_attribute_links` version which uses detected attributes).

### 5.3 "What domain should I show in the spotlight card on Home?"

```sql
SELECT d.Domain_Name, COUNT(*) AS mentions
FROM checkins c
JOIN domain_emotion_links del ON del.Emotion_ID = c.Emotion_ID
JOIN domains d ON d.Domain_ID = del.Domain_ID
WHERE c.Date >= date('now', '-15 day')
GROUP BY d.Domain_ID
ORDER BY mentions DESC
LIMIT 1;
```

This is the 15-day **most-mentioned domain** — what the user has been struggling with most.

## 6 · Weights are not normalised

Same convention as `domain_attribute_links`: weights are not constrained to sum to 1.0. The system normalises at query time.

## 7 · Seeding

- Seeded once from `assets/data/domain_emotion_links_seed.json`.
- Each emotion is given one **primary** domain by editorial pass.
- Secondary domains are added algorithmically based on the emotion's `Primary_Negative_Attributes` and `Primary_Positive_Attributes`.
- A human reviewer signs off.
- Expected row count: **~80**.

## 8 · Quality bar

For every emotion, the link set must satisfy:

1. **At least one domain** with `Weight ≥ 0.6`.
2. **No more than 3 domains** in total.
3. **The primary domain's weight is at least 1.5× the next highest**.

For every domain, the link set must contain:

1. **At least 5 emotions** (so the domain feels populated).
2. **At least 2 positive emotions** (so the domain is not just a list of problems).

## 9 · Relationship to other tables

```
   domains ── m ── domain_emotion_links ── m ── emotions
                                                  │
                                                  ├── emotion_nafs_weights
                                                  ├── emotion_attribute_links
                                                  └── checkins
```

`domain_emotion_links` is read by:
- The Domain detail screen (to show emotions).
- The Home screen (15-day most-mentioned domain).
- The Check-in screen (for the optional colour-coding per emotion).

It is **never written to at runtime**.

## 10 · Open questions (TBD)

- Should the Check-in screen **group emotions by domain** (e.g. "Iman-related", "Character-related")? This would be a v1.1 UI feature. The data is already there.
- Should the Home screen show a "domain rotation" — one domain spotlight per day, cycling through all 10? Again, v1.1.
- Should a user be able to **mute a domain** if it is not relevant? No — keep the data model simple; the user can ignore a domain in the UI.

## 11 · See also

- `domain_attribute_links.md` — the parallel table for attributes.
- `../01_core_tables/domains.md` — the 10 domains.
- `../01_core_tables/emotions.md` — the 50 emotions.
- `../03_nafs_engine/` — the Nafs weight matrices, which are joined to the emotions/attributes here at query time.
