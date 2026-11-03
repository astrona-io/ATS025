#!/usr/bin/env bash
# Check: channel cannot change after creation, interval can.
set -uo pipefail

status=0
kubectl -n starfleet delete beacon check-immutable --ignore-not-found >/dev/null 2>&1
if ! kubectl apply -f - >/dev/null 2>&1 <<'BEACON'
apiVersion: training.astrona.io/v1
kind: Beacon
metadata:
  name: check-immutable
  namespace: starfleet
spec:
  channel: alpha
  interval: 30
BEACON
then
  echo "FAIL: could not create a valid Beacon"
  exit 1
fi
if kubectl -n starfleet patch beacon check-immutable --type=merge -p '{"spec":{"channel":"beta"}}' >/dev/null 2>&1; then
  echo "FAIL: channel was changed after creation"
  status=1
else
  echo "PASS: changing channel is rejected"
fi
if kubectl -n starfleet patch beacon check-immutable --type=merge -p '{"spec":{"interval":45}}' >/dev/null 2>&1; then
  echo "PASS: changing interval is accepted"
else
  echo "FAIL: changing interval was rejected"
  status=1
fi
kubectl -n starfleet delete beacon check-immutable --ignore-not-found >/dev/null 2>&1
exit "$status"
