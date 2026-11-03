#!/usr/bin/env bash
# Check: jane (group reviewers) can read pods in starfleet and nothing more.
set -uo pipefail

fail=0
AS=(--as=jane --as-group=reviewers)

for verb in get list watch; do
  answer="$(kubectl auth can-i "$verb" pods -n starfleet "${AS[@]}" 2>/dev/null || true)"
  if [ "$answer" != "yes" ]; then
    echo "FAIL: jane cannot $verb pods in starfleet"
    fail=1
  fi
done

if ! kubectl get pods -n starfleet "${AS[@]}" >/dev/null 2>&1; then
  echo "FAIL: a real request to list pods in starfleet as jane was refused"
  fail=1
fi

denied() {
  local answer
  answer="$(kubectl auth can-i "$@" "${AS[@]}" 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: jane should not be allowed: $*"
    fail=1
  fi
}

denied create pods -n starfleet
denied delete pods -n starfleet
denied list pods -n outpost
denied get secrets -n starfleet
denied list deployments.apps -n starfleet
denied list nodes

if [ "$fail" -eq 0 ]; then
  echo "PASS: jane reads pods in starfleet and nothing more"
fi
exit "$fail"
