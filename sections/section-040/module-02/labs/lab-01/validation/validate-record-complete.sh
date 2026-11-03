#!/usr/bin/env bash
# Check: upgrade-review exists in starfleet with all keys, and no key holds a stale value. Rejects deleting the ConfigMap.
set -uo pipefail

record_value() {
  kubectl -n starfleet get configmap upgrade-review -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true
}

if ! kubectl -n starfleet get configmap upgrade-review >/dev/null 2>&1; then
  echo "FAIL: ConfigMap upgrade-review not found in namespace starfleet"
  exit 1
fi

status=0
for key in apiServerVersion controllerManagerVersion schedulerVersion kubeProxyVersion kubeletVersion storedVersion oldestKubelet nextMinor skewVerdict; do
  value="$(record_value "$key")"
  if [ -z "$value" ] || [ "$value" = "<no value>" ]; then
    echo "FAIL: key $key is missing or empty"
    status=1
    continue
  fi
  case "$value" in
    v1.20.0|"1.17"|1.17|"1.21"|1.21|unknown|unset)
      echo "FAIL: key $key still holds the stale value '$value'"
      status=1
      ;;
  esac
done

[ "$status" -eq 0 ] && echo "PASS: upgrade-review has nine keys and no stale value"
exit "$status"
