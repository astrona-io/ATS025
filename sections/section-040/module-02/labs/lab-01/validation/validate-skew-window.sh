#!/usr/bin/env bash
# Check: oldestKubelet and nextMinor follow from the API server minor version, and skewVerdict is right for a kubelet at v1.31.4.
set -uo pipefail

record_value() {
  kubectl -n starfleet get configmap upgrade-review -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true
}

pod_image_tag() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{.items[0].spec.containers[0].image}' 2>/dev/null | sed 's/@.*//; s/.*://'
}

minor_of() {
  printf '%s\n' "$1" | sed -n 's/^v\{0,1\}1\.\([0-9][0-9]*\).*/\1/p'
}

# compare KEY EXPECTED : prints PASS or FAIL for one key and returns 1 on failure
compare() {
  local actual
  actual="$(record_value "$1")"
  if [ -z "$2" ]; then
    echo "FAIL: could not read the source of $1 from the cluster"
    return 1
  fi
  if [ "$actual" != "$2" ]; then
    echo "FAIL: $1 is '${actual}', the cluster says '${2}'"
    return 1
  fi
  echo "PASS: $1 is ${actual}"
}

api_minor="$(minor_of "$(pod_image_tag kube-apiserver)")"
if [ -z "$api_minor" ]; then
  echo "FAIL: could not read the API server version"
  exit 1
fi
if [ $((31)) -ge $((api_minor - 3)) ]; then verdict=supported; else verdict=unsupported; fi
status=0
compare oldestKubelet "1.$((api_minor - 3))" || status=1
compare nextMinor "1.$((api_minor + 1))" || status=1
compare skewVerdict "$verdict" || status=1
exit "$status"
