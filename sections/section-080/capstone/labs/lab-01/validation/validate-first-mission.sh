#!/usr/bin/env bash
# Check: Mission apollo exists with phase Planned and the default crew.
set -uo pipefail

if ! kubectl -n starfleet get mission apollo >/dev/null 2>&1; then
  echo "FAIL: Mission apollo does not exist in starfleet"
  exit 1
fi
status=0
phase="$(kubectl -n starfleet get mission apollo -o jsonpath='{.spec.phase}' 2>/dev/null || true)"
crew="$(kubectl -n starfleet get mission apollo -o jsonpath='{.spec.crewSize}' 2>/dev/null || true)"
if [ "$phase" = "Planned" ]; then echo "PASS: apollo has phase Planned"; else echo "FAIL: phase is '${phase}', expected Planned"; status=1; fi
if [ "$crew" = "3" ]; then echo "PASS: apollo has the default crewSize 3"; else echo "FAIL: crewSize is '${crew}', expected the default 3"; status=1; fi
exit "$status"
