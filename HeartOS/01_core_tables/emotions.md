# `emotions` — The 50 Core Emotions

> The user's daily check-in is an emotion from this list. The list is **immutable at runtime** — additions require a new app version.

---

## 1 · Purpose

`emotions` is the user's vocabulary for the state of the heart. It is the **entry point** of the entire system: every check-in references exactly one row from this table, and that row drives the cascade through the Heart Graph into a recommendation.

## 2 · Schema

See `../00_root/erd.md` §2.2 for the full column list. Summary:

| Col | Type | Required | Example |
|---|---|---|---|
| `Emotion_ID` | INTEGER PK | ✅ | `1` |
| `Core_Emotion` | TEXT | ✅ | `Anger` |
| `Arabic_Name` | TEXT | ✅ | `الغضب` |
| `Category` | TEXT | ✅ | `Negative` / `Positive` |
| `Description` | TEXT | ✅ | one sentence |
| `Common_Triggers` | TEXT | ✅ | "insult, injustice, disagreement" |
| `Primary_Negative_Attributes` | TEXT | ✅ | `;`-separated |
| `Secondary_Negative_Attributes` | TEXT | | `;`-separated |
| `Primary_Positive_Attributes` | TEXT | ✅ | `;`-separated |
| `Growth_Path` | TEXT | ✅ | `Ghadab→Sabr→Hilm→Rifq` |
| `Dominant_Nafs_State` | TEXT | ✅ | one of the 4 Nafs states |
| `Severity_Weight` | INTEGER | ✅ | 1–10 |
| `Recommended_Attribute_Priority` | TEXT | ✅ | |
| `Recommended_Intervention_Type` | TEXT | ✅ | e.g. `Patience` |
| `Recommended_Dua` | TEXT | | |
| `Recommended_Allah_Names` | TEXT | | `;`-separated |
| `Recommended_Dhikr` | TEXT | | |
| `Daily_Action` | TEXT | ✅ | one micro-task |
| `Related_Emotions` | TEXT | | `;`-separated |
| `Related_Attribute_IDs` | TEXT | | `;`-separated |
| `Keywords` | TEXT | | comma-separated search tokens |

## 3 · Distribution

```
   50 emotions
   ├── 40 Negative  (80%)
   └── 10 Positive  (20%)
```

The 10 positive emotions exist so the user can log **gratitude, contentment, hope, trust, love, …** — not just negative states. The system is not a complaint box.

### 3.1 Nafs distribution (Dominant_Nafs_State)

| Nafs state | # emotions | Examples |
|---|---|---|
| Ammarah | 16 | Anger, Jealousy, Hatred, Greed |
| Lawwamah | 24 | Anxiety, Fear, Regret, Shame |
| Mulhamah | 2 | Inspiration, Insight |
| Mutmainnah | 8 | Gratitude, Contentment, Trust, Hope |

## 4 · Emotion categories

| Category | Examples |
|---|---|
| **Negative · Anger cluster** | Anger, Hatred, Resentment, Rage |
| **Negative · Fear cluster** | Anxiety, Fear, Panic, Worry |
| **Negative · Envy cluster** | Jealousy, Covetousness |
| **Negative · Sadness cluster** | Sadness, Grief, Loneliness |
| **Negative · Pride cluster** | Arrogance, Self-admiration, Showing-off |
| **Negative · Dunya cluster** | Greed, Love of wealth, Restlessness |
| **Positive · Tawakkul cluster** | Trust, Reliance, Certainty |
| **Positive · Shukr cluster** | Gratitude, Contentment |
| **Positive · Mahabbah cluster** | Love, Hope, Longing |

The full enumerated list with IDs is in `../07_appendices/50_core_emotions.md`.

## 5 · Relationships

`emotions` participates in these link tables:

| Link table | Role |
|---|---|
| `emotion_attribute_links` | Maps each emotion to the 1–3 attributes it surfaces (Disease, Treatment, Core, Strengthens). |
| `domain_emotion_links` | Maps each emotion to 1–3 of the 10 domains with a weight. |
| `emotion_nafs_weights` | Provides the per-emotion Nafs bias vector. |
| `checkins` | The user logs an emotion here daily. |
| `interventions_history` | Records which intervention was shown for which emotion. |

The diagram:

```
   emotions ── emotion_attribute_links ──▶ attributes
       │                                       │
       │                                       │
       ├── domain_emotion_links ──▶ domains   │
       │                                       │
       ├── emotion_nafs_weights ──▶ nafs_states
       │
       └── checkins ──▶ detected_attributes
```

## 6 · Flow

```
   User picks "Anger" (intensity 7)
            │
            ▼
   1. Resolve emotion row          → Primary_Negative = "Ghadab"
                                       Primary_Positive = "Sabr;Hilm;Rifq"
                                       Growth_Path       = "Ghadab→Sabr→Hilm→Rifq"
                                       Dominant_Nafs     = "Ammarah"
            │
            ▼
   2. Look up emotion_attribute_links  → top weighted attributes: Ghadab (Disease), Sabr (Treatment)
            │
            ▼
   3. Write to checkins (today)
            │
            ▼
   4. Compute detected_attributes      → insert rows
            │
            ▼
   5. Apply emotion_nafs_weights       → contributes to Nafs vector
            │
            ▼
   6. Show intervention (Patience, dua for Sabr, etc.)
```

## 7 · The `Growth_Path` field

`Growth_Path` is a `→`-separated string of attribute names. It is the **canonical, human-readable** version of the path. The machine-readable form is a chain of `attribute_links` rows with `Relationship = Cure` and `Leads_To`.

| Emotion | Growth_Path |
|---|---|
| Anger (1) | Ghadab → Sabr → Hilm → Rifq |
| Jealousy (2) | Hasad → Shukr → Qanaah → Ridha |
| Anxiety (3) | Weak Tawakkul → Tawakkul → Yaqeen → Sakinah |
| Fear (4) | Khawf imbalance → Tawakkul → Raja → Yaqeen → Sakinah |

(See `07_appendices/50_core_emotions.md` for all 50.)

## 8 · Implementation notes

- The table is **seeded once** from a JSON file at first launch.
- The list is intentionally **flat** (no parent category column) — categories live in `domain_emotion_links`.
- The `Keywords` field is used by the typeahead search on the Check-in screen.
- `Severity_Weight` is used in `08_algorithms/severity_algorithm.md` to amplify or dampen the Nafs update.
- The Arabic name is the **canonical display label** in Arabic locales; the English name is the canonical label in English locales.
