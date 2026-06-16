# Heart OS — Heart Graph Diagram

> The directed multigraph over the 200 attributes, visualised. This is the "brain" of Heart OS — see [`../00_root/heart_graph.md`](../00_root/heart_graph.md) for the prose.

---

## 1 · Conceptual overview

```mermaid
flowchart LR
    E[Emotion<br/>e.g. Anger]:::emotion
    A1[Disease Attribute<br/>e.g. Ghadab]:::negative
    A2[Treatment Attribute<br/>e.g. Sabr]:::positive
    A3[Step<br/>e.g. Hilm]:::positive
    A4[Deepening<br/>e.g. Rifq]:::positive
    A5[Station<br/>e.g. Rahmah]:::positive

    E -- "emotion_attribute_links<br/>Role=Disease" --> A1
    E -- "emotion_attribute_links<br/>Role=Treatment" --> A2
    A1 -- "attribute_links<br/>Cure" --> A2
    A2 -- "attribute_links<br/>Leads_To" --> A3
    A3 -- "attribute_links<br/>Leads_To" --> A4
    A4 -- "attribute_links<br/>Strengthens" --> A5

    classDef emotion fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef negative fill:#fecaca,stroke:#dc2626,color:#7f1d1d
    classDef positive fill:#bbf7d0,stroke:#16a34a,color:#14532d
```

## 2 · The four edge types

```mermaid
flowchart LR
    subgraph " "
        SRC[Source]:::neutral
        TGT[Target]:::neutral
    end

    SRC ==>|Cure<br/>0.9| TGT
    SRC -->|Leads_To<br/>0.7| TGT
    SRC -.->|Strengthens<br/>0.6| TGT
    SRC x--x|Opposes<br/>1.0| TGT

    classDef neutral fill:#e2e8f0,stroke:#475569,color:#0f172a
```

| Edge | Weight | Example |
|---|---|---|
| `Cure` | 0.9 | Ghadab → Sabr |
| `Leads_To` | 0.7 | Sabr → Hilm |
| `Strengthens` | 0.6 | Hilm → Rifq |
| `Opposes` | 1.0 | Kibr ↔ Tawadu |

## 3 · The 8 master pathways (sub-graphs)

```mermaid
flowchart TB
    subgraph P1["1. Anger → Mercy"]
        P1a[Ghadab] --> P1b[Sabr] --> P1c[Hilm] --> P1d[Rifq] --> P1e[Rahmah]
    end
    subgraph P2["2. Anxiety → Peace"]
        P2a[Weak Tawakkul] --> P2b[Tawakkul] --> P2c[Yaqeen] --> P2d[Sakinah]
    end
    subgraph P3["3. Envy → Contentment"]
        P3a[Hasad] --> P3b[Shukr] --> P3c[Qanaah] --> P3d[Ridha]
    end
    subgraph P4["4. Pride → Humility"]
        P4a[Kibr] --> P4b[Tawadu] --> P4c[Ikhlas]
    end
    subgraph P5["5. Sin → Love"]
        P5a[Tawbah] --> P5b[Inabah] --> P5c[Raja] --> P5d[Mahabbah]
    end
    subgraph P6["6. Heedlessness → Presence"]
        P6a[Yaqzah] --> P6b[Dhikr] --> P6c[Muraqabah] --> P6d[Ihsan]
    end
    subgraph P7["7. Dunya → Zuhd"]
        P7a[Hubb ad-Dunya] --> P7b[Zuhd] --> P7c[Ridha]
    end
    subgraph P8["8. Knowledge → Nearness"]
        P8a[Ilm] --> P8b[Yaqeen] --> P8c[Mahabbah] --> P8d[Shawq] --> P8e[Wilayah]
    end

    classDef neg fill:#fecaca,stroke:#dc2626,color:#7f1d1d
    classDef pos fill:#bbf7d0,stroke:#16a34a,color:#14532d
```

## 4 · Graph properties

| Property | Value |
|---|---|
| Nodes | 200 attributes |
| Edges | ~400 directed |
| Density | ~2% (sparse) |
| Avg out-degree | 2.0 |
| Hub attributes (degree ≥ 10) | Sabr, Shukr, Tawakkul, Tawadu, Ikhlas, Muraqabah |
| Cycle count in `Cure`+`Leads_To` | 0 (verified at seed) |

## 5 · See also

- [`../00_root/heart_graph.md`](../00_root/heart_graph.md) — the prose.
- [`../02_relationships/attribute_links.md`](../02_relationships/attribute_links.md) — the edge table.
- [`../05_pathways/`](../05_pathways/) — the 8 master pathways in detail.
