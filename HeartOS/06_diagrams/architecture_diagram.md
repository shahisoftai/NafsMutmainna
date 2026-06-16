# Heart OS — Architecture Diagram

> The four-layer model, rendered as Mermaid diagrams. For an interactive HTML rendering, see [`../../docs/HEART_OS_ARCHITECTURE.html`](../../docs/HEART_OS_ARCHITECTURE.html).

---

## 1 · The four layers (overview)

```mermaid
flowchart TB
    subgraph L1["🟡 LAYER 1 — KNOWLEDGE (immutable, seed once)"]
        ATTR[attributes<br/>200 records]
        EMOT[emotions<br/>50 records]
    end

    subgraph L2["🟣 LAYER 2 — GRAPH (relationships & intelligence)"]
        EAL[emotion_attribute_links]
        AL[attribute_links<br/>Heart Graph]
        DOM[domains<br/>10 records]
        DAL[domain_attribute_links]
        DEL[domain_emotion_links]
    end

    subgraph L3["🟢 LAYER 3 — NAFS ENGINE (scoring spine)"]
        NS[nafs_states<br/>4 records]
        ANW[attribute_nafs_weights]
        ENW[emotion_nafs_weights]
    end

    subgraph L4["🔵 LAYER 4 — USER (activity & history)"]
        CHK[checkins]
        DA[detected_attributes]
        IH[interventions_history]
        NH[nafs_history]
        HAB[habits]
        HL[habit_logs]
    end

    EMOT --> EAL
    ATTR --> EAL
    ATTR --> AL
    ATTR --> DAL
    DOM --> DAL
    DOM --> DEL
    EMOT --> DEL
    ATTR --> ANW
    EMOT --> ENW
    NS -.weights.-> ANW
    NS -.weights.-> ENW
    EMOT --> CHK
    CHK --> DA
    CHK --> IH
    CHK --> NH
    HAB --> HL

    classDef know fill:#fef3c7,stroke:#f59e0b,color:#78350f
    classDef graph fill:#ede9fe,stroke:#8b5cf6,color:#4c1d95
    classDef nafs fill:#d1fae5,stroke:#10b981,color:#064e3b
    classDef user fill:#dbeafe,stroke:#3b82f6,color:#1e3a8a

    class ATTR,EMOT know
    class EAL,AL,DOM,DAL,DEL graph
    class NS,ANW,ENW nafs
    class CHK,DA,IH,NH,HAB,HL user
```

## 2 · Data flow (one check-in → Nafs meter)

```mermaid
flowchart LR
    U([User]) -->|"How is your heart?"| CI[Check-in]
    CI -->|"emotion + intensity"| CK[(checkins)]
    CK -->|"emotion_attribute_links"| DA[(detected_attributes)]
    DA -->|"× attribute_nafs_weights"| AS[AttributeScore<br/>50%]
    CK -->|"× emotion_nafs_weights"| ES[EmotionScore<br/>20%]
    HL[(habit_logs)] -->|"7-day rate"| HS[HabitScore<br/>20%]
    NH2[(nafs_history<br/>last 14 days)] -->|"trend"| TS[TrendScore<br/>10%]
    AS --> BLEND[Blend & Normalise]
    ES --> BLEND
    HS --> BLEND
    TS --> BLEND
    BLEND --> NH[(nafs_history<br/>today)]
    NH --> METER[15-day Weighted<br/>Moving Average]
    METER --> HOME([Home Screen<br/>Nafs Meter])

    classDef store fill:#e0e7ff,stroke:#6366f1,color:#312e81
    classDef score fill:#d1fae5,stroke:#10b981,color:#064e3b
    class CK,DA,HL,NH2,NH store
    class AS,ES,HS,TS,BLEND,METER score
```

## 3 · The Nafs Meter (visual)

```mermaid
flowchart LR
    A["Ammarah<br/>12%"]:::ammarah
    L["Lawwamah<br/>48%"]:::lawwamah
    M["Mulhamah<br/>24%"]:::mulhamah
    T["Mutmainnah<br/>16%"]:::mutmainnah

    A --- L --- M --- T

    classDef ammarah fill:#fecaca,stroke:#dc2626,color:#7f1d1d
    classDef lawwamah fill:#fde68a,stroke:#d97706,color:#78350f
    classDef mulhamah fill:#bfdbfe,stroke:#2563eb,color:#1e3a8a
    classDef mutmainnah fill:#bbf7d0,stroke:#16a34a,color:#14532d
```

## 4 · Layer responsibilities (summary)

| Layer | Purpose | Mutable at runtime? | Read by | Written by |
|---|---|---|---|---|
| Knowledge | Static Islamic content | ❌ | All | Seed script |
| Graph | Relationships | ❌ | Insight, Pathways | Seed script |
| Nafs Engine | Scoring spine | ❌ | All | Seed script |
| User | Activity & history | ✅ | All | App (check-in pipeline) |

The **only** layer that changes at runtime is the User layer. Everything else is shipped in the binary.

## 5 · See also

- [`../00_root/architecture.md`](../00_root/architecture.md) — the prose version.
- [`../00_root/erd.md`](../00_root/erd.md) — the table-level details.
- [`../../docs/HEART_OS_ARCHITECTURE.html`](../../docs/HEART_OS_ARCHITECTURE.html) — interactive HTML version.
