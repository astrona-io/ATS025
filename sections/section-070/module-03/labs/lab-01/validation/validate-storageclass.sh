#!/usr/bin/env bash
# Check: StorageClass outpost-retain uses the cluster provisioner with Retain, WaitForFirstConsumer and expansion.
set -uo pipefail

status=0
if ! kubectl get storageclass outpost-retain >/dev/null 2>&1; then
  echo "FAIL: StorageClass outpost-retain does not exist"
  exit 1
fi
get() { kubectl get storageclass outpost-retain -o "jsonpath=$1" 2>/dev/null; }
default_provisioner="$(kubectl get storageclass standard -o jsonpath='{.provisioner}' 2>/dev/null)"

if [ -n "$default_provisioner" ] && [ "$(get '{.provisioner}')" = "$default_provisioner" ]; then
  echo "PASS: provisioner is $default_provisioner"
else
  echo "FAIL: provisioner must be the provisioner of the standard class ($default_provisioner)"
  status=1
fi
if [ "$(get '{.reclaimPolicy}')" = "Retain" ]; then
  echo "PASS: reclaimPolicy is Retain"
else
  echo "FAIL: reclaimPolicy must be Retain"
  status=1
fi
if [ "$(get '{.volumeBindingMode}')" = "WaitForFirstConsumer" ]; then
  echo "PASS: volumeBindingMode is WaitForFirstConsumer"
else
  echo "FAIL: volumeBindingMode must be WaitForFirstConsumer"
  status=1
fi
if [ "$(get '{.allowVolumeExpansion}')" = "true" ]; then
  echo "PASS: allowVolumeExpansion is true"
else
  echo "FAIL: allowVolumeExpansion must be true"
  status=1
fi
exit "$status"
