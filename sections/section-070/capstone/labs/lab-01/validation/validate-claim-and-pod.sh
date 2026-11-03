#!/usr/bin/env bash
# Check: claim probe-data exists and pod recorder mounts it at /data.
set -uo pipefail

status=0
if ! kubectl -n starfleet get pvc probe-data >/dev/null 2>&1; then
  echo "FAIL: PersistentVolumeClaim probe-data does not exist in starfleet"
  exit 1
fi
pvc() { kubectl -n starfleet get pvc probe-data -o "jsonpath=$1" 2>/dev/null; }

[ "$(pvc '{.spec.storageClassName}')" = "starfleet-data" ] && echo "PASS: the claim uses starfleet-data" || { echo "FAIL: storageClassName must be starfleet-data"; status=1; }
[ "$(pvc '{.spec.resources.requests.storage}')" = "2Gi" ] && echo "PASS: the claim requests 2Gi" || { echo "FAIL: the claim must request 2Gi"; status=1; }
[ "$(pvc '{.spec.accessModes[*]}')" = "ReadWriteOnce" ] && echo "PASS: access mode is ReadWriteOnce" || { echo "FAIL: the only access mode must be ReadWriteOnce"; status=1; }

if ! kubectl -n starfleet get pod recorder >/dev/null 2>&1; then
  echo "FAIL: pod recorder does not exist in starfleet"
  exit 1
fi
pod() { kubectl -n starfleet get pod recorder -o "jsonpath=$1" 2>/dev/null; }
[ "$(pod '{.metadata.labels.app}')" = "recorder" ] && echo "PASS: pod recorder has the label app=recorder" || { echo "FAIL: pod recorder needs the label app=recorder"; status=1; }
[ "$(pod '{.spec.volumes[?(@.persistentVolumeClaim.claimName=="probe-data")].name}')" != "" ] && echo "PASS: the pod uses the claim probe-data" || { echo "FAIL: the pod must use the claim probe-data as a volume"; status=1; }
volume_name="$(pod '{.spec.volumes[?(@.persistentVolumeClaim.claimName=="probe-data")].name}')"
mount_path="$(pod "{.spec.containers[0].volumeMounts[?(@.name==\"$volume_name\")].mountPath}")"
[ -n "$volume_name" ] && [ "$mount_path" = "/data" ] && echo "PASS: the claim is mounted at /data" || { echo "FAIL: the claim must be mounted at /data in the first container"; status=1; }
exit "$status"
