---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Question

Solve this question on: `terminal`

The starfleet team keeps the `shuttle` application as a Kustomize base. The outpost team needs its own copy of it in the namespace `outpost`. Build an overlay on top of the base. Do not edit the base files.

Save the base first. Create a directory named `base` for these three files:

Save this as `base/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
configMapGenerator:
  - name: shuttle-config
    literals:
      - MODE=idle
```

Save this as `base/deployment.yaml`:

```yaml
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
```

Save this as `base/service.yaml`:

```yaml
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
```

Create the overlay in a directory named `overlays/outpost` that refers to the base. The result must have these properties:

1. All objects are in the namespace `outpost`, and every name starts with `outpost-`. The Deployment is `outpost-shuttle` and the Service is `outpost-shuttle`.
2. The Deployment has three replicas and runs the image `docker.io/library/busybox:1.37.0`. The image name `shuttle` in the base is only a placeholder.
3. The label `environment: outpost` is on the Deployment, on its selector and its pod template, and in the Service selector.
4. The container `shuttle` has the limits `cpu: 100m` and `memory: 64Mi`. Add them with a patch, not by editing the base.
5. The Service listens on port `8080` and still targets the named container port `http`. Change it with a patch.
6. The generated ConfigMap has `MODE` set to `patrol` instead of `idle`. The Deployment must refer to the generated name.

Apply the overlay with `kubectl apply -k`. Do not change the `bridge` Deployment in `starfleet`, and do not apply anything in the namespaces `default` or `starfleet`. `kubectl` already points at the cluster.
