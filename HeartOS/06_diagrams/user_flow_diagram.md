# Heart OS — User Flow Diagram

> The 5-screen core loop, rendered as Mermaid. For the prose walkthrough, see [`../00_root/user_flow.md`](../00_root/user_flow.md).

---

## 1 · The 5-screen loop

```mermaid
flowchart LR
    H[🏠 Home<br/>Nafs Meter] -->|tap CTA| C[📝 Check-in<br/>Emotion Picker]
    C -->|Continue| I[💡 Insight<br/>Attributes + Growth Path]
    I -->|Show me what to do| V[📖 Intervention<br/>Quran · Hadith · Dua · Action]
    V -->|How did this make you feel?| R[🔄 Reflect<br/>Better · Same · Worse]
    R -->|Save| H

    classDef screen fill:#dbeafe,stroke:#3b82f6,color:#1e3a8a
    class H,C,I,V,R screen
```

## 2 · Detailed Check-in screen

```mermaid
flowchart TB
    subgraph CI["📝 Check-in Screen"]
        A[Emotion List<br/>50 options] --> A1{Filter by<br/>Category?}
        A1 -->|Negative| A2[40 negative emotions]
        A1 -->|Positive| A3[10 positive emotions]
        A2 --> A4[Tap emotion]
        A3 --> A4
        A4 --> A5[Intensity Slider<br/>1–10]
        A5 --> A6{Notes?}
        A6 -->|Yes| A7[Free text<br/>max 500 chars]
        A6 -->|No| A8[Continue]
        A7 --> A8
    end

    A8 ==>|INSERT| DB[(SQLite<br/>checkins)]
```

## 3 · Detailed Insight screen

```mermaid
flowchart TB
    subgraph IS["💡 Insight Screen"]
        B1[Resolve emotion] --> B2[emotion_attribute_links<br/>Disease / Treatment / Core / Strengthens]
        B2 --> B3[Top 3–5 attributes<br/>with scores]
        B3 --> B4[attribute_links<br/>Cure + Leads_To]
        B4 --> B5[Growth Path Strip<br/>2–3 hops]
        B3 --> B6[Domain badge<br/>highest weight]
        B5 --> B7[Show me what to do]
        B6 --> B7
    end

    B7 ==>|INSERT| DB2[(SQLite<br/>detected_attributes)]
```

## 4 · Detailed Intervention screen

```mermaid
flowchart TB
    subgraph VS["📖 Intervention Screen"]
        V1[Quran card<br/>verse + ref + translation] --> V2[Hadith card<br/>text + ref]
        V2 --> V3[Dua card<br/>Arabic + transliteration]
        V3 --> V4[Allah Names card<br/>1–3 names]
        V4 --> V5[Dhikr card<br/>set to recite]
        V5 --> V6[Daily Action card<br/>one micro-task]
        V6 --> V7{User marks<br/>as Done?}
        V7 -->|Yes| V8[Set Completed = 1]
        V7 -->|No| V9[Swipe / skip]
        V8 --> V10[How did this make you feel?]
    end

    V8 ==>|UPDATE| DB3[(SQLite<br/>interventions_history)]
```

## 5 · The data pipeline behind the loop

```mermaid
flowchart LR
    A([User]) -->|emotion + intensity| B[checkins]
    B --> C[detected_attributes]
    B --> D[interventions_history]
    C --> E[AttributeScore]
    B --> F[EmotionScore]
    G[habit_logs] --> H[HabitScore]
    I[nafs_history 14d] --> J[TrendScore]
    E --> K[Daily Nafs Vector]
    F --> K
    H --> K
    J --> K
    K --> L[(nafs_history<br/>today)]
    L --> M[15-day Meter]

    classDef input fill:#dbeafe,stroke:#3b82f6
    classDef score fill:#d1fae5,stroke:#10b981
    classDef store fill:#e0e7ff,stroke:#6366f1
    class B,C,D,G,I,L,M store
    class E,F,H,J,K score
```

## 6 · First-run flow

```mermaid
flowchart LR
    S([Splash]) --> O[Onboarding<br/>3 cards]
    O --> P{Permit<br/>notifications?}
    P -->|Yes| N[Request permission]
    P -->|No| H2[Home]
    N --> SC{Seed<br/>check-in?}
    SC -->|Yes| SE[Pick starter emotion]
    SC -->|No| H2
    SE --> H2[Home<br/>Lawwamah baseline]
    H2 --> C[Check-in<br/>first real]
```

## 7 · See also

- [`../00_root/user_flow.md`](../00_root/user_flow.md) — the prose walkthrough.
- [`../00_root/architecture.md`](../00_root/architecture.md) — the 4-layer model.
- [`../00_root/scoring_engine.md`](../00_root/scoring_engine.md) — the algorithm behind the meter.
