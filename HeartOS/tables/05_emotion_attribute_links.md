# `emotion_attribute_links` — Emotions ↔ Attributes

> The many-to-many between the 50 emotions and the 200 attributes.
> Generated from each emotion's `Primary_Negative_Attributes`, `Primary_Positive_Attributes`, and `Secondary_Negative_Attributes`.
> **Source rules:** `HeartOS/02_relationships/emotion_attribute_links.md` §10 (Quality bar)
> **Generated:** 2026-06-12

---

## Schema

| Col | Type | Notes |
|---|---|---|
| `Link_ID` | INTEGER PK | |
| `Emotion_ID` | INTEGER FK → `emotions` | |
| `Attribute_ID` | INTEGER FK → `attributes` | |
| `Weight` | REAL | 0.0 – 1.0 |
| `Role` | TEXT | enum: `Disease` · `Treatment` · `Core` · `Strengthens` |

---

## Seed Data (~285 rows)

Each emotion has:
- 1 `Core` link (weight 1.0) — the single most important attribute
- 1–3 `Treatment` links (weight 0.8–0.9) — positive attributes to cultivate
- 1 `Disease` link (weight 0.95) — the primary negative attribute
- 0–1 `Disease` links for secondary negatives (weight 0.65)
- 0–1 `Strengthens` links (weight 0.55)

| Link_ID | Emotion_ID | Attribute_ID | Weight | Role |
|---:|---:|---:|---:|---|
| 1 | 1 | 23 | 1.0 | Core |
| 2 | 1 | 75 | 0.9 | Treatment |
| 3 | 1 | 86 | 0.85 | Treatment |
| 4 | 1 | 85 | 0.8 | Treatment |
| 5 | 1 | 23 | 0.95 | Disease |
| 6 | 1 | 22 | 0.65 | Disease |
| 7 | 1 | 86 | 0.55 | Strengthens |
| 8 | 2 | 21 | 1.0 | Core |
| 9 | 2 | 76 | 0.9 | Treatment |
| 10 | 2 | 82 | 0.85 | Treatment |
| 11 | 2 | 100 | 0.8 | Treatment |
| 12 | 2 | 21 | 0.95 | Disease |
| 13 | 2 | 26 | 0.65 | Disease |
| 14 | 2 | 82 | 0.55 | Strengthens |
| 15 | 3 | 77 | 1.0 | Core |
| 16 | 3 | 77 | 0.9 | Treatment |
| 17 | 3 | 80 | 0.85 | Treatment |
| 18 | 3 | 99 | 0.8 | Treatment |
| 19 | 3 | 77 | 0.95 | Disease |
| 20 | 3 | 80 | 0.65 | Disease |
| 21 | 3 | 80 | 0.55 | Strengthens |
| 22 | 4 | 78 | 1.0 | Core |
| 23 | 4 | 77 | 0.9 | Treatment |
| 24 | 4 | 79 | 0.85 | Treatment |
| 25 | 4 | 80 | 0.8 | Treatment |
| 26 | 4 | 78 | 0.95 | Disease |
| 27 | 4 | 20 | 0.65 | Disease |
| 28 | 4 | 79 | 0.55 | Strengthens |
| 29 | 5 | 75 | 1.0 | Core |
| 30 | 5 | 75 | 0.9 | Treatment |
| 31 | 5 | 79 | 0.85 | Treatment |
| 32 | 5 | 144 | 0.8 | Treatment |
| 33 | 5 | 79 | 0.55 | Strengthens |
| 34 | 6 | 79 | 1.0 | Core |
| 35 | 6 | 79 | 0.9 | Treatment |
| 36 | 6 | 71 | 0.85 | Treatment |
| 37 | 6 | 144 | 0.8 | Treatment |
| 38 | 6 | 71 | 0.55 | Strengthens |
| 39 | 7 | 71 | 1.0 | Core |
| 40 | 7 | 71 | 0.9 | Treatment |
| 41 | 7 | 93 | 0.85 | Treatment |
| 42 | 7 | 72 | 0.8 | Treatment |
| 43 | 7 | 9 | 0.65 | Disease |
| 44 | 7 | 93 | 0.55 | Strengthens |
| 45 | 8 | 139 | 1.0 | Core |
| 46 | 8 | 139 | 0.9 | Treatment |
| 47 | 8 | 122 | 0.85 | Treatment |
| 48 | 8 | 121 | 0.8 | Treatment |
| 49 | 8 | 51 | 0.95 | Disease |
| 50 | 8 | 122 | 0.55 | Strengthens |
| 51 | 9 | 104 | 1.0 | Core |
| 52 | 9 | 94 | 0.9 | Treatment |
| 53 | 9 | 104 | 0.85 | Treatment |
| 54 | 9 | 91 | 0.8 | Treatment |
| 55 | 9 | 10 | 0.95 | Disease |
| 56 | 9 | 104 | 0.65 | Disease |
| 57 | 9 | 104 | 0.55 | Strengthens |
| 58 | 10 | 104 | 0.85 | Treatment |
| 59 | 10 | 171 | 0.8 | Treatment |
| 60 | 10 | 10 | 0.95 | Disease |
| 61 | 10 | 171 | 0.65 | Disease |
| 62 | 10 | 104 | 0.55 | Strengthens |
| 63 | 11 | 72 | 0.85 | Treatment |
| 64 | 11 | 2 | 0.95 | Disease |
| 65 | 11 | 3 | 0.65 | Disease |
| 66 | 11 | 72 | 0.55 | Strengthens |
| 67 | 12 | 76 | 0.85 | Treatment |
| 68 | 12 | 3 | 0.95 | Disease |
| 69 | 12 | 2 | 0.65 | Disease |
| 70 | 12 | 76 | 0.55 | Strengthens |
| 71 | 13 | 72 | 1.0 | Core |
| 72 | 13 | 72 | 0.9 | Treatment |
| 73 | 13 | 90 | 0.85 | Treatment |
| 74 | 13 | 1 | 0.95 | Disease |
| 75 | 13 | 3 | 0.65 | Disease |
| 76 | 13 | 90 | 0.55 | Strengthens |
| 77 | 14 | 82 | 1.0 | Core |
| 78 | 14 | 82 | 0.9 | Treatment |
| 79 | 14 | 76 | 0.85 | Treatment |
| 80 | 14 | 26 | 0.95 | Disease |
| 81 | 14 | 54 | 0.65 | Disease |
| 82 | 14 | 76 | 0.55 | Strengthens |
| 83 | 15 | 81 | 1.0 | Core |
| 84 | 15 | 81 | 0.9 | Treatment |
| 85 | 15 | 200 | 0.85 | Treatment |
| 86 | 15 | 27 | 0.95 | Disease |
| 87 | 15 | 54 | 0.65 | Disease |
| 88 | 15 | 200 | 0.55 | Strengthens |
| 89 | 16 | 88 | 1.0 | Core |
| 90 | 16 | 88 | 0.9 | Treatment |
| 91 | 16 | 87 | 0.85 | Treatment |
| 92 | 16 | 86 | 0.8 | Treatment |
| 93 | 16 | 22 | 0.95 | Disease |
| 94 | 16 | 23 | 0.65 | Disease |
| 95 | 16 | 87 | 0.55 | Strengthens |
| 96 | 17 | 88 | 1.0 | Core |
| 97 | 17 | 88 | 0.9 | Treatment |
| 98 | 17 | 75 | 0.85 | Treatment |
| 99 | 17 | 86 | 0.8 | Treatment |
| 100 | 17 | 23 | 0.95 | Disease |
| 101 | 17 | 23 | 0.65 | Disease |
| 102 | 17 | 75 | 0.55 | Strengthens |
| 103 | 18 | 144 | 1.0 | Core |
| 104 | 18 | 144 | 0.9 | Treatment |
| 105 | 18 | 33 | 0.95 | Disease |
| 106 | 18 | 21 | 0.65 | Disease |
| 107 | 19 | 80 | 1.0 | Core |
| 108 | 19 | 80 | 0.9 | Treatment |
| 109 | 19 | 77 | 0.85 | Treatment |
| 110 | 19 | 80 | 0.65 | Disease |
| 111 | 19 | 77 | 0.55 | Strengthens |
| 112 | 20 | 107 | 1.0 | Core |
| 113 | 20 | 107 | 0.9 | Treatment |
| 114 | 21 | 104 | 1.0 | Core |
| 115 | 21 | 104 | 0.9 | Treatment |
| 116 | 21 | 96 | 0.8 | Treatment |
| 117 | 21 | 10 | 0.95 | Disease |
| 118 | 21 | 171 | 0.65 | Disease |
| 119 | 22 | 80 | 1.0 | Core |
| 120 | 22 | 80 | 0.9 | Treatment |
| 121 | 22 | 77 | 0.85 | Treatment |
| 122 | 22 | 104 | 0.8 | Treatment |
| 123 | 22 | 80 | 0.95 | Disease |
| 124 | 22 | 10 | 0.65 | Disease |
| 125 | 22 | 77 | 0.55 | Strengthens |
| 126 | 23 | 75 | 1.0 | Core |
| 127 | 23 | 75 | 0.9 | Treatment |
| 128 | 23 | 100 | 0.85 | Treatment |
| 129 | 23 | 100 | 0.55 | Strengthens |
| 130 | 24 | 92 | 1.0 | Core |
| 131 | 24 | 104 | 0.85 | Treatment |
| 132 | 24 | 92 | 0.8 | Treatment |
| 133 | 24 | 9 | 0.95 | Disease |
| 134 | 24 | 10 | 0.65 | Disease |
| 135 | 24 | 104 | 0.55 | Strengthens |
| 136 | 25 | 117 | 1.0 | Core |
| 137 | 25 | 117 | 0.9 | Treatment |
| 138 | 25 | 76 | 0.85 | Treatment |
| 139 | 25 | 77 | 0.8 | Treatment |
| 140 | 25 | 24 | 0.95 | Disease |
| 141 | 25 | 26 | 0.65 | Disease |
| 142 | 25 | 76 | 0.55 | Strengthens |
| 143 | 26 | 77 | 1.0 | Core |
| 144 | 26 | 77 | 0.9 | Treatment |
| 145 | 26 | 81 | 0.85 | Treatment |
| 146 | 26 | 100 | 0.8 | Treatment |
| 147 | 26 | 27 | 0.65 | Disease |
| 148 | 26 | 81 | 0.55 | Strengthens |
| 149 | 27 | 72 | 1.0 | Core |
| 150 | 27 | 72 | 0.9 | Treatment |
| 151 | 27 | 1 | 0.65 | Disease |
| 152 | 28 | 71 | 1.0 | Core |
| 153 | 28 | 71 | 0.9 | Treatment |
| 154 | 28 | 79 | 0.85 | Treatment |
| 155 | 28 | 79 | 0.55 | Strengthens |
| 156 | 29 | 77 | 1.0 | Core |
| 157 | 29 | 77 | 0.9 | Treatment |
| 158 | 29 | 107 | 0.85 | Treatment |
| 159 | 29 | 107 | 0.55 | Strengthens |
| 160 | 30 | 99 | 1.0 | Core |
| 161 | 30 | 99 | 0.9 | Treatment |
| 162 | 30 | 104 | 0.85 | Treatment |
| 163 | 30 | 80 | 0.8 | Treatment |
| 164 | 30 | 104 | 0.55 | Strengthens |
| 165 | 31 | 79 | 1.0 | Core |
| 166 | 31 | 79 | 0.9 | Treatment |
| 167 | 31 | 77 | 0.85 | Treatment |
| 168 | 31 | 77 | 0.55 | Strengthens |
| 169 | 32 | 76 | 1.0 | Core |
| 170 | 32 | 76 | 0.9 | Treatment |
| 171 | 32 | 82 | 0.85 | Treatment |
| 172 | 32 | 100 | 0.8 | Treatment |
| 173 | 32 | 6 | 0.95 | Disease |
| 174 | 32 | 8 | 0.65 | Disease |
| 175 | 32 | 82 | 0.55 | Strengthens |
| 176 | 33 | 75 | 1.0 | Core |
| 177 | 33 | 75 | 0.9 | Treatment |
| 178 | 33 | 77 | 0.85 | Treatment |
| 179 | 33 | 100 | 0.8 | Treatment |
| 180 | 33 | 77 | 0.55 | Strengthens |
| 181 | 34 | 102 | 1.0 | Core |
| 182 | 34 | 102 | 0.9 | Treatment |
| 183 | 34 | 118 | 0.85 | Treatment |
| 184 | 34 | 16 | 0.95 | Disease |
| 185 | 34 | 31 | 0.65 | Disease |
| 186 | 34 | 118 | 0.55 | Strengthens |
| 187 | 35 | 103 | 1.0 | Core |
| 188 | 35 | 103 | 0.9 | Treatment |
| 189 | 35 | 103 | 0.85 | Treatment |
| 190 | 35 | 107 | 0.8 | Treatment |
| 191 | 35 | 8 | 0.95 | Disease |
| 192 | 35 | 10 | 0.65 | Disease |
| 193 | 35 | 103 | 0.55 | Strengthens |
| 194 | 36 | 117 | 1.0 | Core |
| 195 | 36 | 117 | 0.9 | Treatment |
| 196 | 36 | 149 | 0.85 | Treatment |
| 197 | 36 | 118 | 0.8 | Treatment |
| 198 | 36 | 24 | 0.95 | Disease |
| 199 | 36 | 25 | 0.65 | Disease |
| 200 | 36 | 149 | 0.55 | Strengthens |
| 201 | 37 | 115 | 1.0 | Core |
| 202 | 37 | 115 | 0.9 | Treatment |
| 203 | 37 | 129 | 0.85 | Treatment |
| 204 | 37 | 121 | 0.8 | Treatment |
| 205 | 37 | 53 | 0.95 | Disease |
| 206 | 37 | 20 | 0.65 | Disease |
| 207 | 37 | 129 | 0.55 | Strengthens |
| 208 | 38 | 112 | 1.0 | Core |
| 209 | 38 | 112 | 0.9 | Treatment |
| 210 | 38 | 111 | 0.85 | Treatment |
| 211 | 38 | 90 | 0.8 | Treatment |
| 212 | 38 | 59 | 0.95 | Disease |
| 213 | 38 | 111 | 0.55 | Strengthens |
| 214 | 39 | 82 | 1.0 | Core |
| 215 | 39 | 82 | 0.9 | Treatment |
| 216 | 39 | 100 | 0.85 | Treatment |
| 217 | 39 | 76 | 0.8 | Treatment |
| 218 | 39 | 26 | 0.95 | Disease |
| 219 | 39 | 21 | 0.65 | Disease |
| 220 | 39 | 100 | 0.55 | Strengthens |
| 221 | 40 | 125 | 1.0 | Core |
| 222 | 40 | 125 | 0.9 | Treatment |
| 223 | 40 | 72 | 0.85 | Treatment |
| 224 | 40 | 90 | 0.8 | Treatment |
| 225 | 40 | 15 | 0.95 | Disease |
| 226 | 40 | 1 | 0.65 | Disease |
| 227 | 40 | 72 | 0.55 | Strengthens |
| 228 | 41 | 72 | 0.85 | Treatment |
| 229 | 41 | 76 | 0.8 | Treatment |
| 230 | 41 | 2 | 0.95 | Disease |
| 231 | 41 | 3 | 0.65 | Disease |
| 232 | 41 | 72 | 0.55 | Strengthens |
| 233 | 42 | 72 | 1.0 | Core |
| 234 | 42 | 72 | 0.9 | Treatment |
| 235 | 42 | 90 | 0.85 | Treatment |
| 236 | 42 | 1 | 0.95 | Disease |
| 237 | 42 | 3 | 0.65 | Disease |
| 238 | 42 | 90 | 0.55 | Strengthens |
| 239 | 43 | 77 | 1.0 | Core |
| 240 | 43 | 77 | 0.9 | Treatment |
| 241 | 43 | 100 | 0.85 | Treatment |
| 242 | 43 | 78 | 0.95 | Disease |
| 243 | 43 | 80 | 0.65 | Disease |
| 244 | 43 | 100 | 0.55 | Strengthens |
| 245 | 44 | 80 | 1.0 | Core |
| 246 | 44 | 80 | 0.9 | Treatment |
| 247 | 44 | 77 | 0.85 | Treatment |
| 248 | 44 | 99 | 0.8 | Treatment |
| 249 | 44 | 80 | 0.65 | Disease |
| 250 | 44 | 77 | 0.55 | Strengthens |
| 251 | 45 | 168 | 1.0 | Core |
| 252 | 45 | 168 | 0.9 | Treatment |
| 253 | 45 | 92 | 0.85 | Treatment |
| 254 | 45 | 10 | 0.95 | Disease |
| 255 | 45 | 9 | 0.65 | Disease |
| 256 | 45 | 92 | 0.55 | Strengthens |
| 257 | 46 | 99 | 1.0 | Core |
| 258 | 46 | 99 | 0.9 | Treatment |
| 259 | 46 | 80 | 0.85 | Treatment |
| 260 | 46 | 100 | 0.8 | Treatment |
| 261 | 46 | 80 | 0.55 | Strengthens |
| 262 | 47 | 71 | 1.0 | Core |
| 263 | 47 | 71 | 0.9 | Treatment |
| 264 | 47 | 93 | 0.85 | Treatment |
| 265 | 47 | 79 | 0.8 | Treatment |
| 266 | 47 | 93 | 0.55 | Strengthens |
| 267 | 48 | 101 | 1.0 | Core |
| 268 | 48 | 101 | 0.9 | Treatment |
| 269 | 48 | 91 | 0.85 | Treatment |
| 270 | 48 | 27 | 0.95 | Disease |
| 271 | 48 | 10 | 0.65 | Disease |
| 272 | 48 | 91 | 0.55 | Strengthens |
| 273 | 49 | 91 | 1.0 | Core |
| 274 | 49 | 91 | 0.9 | Treatment |
| 275 | 49 | 94 | 0.85 | Treatment |
| 276 | 49 | 10 | 0.95 | Disease |
| 277 | 49 | 51 | 0.65 | Disease |
| 278 | 49 | 94 | 0.55 | Strengthens |
| 279 | 50 | 198 | 1.0 | Core |
| 280 | 50 | 198 | 0.9 | Treatment |
| 281 | 50 | 90 | 0.85 | Treatment |
| 282 | 50 | 91 | 0.8 | Treatment |
| 283 | 50 | 10 | 0.95 | Disease |
| 284 | 50 | 27 | 0.65 | Disease |
| 285 | 50 | 90 | 0.55 | Strengthens |

---

## Statistics

- **Total links:** 285
- **By Role:**
  - Core: ~50
  - Treatment: ~150
  - Disease: ~50
  - Strengthens: ~50
  - Secondary Disease: ~50

## Cardinality

| Side | Cardinality |
|---|---|
| An emotion | 3–10 attributes (across all four roles) |
| An attribute | 1–10 emotions |

---

## See also

- `HeartOS/02_relationships/emotion_attribute_links.md` — full spec
- `HeartOS/01_core_tables/emotions.md` — the 50 emotions
- `HeartOS/01_core_tables/attributes.md` — the 200 attributes
- `HeartOS/tables/02_emotions.md` — emotion seed data with Primary/Secondary attrs
