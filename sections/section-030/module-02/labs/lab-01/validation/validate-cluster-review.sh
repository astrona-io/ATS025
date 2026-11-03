#!/usr/bin/env bash
# Check: ConfigMap cluster-review in starfleet records the values of the
# running cluster, read from the kubeadm-config ConfigMap. The expected values
# are recomputed here, so a copied example value fails.
set -uo pipefail

# Helpers: plain text parsing of YAML, because the grader has no YAML parser.
# doc_of_kind KIND: print the YAML document whose "kind:" line is KIND.
doc_of_kind() {
  awk -v want="$1" '
    function flush() { if (found) printf "%s", buffer; buffer = ""; found = 0 }
    /^---[ \t]*$/ { flush(); next }
    {
      buffer = buffer $0 "\n"
      line = $0
      gsub(/["\047]/, "", line)
      sub(/[ \t]+#.*$/, "", line)
      if (line ~ ("^kind:[ \t]*" want "[ \t]*$")) found = 1
    }
    END { flush() }'
}
# top_field NAME: value of an unindented "NAME:" line on stdin.
top_field() {
  grep -E "^$1:" | head -1 | sed -E "s/^[^:]*:[[:space:]]*//; s/[\"']//g; s/[[:space:]]+#.*\$//; s/[[:space:]]+\$//"
}
# networking_field NAME: value of an indented NAME under the top-level networking block.
networking_field() {
  awk -v key="$1" '
    /^networking:[ \t]*$/ { inside = 1; next }
    /^[^ \t#]/ { inside = 0 }
    inside && $0 ~ ("^[ \t]+" key ":") {
      value = $0
      sub(/^[^:]*:[ \t]*/, "", value)
      gsub(/["\047]/, "", value)
      sub(/[ \t]+#.*$/, "", value)
      sub(/[ \t]+$/, "", value)
      print value
      exit
    }'
}

cluster_yaml="$(kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' 2>/dev/null || true)"
if [ -z "$cluster_yaml" ]; then
  echo "FAIL: cannot read ClusterConfiguration from kubeadm-config in kube-system"
  exit 1
fi

expected_version="$(printf '%s\n' "$cluster_yaml" | top_field kubernetesVersion)"
expected_name="$(printf '%s\n' "$cluster_yaml" | top_field clusterName)"
expected_pod="$(printf '%s\n' "$cluster_yaml" | networking_field podSubnet)"
expected_service="$(printf '%s\n' "$cluster_yaml" | networking_field serviceSubnet)"

if ! kubectl -n starfleet get configmap cluster-review >/dev/null 2>&1; then
  echo "FAIL: ConfigMap cluster-review does not exist in namespace starfleet"
  exit 1
fi

fail=0
check_key() {
  local key="$1" expected="$2" actual
  actual="$(kubectl -n starfleet get configmap cluster-review -o jsonpath="{.data.${key}}" 2>/dev/null || true)"
  actual="$(printf '%s' "$actual" | tr -d '[:space:]')"
  if [ -z "$expected" ]; then
    echo "FAIL: could not read the expected value for ${key} from kubeadm-config"
    fail=1
  elif [ "$actual" != "$expected" ]; then
    echo "FAIL: cluster-review key ${key} is '${actual}', expected '${expected}'"
    fail=1
  fi
}
check_key kubernetesVersion "$expected_version"
check_key clusterName "$expected_name"
check_key podSubnet "$expected_pod"
check_key serviceSubnet "$expected_service"

if [ "$fail" -eq 0 ]; then
  echo "PASS: cluster-review matches kubeadm-config (${expected_version}, ${expected_name}, ${expected_pod}, ${expected_service})"
fi
exit "$fail"
