#!/usr/bin/env bash
# Check: ConfigMap network-report records the probe Service address, ready endpoints and DNS name.
set -uo pipefail

status=0
report() { kubectl -n starfleet get configmap network-report -o "jsonpath={.data.$1}" 2>/dev/null; }

if ! kubectl -n starfleet get configmap network-report >/dev/null 2>&1; then
  echo "FAIL: ConfigMap network-report does not exist in starfleet"
  exit 1
fi

cluster_ip="$(kubectl -n starfleet get service probe -o jsonpath='{.spec.clusterIP}' 2>/dev/null)"
ready_count="$(kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe \
  -o jsonpath='{range .items[*].endpoints[?(@.conditions.ready==true)]}{.addresses[0]}{"\n"}{end}' 2>/dev/null | grep -c .)"

if [ "$(report probeClusterIP)" = "$cluster_ip" ] && [ -n "$cluster_ip" ]; then
  echo "PASS: probeClusterIP is $cluster_ip"
else
  echo "FAIL: probeClusterIP must be the cluster IP of Service probe ($cluster_ip)"
  status=1
fi
if [ "$(report readyEndpoints)" = "$ready_count" ] && [ "$ready_count" -gt 0 ]; then
  echo "PASS: readyEndpoints is $ready_count"
else
  echo "FAIL: readyEndpoints must be the number of ready endpoints in the EndpointSlice ($ready_count)"
  status=1
fi
if [ "$(report dnsName)" = "probe.starfleet.svc.cluster.local" ]; then
  echo "PASS: dnsName is the fully qualified Service name"
else
  echo "FAIL: dnsName must be probe.starfleet.svc.cluster.local"
  status=1
fi
exit "$status"
