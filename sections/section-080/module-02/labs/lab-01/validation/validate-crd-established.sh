#!/usr/bin/env bash
# Check: the Beacon CRD is established and v1 is served and stored.
set -uo pipefail

crd=beacons.training.astrona.io
status=0
est="$(kubectl get crd "$crd" -o jsonpath='{.status.conditions[?(@.type=="Established")].status}' 2>/dev/null || true)"
served="$(kubectl get crd "$crd" -o jsonpath='{.spec.versions[?(@.name=="v1")].served}' 2>/dev/null || true)"
stored="$(kubectl get crd "$crd" -o jsonpath='{.spec.versions[?(@.name=="v1")].storage}' 2>/dev/null || true)"
if [ "$est" != "True" ]; then
  echo "FAIL: CRD ${crd} is not established (Established=${est:-missing})"
  status=1
elif [ "$served" != "true" ] || [ "$stored" != "true" ]; then
  echo "FAIL: version v1 must be served and the storage version (served=${served:-?}, storage=${stored:-?})"
  status=1
else
  echo "PASS: ${crd} is established and serves v1 as the storage version"
fi
exit "$status"
