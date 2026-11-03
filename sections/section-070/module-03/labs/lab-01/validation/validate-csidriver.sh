#!/usr/bin/env bash
# Check: CSIDriver logbook.csi.astrona.io has the requested fields.
set -uo pipefail

status=0
name="logbook.csi.astrona.io"
if ! kubectl get csidriver "$name" >/dev/null 2>&1; then
  echo "FAIL: CSIDriver $name does not exist"
  exit 1
fi
get() { kubectl get csidriver "$name" -o "jsonpath=$1" 2>/dev/null; }

[ "$(get '{.spec.attachRequired}')" = "false" ] && echo "PASS: attachRequired is false" || { echo "FAIL: attachRequired must be false"; status=1; }
[ "$(get '{.spec.podInfoOnMount}')" = "true" ] && echo "PASS: podInfoOnMount is true" || { echo "FAIL: podInfoOnMount must be true"; status=1; }
[ "$(get '{.spec.fsGroupPolicy}')" = "File" ] && echo "PASS: fsGroupPolicy is File" || { echo "FAIL: fsGroupPolicy must be File"; status=1; }
modes="$(get '{range .spec.volumeLifecycleModes[*]}{@}{"\n"}{end}' | sort | tr '\n' ' ')"
if [ "$modes" = "Ephemeral Persistent " ]; then
  echo "PASS: volumeLifecycleModes are Persistent and Ephemeral"
else
  echo "FAIL: volumeLifecycleModes must be exactly Persistent and Ephemeral (found: ${modes:-none})"
  status=1
fi
exit "$status"
