#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`. Needs helm on the host.
set -euo pipefail

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/chart/templates"

cat > "$work/chart/Chart.yaml" <<'CHART'
apiVersion: v2
name: scout-chart
description: A small chart for the scout workload
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
    app: scout
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: scout
      release: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: scout
        release: {{ .Release.Name }}
    spec:
      containers:
        - name: scout
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          command: ["sh", "-c", "echo scout level=$LOG_LEVEL; sleep 3600"]
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
spec:
  selector:
    app: scout
    release: {{ .Release.Name }}
  ports:
    - name: http
      port: 8080
      targetPort: 8080
TEMPLATE

helm install scout "$work/chart" --namespace starfleet --set replicaCount=2 --wait --timeout 120s
helm upgrade scout "$work/chart" --namespace starfleet --set replicaCount=3 --set logLevel=debug --wait --timeout 120s
helm rollback scout 1 --namespace starfleet --wait --timeout 120s
echo "[solution] Applied."
