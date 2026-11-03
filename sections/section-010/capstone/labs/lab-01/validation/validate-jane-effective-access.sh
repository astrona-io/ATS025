#!/usr/bin/env bash
# Check: jane (group reviewers) reads pods and Deployments in starfleet and
# nothing outside that namespace or beyond reading.
set -uo pipefail

fail=0
AS=(--as=jane --as-group=reviewers)

for resource in pods deployments.apps; do
  for verb in get list watch; do
    answer="$(kubectl auth can-i "$verb" "$resource" -n starfleet "${AS[@]}" 2>/dev/null || true)"
    if [ "$answer" != "yes" ]; then
      echo "FAIL: jane cannot $verb $resource in starfleet"
      fail=1
    fi
  done
done

if ! kubectl get deployments -n starfleet "${AS[@]}" >/dev/null 2>&1; then
  echo "FAIL: a real request to list Deployments in starfleet as jane was refused"
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
denied delete deployments.apps -n starfleet
denied get secrets -n starfleet
denied list pods -n outpost
denied list deployments.apps -n outpost
denied list nodes

if [ "$fail" -eq 0 ]; then
  echo "PASS: jane reads pods and Deployments in starfleet and nothing more"
fi
exit "$fail"
