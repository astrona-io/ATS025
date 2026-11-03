#!/usr/bin/env bash
# Check: interval is limited to 5 through 3600 and defaults to 60.
set -uo pipefail

try() {
  kubectl apply --dry-run=server -f - >/dev/null 2>&1 <<BEACON
apiVersion: training.astrona.io/v1
kind: Beacon
metadata:
  name: check-interval
  namespace: starfleet
spec:
  channel: alpha
  interval: $1
BEACON
}

status=0
for v in 4 3601; do
  if try "$v"; then
    echo "FAIL: interval ${v} was accepted"
    status=1
  else
    echo "PASS: interval ${v} is rejected"
  fi
done
for v in 5 3600; do
  if try "$v"; then
    echo "PASS: interval ${v} is accepted"
  else
    echo "FAIL: interval ${v} was rejected"
    status=1
  fi
done
kubectl -n starfleet delete beacon check-default --ignore-not-found >/dev/null 2>&1
if kubectl apply -f - >/dev/null 2>&1 <<'BEACON'
apiVersion: training.astrona.io/v1
kind: Beacon
metadata:
  name: check-default
  namespace: starfleet
spec:
  channel: gamma
BEACON
then
  got="$(kubectl -n starfleet get beacon check-default -o jsonpath='{.spec.interval}' 2>/dev/null || true)"
  kubectl -n starfleet delete beacon check-default --ignore-not-found >/dev/null 2>&1
  if [ "$got" = "60" ]; then
    echo "PASS: interval defaults to 60"
  else
    echo "FAIL: interval default is '${got}', expected 60"
    status=1
  fi
else
  echo "FAIL: could not create a Beacon without interval"
  status=1
fi
exit "$status"
