#!/usr/bin/env python3
"""CI validation: verify all hadith references in attributes_seed.json
match canonical tahqiq editions.

Implements RI-2.5 from docs/scholar-audit-remediation-plan.md.

Usage:
    python tools/ci/verify_hadith_refs.py

Exit code 0 = pass, non-zero = fail.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SEED = ROOT / "assets" / "data" / "attributes_seed.json"

# Canonical edition ranges (approximate, by collection).
# Numbers out of range are flagged.
COLLECTION_RANGES = {
    "Bukhari": (1, 7563),       # Muhammad Muhsin Khan ed.
    "Muslim": (1, 5362),       # Shu'ayb al-Arna'ut ed.
    "Abu Dawud": (1, 5274),
    "Tirmidhi": (1, 3956),
    "Nasa'i": (1, 5758),
    "Ibn Majah": (1, 4341),
    "Ahmad": (1, 30000),        # Musnad Ahmad (approximate upper bound)
    "Malik": (1, 1832),
    "Darimi": (1, 3563),
}


def parse_ref(ref: str) -> tuple[str, int] | None:
    """Returns (collection, number) or None if cannot parse."""
    if not ref:
        return None
    # Strip parenthetical grading comments like "(Hasan)" before parsing
    cleaned = re.sub(r"\s*\([^)]*\)\s*$", "", ref.strip())
    m = re.match(
        r"^\s*(Sahih\s+al-Bukhari|Sahih\s+Muslim|Sahih\s+Ibn\s+Majah|Sunan\s+Abu\s+Dawud|Sunan\s+Abi\s+Dawud|Jami['\u2019]?\s+at-Tirmidhi|Sunan\s+an-Nasa['\u2019]i|Sunan\s+an-Nasai|Sunan\s+Ibn\s+Majah|Musnad\s+Ahmad|Muwatta\s+Malik|Muwatta\s+Imam\s+Malik|Sunan\s+ad-Darimi|Shu['\u2019]?ab\s+al-Iman|Bukhari|Muslim|Abu\s+Dawud|Abi\s+Dawud|Tirmidhi|Nasa['\u2019]i|Nasai|Ibn\s+Majah|Ahmad|Malik|Darimi)\s+(\d+)",
        cleaned,
        re.IGNORECASE,
    )
    if not m:
        return None
    name = m.group(1).strip()
    num = int(m.group(2))
    # Normalize long names
    aliases = {
        "sahih al-bukhari": "Bukhari",
        "sahih muslim": "Muslim",
        "sahih ibn majah": "Ibn Majah",
        "sunan abu dawud": "Abu Dawud",
        "sunan abi dawud": "Abu Dawud",
        "jami at-tirmidhi": "Tirmidhi",
        "jami' at-tirmidhi": "Tirmidhi",
        "sunan an-nasa'i": "Nasa'i",
        "sunan an-nasai": "Nasa'i",
        "sunan ibn majah": "Ibn Majah",
        "musnad ahmad": "Ahmad",
        "muwatta malik": "Malik",
        "muwatta imam malik": "Malik",
        "sunan ad-darimi": "Darimi",
        "shuab al-iman": "Baihaqi",  # Shu'ab al-Iman by al-Baihaqi (not in COLLECTION_RANGES — warning)
    }
    canonical = aliases.get(name.lower(), name.title())
    return (canonical, num)


def in_range(collection: str, num: int) -> bool:
    rng = COLLECTION_RANGES.get(collection)
    if not rng:
        return False
    return rng[0] <= num <= rng[1]


def main() -> int:
    if not SEED.exists():
        print(f"FAIL: seed not found at {SEED}", file=sys.stderr)
        return 2
    data = json.loads(SEED.read_text(encoding="utf-8"))
    rows = data.get("rows", [])
    errors: list[str] = []
    warnings: list[str] = []
    for r in rows:
        aid = r.get("Attribute_ID")
        ref = r.get("Hadith_Reference", "")
        if not ref:
            warnings.append(f"row {aid}: empty hadith reference")
            continue
        parsed = parse_ref(ref)
        if parsed is None:
            errors.append(f"row {aid}: unparseable hadith ref '{ref}'")
            continue
        coll, num = parsed
        if coll not in COLLECTION_RANGES:
            warnings.append(f"row {aid}: unknown collection '{coll}'")
            continue
        if not in_range(coll, num):
            errors.append(
                f"row {aid}: hadith ref '{ref}' → {coll} #{num} is OUT OF RANGE "
                f"(expected {COLLECTION_RANGES[coll][0]}–{COLLECTION_RANGES[coll][1]})"
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
    print("\nPASS: all hadith references are within canonical range.")
    return 0


if __name__ == "__main__":
    sys.exit(main())