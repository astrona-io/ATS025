---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Apply A Kustomize Base Solution

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-025-lab-060-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-025-lab-060-01-02" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Inspect the relevant evidence:

```sh
kubectl -n starfleet get pods
kubectl -n starfleet get deployment probe -o yaml
```

Kustomize reads a resource list and renders complete Kubernetes objects. The server stores those objects, not the directory layout. Grading verifies the deployed result; author checks separately render the supplied base. Keep the resource definition in the base so the same base can support an overlay.


Save this as `base/deployment-probe.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 2
  selector:
    matchLabels:
      app: probe
      release: probe
  template:
    metadata:
      labels:
        app: probe
        release: probe
        environment: base
    spec:
      containers:
      - name: probe
        image: docker.io/library/python:3.13-alpine
        command:
        - python
        - /app/server.py
        env:
        - name: VERSION
          value: v1
        ports:
        - name: http
          containerPort: 8080
        readinessProbe:
          httpGet:
            path: /ready
            port: http
          periodSeconds: 2
        resources:
          requests:
            cpu: 10m
            memory: 32Mi
          limits:
            memory: 128Mi
        volumeMounts:
        - name: app
          mountPath: /app
          readOnly: true
      volumes:
      - name: app
        configMap:
          name: probe-code
```

Save this as `base/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment-probe.yaml
```

Apply the required change:

```sh
kubectl apply -k base
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
```

Create a Kustomize base containing Deployment `probe` with two replicas and template label `environment: base`. Include a `kustomization.yaml` resource list and apply the base. Preserve the application configuration and original Service. The client must still receive version one.

After recording the result, remove this independent lab with `astrona destroy ats-025-lab-060-01-02`.

## Common pitfalls

> [!WARNING]
> List the resource in the kustomization before rendering it. Kubernetes stores the rendered objects; it does not retain the local directory layout. Keep all resource definitions self-contained.
