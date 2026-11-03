#!/usr/bin/env bash
# Check: apiServerVersion, controllerManagerVersion and schedulerVersion equal the image tags of the static pods.
set -uo pipefail

record_value() {
  kubectl -n starfleet get configmap upgrade-review -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true
}

pod_image_tag() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{.items[0].spec.containers[0].image}' 2>/dev/null | sed 's/@.*//; s/.*://'
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

status=0
compare apiServerVersion "$(pod_image_tag kube-apiserver)" || status=1
compare controllerManagerVersion "$(pod_image_tag kube-controller-manager)" || status=1
compare schedulerVersion "$(pod_image_tag kube-scheduler)" || status=1
exit "$status"
