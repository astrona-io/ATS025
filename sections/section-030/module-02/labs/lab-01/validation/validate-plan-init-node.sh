#!/usr/bin/env bash
# Check: the InitConfiguration names the first node, and the running cluster's
# own kubeadm-config ConfigMap is untouched (the plan is a separate file).
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

plan="$(kubectl -n starfleet get configmap kubeadm-plan -o jsonpath='{.data.kubeadm\.yaml}' 2>/dev/null || true)"
doc="$(printf '%s\n' "$plan" | doc_of_kind InitConfiguration)"
if [ -z "$doc" ]; then
  echo "FAIL: no InitConfiguration document in kubeadm-plan"
  exit 1
fi

name="$(printf '%s\n' "$doc" | awk '
  /^nodeRegistration:[ \t]*$/ { inside = 1; next }
  /^[^ \t#]/ { inside = 0 }
  inside && /^[ \t]+name:/ { value = $0; sub(/^[^:]*:[ \t]*/, "", value); gsub(/["\047]/, "", value); sub(/[ \t]+$/, "", value); print value; exit }')"

fail=0
if [ "$name" != "outpost-cp-1" ]; then
  echo "FAIL: nodeRegistration.name is '${name}', expected outpost-cp-1"
  fail=1
fi

running="$(kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' 2>/dev/null || true)"
if ! printf '%s\n' "$running" | grep -Eq '^clusterName:'; then
  echo "FAIL: kubeadm-config in kube-system no longer holds a ClusterConfiguration"
  fail=1
fi
if printf '%s\n' "$running" | grep -Eq '^[[:space:]]*(podSubnet|serviceSubnet):[[:space:]]*10\.20[01]\.'; then
  echo "FAIL: the running cluster's kubeadm-config was edited; change only the kubeadm-plan ConfigMap"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: InitConfiguration names outpost-cp-1 and kubeadm-config is unchanged"
fi
exit "$fail"
