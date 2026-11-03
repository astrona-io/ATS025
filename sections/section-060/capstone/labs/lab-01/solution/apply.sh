#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`. Needs helm on the host.
set -euo pipefail

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/chart/templates" "$work/base" "$work/overlay"

cat > "$work/chart/Chart.yaml" <<'CHART'
apiVersion: v2
name: relay-chart
description: A small chart for the relay workload
type: application
version: 0.1.0
appVersion: "1.0"
CHART

cat > "$work/chart/values.yaml" <<'VALUES'
replicaCount: 1
logLevel: info
image:
  repository: docker.io/library/busybox
  tag: "1.37.0"
VALUES

cat > "$work/chart/templates/deployment.yaml" <<'TEMPLATE'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
  namespace: {{ .Release.Namespace }}
  labels:
    app: relay
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: relay
  template:
    metadata:
      labels:
        app: relay
    spec:
      containers:
        - name: relay
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          command: ["sh", "-c", "echo relay level=$LOG_LEVEL; sleep 3600"]
          env:
            - name: LOG_LEVEL
              value: {{ .Values.logLevel | quote }}
TEMPLATE

cat > "$work/chart/templates/service.yaml" <<'TEMPLATE'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}
  namespace: {{ .Release.Namespace }}
  labels:
    app: relay
spec:
  selector:
    app: relay
  ports:
    - name: http
      port: 8080
      targetPort: 8080
TEMPLATE

# Adopt the hand-applied objects into release relay.
for kind in deployment service; do
  kubectl -n starfleet label "$kind" relay app.kubernetes.io/managed-by=Helm --overwrite
  kubectl -n starfleet annotate "$kind" relay meta.helm.sh/release-name=relay meta.helm.sh/release-namespace=starfleet --overwrite
done
helm install relay "$work/chart" --namespace starfleet --set replicaCount=2 --set logLevel=debug --wait --timeout 120s

# Render a second copy and customize it with Kustomize.
helm template relay-outpost "$work/chart" --namespace outpost > "$work/base/relay.yaml"
cat > "$work/base/kustomization.yaml" <<'BASE'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - relay.yaml
BASE
cat > "$work/overlay/limits.yaml" <<'PATCH'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay-outpost
spec:
  replicas: 4
  template:
    spec:
      containers:
        - name: relay
          resources:
            limits:
              memory: 64Mi
PATCH
cat > "$work/overlay/kustomization.yaml" <<'OVERLAY'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../base
namespace: outpost
labels:
  - pairs:
      tier: outpost
    includeTemplates: true
patches:
  - path: limits.yaml
OVERLAY
kubectl apply -k "$work/overlay"
kubectl -n outpost rollout status deployment/relay-outpost --timeout=120s
echo "[solution] Applied."
