#!/usr/bin/env bash
# Check: the Deployment sets WATCH_NAMESPACE=starfleet.
set -uo pipefail

val="$(kubectl -n beacon-system get deployment beacon-operator -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="WATCH_NAMESPACE")].value}' 2>/dev/null || true)"
if [ "$val" = "starfleet" ]; then
  echo "PASS: WATCH_NAMESPACE is starfleet"
else
  echo "FAIL: WATCH_NAMESPACE is '${val}', expected starfleet"
  exit 1
fi
