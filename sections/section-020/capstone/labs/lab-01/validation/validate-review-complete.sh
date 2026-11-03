#!/usr/bin/env bash
# Check: readiness-review exists with eight keys and none holds a stale value.
set -uo pipefail

if ! kubectl -n starfleet get configmap readiness-review >/dev/null 2>&1; then
  echo "FAIL: ConfigMap readiness-review not found in namespace starfleet"
  exit 1
fi

status=0
for key in criSocket containerRuntimeVersion cgroupDriver failSwapOn apiserverPort etcdClientPort podCIDR serviceCIDR; do
  value="$(kubectl -n starfleet get configmap readiness-review -o go-template="{{index .data \"$key\"}}" 2>/dev/null || true)"
  case "$value" in
    ""|"<no value>")
      echo "FAIL: key $key is missing or empty"; status=1 ;;
    unix:///var/run/dockershim.sock|docker://19.3.0|cgroupfs-legacy|unknown|8080|4001|192.168.0.0/16|10.0.0.0/8)
      echo "FAIL: key $key still holds the stale value '$value'"; status=1 ;;
  esac
done

[ "$status" -eq 0 ] && echo "PASS: readiness-review has eight keys and no stale value"
exit "$status"
