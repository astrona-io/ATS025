#!/usr/bin/env bash
# Check: pki-map exists with eight keys and none holds a stale value.
set -uo pipefail

if ! kubectl -n starfleet get configmap pki-map >/dev/null 2>&1; then
  echo "FAIL: ConfigMap pki-map not found in namespace starfleet"
  exit 1
fi

status=0
for key in apiserverServingCert apiserverKubeletClientCert apiserverEtcdClientCert saPublicKey saSigningKey clusterSigningCert etcdPeerCert schedulerKubeconfig; do
  value="$(kubectl -n starfleet get configmap pki-map -o go-template="{{index .data \"$key\"}}" 2>/dev/null || true)"
  case "$value" in
    ""|"<no value>")
      echo "FAIL: key $key is missing or empty"; status=1 ;;
    /etc/kubernetes/pki/old-*|/etc/kubernetes/old-*)
      echo "FAIL: key $key still holds the stale value '$value'"; status=1 ;;
  esac
done

[ "$status" -eq 0 ] && echo "PASS: pki-map has eight keys and no stale value"
exit "$status"
