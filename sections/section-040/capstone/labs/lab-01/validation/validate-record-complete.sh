#!/usr/bin/env bash
# Check: lifecycle-review exists in starfleet with all keys, and no key holds a stale value. Rejects deleting the ConfigMap.
set -uo pipefail

record_value() {
  kubectl -n starfleet get configmap lifecycle-review -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true
}

if ! kubectl -n starfleet get configmap lifecycle-review >/dev/null 2>&1; then
  echo "FAIL: ConfigMap lifecycle-review not found in namespace starfleet"
  exit 1
fi

status=0
for key in apiServerVersion kubeletVersion storedVersion etcdVersion oldestKubelet nextMinor snapshotRevision snapshotTotalKeys snapshotPath workerName; do
  value="$(record_value "$key")"
  if [ -z "$value" ] || [ "$value" = "<no value>" ]; then
    echo "FAIL: key $key is missing or empty"
    status=1
    continue
  fi
  case "$value" in
    v1.20.0|"1.17"|1.17|"1.21"|1.21|3.4.0-0|"1"|1|/tmp/old.db|old-worker)
      echo "FAIL: key $key still holds the stale value '$value'"
      status=1
      ;;
  esac
done

[ "$status" -eq 0 ] && echo "PASS: lifecycle-review has ten keys and no stale value"
exit "$status"
