#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

pod_cidr="$(kubectl get nodes -o jsonpath='{.items[0].spec.podCIDR}')"
shuttle_ip="$(kubectl -n starfleet get pod shuttle -o jsonpath='{.status.podIP}')"
cluster_ip="$(kubectl -n starfleet get service probe -o jsonpath='{.spec.clusterIP}')"
ready_count="$(kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe \
  -o jsonpath='{range .items[*].endpoints[?(@.conditions.ready==true)]}{.addresses[0]}{"\n"}{end}' | grep -c .)"

kubectl -n starfleet create configmap network-report \
  --from-literal=podCIDR="$pod_cidr" \
  --from-literal=shuttleIP="$shuttle_ip" \
  --from-literal=probeClusterIP="$cluster_ip" \
  --from-literal=readyEndpoints="$ready_count" \
  --from-literal=dnsName=probe.starfleet.svc.cluster.local \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<'POLICY'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: starfleet
spec:
  podSelector: {}
  policyTypes:
    - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-ingress
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: shuttle
      ports:
        - protocol: TCP
          port: 8080
POLICY
echo "[solution] Applied."
