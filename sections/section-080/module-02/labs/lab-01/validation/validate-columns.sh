#!/usr/bin/env bash
# Check: kubectl get beacons shows the Channel and Interval columns.
set -uo pipefail

status=0
paths="$(kubectl get crd beacons.training.astrona.io -o jsonpath='{.spec.versions[?(@.name=="v1")].additionalPrinterColumns[*].jsonPath}' 2>/dev/null || true)"
case " $paths " in *" .spec.channel "*) echo "PASS: a column reads .spec.channel" ;; *) echo "FAIL: no printer column reads .spec.channel"; status=1 ;; esac
case " $paths " in *" .spec.interval "*) echo "PASS: a column reads .spec.interval" ;; *) echo "FAIL: no printer column reads .spec.interval"; status=1 ;; esac
header="$(kubectl -n starfleet get beacons 2>/dev/null | head -n 1 || true)"
if echo "$header" | grep -qi 'CHANNEL' && echo "$header" | grep -qi 'INTERVAL'; then
  echo "PASS: kubectl get shows CHANNEL and INTERVAL"
else
  echo "FAIL: header is '${header}'"
  status=1
fi
exit "$status"
