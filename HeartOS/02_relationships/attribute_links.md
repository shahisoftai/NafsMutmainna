# `attribute_links` — The Heart Graph

> The directed multigraph over the 200 attributes. This is the "brain" of Heart OS — it is queried on every Insight and every Pathway traversal.

---

## 1 · Purpose

`attribute_links` is the **edge table** of the Heart Graph. It defines the directional relationships between attributes: what cures what, what leads to what, what strengthens what, and what opposes what.

This is the table that turns a check-in into a **growth path**. Combined with `emotion_attribute_links`, it is the full machinery that takes "I feel angry" and produces "Cultivate Sabr → Hilm → Rifq → Rahmah".

## 2 · Schema

| Col | Type | Notes |
|---|---|---|
| `Link_ID` | INTEGER PK | |
| `Source_Attribute_ID` | INTEGER FK → `attributes` | the "from" node |
| `Target_Attribute_ID` | INTEGER FK → `attributes` | the "to" node |
| `Weight` | REAL | 0.0 – 1.0 |
| `Relationship` | TEXT | enum: `Cure` · `Leads_To` · `Strengthens` · `Opposes` |

This is a **self-referencing** many-to-many: both source and target point to `attributes`.

## 3 · The `Relationship` enum

| Relationship | Meaning | Direction | Default weight |
|---|---|---|---|
| `Cure` | Treating the source by cultivating the target | source → treatment | 0.9 |
| `Leads_To` | The natural next step on the path to remedy | source → next-step | 0.7 |
| `Strengthens` | Reinforcing the target deepens the source | source → reinforcer | 0.6 |
| `Opposes` | Mutually exclusive states | source ↔ target | 1.0 |

### 3.1 `Cure` — the most important edge

`Cure` is the **primary therapeutic link**. When the Insight screen asks "what is the cure of Anger?", it queries:

```sql
SELECT a.*, l.Weight
FROM attributes a
JOIN attribute_links l ON l.Target_Attribute_ID = a.Attribute_ID
WHERE l.Source_Attribute_ID = <Ghadab> AND l.Relationship = 'Cure'
ORDER BY l.Weight DESC;
```

The top result (Sabr) is the **first recommendation**.

### 3.2 `Leads_To` — the chain builder

`Leads_To` is the **sequencing link**. After the user has worked on Sabr, the next attribute in the chain is whatever Sabr leads to (Hilm). The growth-path strip on the Insight screen is a 2–3 hop walk along `Leads_To` edges.

### 3.3 `Strengthens` — the deepener

`Strengthens` is a **lateral link**. It says: "Cultivating Target also reinforces Source." This is used to suggest *related* virtues on the Attribute Detail screen and to widen the recommendation when the user has been working on an attribute for 7+ days.

### 3.4 `Opposes` — the inverse

`Opposes` is **symmetric** in semantic terms but stored as a directed edge (or sometimes as a bidirectional pair). It is used to:

1. Show the user the **opposite** of the disease (e.g. Kibr ↔ Tawadu).
2. Validate the seed: an attribute and its opposite should never both be in a single growth path.

## 4 · The canonical growth path

The most-cited growth path in the system is **Ghadab → Sabr → Hilm → Rifq → Rahmah**. The edges are:

| Source | Relationship | Target | Weight |
|---|---|---|---|
| Ghadab | Cure | Sabr | 0.95 |
| Ghadab | Opposes | Hilm | 1.0 |
| Sabr | Leads_To | Hilm | 0.9 |
| Hilm | Leads_To | Rifq | 0.85 |
| Rifq | Strengthens | Rahmah | 0.7 |

The Insight screen for *Anger* shows the strip: `Ghadab → Sabr → Hilm → Rifq`.

## 5 · Density and shape

| Property | Value |
|---|---|
| Total expected edges | ~400 (≈ 2 per attribute per direction) |
| Average out-degree | 2.0 |
| Average in-degree | 2.0 |
| Hub attributes (degree ≥ 10) | Sabr, Shukr, Tawakkul, Tawadu, Ikhlas, Muraqabah |
| Leaf attributes (degree = 0) | rare — almost every attribute has at least one edge |

The graph is **connected** — from any attribute, BFS can reach any other via `Leads_To` and `Cure` edges. The `Opposes` edges form a separate bipartite-style sub-graph.

## 6 · Algorithms that use the graph

### 6.1 BFS — "what is the cure of X?"

```python
def cure_of(source_attr_id):
    return [
        (edge.target, edge.weight)
        for edge in attribute_links
        if edge.source == source_attr_id
        and edge.relationship == "Cure"
    ]
```

### 6.2 Path expansion — "what is the growth path from X?"

```python
def growth_path(source_attr_id, max_hops=3):
    path = [source_attr_id]
    current = source_attr_id
    for _ in range(max_hops):
        next_edge = best_outgoing(current, relationship="Leads_To")
        if next_edge is None: break
        path.append(next_edge.target)
        current = next_edge.target
    return path
```

### 6.3 Multi-source BFS — "all attributes reachable from this set"

For `detected_attributes`, we walk from the detected attributes outward to find everything that could be affected (within a 2-hop radius).

### 6.4 Cycle detection (at seed time, not runtime)

A `Cure` or `Leads_To` cycle would be a data quality bug. The seed CI runs a DFS-based cycle check and rejects any cycle.

## 7 · Cardinality

| Side | Cardinality |
|---|---|
| An attribute (as source) | 0–5 outgoing edges (typically 2–3) |
| An attribute (as target) | 0–10 incoming edges |
| An attribute in a master pathway | 1–3 hops in the chain |

## 8 · How it is seeded

- The table is **seeded once** from `assets/data/attribute_links_seed.json`.
- The JSON is hand-curated by a small editorial team.
- Every edge has an **Islamic source**: either a Quran verse, a Hadith, or a classical reference (e.g. *Madarij al-Salikin* by Ibn al-Qayyim).
- Every edge has a `Weight` in the range [0.5, 1.0] (no "weak" links — if a link is too weak, it is omitted).

## 9 · Scholarly note — Kibr pathway edges (ID 2)

| Source | Rel | Target | Weight | Islamic anchor |
|---|---|---|---|---|
| Kibr | Opposes | Tawadu | 1.0 | Qur'an 31:18 |
| Kibr | Cure | Tawadu | 0.95 | Sahih Muslim 91 |
| Kibr | Cure | Dhikr al-Mawt | 0.6 | Hadith — frequent remembrance of death humbles |
| Kibr | Strengthens (negative) | Ujb | 0.7 | Both rooted in self-admiration |
| Kibr | Opposes | Ikhlas | 1.0 | Kibr is the disease, Ikhlas is the cure |
| Tawadu | Leads_To | Ikhlas | 0.85 | Classical path |
| Ikhlas | Leads_To | Muraqabah | 0.7 | Sincere acts deepen God-consciousness |
| Muraqabah | Strengthens | Mahabbah | 0.6 | God-consciousness produces love |

The canonical pathway for *Kibr*: `Kibr → Tawadu → Ikhlas → Muraqabah → Mahabbah`.

## 10 · Implementation notes

- The table is **immutable at runtime** — no CRUD on the user's behalf.
- Updates require a new app version (or, later, an opt-in content update — see `../09_future/synchronization.md`).
- A quality bar applies:
  1. **No cycles** in `Cure` + `Leads_To` edges.
  2. **Every `Cure` link is backed by a Hadith or Quranic verse.**
  3. **Every growth path terminates in a positive attribute.**

## 11 · The 8 master pathways (preview)

The 8 hand-picked pathways in `../05_pathways/` are all **sub-graphs** of `attribute_links`. They are stored separately in `master_pathways` (deferred to v2) but their edges are present in this table from day 1.

| # | Pathway | First edge | Last edge |
|---|---|---|---|
| 1 | Anger → Mercy | Ghadab → Sabr (Cure) | Rifq → Rahmah (Strengthens) |
| 2 | Anxiety → Peace | Weak Tawakkul → Tawakkul (Cure) | Yaqeen → Sakinah (Leads_To) |
| 3 | Envy → Contentment | Hasad → Shukr (Cure) | Qanaah → Ridha (Leads_To) |
| 4 | Pride → Humility | Kibr → Tawadu (Cure) | Tawadu → Ikhlas (Leads_To) |
| 5 | Sin → Love | (Tawbah is the start) | Mahabbah |
| 6 | Heedlessness → Presence | (Yaqzah is the start) | Ihsan |
| 7 | Dunya → Zuhd | Hubb ad-Dunya → Zuhd (Cure) | Zuhd → Ridha (Leads_To) |
| 8 | Ignorance → Nearness | Ilm → Yaqeen (Cure) | Shawq → Wilayah (Leads_To) |

See `../05_pathways/` for the full chains, Quranic anchors, and practitioner notes.
