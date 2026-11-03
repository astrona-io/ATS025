#!/usr/bin/env bash
# Check: the schema rejects a bad channel and a missing channel, and accepts a valid object.
set -uo pipefail

try() {
  kubectl apply --dry-run=server -f - >/dev/null 2>&1 <<BEACON
apiVersion: training.astrona.io/v1
kind: Beacon
metadata:
  name: check-schema
  namespace: starfleet
spec:
$1
BEACON
}

status=0
if try "  channel: delta"; then
  echo "FAIL: the API server accepted channel 'delta'"
  status=1
else
  echo "PASS: channel 'delta' is rejected"
fi
if try "  interval: 30"; then
  echo "FAIL: the API server accepted an object without channel"
  status=1
else
  echo "PASS: a missing channel is rejected"
fi
if try "  channel: beta"; then
  echo "PASS: a valid object is accepted"
else
  echo "FAIL: the API server rejected channel 'beta'"
  status=1
fi
exit "$status"
