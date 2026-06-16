# Heart OS — The Heart Graph

> The single most important data structure in the system. A directed graph over the 200 attributes that powers every growth path, every recommendation, and every "what to do next" message.

---

## 1 · What is it?

`attribute_links` is a many-to-many self-referencing table on `attributes`. Each row is a **directed edge** with a `Weight` and a `Relationship` type. Taken together, the edges form a directed multigraph that we call **the Heart Graph**.

| Edge type | Meaning | Example |
|---|---|---|
| `Cure` | Treating the source by cultivating the target | `Ghadab` — Cure → `Sabr` |
| `Leads_To` | The natural next step on the path to remedy | `Sabr` — Leads_To → `Hilm` |
| `Strengthens` | Reinforcing the target deepens the source | `Hilm` — Strengthens → `Rifq` |
| `Opposes` | Mutually exclusive states | `Kibr` — Opposes → `Tawadu` |

The graph is **dense but not complete**: most attributes have 2–5 outgoing edges and 2–5 incoming edges. This sparsity is intentional — the graph must be navigable, not exhaustive.

---

## 2 · Anatomy of a growth path

The most common traversal pattern is `Cure` → `Leads_To` (chain), then optionally `Strengthens` (deepen). Example:

```
  Ghadab   ─Cure→   Sabr   ─Leads_To→   Hilm   ─Leads_To→   Rifq   ─Strengthens→   Rahmah
 (Anger)         (Patience)         (Forbearance)         (Gentleness)            (Mercy)
```

This is a **canonical Islamic spiritual path** for the disease of anger. It is the seed for `master_pathways/anger_to_mercy.md` and is the **default recommendation** for the emotion *Anger* (Emotion_ID 1).

Other canonical chains seeded into v1:

| Pathway | Chain |
|---|---|
| Anxiety → Peace | Weak Tawakkul → Tawakkul → Yaqeen → Sakinah |
| Envy → Contentment | Hasad → Shukr → Qanaah → Ridha |
| Pride → Humility | Kibr → Tawadu → Ikhlas |
| Sin → Love | Tawbah → Inabah → Raja → Mahabbah |
| Heedlessness → Presence | Yaqzah → Dhikr → Muraqabah → Ihsan |
| Dunya → Zuhd | Hubb ad-Dunya → Zuhd → Ridha |
| Ignorance → Nearness | Ilm → Yaqeen → Mahabbah → Shawq → Wilayah |

See `05_pathways/` for all 8.

---

## 3 · Why a graph, not a tree or list?

| Alternative | Why it doesn't work |
|---|---|
| **Flat list** of attributes | Loses directionality — "after Sabr comes Hilm" needs an ordered edge. |
| **Tree** | One parent per node — but each attribute can be a remedy for several diseases and a step toward several goals. The graph is inherently a DAG (and sometimes has bidirectional Strengthens edges, so not strictly acyclic). |
| **Embed path as a column in `attributes`** | Impossible: the same attribute participates in many paths. A separate edge table is required. |
| **Use an LLM** | Adds latency, cost, and a network dependency. The graph is fully explainable and reproducible. |

---

## 4 · Algorithms that use the graph

### 4.1 BFS for "what is the cure of X?"

```python
def cure_of(source_attr_id):
    for edge in attribute_links where Source = source_attr_id and Relationship = "Cure":
        yield edge.Target, edge.Weight
```

Output is a ranked list of remedies. The Insight screen shows the top 3.

### 4.2 Path expansion for the growth path strip

```python
def growth_path(source_attr_id, max_hops=3):
    path = [source_attr_id]
    current = source_attr_id
    for _ in range(max_hops):
        next_edge = best_outgoing(current, Relationship="Leads_To")
        if next_edge is None: break
        path.append(next_edge.Target)
        current = next_edge.Target
    return path
```

### 4.3 Multi-source BFS for "all attributes affected by this set of emotions"

This is what `detected_attributes` is populated by (see `04_user_tables/detected_attributes.md`).

### 4.4 Negative-cycle detection

The `Opposes` edges form anti-chains. Acyclic enforcement is a data-quality check at seed time, not a runtime concern.

---

## 5 · Visual

```
                  ┌──────────┐
                  │  Tawadu  │
                  └────▲─────┘
                       │Strengthens
                       │
   ┌────────┐    Cure  │              ┌────────┐
   │  Kibr  │──────────┼──────────────│  Ikhlas│
   └────────┘           │              └────▲───┘
                        │                   │Leads_To
                        │                   │
                  ┌─────┴────┐              │
                  │  Sabr    │──────────────┘
                  └────▲─────┘  Leads_To
                       │
                       │Cure
                  ┌────┴────┐
                  │  Ghadab │  (Anger)
                  └─────────┘
```

(The full graph is a 200-node network — see `06_diagrams/heart_graph_diagram.md` for the rendered image.)

---

## 6 · Seeding & maintenance

- The graph is **seeded once** from a JSON file shipped in the binary (`assets/data/heart_graph_seed.json`).
- It is **immutable at runtime** — no CRUD on the user's behalf.
- Updates require a new app version (or, later, an opt-in content update via the cloud sync layer — see `09_future/synchronization.md`).
- The seed file is the **single source of truth** for v1. Every recommended chain in `05_pathways/` is present in this graph.

---

## 7 · Quality bar

A growth path shown to a user must satisfy three properties:

1. **Islamic authenticity** — backed by a Quran verse, a Hadith, or both. The chain in `01_core_tables/attributes.md` and `07_appendices/200_attributes.md` is the canonical source.
2. **Distinguishable from alternatives** — different starting points must yield different paths, otherwise the graph is doing nothing.
3. **Short** — never show more than 3 steps. The Insight screen explicitly limits the strip to 3.

The seed JSON has been reviewed against all three criteria.
