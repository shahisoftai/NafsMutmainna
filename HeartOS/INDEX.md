# Heart OS — Documentation Index

> Complete table of contents for the Heart OS v1 architecture documentation.

---

## 📁 Folder structure

```
HeartOS/
├── INDEX.md                          ← you are here
│
├── 00_root/                          · 7 files · top-level overview
│   ├── README.md                       entry point
│   ├── architecture.md                 four-layer model
│   ├── user_flow.md                    the 5-screen loop
│   ├── erd.md                          entity-relationship diagram
│   ├── heart_graph.md                  the directed graph
│   ├── scoring_engine.md               the Nafs meter algorithm
│   └── roadmap.md                      v1 / v1.1 / v1.2 / v2
│
├── 01_core_tables/                  · 4 files · foundational tables
│   ├── emotions.md                     the 50 core emotions
│   ├── attributes.md                   the 200 heart attributes
│   ├── domains.md                      the 10 macro-domains
│   └── nafs_states.md                  the 4 Nafs stations
│
├── 02_relationships/                · 4 files · link tables
│   ├── emotion_attribute_links.md      many-to-many emotion ↔ attribute
│   ├── attribute_links.md              the Heart Graph (attribute ↔ attribute)
│   ├── domain_attribute_links.md       domain ↔ attribute
│   └── domain_emotion_links.md         domain ↔ emotion
│
├── 03_nafs_engine/                  · 3 files · scoring spine
│   ├── attribute_nafs_weights.md       200×4 attribute matrix
│   ├── emotion_nafs_weights.md         50×4 emotion matrix
│   └── nafs_meter_algorithm.md         the 50/20/20/10 blend
│
├── 04_user_tables/                  · 6 files · user activity
│   ├── checkins.md                     daily emotional log
│   ├── detected_attributes.md          inferred attributes per check-in
│   ├── interventions_history.md        recommendations shown
│   ├── nafs_history.md                 the 15-day Nafs diary
│   ├── habits.md                       user-defined daily practices
│   └── habit_logs.md                   daily habit completion
│
├── 05_pathways/                     · 9 files · 8 master pathways + overview
│   ├── master_pathways.md              the 8 pathways at a glance
│   ├── anger_to_mercy.md               Ghadab → Sabr → Hilm → Rifq → Rahmah
│   ├── anxiety_to_peace.md             Weak Tawakkul → Tawakkul → Yaqeen → Sakinah
│   ├── envy_to_contentment.md          Hasad → Shukr → Qanaah → Ridha
│   ├── pride_to_humility.md            Kibr → Tawadu → Ikhlas
│   ├── sin_to_love.md                  Tawbah → Inabah → Raja → Mahabbah
│   ├── ghaflah_to_presence.md          Yaqzah → Dhikr → Muraqabah → Ihsan
│   ├── dunya_to_zuhd.md                Hubb ad-Dunya → Zuhd → Ridha
│   └── knowledge_to_nearness.md        Ilm → Yaqeen → Mahabbah → Shawq → Wilayah
│
├── 06_diagrams/                     · 5 files · Mermaid renderings
│   ├── architecture_diagram.md         four-layer overview
│   ├── erd_diagram.md                   table-level ER
│   ├── heart_graph_diagram.md          the directed graph
│   ├── user_flow_diagram.md            the 5-screen loop
│   └── recommendation_engine_diagram.md
│
├── 07_appendices/                   · 5 files · full data lists
│   ├── 50_core_emotions.md             all 50 emotions with full details
│   ├── 200_attributes.md               all 200 attributes with full details
│   ├── domain_structure.md             the 10 + 5 macro-domains
│   ├── intervention_types.md           the 6 intervention types
│   └── allah_names_mapping.md          frequency index of Allah Names
│
├── 08_algorithms/                   · 4 files · formal algorithms
│   ├── recommendation_algorithm.md     the intervention pipeline
│   ├── scoring_algorithm.md            the daily Nafs algorithm
│   ├── trend_algorithm.md              streak & trend detection
│   └── severity_algorithm.md           emotion × intensity → severity
│
└── 09_future/                       · 4 files · deferred features
    ├── ai_layer.md                     the optional AI companion (v2)
    ├── analytics.md                    the in-app dashboard (v2)
    ├── multilingual_support.md         Arabic / Urdu / others (v1.1+)
    └── synchronization.md              opt-in cloud sync (v2.1)
```

**Total: 52 markdown files** (51 docs + AUDIT_REPORT.md) across 9 sections.

---

## 🚀 Where to start

| If you want to… | Start here |
|---|---|
| **Understand the project in 5 minutes** | [`00_root/README.md`](00_root/README.md) |
| **See the data model** | [`00_root/erd.md`](00_root/erd.md) |
| **See the architecture** | [`00_root/architecture.md`](00_root/architecture.md) |
| **Walk through the user experience** | [`00_root/user_flow.md`](00_root/user_flow.md) |
| **Understand the recommendation engine** | [`00_root/heart_graph.md`](00_root/heart_graph.md) + [`08_algorithms/recommendation_algorithm.md`](08_algorithms/recommendation_algorithm.md) |
| **Understand the Nafs meter** | [`00_root/scoring_engine.md`](00_root/scoring_engine.md) + [`03_nafs_engine/nafs_meter_algorithm.md`](03_nafs_engine/nafs_meter_algorithm.md) |
| **See a specific table** | [`01_core_tables/`](01_core_tables/) or [`04_user_tables/`](04_user_tables/) |
| **Follow a spiritual pathway** | [`05_pathways/`](05_pathways/) |
| **Look up an emotion** | [`07_appendices/50_core_emotions.md`](07_appendices/50_core_emotions.md) |
| **Look up an attribute** | [`07_appendices/200_attributes.md`](07_appendices/200_attributes.md) |
| **See the formal algorithm** | [`08_algorithms/`](08_algorithms/) |
| **See the Mermaid diagrams** | [`06_diagrams/`](06_diagrams/) |
| **Read the v2 roadmap** | [`09_future/`](09_future/) |

---

## 📊 Statistics

| Metric | Value |
|---|---|
| Total markdown files | **51** |
| Audit report | 1 (added 2026-06-12) |
| Total lines of documentation | **~9 500** |
| Attributes documented | **200** (with Quran/Hadith/Allah Names) |
| Emotions documented | **50** (with growth paths) |
| Nafs states documented | **4** (Ammarah · Lawwamah · Mulhamah · Mutmainnah) |
| Domains documented | **10** runtime + 5 narrative macro-domains |
| Master pathways | **8** |
| Intervention types | **6** (Quran · Hadith · Dua · Names · Dhikr · Action) |
| Tables in the schema | **14** core + 3 deferred |
| Mermaid diagrams | **10+** |
| Quranic references in seed | **~200** |
| Hadith references in seed | **~200** |
| Allah Names referenced | **~100** unique |

---

## 🌳 Documentation tree (visual)

```
INDEX.md
│
├── 00_root/ ──────────── Overview (7 files)
│     README ── architecture ── user_flow ── erd ── heart_graph ── scoring_engine ── roadmap
│
├── 01_core_tables/ ───── Foundation (4 files)
│     emotions ── attributes ── domains ── nafs_states
│
├── 02_relationships/ ──── Graph edges (4 files)
│     emotion_attribute_links ── attribute_links ── domain_attribute_links ── domain_emotion_links
│
├── 03_nafs_engine/ ────── Scoring spine (3 files)
│     attribute_nafs_weights ── emotion_nafs_weights ── nafs_meter_algorithm
│
├── 04_user_tables/ ────── User activity (6 files)
│     checkins ── detected_attributes ── interventions_history ── nafs_history ── habits ── habit_logs
│
├── 05_pathways/ ───────── 8 master pathways (9 files)
│     master_pathways ── anger_to_mercy ── anxiety_to_peace ── envy_to_contentment
│                      ── pride_to_humility ── sin_to_love ── ghaflah_to_presence
│                      ── dunya_to_zuhd ── knowledge_to_nearness
│
├── 06_diagrams/ ───────── Mermaid renderings (5 files)
│     architecture ── erd ── heart_graph ── user_flow ── recommendation_engine
│
├── 07_appendices/ ─────── Full data (5 files)
│     50_core_emotions ── 200_attributes ── domain_structure ── intervention_types ── allah_names_mapping
│
├── 08_algorithms/ ─────── Formal algorithms (4 files)
│     recommendation_algorithm ── scoring_algorithm ── trend_algorithm ── severity_algorithm
│
└── 09_future/ ─────────── Deferred features (4 files)
      ai_layer ── analytics ── multilingual_support ── synchronization
```

---

## 🔗 Cross-references

Every file in this folder cross-references the others. The most-cited files are:

1. **`00_root/architecture.md`** — referenced by 20+ files as the top-level model.
2. **`00_root/erd.md`** — referenced by 15+ files for table schemas.
3. **`00_root/heart_graph.md`** — referenced by 10+ files for graph concepts.
4. **`00_root/scoring_engine.md`** — referenced by 8+ files for Nafs-meter concepts.
5. **`03_nafs_engine/nafs_meter_algorithm.md`** — referenced by 6+ files for the algorithm.

---

## 📝 Conventions used throughout

- **File names** are lowercase, snake_case (e.g. `attribute_nafs_weights.md`).
- **Table names** are snake_case (e.g. `attribute_nafs_weights`).
- **Column names** are PascalCase (e.g. `Attribute_ID`).
- **Constants** are UPPER_SNAKE_CASE (e.g. `NEUTRAL`).
- **Functions** are snake_case (e.g. `daily_nafs`).
- **Em-dash** (—) is used for apposition. **En-dash** (–) is used for ranges.
- **Mermaid** diagrams use `flowchart TB` (top-bottom) or `flowchart LR` (left-right).
- **Audit** — see `AUDIT_REPORT.md` for the 2026-06-12 reaudit findings.

---

## ✅ Quality bar

A file in this folder:

1. Has a clear **Purpose** section.
2. Has a **Schema** section (if it documents a table).
3. Has a **See also** section with links to related files.
4. Uses Mermaid diagrams where useful.
5. Marks all proposals with ⚠️ PROPOSAL.
6. Does not contain copy-pasted copyrighted text (Quran/Hadith are referenced, not reproduced in full).
7. Is internally consistent with all other files in the folder.
8. **Does not contain "Worked example" sections with illustrative sample data.** Per the 2026-06-12 authenticity reaudit (see [`AUDIT_REPORT.md`](AUDIT_REPORT.md) §3.4), narrative files use **Scholarly note** or **Scholarly illustration** sections based on Quran, Hadith, and classical Islamic scholarship — not sample/placeholder data.

---

## 🛠️ Maintenance

This folder is maintained alongside the codebase. When a schema changes, the corresponding `.md` file is updated in the same PR. When an algorithm changes, the corresponding `08_algorithms/*.md` file is updated.

**No file in this folder is write-once.** Every file is a living document.

---

## 🔍 Audit Report

The HeartOS documentation was reaudited on 2026-06-12 against the source-of-truth files (`200-Attributes.xlsx`, `50-cores.xlsx`, `NafsMutmainna-200-Attributes.docx`). The full findings are in [`AUDIT_REPORT.md`](AUDIT_REPORT.md). Key results:

- All 51 documents verified to be based on Quran, Hadith (Sahih/Hasan), and classical Islamic scholarship.
- All "Worked example" sections in narrative files removed or converted into scholarly notes.
- Duplicate emotion detail sections in `50_core_emotions.md` removed.
- Hadith authentication standard documented in `GLOSSARY.md` §"Hadith authentication".
- Cross-references between all four layers verified consistent.

No content was modified that could alter the Islamic authenticity of the system. The 200 Attributes and 50 Core Emotions tables are preserved as authored in the source files.

---

*Heart OS v1 — 52 files (with AUDIT_REPORT.md) · 9 sections · one offline spiritual companion.*
