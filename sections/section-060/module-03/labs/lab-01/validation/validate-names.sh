#!/usr/bin/env bash
# Check: outpost-shuttle Deployment and Service exist in outpost; nothing named shuttle was applied elsewhere.
set -uo pipefail
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; status=1; }
status=0

for kind in deployment service; do
  if kubectl -n outpost get "$kind" outpost-shuttle >/dev/null 2>&1; then
    pass "$kind outpost-shuttle exists in outpost"
  else
    fail "$kind outpost-shuttle does not exist in outpost"
  fi
done
for namespace in default starfleet; do
  for kind in deployment service; do
    for name in shuttle outpost-shuttle; do
      if kubectl -n "$namespace" get "$kind" "$name" >/dev/null 2>&1; then
        fail "$kind $name exists in $namespace; the overlay must set the namespace outpost"
      fi
    done
  done
done
[ "$status" = "0" ] && pass "nothing named shuttle leaked into default or starfleet"
exit "$status"
