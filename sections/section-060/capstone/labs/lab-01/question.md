---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Question

Solve this question on: `terminal`

Before the starfleet team adopted Helm, an engineer applied the `relay` component by hand. In the namespace `starfleet` there is a Deployment `relay` and a Service `relay` that carry no Helm metadata. The outpost team now needs a customized copy of the same component in the namespace `outpost`. The namespace `starfleet` also holds an unrelated Deployment `bridge`.

The chart for the component is below.

Save this as `chart/Chart.yaml`:

```yaml
apiVersion: v2
name: relay-chart
description: A small chart for the relay workload
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
```

Save this as `chart/templates/service.yaml`:

```yaml
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
```

Do the following:

1. Bring the existing `relay` Deployment and Service under a Helm release named `relay` in `starfleet`. The release must use the chart above and record the values `replicaCount: 2` and `logLevel: debug`. The existing objects must be adopted: they must keep their identity and must not be deleted and recreated.
2. The Deployment `relay` must end with two available replicas and `LOG_LEVEL` set to `debug`, and both objects must carry the Helm ownership metadata of the release.
3. Create the outpost copy without a Helm release. Render the chart with the release name `relay-outpost` for the namespace `outpost`, use the rendered YAML as a Kustomize base, and write an overlay that sets four replicas, adds the label `tier: outpost` to the pod template and sets the memory limit `64Mi` on the container `relay`. Apply the overlay with `kubectl apply -k`.
4. The Service `relay-outpost` must have endpoints.
5. Do not change the `bridge` Deployment, and do not create a Helm release for the outpost copy.

`kubectl` and `helm` already point at the cluster.
