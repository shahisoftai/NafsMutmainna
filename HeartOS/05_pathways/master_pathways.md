# Master Pathways — Overview

> The 8 canonical spiritual pathways shipped with Heart OS v1. Each pathway is a hand-curated chain of attributes, each with its Quranic anchor, Hadith, dua, Allah Names, and practitioner notes.

---

## 1 · What is a pathway?

A **pathway** is a directed chain in the Heart Graph that takes the user from a *disease state* to a *spiritual station*. Each pathway:

- Starts at a **negative attribute** (the disease).
- Visits 2–4 **intermediate attributes** (the remedies and their consequences).
- Terminates at a **positive attribute** (the spiritual station).
- Has a **Quranic anchor** at each step.
- Has a **practitioner note** that translates the abstract attribute into a felt, everyday practice.

A pathway is **more than a chain of attributes** — it is a *curriculum* the user can follow for weeks or months. The Pathways screen shows the user which pathways they are "on" based on their recent check-ins.

## 2 · The 8 master pathways

| # | Pathway | From → To | Core emotion |
|---|---|---|---|
| 1 | **Anger → Mercy** | Ghadab → Sabr → Hilm → Rifq → Rahmah | Anger |
| 2 | **Anxiety → Peace** | Weak Tawakkul → Tawakkul → Yaqeen → Sakinah | Anxiety |
| 3 | **Envy → Contentment** | Hasad → Shukr → Qanaah → Ridha | Jealousy |
| 4 | **Pride → Humility** | Kibr → Tawadu → Ikhlas | Pride |
| 5 | **Sin → Love** | (Tawbah) → Inabah → Raja → Mahabbah | Guilt, Regret |
| 6 | **Heedlessness → Presence** | (Yaqzah) → Dhikr → Muraqabah → Ihsan | Heedlessness |
| 7 | **Dunya → Zuhd** | Hubb ad-Dunya → Zuhd → Ridha | Love of wealth |
| 8 | **Knowledge → Nearness** | Ilm → Yaqeen → Mahabbah → Shawq → Wilayah | Ignorance, Seeking |

Each pathway is documented in its own file in this directory. The files have a **consistent structure** so the reader can compare them.

## 3 · Pathway structure (template)

Each pathway file contains:

1. **Summary** — the chain in one line.
2. **The journey** — step-by-step table with attribute, Quranic anchor, and practitioner note.
3. **Recommended practices** — dhikr, dua, daily action.
4. **Signs of progress** — what it looks like when the user is moving along the chain.
5. **Stall signs** — what to do if the user feels stuck.
6. **Related emotions** — which check-ins surface this pathway.
7. **Domain** — which of the 10 domains the pathway primarily belongs to.

## 4 · How pathways are surfaced

The Pathways screen (`/pathways`) shows:

- **8 pathway cards** in a 2-column grid.
- Each card shows the chain as a horizontal arrow strip.
- The card is **highlighted** if the user has surfaced the starting attribute in the last 7 days.
- A **progress bar** shows how far along the chain the user has progressed (based on the detected-attribute log).
- A **"Start this pathway"** CTA if the user is not yet on it but is eligible.

### 4.1 Eligibility

A pathway is "eligible" for a user if:

1. The starting attribute is in the user's top-5 detected attributes in the last 14 days, **OR**
2. The user has logged the related emotion (e.g. Anger) at intensity ≥ 5 in the last 14 days, **OR**
3. The user has manually started the pathway (pin to Home).

### 4.2 Progress

A user is "on" step *k* of a pathway if:

- The step's attribute has been detected in the last 14 days with `Score > 0.3`, **OR**
- The user has completed the daily action associated with the step on 5+ of the last 14 days.

The progress bar fills step by step as the user advances.

## 5 · Pathways vs the Insight screen

The **Insight screen** (`/insight`) shows a *short-term* growth path (2–3 steps) based on the current check-in. The **Pathways screen** (`/pathways`) shows the *long-term* curriculum (4–5 steps) for each major disease.

They are complementary:
- The Insight screen answers: *"What do I do right now?"*
- The Pathways screen answers: *"What is my long-term project?"*

## 6 · Why exactly 8?

| Count | Verdict |
|---|---|
| 4 | Too few — misses several major diseases. |
| **8** | ✅ Covers the 8 most common spiritual diseases in the Islamic tradition. |
| 12+ | Dilutes the user's attention. |

The 8 are chosen because they cover the principal diseases of the heart (*amradh al-qalb*) treated in the classical works of *tazkiyah*, most notably Imam al-Ghazali's *Ihya' 'Ulum al-Din* and Ibn al-Qayyim's *Madarij al-Salikin*. The classical scholars did not fix the number of diseases to eight; the count here is a curriculum design of Heart OS v1 — anchored in the tradition but not derived from any single classical taxonomy.

## 7 · Adding new pathways (v1.2+)

In v1.0, the 8 pathways are **hard-coded** in the seed JSON (`assets/data/master_pathways_seed.json`). They are stored in the deferred `master_pathways` table only as documentation (not as a runtime table).

In v1.2, the `master_pathways` table is created and the seed is loaded. New pathways can be added by:

1. Defining the chain in the seed JSON.
2. Ensuring all the edges exist in `attribute_links`.
3. Updating the Pathways screen to show the new card.

## 8 · The 8 pathways at a glance

### 8.1 Anger → Mercy

```
   Ghadab → Sabr → Hilm → Rifq → Rahmah
   (Anger) (Patience) (Forbearance) (Gentleness) (Mercy)
```

The canonical chain for the disease of anger. See `anger_to_mercy.md`.

### 8.2 Anxiety → Peace

```
   Weak Tawakkul → Tawakkul → Yaqeen → Sakinah
   (Weak Reliance) (Reliance) (Certainty) (Tranquility)
```

The chain from worry to inner stillness. See `anxiety_to_peace.md`.

### 8.3 Envy → Contentment

```
   Hasad → Shukr → Qanaah → Ridha
   (Envy) (Gratitude) (Contentment) (Satisfaction)
```

The chain from comparison to satisfaction. See `envy_to_contentment.md`.

### 8.4 Pride → Humility

```
   Kibr → Tawadu → Ikhlas
   (Arrogance) (Humility) (Sincerity)
```

The short chain for the disease of self-exaltation. See `pride_to_humility.md`.

### 8.5 Sin → Love

```
   (Tawbah) → Inabah → Raja → Mahabbah
   (Repentance) (Turning) (Hope) (Love)
```

The chain from guilt to love of Allah. See `sin_to_love.md`.

### 8.6 Heedlessness → Presence

```
   (Yaqzah) → Dhikr → Muraqabah → Ihsan
   (Awakening) (Remembrance) (Watchfulness) (Excellence)
```

The chain from distraction to presence. See `ghaflah_to_presence.md`.

### 8.7 Dunya → Zuhd

```
   Hubb ad-Dunya → Zuhd → Ridha
   (Love of World) (Asceticism) (Satisfaction)
```

The chain from materialism to detachment. See `dunya_to_zuhd.md`.

### 8.8 Knowledge → Nearness

```
   Ilm → Yaqeen → Mahabbah → Shawq → Wilayah
   (Knowledge) (Certainty) (Love) (Longing) (Closeness)
```

The longest chain — from learning to divine closeness. See `knowledge_to_nearness.md`.

## 9 · The curriculum behind each pathway

Each pathway file includes:

- A **weekly rhythm** suggestion (e.g. "Week 1: focus on Step 1; Week 2: Step 2; …").
- A **reading list** — 1–3 Quranic passages to recite daily.
- A **dhikr set** — a specific set to recite 100×/day.
- A **dua set** — 2–3 duas to memorise and recite.
- A **practical exercise** — one weekly real-world action.

The full curriculum is in the individual pathway files.

## 10 · See also

- `anger_to_mercy.md`, `anxiety_to_peace.md`, … — the individual pathways.
- `../02_relationships/attribute_links.md` — the underlying graph.
- `../01_core_tables/attributes.md` — the attribute definitions.
- `../00_root/heart_graph.md` — the graph that powers the pathways.
- `../00_root/user_flow.md` §3 — the Pathways screen UX.
