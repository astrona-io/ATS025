#!/usr/bin/env bash
# Check: the Mission CRD is established and the schema rejects bad values.
set -uo pipefail

est="$(kubectl get crd missions.training.astrona.io -o jsonpath='{.status.conditions[?(@.type=="Established")].status}' 2>/dev/null || true)"
if [ "$est" != "True" ]; then
  echo "FAIL: CRD missions.training.astrona.io is not established"
  exit 1
fi
echo "PASS: CRD missions.training.astrona.io is established"

try() {
  kubectl apply --dry-run=server -f - >/dev/null 2>&1 <<MISSION
apiVersion: training.astrona.io/v1
kind: Mission
metadata:
  name: check-schema
  namespace: starfleet
spec:
  callSign: check-one
$1
MISSION
}

status=0
if try "  phase: Lost"; then echo "FAIL: phase 'Lost' was accepted"; status=1; else echo "PASS: phase 'Lost' is rejected"; fi
if try "  phase: Active
  crewSize: 0"; then echo "FAIL: crewSize 0 was accepted"; status=1; else echo "PASS: crewSize 0 is rejected"; fi
if try "  phase: Active
  crewSize: 21"; then echo "FAIL: crewSize 21 was accepted"; status=1; else echo "PASS: crewSize 21 is rejected"; fi
if try "  phase: Active
  crewSize: 20"; then echo "PASS: a valid object is accepted"; else echo "FAIL: a valid object was rejected"; status=1; fi
exit "$status"
