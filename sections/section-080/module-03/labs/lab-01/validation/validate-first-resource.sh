#!/usr/bin/env bash
# Check: Beacon first-beacon with channel alpha exists in starfleet.
set -uo pipefail

if ! kubectl -n starfleet get beacon first-beacon >/dev/null 2>&1; then
  echo "FAIL: Beacon first-beacon does not exist in starfleet"
  exit 1
fi
ch="$(kubectl -n starfleet get beacon first-beacon -o jsonpath='{.spec.channel}' 2>/dev/null || true)"
if [ "$ch" = "alpha" ]; then
  echo "PASS: first-beacon has channel alpha"
else
  echo "FAIL: first-beacon channel is '${ch}', expected alpha"
  exit 1
fi
