#!/usr/bin/env bash
# Check: The API server is ready and the live etcd still uses /var/lib/etcd (no restore over the live data).
set -uo pipefail

etcd_flag() {
  kubectl -n kube-system get pod -l component=etcd -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' 2>/dev/null | sed -n "s/^--$1=//p" | head -n 1
}
etcd_volume_path() {
  kubectl -n kube-system get pod -l component=etcd -o jsonpath="{.items[0].spec.volumes[?(@.name==\"$1\")].hostPath.path}" 2>/dev/null
}

status=0
if [ "$(kubectl get --raw=/readyz 2>/dev/null)" != "ok" ]; then
  echo "FAIL: the API server is not ready"
  status=1
else
  echo "PASS: the API server is ready"
fi
if [ "$(etcd_flag data-dir)" != "/var/lib/etcd" ] || [ "$(etcd_volume_path etcd-data)" != "/var/lib/etcd" ]; then
  echo "FAIL: the live etcd does not use /var/lib/etcd any more"
  status=1
else
  echo "PASS: the live etcd data directory is unchanged"
fi
exit "$status"
