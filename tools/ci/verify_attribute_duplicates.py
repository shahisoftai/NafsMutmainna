#!/usr/bin/env python3
"""CI validation: detect duplicate heart-attribute names in attributes_seed.json.

Implements RI-2.1 (Duplicate_Attribute_Resolver) from
docs/scholar-audit-remediation-plan.md.

Two attributes with the same name (regardless of case and whitespace) and the
same Arabic name are flagged as duplicates. The canonical resolution strategy
is documented in §2.1 of the remediation plan.

Usage:
    python tools/ci/verify_attribute_duplicates.py
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SEED = ROOT / "assets" / "data" / "attributes_seed.json"


def normalize(s: str) -> str:
    return (s or "").strip().lower().replace("'", "").replace("\u2018", "").replace("\u2019", "").replace("\u02BC", "").replace("-", "").replace("_", "").replace(" ", "")


def main() -> int:
    data = json.loads(SEED.read_text(encoding="utf-8"))
    rows = data.get("rows", [])
    name_groups: dict[str, list[tuple[int, str]]] = {}
    for r in rows:
        aid = r.get("Attribute_ID")
        name = r.get("Attribute", "")
        arabic = r.get("Arabic_Name", "")
        key = f"{normalize(name)}|{normalize(arabic)}"
        name_groups.setdefault(key, []).append((aid, name))
    duplicates = {k: v for k, v in name_groups.items() if len(v) > 1}
    if not duplicates:
        print(f"PASS: 0 duplicate attribute names across {len(rows)} rows.")
        return 0
    print(f"FAIL: {len(duplicates)} duplicate attribute names detected:")
    for k, ids in duplicates.items():
        ids_str = ", ".join(f"#{aid} ({name})" for aid, name in ids)
        print(f"  - {ids_str}")
    print(
        "\nSee docs/scholar-audit-remediation-plan.md §2.1 for the canonical "
        "resolution strategy."
    )
    return 1


if __name__ == "__main__":
    sys.exit(main())