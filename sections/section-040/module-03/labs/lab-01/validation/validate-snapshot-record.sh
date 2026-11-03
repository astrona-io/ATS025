#!/usr/bin/env bash
# Check: snapshotRevision and snapshotTotalKeys equal the values etcdutl reads from the snapshot file.
set -uo pipefail

record_value() {
  kubectl -n starfleet get configmap etcd-recovery -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true
}

# compare KEY EXPECTED : prints PASS or FAIL for one key and returns 1 on failure
compare() {
  local actual
  actual="$(record_value "$1")"
  if [ -z "$2" ]; then
    echo "FAIL: could not read the source of $1 from the cluster"
    return 1
  fi
  if [ "$actual" != "$2" ]; then
    echo "FAIL: $1 is '${actual}', the cluster says '${2}'"
    return 1
  fi
  echo "PASS: $1 is ${actual}"
}

etcd_pod() {
  kubectl -n kube-system get pod -l component=etcd -o jsonpath='{.items[0].metadata.name}' 2>/dev/null
}
snapshot_field() {
  # snapshot_field FILE FIELD : reads a number from etcdutl snapshot status JSON
  kubectl -n kube-system exec "$(etcd_pod)" -- etcdutl snapshot status "$1" --write-out=json 2>/dev/null | sed -n "s/.*\"$2\":\([0-9][0-9]*\).*/\1/p"
}

status=0
compare snapshotRevision "$(snapshot_field /tmp/recovery-snapshot.db revision)" || status=1
compare snapshotTotalKeys "$(snapshot_field /tmp/recovery-snapshot.db totalKey)" || status=1
exit "$status"
