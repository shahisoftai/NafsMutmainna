#!/usr/bin/env python3
"""CI validation: verify the emotion_attribute_links_seed.json against the
quality bar documented in
HeartOS/02_relationships/emotion_attribute_links.md §10.

Quality bar (per RI):
  1. At least one Treatment per emotion.
  2. At least one Disease per emotion (positive emotions may have 0
     by design — see *No Disease link to a positive attribute*).
  3. Exactly one Core per emotion with Weight = 1.0.
  4. No Treatment link to a negative attribute.
  5. No Disease link to a positive attribute.

Usage:
    python tools/ci/verify_emotion_attribute_links.py
"""
from __future__ import annotations

import json
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SEED = ROOT / "assets" / "data" / "emotion_attribute_links_seed.json"
EMOTIONS = ROOT / "assets" / "data" / "emotions_seed.json"
ATTRIBUTES = ROOT / "assets" / "data" / "attributes_seed.json"


def main() -> int:
    if not SEED.exists():
        print(f"FAIL: link seed not found at {SEED}", file=sys.stderr)
        return 2
    if not EMOTIONS.exists() or not ATTRIBUTES.exists():
        print("FAIL: emotion or attribute seed missing", file=sys.stderr)
        return 2

    links = json.loads(SEED.read_text(encoding="utf-8")).get("rows", [])
    emotions = json.loads(EMOTIONS.read_text(encoding="utf-8")).get("rows", [])
    attributes = json.loads(ATTRIBUTES.read_text(encoding="utf-8")).get("rows", [])

    emotion_by_id = {e["Emotion_ID"]: e for e in emotions}
    attribute_by_id = {a["Attribute_ID"]: a for a in attributes}

    print(f"Checking {len(links)} link rows against {len(emotions)} emotions / {len(attributes)} attributes")

    per_emotion = defaultdict(list)
    errors: list[str] = []

    # Per-link checks
    for link in links:
        eid = link.get("Emotion_ID")
        aid = link.get("Attribute_ID")
        role = link.get("Role")
        weight = link.get("Weight")
        if eid not in emotion_by_id:
            errors.append(f"link {link.get('Link_ID')}: unknown Emotion_ID {eid}")
            continue
        if aid not in attribute_by_id:
            errors.append(f"link {link.get('Link_ID')}: unknown Attribute_ID {aid}")
            continue
        if role not in ("Disease", "Treatment", "Core", "Strengthens"):
            errors.append(f"link {link.get('Link_ID')}: invalid Role {role!r}")
            continue
        attr_nature = attribute_by_id[aid]["Nature"]
        # Rule 4: No Treatment link to a negative attribute
        if role == "Treatment" and attr_nature == "Negative":
            errors.append(
                f"link {link.get('Link_ID')}: Treatment → negative attribute "
                f"{attribute_by_id[aid]['Attribute']} (ID {aid})"
            )
        # Rule 5: No Disease link to a positive attribute
        if role == "Disease" and attr_nature == "Positive":
            errors.append(
                f"link {link.get('Link_ID')}: Disease → positive attribute "
                f"{attribute_by_id[aid]['Attribute']} (ID {aid})"
            )
        per_emotion[eid].append(link)

    # Per-emotion checks
    for eid, emo in emotion_by_id.items():
        links_for_emo = per_emotion.get(eid, [])
        roles = [l["Role"] for l in links_for_emo]
        # Rule 1: at least one Treatment
        if "Treatment" not in roles:
            errors.append(f"emotion {eid} ({emo['Core_Emotion']}): missing Treatment")
        # Rule 2: at least one Disease (positive emotions may have 0 by design)
        if "Disease" not in roles and emo["Category"] == "Negative":
            errors.append(
                f"emotion {eid} ({emo['Core_Emotion']}): missing Disease (Category={emo['Category']})"
            )
        # Rule 3: exactly one Core with Weight = 1.0
        cores = [l for l in links_for_emo if l["Role"] == "Core"]
        if len(cores) > 1:
            errors.append(f"emotion {eid} ({emo['Core_Emotion']}): {len(cores)} Core links (expected 1)")
        for c in cores:
            if c["Weight"] != 1.0:
                errors.append(
                    f"emotion {eid} ({emo['Core_Emotion']}): Core weight {c['Weight']} (expected 1.0)"
                )

    if errors:
        print(f"\n{len(errors)} ERRORS:", file=sys.stderr)
        for e in errors[:30]:
            print(f"  - {e}", file=sys.stderr)
        return 1
    print("\nPASS: emotion-attribute link seed meets quality bar.")
    return 0


if __name__ == "__main__":
    sys.exit(main())