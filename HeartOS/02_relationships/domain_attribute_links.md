# `domain_attribute_links` — How Attributes Belong to Domains

> The many-to-many between the 10 macro-domains and the 200 attributes. Every attribute can belong to 1–3 domains with a weight that captures the strength of association.

---

## 1 · Purpose

`domain_attribute_links` lets the system answer:

- *"Which attributes does the Iman domain cover?"*
- *"Show me the Character-domain attributes the user has been struggling with."*
- *"What is the dominant domain of this check-in?"* (by summing weights of detected attributes)

This table is also what drives the **Domain detail screen** in the app: a list of all attributes in a domain, sorted by their weight in that domain.

## 2 · Schema

| Col | Type | Notes |
|---|---|---|
| `Link_ID` | INTEGER PK | |
| `Domain_ID` | INTEGER FK → `domains` | |
| `Attribute_ID` | INTEGER FK → `attributes` | |
| `Weight` | REAL | 0.0 – 1.0 |

Composite index: `(Domain_ID, Attribute_ID)`.

## 3 · Cardinality

| Side | Cardinality |
|---|---|
| An attribute | 1–3 domains (typically 1 primary, 1–2 secondary) |
| A domain | 15–30 attributes |

The total expected row count is **~250** (≈ 1.25 domains per attribute, on average).

## 4 · How it is queried

### 7.1 "Show me all attributes in a domain"

```sql
SELECT a.*, l.Weight
FROM attributes a
JOIN domain_attribute_links l ON l.Attribute_ID = a.Attribute_ID
WHERE l.Domain_ID = ?
ORDER BY l.Weight DESC;
```

### 7.2 "What is the dominant domain of these detected attributes?"

```sql
SELECT d.Domain_Name, SUM(dal.Weight * da.Score) AS score
FROM detected_attributes da
JOIN domain_attribute_links dal ON dal.Attribute_ID = da.Attribute_ID
JOIN domains d ON d.Domain_ID = dal.Domain_ID
WHERE da.Date = ?
GROUP BY d.Domain_ID
ORDER BY score DESC
LIMIT 1;
```

This is the SQL that powers the **domain badge** on the Insight screen.

### 7.3 "Show me attributes in a domain, filtered by Nafs state"

```sql
SELECT a.*, dal.Weight AS domain_weight, anw.Ammarah, anw.Lawwamah, anw.Mulhamah, anw.Mutmainnah
FROM attributes a
JOIN domain_attribute_links dal ON dal.Attribute_ID = a.Attribute_ID
JOIN attribute_nafs_weights anw ON anw.Attribute_ID = a.Attribute_ID
WHERE dal.Domain_ID = ?
ORDER BY anw.Mutmainnah DESC;
```

This is the "show me the virtues in Iman" query.

## 8 · Weights are not normalised

The weights in this table are **not constrained to sum to 1.0** for any given attribute. An attribute can have a total domain-weight of, say, 1.45 (split 0.95 + 0.50 across two domains).

This is intentional: the weight captures the *strength* of association with each domain, not a probability distribution. The system normalises at query time when needed (e.g. for the "dominant domain" computation).

## 9 · Seeding

- The table is **seeded once** from `assets/data/domain_attribute_links_seed.json`.
- The seed is generated semi-automatically:
  1. Each attribute is given one **primary** domain by a domain expert.
  2. The algorithm scans `attribute_links` and `emotion_attribute_links` to suggest **secondary** domains.
  3. A human reviews and adjusts.
- The expected row count is **~250**.

## 10 · Quality bar

For every attribute, the link set must satisfy:

1. **At least one domain** with `Weight ≥ 0.5`.
2. **No more than 3 domains** (an attribute that touches 4+ domains is too scattered).
3. **The primary domain's weight is at least 2× the next highest** (clear hierarchy).

A CI check enforces (3) at seed time.

## 11 · Relationship to other tables

```
   domains ── m ── domain_attribute_links ── m ── attributes
                                                     │
                                                     │
                                          attribute_nafs_weights
                                          (joins here for filtered views)
```

`domain_attribute_links` is read by:
- The Domain detail screen.
- The Insight screen (to compute the dominant domain).
- The Home screen (to show a "domain spotlight" card).
- The Analytics screen (to compute the domain distribution of a user's check-ins).

It is **never written to at runtime** — it is part of the immutable seed.
