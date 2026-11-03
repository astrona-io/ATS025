#!/usr/bin/env bash
# Check: the status subresource is enabled on v1.
set -uo pipefail

val="$(kubectl get crd beacons.training.astrona.io -o jsonpath='{.spec.versions[?(@.name=="v1")].subresources}' 2>/dev/null || true)"
case "$val" in
  *'"status"'*) echo "PASS: the status subresource is enabled"; exit 0 ;;
  *) echo "FAIL: subresources of v1 is '${val}', status is missing"; exit 1 ;;
esac
