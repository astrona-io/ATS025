---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Install A Chart With Explicit Values

Install an existing bundled chart and verify release ownership and effective values. Use the isolated `starfleet` environment to verify the result.

## Objective

Install an existing bundled chart and verify release ownership and effective values.

## Starting state

The existing chart is supplied in full below. Save its three files in a local `chart` directory before inspecting or installing it. Release `demo` has not been installed.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-025-lab-060-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-025-lab-060-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


Save this as `chart/Chart.yaml`:

```yaml
apiVersion: v2
name: probe-chart
version: 0.1.0
appVersion: v1
type: application
```

Save this as `chart/values.yaml`:

```yaml
replicaCount: 1
version: v1
```

Save this as `chart/templates/application.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helm-probe
  namespace: {{ .Release.Namespace }}
  labels:
    app.kubernetes.io/managed-by: Helm
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: helm-probe
  template:
    metadata:
      labels:
        app: helm-probe
    spec:
      containers:
      - name: probe
        image: docker.io/library/python:3.13-alpine
        command: [python, /app/server.py]
        env:
        - name: VERSION
          value: {{ .Values.version | quote }}
        ports:
        - name: http
          containerPort: 8080
        readinessProbe:
          httpGet:
            path: /ready
            port: http
        volumeMounts:
        - name: app
          mountPath: /app
      volumes:
      - name: app
        configMap:
          name: probe-code
---
apiVersion: v1
kind: Service
metadata:
  name: helm-probe
  namespace: {{ .Release.Namespace }}
spec:
  selector:
    app: helm-probe
  ports:
  - port: 80
    targetPort: http
```

## Required result

Use the provided `probe-chart` chart, release `demo` in `starfleet`, and two replicas. Install version one and retain a deployed Helm release with effective value `replicaCount: 2`. The client must reach the `helm-probe` Service. Do not replace Helm ownership with a manually applied Deployment.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.
