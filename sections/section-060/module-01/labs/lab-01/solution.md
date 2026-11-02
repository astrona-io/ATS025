---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Install A Chart With Explicit Values Solution

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-025-lab-060-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-025-lab-060-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The existing chart is supplied in full below. Save its three files in a local `chart` directory before inspecting or installing it. Release `demo` has not been installed.

Inspect the relevant evidence:

```sh
helm list -n starfleet
helm show values chart
```

Helm renders a chart with supplied values and records a release. Inspect the existing chart before changing values. A ready Deployment alone does not establish that Helm installed it, so the grader also checks release status and effective values.


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

Apply the required change:

```sh
helm upgrade --install demo chart -n starfleet --set replicaCount=2 --set version=v1 --wait --timeout 3m
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet rollout status deployment/helm-probe --timeout=180s
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://helm-probe/
```

Use the provided `probe-chart` chart, release `demo` in `starfleet`, and two replicas. Install version one and retain a deployed Helm release with effective value `replicaCount: 2`. The client must reach the `helm-probe` Service. Do not replace Helm ownership with a manually applied Deployment.

After recording the result, remove this independent lab with `astrona destroy ats-025-lab-060-01-01`.

## Common pitfalls

> [!WARNING]
> Inspect the existing chart values before installation. A manually applied Deployment does not create Helm release ownership. Keep the release name and namespace fixed.
