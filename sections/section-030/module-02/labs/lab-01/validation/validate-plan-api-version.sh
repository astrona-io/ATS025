#!/usr/bin/env bash
# Check: the plan file in ConfigMap kubeadm-plan uses the v1beta4 API version in
# every document and has both an InitConfiguration and a ClusterConfiguration.
# Rejects the draft that still uses v1beta3.
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
if [ -z "$plan" ]; then
  echo "FAIL: ConfigMap kubeadm-plan in starfleet has no key kubeadm.yaml"
  exit 1
fi

fail=0
if printf '%s\n' "$plan" | grep -Eq 'kubeadm\.k8s\.io/v1beta3'; then
  echo "FAIL: the file still uses kubeadm.k8s.io/v1beta3"
  fail=1
fi
for kind in InitConfiguration ClusterConfiguration; do
  doc="$(printf '%s\n' "$plan" | doc_of_kind "$kind")"
  if [ -z "$doc" ]; then
    echo "FAIL: no ${kind} document found"
    fail=1
    continue
  fi
  api="$(printf '%s\n' "$doc" | top_field apiVersion)"
  if [ "$api" != "kubeadm.k8s.io/v1beta4" ]; then
    echo "FAIL: ${kind} has apiVersion '${api}', expected kubeadm.k8s.io/v1beta4"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: kubeadm-plan has InitConfiguration and ClusterConfiguration at v1beta4"
fi
exit "$fail"
