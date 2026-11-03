#!/usr/bin/env bash
# Check: etcd-recovery exists in starfleet with all keys, and no key holds a stale value. Rejects deleting the ConfigMap.
set -uo pipefail

record_value() {
  kubectl -n starfleet get configmap etcd-recovery -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true
}

if ! kubectl -n starfleet get configmap etcd-recovery >/dev/null 2>&1; then
  echo "FAIL: ConfigMap etcd-recovery not found in namespace starfleet"
  exit 1
fi

status=0
for key in dataDir memberName trustedCaFile peerUrl dataHostPath certHostPath snapshotRevision snapshotTotalKeys; do
  value="$(record_value "$key")"
  if [ -z "$value" ] || [ "$value" = "<no value>" ]; then
    echo "FAIL: key $key is missing or empty"
    status=1
    continue
  fi
  case "$value" in
    /var/lib/old-etcd|old-member|/etc/old/ca.crt|https://10.0.0.1:2380|/etc/old/pki|"1"|1|unset)
      echo "FAIL: key $key still holds the stale value '$value'"
      status=1
      ;;
  esac
done

[ "$status" -eq 0 ] && echo "PASS: etcd-recovery has eight keys and no stale value"
exit "$status"
