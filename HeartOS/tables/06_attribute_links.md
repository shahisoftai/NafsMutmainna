# `attribute_links` — The Heart Graph

> The directed multigraph over the 200 attributes. The "brain" of Heart OS.
> **Source:** `HeartOS/02_relationships/attribute_links.md`, `HeartOS/05_pathways/*.md`, `HeartOS/06_diagrams/heart_graph_diagram.md`
> **Generated:** 2026-06-12

---

## Schema

| Col | Type | Notes |
|---|---|---|
| `Link_ID` | INTEGER PK | |
| `Source_Attribute_ID` | INTEGER FK → `attributes` | the "from" node |
| `Target_Attribute_ID` | INTEGER FK → `attributes` | the "to" node |
| `Weight` | REAL | 0.0 – 1.0 |
| `Relationship` | TEXT | enum: `Cure` · `Leads_To` · `Strengthens` · `Opposes` |

---

## The `Relationship` Enum

| Relationship | Meaning | Default weight |
|---|---|---|
| `Cure` | Treating the source by cultivating the target | 0.85–0.95 |
| `Leads_To` | The natural next step on the path to remedy | 0.7–0.95 |
| `Strengthens` | Reinforcing the target deepens the source | 0.6–0.7 |
| `Opposes` | Mutually exclusive states | 1.0 |

---

## Seed Data (218 rows)

| Link_ID | Source | Target | Weight | Relationship |
|---:|---:|---:|---:|---|
| 1 | 1 | 72 | 0.95 | Cure |
| 2 | 2 | 98 | 0.95 | Cure |
| 3 | 3 | 98 | 0.9 | Cure |
| 4 | 4 | 73 | 0.9 | Cure |
| 5 | 5 | 72 | 0.85 | Cure |
| 6 | 6 | 76 | 0.9 | Cure |
| 7 | 7 | 107 | 0.8 | Cure |
| 8 | 8 | 80 | 0.9 | Cure |
| 9 | 9 | 92 | 0.85 | Cure |
| 10 | 10 | 161 | 0.9 | Cure |
| 11 | 11 | 168 | 0.85 | Cure |
| 12 | 12 | 81 | 0.8 | Cure |
| 13 | 13 | 74 | 0.9 | Cure |
| 14 | 14 | 79 | 0.95 | Cure |
| 15 | 15 | 196 | 0.95 | Cure |
| 16 | 16 | 101 | 0.85 | Cure |
| 17 | 17 | 119 | 0.8 | Cure |
| 18 | 18 | 95 | 0.85 | Cure |
| 19 | 19 | 112 | 0.8 | Cure |
| 20 | 20 | 139 | 0.75 | Cure |
| 21 | 21 | 76 | 0.9 | Cure |
| 22 | 22 | 89 | 0.9 | Cure |
| 23 | 23 | 86 | 0.95 | Cure |
| 24 | 24 | 117 | 0.9 | Cure |
| 25 | 25 | 118 | 0.85 | Cure |
| 26 | 26 | 82 | 0.9 | Cure |
| 27 | 27 | 81 | 0.9 | Cure |
| 28 | 29 | 73 | 0.9 | Cure |
| 29 | 30 | 113 | 0.9 | Cure |
| 30 | 31 | 146 | 0.8 | Cure |
| 31 | 32 | 138 | 0.8 | Cure |
| 32 | 33 | 144 | 0.8 | Cure |
| 33 | 34 | 155 | 0.8 | Cure |
| 34 | 35 | 84 | 0.85 | Cure |
| 35 | 36 | 85 | 0.85 | Cure |
| 36 | 37 | 88 | 0.8 | Cure |
| 37 | 39 | 98 | 0.8 | Cure |
| 38 | 40 | 119 | 0.8 | Cure |
| 39 | 41 | 73 | 0.85 | Cure |
| 40 | 42 | 114 | 0.85 | Cure |
| 41 | 43 | 85 | 0.85 | Cure |
| 42 | 44 | 119 | 0.85 | Cure |
| 43 | 46 | 72 | 0.85 | Cure |
| 44 | 47 | 98 | 0.8 | Cure |
| 45 | 48 | 98 | 0.8 | Cure |
| 46 | 49 | 81 | 0.8 | Cure |
| 47 | 50 | 72 | 0.85 | Cure |
| 48 | 51 | 139 | 0.85 | Cure |
| 49 | 52 | 77 | 0.8 | Cure |
| 50 | 53 | 115 | 0.85 | Cure |
| 51 | 54 | 82 | 0.8 | Cure |
| 52 | 55 | 150 | 0.8 | Cure |
| 53 | 56 | 150 | 0.75 | Cure |
| 54 | 58 | 118 | 0.85 | Cure |
| 55 | 59 | 112 | 0.9 | Cure |
| 56 | 60 | 79 | 0.9 | Cure |
| 57 | 61 | 72 | 0.9 | Cure |
| 58 | 62 | 98 | 0.9 | Cure |
| 59 | 63 | 107 | 0.8 | Cure |
| 60 | 64 | 161 | 0.85 | Cure |
| 61 | 65 | 94 | 0.8 | Cure |
| 62 | 66 | 80 | 0.9 | Cure |
| 63 | 67 | 73 | 0.85 | Cure |
| 64 | 68 | 121 | 0.8 | Cure |
| 65 | 69 | 76 | 0.85 | Cure |
| 66 | 70 | 75 | 0.85 | Cure |
| 67 | 23 | 75 | 0.95 | Leads_To |
| 68 | 75 | 86 | 0.9 | Leads_To |
| 69 | 86 | 85 | 0.85 | Leads_To |
| 70 | 85 | 87 | 0.8 | Leads_To |
| 71 | 21 | 76 | 0.9 | Leads_To |
| 72 | 76 | 82 | 0.85 | Leads_To |
| 73 | 82 | 100 | 0.8 | Leads_To |
| 74 | 2 | 98 | 0.9 | Leads_To |
| 75 | 98 | 72 | 0.85 | Leads_To |
| 76 | 72 | 96 | 0.8 | Leads_To |
| 77 | 96 | 91 | 0.75 | Leads_To |
| 78 | 77 | 80 | 0.85 | Leads_To |
| 79 | 80 | 99 | 0.8 | Leads_To |
| 80 | 71 | 93 | 0.9 | Leads_To |
| 81 | 93 | 79 | 0.85 | Leads_To |
| 82 | 79 | 91 | 0.8 | Leads_To |
| 83 | 91 | 198 | 0.75 | Leads_To |
| 84 | 10 | 161 | 0.85 | Leads_To |
| 85 | 161 | 94 | 0.8 | Leads_To |
| 86 | 94 | 171 | 0.75 | Leads_To |
| 87 | 171 | 90 | 0.7 | Leads_To |
| 88 | 27 | 159 | 0.85 | Leads_To |
| 89 | 159 | 100 | 0.8 | Leads_To |
| 90 | 103 | 107 | 0.85 | Leads_To |
| 91 | 107 | 80 | 0.8 | Leads_To |
| 92 | 101 | 198 | 0.7 | Leads_To |
| 93 | 90 | 91 | 0.8 | Leads_To |
| 94 | 91 | 198 | 0.75 | Leads_To |
| 95 | 198 | 193 | 0.7 | Leads_To |
| 96 | 193 | 191 | 0.65 | Leads_To |
| 97 | 72 | 131 | 0.7 | Strengthens |
| 98 | 98 | 97 | 0.7 | Strengthens |
| 99 | 75 | 165 | 0.7 | Strengthens |
| 100 | 77 | 133 | 0.7 | Strengthens |
| 101 | 76 | 187 | 0.7 | Strengthens |
| 102 | 99 | 185 | 0.7 | Strengthens |
| 103 | 80 | 44 | 0.65 | Strengthens |
| 104 | 91 | 180 | 0.7 | Strengthens |
| 105 | 91 | 181 | 0.7 | Strengthens |
| 106 | 96 | 140 | 0.7 | Strengthens |
| 107 | 74 | 121 | 0.7 | Strengthens |
| 108 | 74 | 83 | 0.7 | Strengthens |
| 109 | 74 | 158 | 0.7 | Strengthens |
| 110 | 90 | 194 | 0.7 | Strengthens |
| 111 | 90 | 175 | 0.7 | Strengthens |
| 112 | 139 | 121 | 0.7 | Strengthens |
| 113 | 107 | 108 | 0.7 | Strengthens |
| 114 | 107 | 162 | 0.7 | Strengthens |
| 115 | 118 | 132 | 0.7 | Strengthens |
| 116 | 125 | 195 | 0.7 | Strengthens |
| 117 | 196 | 125 | 0.7 | Strengthens |
| 118 | 91 | 102 | 0.7 | Strengthens |
| 119 | 78 | 168 | 0.7 | Strengthens |
| 120 | 168 | 169 | 0.7 | Strengthens |
| 121 | 85 | 156 | 0.7 | Strengthens |
| 122 | 87 | 86 | 0.65 | Strengthens |
| 123 | 155 | 175 | 0.7 | Strengthens |
| 124 | 1 | 72 | 1.0 | Opposes |
| 125 | 2 | 98 | 1.0 | Opposes |
| 126 | 3 | 98 | 1.0 | Opposes |
| 127 | 4 | 73 | 1.0 | Opposes |
| 128 | 5 | 72 | 1.0 | Opposes |
| 129 | 6 | 76 | 1.0 | Opposes |
| 130 | 7 | 107 | 1.0 | Opposes |
| 131 | 8 | 80 | 1.0 | Opposes |
| 132 | 9 | 92 | 1.0 | Opposes |
| 133 | 10 | 161 | 1.0 | Opposes |
| 134 | 11 | 168 | 1.0 | Opposes |
| 135 | 12 | 81 | 1.0 | Opposes |
| 136 | 13 | 74 | 1.0 | Opposes |
| 137 | 14 | 79 | 1.0 | Opposes |
| 138 | 15 | 196 | 1.0 | Opposes |
| 139 | 16 | 101 | 1.0 | Opposes |
| 140 | 17 | 119 | 1.0 | Opposes |
| 141 | 18 | 95 | 1.0 | Opposes |
| 142 | 19 | 112 | 1.0 | Opposes |
| 143 | 22 | 89 | 1.0 | Opposes |
| 144 | 23 | 86 | 1.0 | Opposes |
| 145 | 24 | 117 | 1.0 | Opposes |
| 146 | 25 | 118 | 1.0 | Opposes |
| 147 | 26 | 82 | 1.0 | Opposes |
| 148 | 27 | 81 | 1.0 | Opposes |
| 149 | 29 | 73 | 1.0 | Opposes |
| 150 | 30 | 113 | 1.0 | Opposes |
| 151 | 31 | 146 | 1.0 | Opposes |
| 152 | 32 | 138 | 1.0 | Opposes |
| 153 | 33 | 144 | 1.0 | Opposes |
| 154 | 34 | 155 | 1.0 | Opposes |
| 155 | 35 | 84 | 1.0 | Opposes |
| 156 | 36 | 85 | 1.0 | Opposes |
| 157 | 38 | 119 | 1.0 | Opposes |
| 158 | 39 | 98 | 1.0 | Opposes |
| 159 | 41 | 73 | 1.0 | Opposes |
| 160 | 42 | 114 | 1.0 | Opposes |
| 161 | 43 | 85 | 1.0 | Opposes |
| 162 | 44 | 119 | 1.0 | Opposes |
| 163 | 46 | 72 | 1.0 | Opposes |
| 164 | 47 | 98 | 1.0 | Opposes |
| 165 | 48 | 98 | 1.0 | Opposes |
| 166 | 49 | 81 | 1.0 | Opposes |
| 167 | 50 | 72 | 1.0 | Opposes |
| 168 | 51 | 139 | 1.0 | Opposes |
| 169 | 53 | 115 | 1.0 | Opposes |
| 170 | 54 | 82 | 1.0 | Opposes |
| 171 | 57 | 104 | 1.0 | Opposes |
| 172 | 59 | 112 | 1.0 | Opposes |
| 173 | 60 | 79 | 1.0 | Opposes |
| 174 | 61 | 72 | 1.0 | Opposes |
| 175 | 62 | 98 | 1.0 | Opposes |
| 176 | 63 | 107 | 1.0 | Opposes |
| 177 | 64 | 161 | 1.0 | Opposes |
| 178 | 66 | 80 | 1.0 | Opposes |
| 179 | 67 | 73 | 1.0 | Opposes |
| 180 | 68 | 121 | 1.0 | Opposes |
| 181 | 69 | 76 | 1.0 | Opposes |
| 182 | 70 | 75 | 1.0 | Opposes |
| 183 | 72 | 131 | 1.0 | Opposes |
| 184 | 73 | 131 | 1.0 | Opposes |
| 185 | 74 | 121 | 1.0 | Opposes |
| 186 | 75 | 165 | 1.0 | Opposes |
| 187 | 76 | 187 | 1.0 | Opposes |
| 188 | 77 | 133 | 1.0 | Opposes |
| 189 | 78 | 168 | 1.0 | Opposes |
| 190 | 79 | 110 | 1.0 | Opposes |
| 191 | 80 | 110 | 1.0 | Opposes |
| 192 | 81 | 159 | 1.0 | Opposes |
| 193 | 82 | 154 | 1.0 | Opposes |
| 194 | 83 | 158 | 1.0 | Opposes |
| 195 | 84 | 120 | 1.0 | Opposes |
| 196 | 85 | 151 | 1.0 | Opposes |
| 197 | 86 | 152 | 1.0 | Opposes |
| 198 | 87 | 156 | 1.0 | Opposes |
| 199 | 88 | 89 | 1.0 | Opposes |
| 200 | 90 | 175 | 1.0 | Opposes |
| 201 | 91 | 180 | 1.0 | Opposes |
| 202 | 93 | 164 | 1.0 | Opposes |
| 203 | 94 | 160 | 1.0 | Opposes |
| 204 | 96 | 174 | 1.0 | Opposes |
| 205 | 97 | 98 | 1.0 | Opposes |
| 206 | 98 | 167 | 1.0 | Opposes |
| 207 | 99 | 185 | 1.0 | Opposes |
| 208 | 100 | 177 | 1.0 | Opposes |
| 209 | 101 | 182 | 1.0 | Opposes |
| 210 | 105 | 183 | 1.0 | Opposes |
| 211 | 107 | 186 | 1.0 | Opposes |
| 212 | 108 | 162 | 1.0 | Opposes |
| 213 | 117 | 149 | 1.0 | Opposes |
| 214 | 121 | 184 | 1.0 | Opposes |
| 215 | 122 | 139 | 1.0 | Opposes |
| 216 | 127 | 181 | 1.0 | Opposes |
| 217 | 133 | 176 | 1.0 | Opposes |
| 218 | 136 | 138 | 1.0 | Opposes |

---

## Statistics

- **Total edges:** 218
- **Cure:** 66
- **Leads_To:** 30
- **Strengthens:** 27
- **Opposes:** 95

## Density

| Property | Value |
|---|---|
| Total expected edges | ~400 (≈ 2 per attribute per direction) |
| Hub attributes (degree ≥ 10) | Sabr, Shukr, Tawakkul, Tawadu, Ikhlas, Mahabbah, Yaqin |
| Graph is connected via Leads_To + Cure edges | ✓ |

---

## The 8 Master Pathways (preview)

| # | Pathway | First edge | Last edge |
|---|---|---|---|
| 1 | Anger → Mercy | Ghadab(23) → Sabr(75) Cure | Rifq(85) → Rahmah(87) Strengthens |
| 2 | Anxiety → Peace | Tawakkul(77) → Yaqeen(80) Cure | Yaqeen(80) → Sakinah(99) Leads_To |
| 3 | Envy → Contentment | Hasad(21) → Shukr(76) Cure | Qana'ah(82) → Ridha(100) Leads_To |
| 4 | Pride → Humility | Kibr(2) → Tawadu(98) Cure | Tawadu(98) → Ikhlas(72) Leads_To |
| 5 | Sin → Love | Tawbah(71) → Inabah(93) | Mahabbah(91) |
| 6 | Heedlessness → Presence | Ghaflah(10) → Yaqzah(161) | Ihsan(90) |
| 7 | Dunya → Zuhd | Hubb ad-Dunya(27) → Zuhd(81) Cure | Zuhd(159) → Ridha(100) |
| 8 | Ignorance → Nearness | Tafakkur(103) → Basirah(107) | Shawq(101) → Wilayah(198) |

---

## See also

- `HeartOS/02_relationships/attribute_links.md` — full spec
- `HeartOS/00_root/heart_graph.md` — the directed graph concept
- `HeartOS/05_pathways/master_pathways.md` — the 8 master pathways
- `HeartOS/06_diagrams/heart_graph_diagram.md` — Mermaid visualisation
- `HeartOS/08_algorithms/recommendation_algorithm.md` — how the graph is queried
