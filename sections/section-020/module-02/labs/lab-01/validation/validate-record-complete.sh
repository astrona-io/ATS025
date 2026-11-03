#!/usr/bin/env bash
# Check: host-readiness exists in starfleet with all six keys, and no key still
# holds a value from the stale record. Rejects deleting the ConfigMap.
set -uo pipefail

if ! kubectl -n starfleet get configmap host-readiness >/dev/null 2>&1; then
  echo "FAIL: ConfigMap host-readiness not found in namespace starfleet"
  exit 1
fi

status=0
for key in cgroupDriver failSwapOn containerRuntimeVersion kubeletVersion kernelVersion osImage; do
  value="$(kubectl -n starfleet get configmap host-readiness -o go-template="{{index .data \"$key\"}}" 2>/dev/null || true)"
  if [ -z "$value" ] || [ "$value" = "<no value>" ]; then
    echo "FAIL: key $key is missing or empty"
    status=1
    continue
  fi
  case "$value" in
    cgroupfs-legacy|unknown|containerd://1.0.0|v1.20.0|4.4.0-legacy|"Legacy Linux 1.0"|unset)
      echo "FAIL: key $key still holds the stale value '$value'"
      status=1
      ;;
  esac
done

[ "$status" -eq 0 ] && echo "PASS: host-readiness has six keys and no stale value"
exit "$status"
