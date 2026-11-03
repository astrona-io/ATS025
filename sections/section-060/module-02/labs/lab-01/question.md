---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Question

Solve this question on: `terminal`

The starfleet team wants the `scout` workload managed by Helm. A small chart is given below, and the cluster has no Helm release yet. The namespace `starfleet` already holds an unrelated Deployment named `bridge`. Leave it alone.

Save this as `chart/Chart.yaml`:

```yaml
apiVersion: v2
name: scout-chart
description: A small chart for the scout workload
type: application
version: 0.1.0
appVersion: "1.0"
```

Save this as `chart/values.yaml`:

```yaml
replicaCount: 1
logLevel: info
image:
  repository: docker.io/library/busybox
  tag: "1.37.0"
```

Save this as `chart/templates/deployment.yaml`:

```yaml
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
```

Save this as `chart/templates/service.yaml`:

```yaml
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
```

Use the chart to do the following in the namespace `starfleet`:

1. Install the chart as a release named `scout` with the value `replicaCount` set to `2`. This is revision 1.
2. Upgrade the release `scout` with the values `replicaCount` set to `3` and `logLevel` set to `debug`. This is revision 2.
3. Roll the release back to revision 1. Helm records this as a new revision, so the release ends with three revisions, and the cluster runs two replicas with `LOG_LEVEL` set to `info` again.

Create the objects with Helm only. Do not apply the rendered YAML with `kubectl`, and do not change the `bridge` Deployment. `kubectl` and `helm` already point at the cluster.
