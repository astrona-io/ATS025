#!/usr/bin/env bash
# Check: claim logbook asks for 1Gi ReadWriteOnce from outpost-retain and waits for a consumer.
set -uo pipefail

status=0
if ! kubectl -n starfleet get pvc logbook >/dev/null 2>&1; then
  echo "FAIL: PersistentVolumeClaim logbook does not exist in starfleet"
  exit 1
fi
get() { kubectl -n starfleet get pvc logbook -o "jsonpath=$1" 2>/dev/null; }

[ "$(get '{.spec.storageClassName}')" = "outpost-retain" ] && echo "PASS: storageClassName is outpost-retain" || { echo "FAIL: storageClassName must be outpost-retain"; status=1; }
[ "$(get '{.spec.resources.requests.storage}')" = "1Gi" ] && echo "PASS: the claim requests 1Gi" || { echo "FAIL: the claim must request 1Gi"; status=1; }
[ "$(get '{.spec.accessModes[*]}')" = "ReadWriteOnce" ] && echo "PASS: access mode is ReadWriteOnce" || { echo "FAIL: the only access mode must be ReadWriteOnce"; status=1; }
if [ "$(get '{.status.phase}')" = "Pending" ]; then
  echo "PASS: the claim is Pending, as expected with WaitForFirstConsumer and no pod"
else
  echo "FAIL: the claim should be Pending because no pod uses it (found: $(get '{.status.phase}'))"
  status=1
fi
exit "$status"
