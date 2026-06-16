# Contributing to Heart OS Documentation

> How to add, update, or correct the Heart OS documentation. This file covers the *docs* only — for the app code, see the project's main `CONTRIBUTING.md` (if it exists) and the Flutter implementation plan in `../memory-bank/`.

---

## 1 · What the docs cover

The `HeartOS/` folder is the **authoritative source-code documentation** of the Heart OS v1 architecture. It documents:

- 14 database tables (schema, indexes, triggers)
- 50 emotions and 200 attributes (with Islamic references)
- 10 macro-domains and 4 Nafs states
- 8 master spiritual pathways
- 6 intervention types
- 4 algorithm families (recommendation, scoring, trend, severity)
- 4 deferred features (AI, analytics, i18n, sync)

It does **not** cover:

- The Flutter app code (that lives in `../lib/`).
- The existing Supabase setup (see `../docs/SUPABASE_VERIFICATION.md`).
- The Google Auth setup (see `../docs/GOOGLE_AUTH_SETUP.md`).

## 2 · File conventions

| Convention | Rule |
|---|---|
| **File names** | lowercase, snake_case (e.g. `attribute_nafs_weights.md`). |
| **Section names** | Title Case (e.g. `## Purpose`, `## Schema`). |
| **Table names** | snake_case in the text (e.g. `attribute_nafs_weights`). |
| **Column names** | PascalCase in the text (e.g. `Attribute_ID`). |
| **Constants** | UPPER_SNAKE_CASE (e.g. `NEUTRAL`, `MAX_HOPS`). |
| **Functions** | snake_case (e.g. `daily_nafs`). |
| **Apposition** | Use em-dash (—). |
| **Ranges** | Use en-dash (–). |
| **Blockquotes** | Use `>` for callouts. |

## 3 · Required sections in every file

Every file in `HeartOS/` should have:

1. A **Purpose** section — what this file is for.
2. (If documenting a table) A **Schema** section.
3. A **Scholarly note** or **Scholarly illustration** section (with Quran/Hadith/scholarly references where applicable) — **not** a "Worked example" with illustrative sample data. Per the 2026-06-12 authenticity reaudit, HeartOS documentation does not contain sample or worked-example data. See [`AUDIT_REPORT.md`](AUDIT_REPORT.md) §3.4.
4. A **See also** section — links to related files.
5. (If applicable) An **Edge cases** section.

## 4 · Mermaid diagrams

Use Mermaid for visualisations. The conventions:

- `flowchart TB` for top-to-bottom (preferred for systems).
- `flowchart LR` for left-to-right (preferred for flows).
- `erDiagram` for entity-relationship diagrams.
- `sequenceDiagram` for time-ordered interactions.

Class colours:

- `classDef know fill:#fef3c7,stroke:#f59e0b` — knowledge layer (amber).
- `classDef graph fill:#ede9fe,stroke:#8b5cf6` — graph layer (violet).
- `classDef nafs fill:#d1fae5,stroke:#10b981` — nafs layer (emerald).
- `classDef user fill:#dbeafe,stroke:#3b82f6` — user layer (blue).
- `classDef neutral fill:#e2e8f0,stroke:#475569` — neutral / generic.

## 5 · Proposing changes

### 5.1 Schema changes

A schema change must:

1. Be **forward-compatible** — never drop a column or table in v1+.
2. Be **additive** — new columns, new tables, new indexes.
3. Be **documented** — the relevant file in `01_core_tables/`, `02_relationships/`, `03_nafs_engine/`, or `04_user_tables/` must be updated in the same PR.
4. Update `SCHEMA.sql` with the new DDL.
5. Update `CHANGELOG.md` with the change.

### 5.2 Algorithm changes

An algorithm change must:

1. Be **proposed first** — mark the new constants with ⚠️ PROPOSAL.
2. Include **test cases** — at least 3 unit tests in `08_algorithms/`.
3. Be **benchmarked** — add a "Performance" section with timings.
4. Update `CHANGELOG.md`.

### 5.3 Content changes (attributes, emotions, pathways)

Adding a new attribute, emotion, or pathway:

1. Add the row(s) to the appropriate seed JSON (`assets/data/...`).
2. Update the corresponding `01_core_tables/`, `02_relationships/`, `05_pathways/`, or `07_appendices/` file.
3. Update `INDEX.md` if the file is new.
4. Update `CHANGELOG.md`.

The editorial bar for new content is **high**:

- Every new attribute must have a Quran or Hadith reference.
- Every new emotion must have a growth path.
- Every new pathway must have at least one reference per step.

## 6 · Style guide for content

### 6.1 Quotes from Quran / Hadith

- **Reference, don't reproduce.** Cite the surah/hadith and the *reference*, but only quote the relevant excerpt (1–3 lines).
- **Always cite the source.** E.g. "Sahih al-Bukhari 91", "Surah Al-Baqarah 2:153".
- **Use the standard translations** for English and Urdu. Don't paraphrase the meaning.

### 6.2 Arabic text

- Use **full diacritics** (tashkeel) for Quranic verses.
- For attribute / emotion names, diacritics are **optional** but recommended in formal docs.

### 6.3 Code blocks

- Use `dart` for Dart code, `sql` for SQL, `python` for Python, `bash` for shell.
- Mermaid blocks don't need a language tag (it's auto-detected).

### 6.4 Links

- Use **relative** links to other files in `HeartOS/` — e.g. `[architecture](../00_root/architecture.md)`.
- Use **absolute** links to files outside `HeartOS/` — e.g. `[/home/najeeb/Linux-Dev/NM-flutter/50-cores.xlsx]`.
- Always test links in a markdown viewer before committing.

## 7 · Review checklist

Before submitting a PR that touches the docs:

- [ ] All links resolve.
- [ ] All Mermaid diagrams render.
- [ ] All tables are valid markdown.
- [ ] No Quran/Hadith text is reproduced in full (only excerpts with citations).
- [ ] `INDEX.md` is updated if files were added or renamed.
- [ ] `CHANGELOG.md` is updated.
- [ ] `SCHEMA.sql` is updated if the schema changed.
- [ ] The "Statistics" section of `INDEX.md` is updated if counts changed.

## 8 · What *not* to do

- ❌ Don't add a new top-level section without consulting the maintainers.
- ❌ Don't use the docs as a personal journal — keep them factual.
- ❌ Don't add content that is not in the seed — the docs document the *system*, not aspirations.
- ❌ Don't reproduce full Quran or Hadith text — cite and excerpt only.
- ❌ Don't add new file types (e.g. `.docx`, `.pdf`) — keep everything in markdown.

## 9 · Maintainers

The Heart OS documentation is maintained by the project lead. For questions:

1. Open an issue with the `docs` label.
2. Reference the specific file path (e.g. `HeartOS/03_nafs_engine/nafs_meter_algorithm.md`).
3. State what you want to change and why.

---

*Heart OS v1 — Documentation is a living document. Update it as the system evolves.*
