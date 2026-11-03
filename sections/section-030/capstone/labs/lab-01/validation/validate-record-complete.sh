#!/usr/bin/env bash
# Check: init-review exists with eight keys and none holds a stale value.
set -uo pipefail

if ! kubectl -n starfleet get configmap init-review >/dev/null 2>&1; then
  echo "FAIL: ConfigMap init-review not found in namespace starfleet"
  exit 1
fi

status=0
for key in kubernetesVersion podSubnet certificatesDir apiServerEndpoint joinGroup autoApproveRole workerNodeName clusterDNS; do
  value="$(kubectl -n starfleet get configmap init-review -o go-template="{{index .data \"$key\"}}" 2>/dev/null || true)"
  case "$value" in
    ""|"<no value>")
      echo "FAIL: key $key is missing or empty"; status=1 ;;
    v1.20.0|192.168.0.0/16|/var/lib/kubernetes/certs|https://old-api.example.test:6443|system:bootstrappers|system:node-bootstrapper|old-worker|10.0.0.10)
      echo "FAIL: key $key still holds the stale value '$value'"; status=1 ;;
  esac
done

[ "$status" -eq 0 ] && echo "PASS: init-review has eight keys and no stale value"
exit "$status"
