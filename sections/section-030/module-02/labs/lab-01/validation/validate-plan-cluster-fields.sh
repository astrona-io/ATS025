#!/usr/bin/env bash
# Check: the ClusterConfiguration in the plan has the required top-level
# fields. The version must equal the version of the running cluster, so the
# old draft version v1.30.0 fails.
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
running_version="$(printf '%s\n' "$cluster_yaml" | top_field kubernetesVersion)"
if [ -z "$running_version" ]; then
  echo "FAIL: cannot read kubernetesVersion from kubeadm-config"
  exit 1
fi

plan="$(kubectl -n starfleet get configmap kubeadm-plan -o jsonpath='{.data.kubeadm\.yaml}' 2>/dev/null || true)"
doc="$(printf '%s\n' "$plan" | doc_of_kind ClusterConfiguration)"
if [ -z "$doc" ]; then
  echo "FAIL: no ClusterConfiguration document in kubeadm-plan"
  exit 1
fi

fail=0
expect_field() {
  local name="$1" expected="$2" actual
  actual="$(printf '%s\n' "$doc" | top_field "$name")"
  if [ "$actual" != "$expected" ]; then
    echo "FAIL: ClusterConfiguration ${name} is '${actual}', expected '${expected}'"
    fail=1
  fi
}
expect_field clusterName outpost
expect_field kubernetesVersion "$running_version"
expect_field controlPlaneEndpoint outpost-api.example.test:6443

if [ "$fail" -eq 0 ]; then
  echo "PASS: ClusterConfiguration has clusterName, kubernetesVersion ${running_version} and controlPlaneEndpoint"
fi
exit "$fail"
