#!/usr/bin/env bash
# Check: Role pod-reader in starfleet has one rule that allows get, list and
# watch on core pods and nothing else.
set -uo pipefail

if ! kubectl -n starfleet get role pod-reader >/dev/null 2>&1; then
  echo "FAIL: Role pod-reader does not exist in starfleet"
  exit 1
fi

fail=0
role="$(kubectl -n starfleet get role pod-reader -o json 2>/dev/null)"

if [ "$(printf '%s' "$role" | jq '.rules | length')" != "1" ]; then
  echo "FAIL: the Role must have exactly one rule"
  fail=1
fi
if [ "$(printf '%s' "$role" | jq -c '.rules[0].apiGroups // []')" != '[""]' ]; then
  echo "FAIL: apiGroups must be [\"\"] (the core group)"
  fail=1
fi
if [ "$(printf '%s' "$role" | jq -c '.rules[0].resources // [] | sort')" != '["pods"]' ]; then
  echo "FAIL: resources must be [\"pods\"] only"
  fail=1
fi
if [ "$(printf '%s' "$role" | jq -c '.rules[0].verbs // [] | sort')" != '["get","list","watch"]' ]; then
  echo "FAIL: verbs must be exactly get, list and watch"
  fail=1
fi
if [ "$(printf '%s' "$role" | jq '[.rules[0].resourceNames // [] | length, (.rules[0].nonResourceURLs // [] | length)] | add')" != "0" ]; then
  echo "FAIL: the rule must not use resourceNames or nonResourceURLs"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: Role pod-reader allows get, list and watch on pods only"
fi
exit "$fail"
