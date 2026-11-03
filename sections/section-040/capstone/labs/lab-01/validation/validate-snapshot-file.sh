#!/usr/bin/env bash
# Check: A valid snapshot with a revision and keys exists at /tmp/lifecycle-snapshot.db in the etcd pod.
set -uo pipefail

etcd_pod() {
  kubectl -n kube-system get pod -l component=etcd -o jsonpath='{.items[0].metadata.name}' 2>/dev/null
}
snapshot_field() {
  # snapshot_field FILE FIELD : reads a number from etcdutl snapshot status JSON
  kubectl -n kube-system exec "$(etcd_pod)" -- etcdutl snapshot status "$1" --write-out=json 2>/dev/null | sed -n "s/.*\"$2\":\([0-9][0-9]*\).*/\1/p"
}

revision="$(snapshot_field /tmp/lifecycle-snapshot.db revision)"
keys="$(snapshot_field /tmp/lifecycle-snapshot.db totalKey)"
if [ -z "$revision" ] || [ -z "$keys" ]; then
  echo "FAIL: etcdutl could not read a snapshot at /tmp/lifecycle-snapshot.db in the etcd pod"
  exit 1
fi
if [ "$revision" -le 0 ] || [ "$keys" -le 0 ]; then
  echo "FAIL: the snapshot has revision ${revision} and ${keys} keys"
  exit 1
fi
echo "PASS: snapshot has revision ${revision} and ${keys} keys"
