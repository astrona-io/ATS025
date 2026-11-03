#!/usr/bin/env bash
# Check: the status subresource and the printer columns exist.
set -uo pipefail

status=0
crd=missions.training.astrona.io
sub="$(kubectl get crd "$crd" -o jsonpath='{.spec.versions[?(@.name=="v1")].subresources}' 2>/dev/null || true)"
case "$sub" in *'"status"'*) echo "PASS: the status subresource is enabled" ;; *) echo "FAIL: the status subresource is missing"; status=1 ;; esac
paths="$(kubectl get crd "$crd" -o jsonpath='{.spec.versions[?(@.name=="v1")].additionalPrinterColumns[*].jsonPath}' 2>/dev/null || true)"
case " $paths " in *" .spec.phase "*) echo "PASS: a column reads .spec.phase" ;; *) echo "FAIL: no column reads .spec.phase"; status=1 ;; esac
case " $paths " in *" .spec.crewSize "*) echo "PASS: a column reads .spec.crewSize" ;; *) echo "FAIL: no column reads .spec.crewSize"; status=1 ;; esac
exit "$status"
