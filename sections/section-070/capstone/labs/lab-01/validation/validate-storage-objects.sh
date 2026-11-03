#!/usr/bin/env bash
# Check: StorageClass starfleet-data and CSIDriver data.csi.astrona.io have the requested fields.
set -uo pipefail

status=0
if ! kubectl get storageclass starfleet-data >/dev/null 2>&1; then
  echo "FAIL: StorageClass starfleet-data does not exist"
  exit 1
fi
sc() { kubectl get storageclass starfleet-data -o "jsonpath=$1" 2>/dev/null; }
default_provisioner="$(kubectl get storageclass standard -o jsonpath='{.provisioner}' 2>/dev/null)"

[ -n "$default_provisioner" ] && [ "$(sc '{.provisioner}')" = "$default_provisioner" ] && echo "PASS: provisioner is $default_provisioner" || { echo "FAIL: provisioner must match the standard class ($default_provisioner)"; status=1; }
[ "$(sc '{.reclaimPolicy}')" = "Retain" ] && echo "PASS: reclaimPolicy is Retain" || { echo "FAIL: reclaimPolicy must be Retain"; status=1; }
[ "$(sc '{.volumeBindingMode}')" = "WaitForFirstConsumer" ] && echo "PASS: volumeBindingMode is WaitForFirstConsumer" || { echo "FAIL: volumeBindingMode must be WaitForFirstConsumer"; status=1; }
[ "$(sc '{.allowVolumeExpansion}')" = "true" ] && echo "PASS: allowVolumeExpansion is true" || { echo "FAIL: allowVolumeExpansion must be true"; status=1; }
defaults="$(kubectl get storageclass -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{"\n"}{end}' 2>/dev/null)"
[ "$defaults" = "standard" ] && echo "PASS: standard is still the only default class" || { echo "FAIL: standard must stay the only default class (found: ${defaults:-none})"; status=1; }

if ! kubectl get csidriver data.csi.astrona.io >/dev/null 2>&1; then
  echo "FAIL: CSIDriver data.csi.astrona.io does not exist"
  exit 1
fi
cd_get() { kubectl get csidriver data.csi.astrona.io -o "jsonpath=$1" 2>/dev/null; }
[ "$(cd_get '{.spec.attachRequired}')" = "false" ] && echo "PASS: attachRequired is false" || { echo "FAIL: attachRequired must be false"; status=1; }
[ "$(cd_get '{.spec.podInfoOnMount}')" = "true" ] && echo "PASS: podInfoOnMount is true" || { echo "FAIL: podInfoOnMount must be true"; status=1; }
exit "$status"
