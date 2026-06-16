# `attributes` — The 200 Heart Attributes

> The Heart OS vocabulary for the *states* of the heart. Every recommendation, every growth path, every intervention is anchored to an attribute from this table.

---

## 1 · Purpose

`attributes` is the **deep, immutable knowledge base** of the system. It defines 200 named states of the qalb (heart) — both the diseases and their remedies — and gives each one its Islamic references (Quran, Hadith, Duas, Allah Names).

This table is the **terminal node** of the Heart Graph (see `../00_root/heart_graph.md`) and the **source of content** for the Intervention screen.

## 2 · Schema

See `../00_root/erd.md` §2.1. The 23 columns cover identity, definition, opposites, references, and practitioner notes.

| Group | Columns |
|---|---|
| **Identity** | `Attribute_ID`, `Attribute`, `Arabic_Name`, `Nature`, `Definition` |
| **Opposites** | `Opposite_Trait`, `Opposite_Arabic_Name` |
| **Search** | `Keywords` |
| **Quranic reference** | `Quran_Reference`, `Quran_Arabic`, `Quran_English`, `Quran_Urdu` |
| **Hadith reference** | `Hadith_Reference`, `Hadith_Arabic`, `Hadith_Urdu` |
| **Quranic dua** | `Quranic_Dua_Reference`, `Quranic_Dua_Arabic`, `Quranic_Dua_Urdu` |
| **Prophetic dua** | `Prophetic_Dua_Reference`, `Prophetic_Dua_Arabic`, `Prophetic_Dua_Urdu` |
| **Allah Names** | `Relevant_Allah_Names` |
| **Practitioner note** | `Practical_Understanding` |

## 3 · Distribution

```
   200 attributes
   ├── 70 Negative  (35%)   ← diseases of the heart (Riya, Kibr, Hasad, …)
   └── 130 Positive (65%)   ← virtues and remedies (Sabr, Hilm, Shukr, …)
```

The skew toward positives is deliberate: most growth paths terminate in a positive attribute, and many positive attributes serve as the *target* of a `Cure` edge from multiple negative attributes.

### 3.1 Macro-domain grouping (from the docx narrative)

The narrative `NafsMutmainna-200-Attributes.docx` organises the 200 attributes into 5 macro-domains:

| Domain | Theme |
|---|---|
| **1. Core Spiritual Vices & Remedies** | The foundational traits — Riya, Kibr, Ujb, Nifaq, … |
| **2. Emotional Vulnerabilities & Impulse Triggers** | Ghadab, Khawf, Hasad, Huzn, … |
| **3. Social Dynamics & Interpersonal Vices** | Gheebah, Namimah, Uqd, … |
| **4. Cognitive Traps & Mental Patterns** | Waswasa, Dhann, Ghaflah, … |
| **5. Behavioral Habits & Self-Regulation** | Sabr, Shukr, Qanaah, Ikhlas, … |

These 5 macro-domains are a **coarser grouping** than the 10 domains in the `domains` table; the 10-domain split is the one used by the app at runtime.

## 4 · Positive vs negative — what each one looks like

### 4.1 Negative attribute (example: Kibr, ID 2)

| Field | Value |
|---|---|
| `Nature` | Negative |
| `Definition` | Rejecting truth and considering oneself superior to others. |
| `Opposite_Trait` | Tawadu (humility) |
| `Quran_Reference` | Luqman 31:18 |
| `Hadith_Reference` | Sahih Muslim 91 |
| `Relevant_Allah_Names` | Al-Kabir, Al-Hakim, Al-Alim |
| `Practical_Understanding` | "Arrogance disappears when a person remembers his weakness, origin, and dependence on Allah." |

### 4.2 Positive attribute (example: Sabr, ID 41)

| Field | Value |
|---|---|
| `Nature` | Positive |
| `Definition` | Restraint of the self from anxiety and haste; perseverance in obedience. |
| `Opposite_Trait` | Jaza' (panic, impatience) |
| `Quran_Reference` | Al-Baqarah 2:153 |
| `Hadith_Reference` | Sahih al-Bukhari 1469 |
| `Relevant_Allah_Names` | As-Sabur, Al-Halim |
| `Practical_Understanding` | "Patience is the believer's weapon — it is half of faith (the other half being gratitude)." |

## 5 · The Quran · Hadith · Dua · Allah Names quartet

Every attribute carries all four. This is what makes the Intervention screen possible without a network call:

```
   Attribute  ── Quran_Arabic  ──►  Quran card  (verse, ref, English, Urdu)
              ── Hadith_Arabic ──►  Hadith card (text, ref)
              ── Prophetic_Dua_Arabic ──►  Dua card
              ── Relevant_Allah_Names ──►  Names card (3 names max)
```

Some attributes also have a `Quranic_Dua_*` triplet for a dua that is *itself* a verse of the Quran.

## 6 · Opposites — the built-in opposition graph

`Opposite_Trait` and `Opposite_Arabic_Name` define the **canonical opposite** of each attribute. This is used:

1. On the Insight screen to show "the other side of this attribute".
2. To seed `attribute_links` with `Relationship = Opposes` for every pair.
3. As a quality check at seed time (every negative must have a positive opposite and vice versa).

| Negative | ↔ | Positive |
|---|---|---|
| Kibr (2) | ↔ | Tawadu (8) |
| Hasad (12) | ↔ | Shukr (22) |
| Ghadab (41) | ↔ | Sabr (43) |
| Khawf (50) | ↔ | Tawakkul (60) |

The full pairing is in `07_appendices/200_attributes.md`.

## 7 · Role in the Heart Graph

`attributes` is the **node set** of the Heart Graph. `attribute_links` is the edge set. Each attribute:

- has 0–10 incoming edges (as a `Target` of `Cure` / `Leads_To` / `Strengthens` / `Opposes`)
- has 0–10 outgoing edges (as a `Source`)
- participates in 0–3 master pathways
- is associated with 0–3 emotions via `emotion_attribute_links`

The degree distribution is intentionally **left-skewed**: a few "hub" attributes (Sabr, Shukr, Tawakkul, Tawadu) have many connections, while most attributes are leaves.

## 8 · Relationships

| Link table | Role |
|---|---|
| `emotion_attribute_links` | Surfaces the attribute when the user logs an emotion. |
| `attribute_links` | Connects it to other attributes (Heart Graph). |
| `domain_attribute_links` | Groups it under one of the 10 domains. |
| `attribute_nafs_weights` | Gives the Nafs-bias vector. |
| `detected_attributes` | Records when it was detected for a user. |
| `interventions_history` | Records when it was the target of an intervention. |

## 9 · Practical understanding field

`Practical_Understanding` is a 1–3 line practitioner note that translates the abstract attribute into a felt, everyday state. Example:

> "Self-admiration blinds a person to his shortcomings. Remembering that every blessing is a gift — not a personal achievement — is the cure."

This field is shown:
- On the Attribute Detail screen.
- In the Insight screen as a one-line subtitle.
- In the Daily Action card on Home.

## 10 · Implementation notes

- The table is **seeded once** at first launch from `assets/data/attributes_seed.json`.
- The JSON is generated from `200-Attributes.xlsx` by a Dart script in `tools/seed_export/`.
- `Attribute_ID` is a stable 1–200 integer and is used as the foreign key in every other table — never re-numbers.
- The Arabic name is shown in the UI when the locale is `ar`; the English name otherwise. The Arabic name is always shown as a secondary line in the English locale for educational value.
