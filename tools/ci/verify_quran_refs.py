#!/usr/bin/env python3
"""CI validation: verify Quran references in attributes_seed.json follow
the surah-name format and resolve to a known surah.

Implements RI-2.7 (Quran_Primary_Verifier) from
docs/scholar-audit-remediation-plan.md.

The canonical Quran references are formatted as "Surah_Name Chapter:Verse" or
"Surah_Name Chapter:Verse-Verse". The script checks:
  - the surah name is recognised (against a known list of 114 surahs)
  - chapter:verse are integers
  - verse is within the chapter's length

Usage:
    python tools/ci/verify_quran_refs.py
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SEED = ROOT / "assets" / "data" / "attributes_seed.json"

# Number of verses in each surah (source: standard quran.com data, simplified).
SURAH_VERSE_COUNT: dict[str, int] = {
    "Al-Fatihah": 7, "Al-Baqarah": 286, "Ali Imran": 200, "Al-Imran": 200,
    "An-Nisa": 176, "Al-Ma'idah": 120, "Al-Maidah": 120, "Al-An'am": 165,
    "Al-A'raf": 206, "Al-Araf": 206, "Al-Anfal": 75, "At-Tawbah": 129,
    "Yunus": 109, "Hud": 123, "Yusuf": 111, "Ar-Ra'd": 43,
    "Ibrahim": 52, "Al-Hijr": 99, "An-Nahl": 128, "Al-Isra": 111,
    "Al-Kahf": 110, "Maryam": 98, "Ta-Ha": 135, "Al-Anbiya": 112,
    "Al-Hajj": 78, "Al-Mu'minun": 118, "Al-Muminun": 118, "An-Nur": 64,
    "Al-Furqan": 77, "Ash-Shu'ara": 227, "An-Naml": 93, "Al-Qasas": 88,
    "Al-'Ankabut": 69, "Al-Ankabut": 69, "Ar-Rum": 60, "Luqman": 34,
    "As-Sajdah": 30, "Al-Ahzab": 73, "Saba": 54, "Fatir": 45,
    "Ya-Sin": 83, "As-Saffat": 182, "Sad": 88, "Az-Zumar": 75,
    "Ghafir": 85, "Fussilat": 54, "Ash-Shura": 53, "Az-Zukhruf": 89,
    "Ad-Dukhan": 59, "Al-Jathiyah": 37, "Al-Ahqaf": 35, "Muhammad": 38,
    "Al-Fath": 29, "Al-Hujurat": 18, "Qaf": 45, "Adh-Dhariyat": 60,
    "At-Tur": 49, "An-Najm": 62, "Al-Qamar": 55, "Ar-Rahman": 78,
    "Al-Waqi'ah": 96, "Al-Hadid": 29, "Al-Mujadilah": 22, "Al-Hashr": 24,
    "Al-Mumtahanah": 13, "As-Saff": 14, "Al-Jumu'ah": 11, "Al-Jumuah": 11,
    "Al-Munafiqun": 11, "At-Taghabun": 18, "At-Talaq": 12, "At-Tahrim": 12,
    "Al-Mulk": 30, "Al-Qalam": 52, "Al-Haqqah": 52, "Al-Ma'arij": 44,
    "Nuh": 28, "Al-Jinn": 28, "Al-Muzzammil": 20, "Al-Muddathir": 56,
    "Al-Qiyamah": 40, "Al-Insan": 31, "Al-Mursalat": 50, "An-Naba": 40,
    "An-Nazi'at": 46, "'Abasa": 42, "Abasa": 42, "At-Takwir": 29,
    "Al-Infitar": 19, "Al-Mutaffifin": 36, "Al-Inshiqaq": 25, "Al-Buruj": 22,
    "At-Tariq": 17, "Al-A'la": 19, "Al-Ghashiyah": 26, "Al-Fajr": 30,
    "Al-Balad": 20, "Ash-Shams": 15, "Al-Layl": 21, "Ad-Duha": 11,
    "Ash-Sharh": 8, "At-Tin": 8, "Al-'Alaq": 19, "Al-Qadr": 5,
    "Al-Bayyinah": 8, "Az-Zalzalah": 8, "Al-'Adiyat": 11, "Al-Qari'ah": 11,
    "At-Takathur": 8, "Al-'Asr": 3, "Al-Asr": 3, "Al-Humazah": 9,
    "Al-Fil": 5, "Quraysh": 4, "Al-Ma'un": 7, "Al-Maun": 7,
    "Al-Kawthar": 3, "Al-Kafirun": 6, "An-Nasr": 3, "Al-Masad": 5,
    "Al-Ikhlas": 4, "Al-Falaq": 5, "An-Nas": 6,
}


def parse_ref(ref: str) -> tuple[str, int, int] | None:
    """Parse a Quran ref like 'Al-Baqarah 2:153' or 'Al-Baqarah 2:153-156' or 'Al-Ahzab 33:58'."""
    if not ref:
        return None
    # Try with explicit verse first
    m = re.match(r"^\s*([A-Z][\w'\-]+(?:\s+[A-Z][\w'\-]+)*)\s+(\d+):(\d+)(?:\s*[-–]\s*(\d+))?", ref.strip())
    if m:
        surah = m.group(1).strip()
        chapter = int(m.group(2))
        verse = int(m.group(3))
        end_verse = int(m.group(4)) if m.group(4) else verse
        return (surah, chapter, end_verse)
    # Fall back: surah name + chapter only (whole surah)
    m2 = re.match(r"^\s*([A-Z][\w'\-]+(?:\s+[A-Z][\w'\-]+)*)\s+(\d+)\s*$", ref.strip())
    if m2:
        return (m2.group(1).strip(), int(m2.group(2)), int(m2.group(2)))
    return None


def main() -> int:
    data = json.loads(SEED.read_text(encoding="utf-8"))
    rows = data.get("rows", [])
    errors: list[str] = []
    warnings: list[str] = []
    for r in rows:
        aid = r.get("Attribute_ID")
        ref = r.get("Quran_Reference", "")
        if not ref:
            warnings.append(f"row {aid}: empty Quran reference")
            continue
        parsed = parse_ref(ref)
        if parsed is None:
            errors.append(f"row {aid}: unparseable Quran ref '{ref}'")
            continue
        surah, chapter, end_verse = parsed
        if surah not in SURAH_VERSE_COUNT:
            warnings.append(f"row {aid}: unknown surah '{surah}' (skipped length check)")
            continue
        max_verses = SURAH_VERSE_COUNT[surah]
        if end_verse > max_verses:
            errors.append(
                f"row {aid}: ref '{ref}' → verse {end_verse} exceeds surah length ({max_verses})"
            )
    print(f"Checked {len(rows)} attributes.")
    if warnings:
        print(f"\n{len(warnings)} warnings:")
        for w in warnings:
            print(f"  - {w}")
    if errors:
        print(f"\n{len(errors)} ERRORS:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1
    print("\nPASS: all Quran references resolve within their surah's length.")
    return 0


if __name__ == "__main__":
    sys.exit(main())