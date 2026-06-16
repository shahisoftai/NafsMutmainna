# Heart OS — ER Diagram (Mermaid)

> The 14 core tables, rendered as a Mermaid `erDiagram`. For the full prose version, see [`../00_root/erd.md`](../00_root/erd.md).

---

## 1 · Full ER diagram

```mermaid
erDiagram
    EMOTIONS ||--o{ EMOTION_ATTRIBUTE_LINKS : "has"
    ATTRIBUTES ||--o{ EMOTION_ATTRIBUTE_LINKS : "has"
    ATTRIBUTES ||--o{ ATTRIBUTE_LINKS : "source"
    ATTRIBUTES ||--o{ ATTRIBUTE_LINKS : "target"
    DOMAINS ||--o{ DOMAIN_ATTRIBUTE_LINKS : "groups"
    ATTRIBUTES ||--o{ DOMAIN_ATTRIBUTE_LINKS : "belongs"
    DOMAINS ||--o{ DOMAIN_EMOTION_LINKS : "groups"
    EMOTIONS ||--o{ DOMAIN_EMOTION_LINKS : "belongs"
    NAFS_STATES ||--o{ ATTRIBUTE_NAFS_WEIGHTS : "weights"
    ATTRIBUTES ||--o{ ATTRIBUTE_NAFS_WEIGHTS : "scored"
    NAFS_STATES ||--o{ EMOTION_NAFS_WEIGHTS : "weights"
    EMOTIONS ||--o{ EMOTION_NAFS_WEIGHTS : "scored"
    EMOTIONS ||--o{ CHECKINS : "logged"
    EMOTIONS ||--o{ DETECTED_ATTRIBUTES : "derives"
    ATTRIBUTES ||--o{ DETECTED_ATTRIBUTES : "scored"
    CHECKINS ||--o{ DETECTED_ATTRIBUTES : "produces"
    CHECKINS ||--o{ INTERVENTIONS_HISTORY : "triggers"
    EMOTIONS ||--o{ INTERVENTIONS_HISTORY : "targets"
    ATTRIBUTES ||--o{ INTERVENTIONS_HISTORY : "targets"
    HABITS ||--o{ HABIT_LOGS : "tracked"

    EMOTIONS {
        int Emotion_ID PK
        string Name
        string Arabic_Name
        text Description
        text Triggers
        text Growth_Path
    }
    ATTRIBUTES {
        int Attribute_ID PK
        string Name
        string Arabic_Name
        text Quran
        text Hadith
        text Dua
        text Allah_Names
    }
    EMOTION_ATTRIBUTE_LINKS {
        int Link_ID PK
        int Emotion_ID FK
        int Attribute_ID FK
        float Weight
        string Role
    }
    ATTRIBUTE_LINKS {
        int Link_ID PK
        int Source_ID FK
        int Target_ID FK
        float Weight
        string Relationship
    }
    DOMAINS {
        int Domain_ID PK
        string Name
        string Arabic_Name
    }
    DOMAIN_ATTRIBUTE_LINKS {
        int Link_ID PK
        int Domain_ID FK
        int Attribute_ID FK
        float Weight
    }
    DOMAIN_EMOTION_LINKS {
        int Link_ID PK
        int Domain_ID FK
        int Emotion_ID FK
        float Weight
    }
    NAFS_STATES {
        int Nafs_ID PK
        string Name
        string Arabic_Name
    }
    ATTRIBUTE_NAFS_WEIGHTS {
        int Attribute_ID PK_FK
        float Ammarah
        float Lawwamah
        float Mulhamah
        float Mutmainnah
    }
    EMOTION_NAFS_WEIGHTS {
        int Emotion_ID PK_FK
        float Ammarah
        float Lawwamah
        float Mulhamah
        float Mutmainnah
    }
    CHECKINS {
        int Checkin_ID PK
        date Date
        int Emotion_ID FK
        int Intensity
        text Notes
    }
    DETECTED_ATTRIBUTES {
        int Record_ID PK
        date Date
        int Attribute_ID FK
        float Score
    }
    INTERVENTIONS_HISTORY {
        int Record_ID PK
        date Date
        int Emotion_ID FK
        int Attribute_ID FK
        string Type
        bool Completed
    }
    NAFS_HISTORY {
        int Record_ID PK
        date Date
        float Ammarah
        float Lawwamah
        float Mulhamah
        float Mutmainnah
    }
    HABITS {
        int Habit_ID PK
        string Name
        string Category
    }
    HABIT_LOGS {
        int Record_ID PK
        date Date
        int Habit_ID FK
        bool Completed
    }
```

## 2 · Layer-grouped view

```mermaid
flowchart TB
    subgraph L1["🟡 Knowledge"]
        E[emotions]
        A[attributes]
    end
    subgraph L2["🟣 Graph"]
        EAL[emotion_attribute_links]
        AL[attribute_links]
        D[domains]
        DAL[domain_attribute_links]
        DEL[domain_emotion_links]
    end
    subgraph L3["🟢 Nafs Engine"]
        NS[nafs_states]
        ANW[attribute_nafs_weights]
        ENW[emotion_nafs_weights]
    end
    subgraph L4["🔵 User"]
        CHK[checkins]
        DA[detected_attributes]
        IH[interventions_history]
        NH[nafs_history]
        HA[habits]
        HL[habit_logs]
    end

    E --> EAL --> A
    A --> AL
    A --> DAL --> D
    D --> DEL --> E
    A --> ANW --> NS
    E --> ENW --> NS
    E --> CHK --> DA --> A
    CHK --> IH --> A
    CHK --> NH
    HA --> HL

    classDef know fill:#fef3c7,stroke:#f59e0b
    classDef graph fill:#ede9fe,stroke:#8b5cf6
    classDef nafs fill:#d1fae5,stroke:#10b981
    classDef user fill:#dbeafe,stroke:#3b82f6
    class E,A know
    class EAL,AL,D,DAL,DEL graph
    class NS,ANW,ENW nafs
    class CHK,DA,IH,NH,HA,HL user
```

## 3 · See also

- [`../00_root/erd.md`](../00_root/erd.md) — the prose version with column details.
- [`../01_core_tables/`](../01_core_tables/) — per-table deep dives.
- [`../02_relationships/`](../02_relationships/) — the link tables.
