# Heart OS — Four-Layer Architecture

> **One sentence:** static Islamic content is connected by a directed graph; the graph is weighted against four Nafs states; user activity rolls up into a 15-day Nafs meter.

---

## 1 · The four layers

```
┌──────────────────────────────────────────────────────────────────────┐
│                                                                      │
│  LAYER 4 ─ USER          checkins · detected_attributes ·            │
│                          interventions_history · nafs_history ·      │
│                          habits · habit_logs                         │
│                                                                      │
│  LAYER 3 ─ NAFS ENGINE   nafs_states · attribute_nafs_weights ·     │
│                          emotion_nafs_weights                        │
│                                                                      │
│  LAYER 2 ─ GRAPH         attribute_links · emotion_attribute_links ·│
│                          domains · domain_attribute_links ·         │
│                          domain_emotion_links                        │
│                                                                      │
│  LAYER 1 ─ KNOWLEDGE     attributes (200) · emotions (50)            │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

Each layer **only reads from the layer above it** and **only writes to the layer below it** (in the conceptual sense — physically, joins are bidirectional). This makes the system easy to reason about, test, and extend.

### 1.1 Knowledge layer (static, seed-once)
| Table | Rows | Purpose |
|---|---|---|
| `attributes` | 200 | Heart attributes — positive and negative — with Quran, Hadith, Dua, Allah Names, opposites. |
| `emotions` | 50 | Core feelings a user may report, with growth paths and intervention guidance. |

### 1.2 Graph layer (relationships & intelligence)
| Table | Rows | Purpose |
|---|---|---|
| `emotion_attribute_links` | ~400 | Many-to-many between emotions and attributes, with a `Role` (Disease, Treatment, Core, Strengthens). |
| `attribute_links` | ~400 | The **Heart Graph** — directed edges between attributes (Cure, Strengthens, Leads_To, Opposes). |
| `domains` | 10 | Macro-categories of spiritual life (Iman, Character, …). |
| `domain_attribute_links` | ~600 | Maps attributes to domains with weights. |
| `domain_emotion_links` | ~200 | Maps emotions to domains with weights. |

### 1.3 Nafs engine (the scoring spine)
| Table | Rows | Purpose |
|---|---|---|
| `nafs_states` | 4 | Ammarah, Lawwamah, Mulhamah, Mutmainnah. |
| `attribute_nafs_weights` | 200 | One row per attribute, four weights (0–100) summing to ~100. |
| `emotion_nafs_weights` | 50 | Same shape, one row per emotion. |

### 1.4 User layer (activity & history)
| Table | Rows (user-specific) | Purpose |
|---|---|---|
| `checkins` | 1/day | Daily emotional log. |
| `detected_attributes` | 1–10/day | Attributes inferred from a check-in. |
| `interventions_history` | 1–10/day | Recommendations shown to the user. |
| `nafs_history` | 1/day | Daily Nafs-meter snapshot. |
| `habits` | ~10 | User-defined habits (Fajr, Quran, Dhikr, …). |
| `habit_logs` | 1/row/day | Daily habit completion. |

---

## 2 · Why four layers?

| Concern | Solved by |
|---|---|
| **Stability of content** — Quran and Hadith don't change | Knowledge layer is read-only at runtime; the seed JSON is shipped in the binary. |
| **Explainability** — every recommendation must have a "why" | Graph layer stores the edges, so the app can show "Cure of Anger is Patience (Hadith ref. …)". |
| **Determinism** — same check-in must yield same Nafs score | Nafs engine is a pure function: `f(emotion_weights, attribute_weights, checkin_intensity)`. |
| **Privacy** — the user owns their journey | User layer lives entirely in local SQLite; never leaves the device. |

---

## 3 · Data flow at a glance

```
  ┌────────────┐
  │   USER     │  daily check-in: emotion + intensity + notes
  └─────┬──────┘
        │
        ▼
  ┌────────────────────────┐
  │  LAYER 1 — KNOWLEDGE   │  resolve emotion → resolve attributes
  └─────┬──────────────────┘
        │
        ▼
  ┌────────────────────────┐
  │  LAYER 2 — GRAPH       │  traverse attribute_links (Cure, Strengthens)
  └─────┬──────────────────┘
        │
        ▼
  ┌────────────────────────┐
  │  LAYER 3 — NAFS        │  multiply by attribute_nafs_weights +
  │      ENGINE            │  emotion_nafs_weights → write nafs_history
  └─────┬──────────────────┘
        │
        ▼
  ┌────────────────────────┐
  │  LAYER 4 — USER        │  log interventions_history · update
  │                        │  detected_attributes · refresh Nafs meter
  └────────────────────────┘
```

See `user_flow.md` for the user-facing version of this diagram and `erd.md` for the physical table structure.

---

## 4 · Implementation in Flutter

The four layers map onto the project's CLEAN architecture:

| Heart OS layer | Flutter package / folder |
|---|---|
| Knowledge | `lib/src/data/datasources/local/content_seeds.dart` (loaded once at first launch) |
| Graph | `lib/src/data/datasources/local/graph_datasource.dart` |
| Nafs Engine | `lib/src/domain/usecases/nafs/*` (pure Dart, no IO) |
| User | `lib/src/data/datasources/local/checkin_datasource.dart` etc. |

The Nafs engine is intentionally a **pure-Dart module** so it can be unit-tested without any Flutter or SQLite dependency. See `../memory-bank/flutter-implementation-plan-comprehensive.md` for the broader CLEAN layout.

---

## 5 · What is *not* in v1

These are deferred to v2 or later — see `09_future/`:

- AI companion / LLM-generated reflections
- Cloud sync of user tables
- Push notifications (Fajr reminders, weekly insights)
- Full Arabic & Urdu localisation
- In-app analytics dashboards

Adding any of these does **not** require changes to the four-layer model.
