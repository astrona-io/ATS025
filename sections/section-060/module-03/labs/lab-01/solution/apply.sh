#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`. Uses the Kustomize built into kubectl.
set -euo pipefail

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/base" "$work/overlays/outpost"

cat > "$work/base/kustomization.yaml" <<'BASE'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
configMapGenerator:
  - name: shuttle-config
    literals:
      - MODE=idle
BASE

cat > "$work/base/deployment.yaml" <<'BASE'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shuttle
spec:
  replicas: 1
  selector:
    matchLabels:
      app: shuttle
  template:
    metadata:
      labels:
        app: shuttle
    spec:
      containers:
        - name: shuttle
          image: shuttle
          command: ["sh", "-c", "echo mode=$MODE; sleep 3600"]
          envFrom:
            - configMapRef:
                name: shuttle-config
          ports:
            - name: http
              containerPort: 8080
BASE

cat > "$work/base/service.yaml" <<'BASE'
apiVersion: v1
kind: Service
metadata:
  name: shuttle
spec:
  selector:
    app: shuttle
  ports:
    - name: http
      port: 80
      targetPort: http
BASE

cat > "$work/overlays/outpost/limits.yaml" <<'PATCH'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shuttle
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: shuttle
          resources:
            limits:
              cpu: 100m
              memory: 64Mi
PATCH

cat > "$work/overlays/outpost/kustomization.yaml" <<'OVERLAY'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
namespace: outpost
namePrefix: outpost-
labels:
  - pairs:
      environment: outpost
    includeSelectors: true
    includeTemplates: true
images:
  - name: shuttle
    newName: docker.io/library/busybox
    newTag: 1.37.0
configMapGenerator:
  - name: shuttle-config
    behavior: merge
    literals:
      - MODE=patrol
patches:
  - path: limits.yaml
  - target:
      kind: Service
      name: shuttle
    patch: |-
      - op: replace
        path: /spec/ports/0/port
        value: 8080
OVERLAY

kubectl apply -k "$work/overlays/outpost"
kubectl -n outpost rollout status deployment/outpost-shuttle --timeout=120s
echo "[solution] Applied."
