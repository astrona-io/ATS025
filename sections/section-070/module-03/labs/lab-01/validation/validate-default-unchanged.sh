#!/usr/bin/env bash
# Check: standard stays the only default StorageClass.
set -uo pipefail

defaults="$(kubectl get storageclass -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{"\n"}{end}' 2>/dev/null)"
if [ "$defaults" = "standard" ]; then
  echo "PASS: standard is the only default class"
  exit 0
fi
echo "FAIL: expected standard as the only default StorageClass, found: ${defaults:-none}"
exit 1
