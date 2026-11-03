#!/usr/bin/env bash
# Check: podSubnet and serviceSubnet are nested under networking with the
# required values. Rejects a top-level podSubnet (an unknown field) and the
# ranges copied from the running cluster.
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
doc="$(printf '%s\n' "$plan" | doc_of_kind ClusterConfiguration)"
if [ -z "$doc" ]; then
  echo "FAIL: no ClusterConfiguration document in kubeadm-plan"
  exit 1
fi

fail=0
for name in podSubnet serviceSubnet; do
  if printf '%s\n' "$doc" | grep -Eq "^${name}:"; then
    echo "FAIL: ${name} is at the top level; it belongs under networking"
    fail=1
  fi
done

pod="$(printf '%s\n' "$doc" | networking_field podSubnet)"
service="$(printf '%s\n' "$doc" | networking_field serviceSubnet)"
if [ "$pod" != "10.200.0.0/16" ]; then
  echo "FAIL: networking.podSubnet is '${pod}', expected 10.200.0.0/16"
  fail=1
fi
if [ "$service" != "10.201.0.0/16" ]; then
  echo "FAIL: networking.serviceSubnet is '${service}', expected 10.201.0.0/16"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: networking.podSubnet and networking.serviceSubnet are set correctly"
fi
exit "$fail"
