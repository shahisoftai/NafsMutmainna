# `emotion_attribute_links` — The Many-to-Many Between Emotions and Attributes

> The single most important link table in the system. It is the bridge between what the user *feels* and what the user *needs to work on*.

---

## 1 · Purpose

When the user logs an emotion, this table is queried to find:
- The **disease attributes** that the emotion surfaces (negative attributes that may be active).
- The **treatment attributes** that should be cultivated (positive attributes to recommend).
- The **core attribute** for the emotion (the single most important attribute to address).
- The **strengthens** links (secondary virtues that grow when the core is worked on).

Without this table, the system would have no way to translate a check-in into an actionable recommendation.

## 2 · Schema

| Col | Type | Notes |
|---|---|---|
| `Link_ID` | INTEGER PK | |
| `Emotion_ID` | INTEGER FK → `emotions` | |
| `Attribute_ID` | INTEGER FK → `attributes` | |
| `Weight` | REAL | 0.0 – 1.0 |
| `Role` | TEXT | enum: `Disease` · `Treatment` · `Core` · `Strengthens` |

Composite index: `(Emotion_ID, Attribute_ID)`.

## 3 · The `Role` enum

| Role | Meaning | When used |
|---|---|---|
| `Disease` | The emotion is a *symptom* of this negative attribute. | The user is *currently* feeling this. |
| `Treatment` | Cultivating this positive attribute is the *remedy* for the emotion. | The user is being *recommended* this. |
| `Core` | The single most important attribute for the emotion. | One per emotion; surfaces first on the Insight screen. |
| `Strengthens` | Secondary virtues that grow as the core is worked on. | Shown after the user has acted on the core. |

## 4 · Weight semantics

- A `Weight` of **1.0** means the link is essential. The Insight screen must show it.
- A `Weight` of **0.5–0.9** means the link is significant. It is shown on the Insight screen but not as prominently.
- A `Weight` of **0.1–0.4** means the link is secondary. It is shown only on the Attribute Detail screen or after the user has acted on the core.

The Insight screen renders links in descending `Weight` order, and deduplicates by `Attribute_ID` (the same attribute may appear as `Disease` and `Treatment` for different emotions; in the same emotion, it should appear in only one role).

## 7 · Cardinality

| Side | Cardinality |
|---|---|
| An emotion | 3–10 attributes (across all four roles) |
| An attribute | 1–10 emotions |

The degree distribution is **skewed**: a few "hub" attributes (Sabr, Shukr, Tawakkul) appear in 10+ emotions' link lists.

## 8 · How it is queried

```sql
-- Top Treatment + Core attributes for recommendations (combined, not fallback)
SELECT a.*, l.Role, l.Weight
FROM attributes a
JOIN emotion_attribute_links l ON l.Attribute_ID = a.Attribute_ID
WHERE l.Emotion_ID = ? AND l.Role IN ('Treatment', 'Core')
ORDER BY l.Weight DESC
LIMIT 3;
```

```sql
-- All attributes affected by an emotion (any role) — drives detected_attributes
SELECT a.*, l.Role, l.Weight
FROM attributes a
JOIN emotion_attribute_links l ON l.Attribute_ID = a.Attribute_ID
WHERE l.Emotion_ID = ?
ORDER BY l.Weight DESC;
```

The first query drives the **Intervention screen** (remedies only).
The second drives the **Insight screen** and the `detected_attributes` table — all roles
are stored so the Insight screen can distinguish Disease attributes (surfaced vice) from
Treatment/Core attributes (recommended virtue).

## 9 · Seeding

- The table is **seeded once** from `assets/data/emotion_attribute_links_seed.json`.
- The seed is generated from the `Primary_Negative_Attributes`, `Secondary_Negative_Attributes`, and `Primary_Positive_Attributes` columns of the 50 emotions. The `Core` and `Strengthens` roles are added by an editorial pass.
- The total expected row count is **~400** (8 attributes per emotion on average).

## 10 · Quality bar

For every emotion, the link set must satisfy:

1. **At least one `Treatment`** with `Weight ≥ 0.8`.
2. **At least one `Disease`** with `Weight ≥ 0.8`.
3. **Exactly one `Core`** with `Weight = 1.0`.
4. **No `Treatment` link to a negative attribute** (a treatment must be a virtue).
5. **No `Disease` link to a positive attribute** (a disease must be a vice).

A CI check enforces these rules on every seed PR.

## 11 · Relationship to other tables

```
   emotions ── m ── emotion_attribute_links ── m ── attributes
                                                  │
                                                  │
                       ┌──────────────────────────┴──────────────────────────┐
                       │                                                     │
                       ▼                                                     ▼
              attribute_links (Heart Graph)               attribute_nafs_weights
```

`emotion_attribute_links` is the **lateral** layer (emotion ↔ attribute). `attribute_links` is the **vertical** layer (attribute ↔ attribute). Together they form the complete graph from a check-in to a recommendation.
