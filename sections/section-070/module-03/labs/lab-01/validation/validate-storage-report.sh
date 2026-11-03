#!/usr/bin/env bash
# Check: ConfigMap storage-report records the default class facts and the class of legacy-claim.
set -uo pipefail

status=0
if ! kubectl -n starfleet get configmap storage-report >/dev/null 2>&1; then
  echo "FAIL: ConfigMap storage-report does not exist in starfleet"
  exit 1
fi
report() { kubectl -n starfleet get configmap storage-report -o "jsonpath={.data.$1}" 2>/dev/null; }
sc() { kubectl get storageclass standard -o "jsonpath=$1" 2>/dev/null; }

check_key() {
  local key="$1" expected="$2"
  if [ -n "$expected" ] && [ "$(report "$key")" = "$expected" ]; then
    echo "PASS: $key is $expected"
  else
    echo "FAIL: $key must be $expected"
    status=1
  fi
}
check_key defaultClass "standard"
check_key provisioner "$(sc '{.provisioner}')"
check_key bindingMode "$(sc '{.volumeBindingMode}')"
check_key reclaimPolicy "$(sc '{.reclaimPolicy}')"
check_key legacyClaimClass "$(kubectl -n starfleet get pvc legacy-claim -o jsonpath='{.spec.storageClassName}' 2>/dev/null)"
exit "$status"
