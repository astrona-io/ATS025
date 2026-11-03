#!/usr/bin/env bash
# Check: control-plane-ports exists with six numeric keys and none holds a value
# from the outdated record. Rejects deleting the ConfigMap.
set -uo pipefail

if ! kubectl -n starfleet get configmap control-plane-ports >/dev/null 2>&1; then
  echo "FAIL: ConfigMap control-plane-ports not found in namespace starfleet"
  exit 1
fi

status=0
for key in apiserver etcdClient etcdPeer scheduler controllerManager kubelet; do
  value="$(kubectl -n starfleet get configmap control-plane-ports -o go-template="{{index .data \"$key\"}}" 2>/dev/null || true)"
  case "$value" in
    ""|"<no value>")
      echo "FAIL: key $key is missing or empty"; status=1 ;;
    8443|4001|7001|10251|10252|10255|unset)
      echo "FAIL: key $key still holds the outdated value '$value'"; status=1 ;;
    *[!0-9]*)
      echo "FAIL: key $key must be a port number, got '$value'"; status=1 ;;
  esac
done

[ "$status" -eq 0 ] && echo "PASS: control-plane-ports has six numeric keys and no outdated value"
exit "$status"
