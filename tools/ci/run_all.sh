#!/usr/bin/env bash
# CI runner: invokes all scholar-audit-remediation validations.
#
# Usage: tools/ci/run_all.sh
# Exits 0 if all pass, non-zero on first failure.

set -e

cd "$(dirname "$0")/../.."

echo "=== HeartOS Scholar-Audit CI ==="
echo

echo "[1/4] Hadith reference verifier (RI-2.5)"
python3 tools/ci/verify_hadith_refs.py
echo

echo "[2/4] Quran reference verifier (RI-2.7)"
python3 tools/ci/verify_quran_refs.py
echo

echo "[3/4] Attribute duplicate resolver (RI-2.1)"
python3 tools/ci/verify_attribute_duplicates.py
echo

echo "[4/4] Emotion-attribute link quality (RI-2.1 quality bar)"
python3 tools/ci/verify_emotion_attribute_links.py
echo

echo "=== ALL CHECKS PASSED ==="