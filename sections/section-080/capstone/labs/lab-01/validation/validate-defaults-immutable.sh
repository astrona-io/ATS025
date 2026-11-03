#!/usr/bin/env bash
# Check: crewSize defaults to 3 and callSign is immutable.
set -uo pipefail

status=0
kubectl -n starfleet delete mission check-immutable --ignore-not-found >/dev/null 2>&1
if ! kubectl apply -f - >/dev/null 2>&1 <<'MISSION'
apiVersion: training.astrona.io/v1
kind: Mission
metadata:
  name: check-immutable
  namespace: starfleet
spec:
  callSign: check-two
  phase: Planned
MISSION
then
  echo "FAIL: could not create a valid Mission"
  exit 1
fi
got="$(kubectl -n starfleet get mission check-immutable -o jsonpath='{.spec.crewSize}' 2>/dev/null || true)"
if [ "$got" = "3" ]; then echo "PASS: crewSize defaults to 3"; else echo "FAIL: crewSize default is '${got}', expected 3"; status=1; fi
if kubectl -n starfleet patch mission check-immutable --type=merge -p '{"spec":{"callSign":"changed"}}' >/dev/null 2>&1; then
  echo "FAIL: callSign was changed after creation"
  status=1
else
  echo "PASS: changing callSign is rejected"
fi
if kubectl -n starfleet patch mission check-immutable --type=merge -p '{"spec":{"phase":"Active"}}' >/dev/null 2>&1; then
  echo "PASS: changing phase is accepted"
else
  echo "FAIL: changing phase was rejected"
  status=1
fi
kubectl -n starfleet delete mission check-immutable --ignore-not-found >/dev/null 2>&1
exit "$status"
