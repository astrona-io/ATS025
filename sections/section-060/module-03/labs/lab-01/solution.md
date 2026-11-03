---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Solution

Solve this lab on `terminal`. The last step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can fix the files and submit again after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/module-03/labs/lab-01
```

## Step 1: Save the base and a first overlay

Save the three base files in `base/`. Then save this as `overlays/outpost/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
namespace: outpost
namePrefix: outpost-
images:
  - name: shuttle
    newName: docker.io/library/busybox
    newTag: 1.37.0
```

This first version sets only the namespace, the name prefix and the image. Render it and read the result:

```sh
kubectl kustomize overlays/outpost
```

`kubectl kustomize` prints the final YAML without contacting the cluster. You should see `namespace: outpost` and the prefix on every name. The generated ConfigMap name ends with a hash. Do not apply this version: the next step adds labels to the Deployment selector, and the selector of an existing Deployment cannot be changed. Render first and apply once.

## Step 2: Add the replicas, labels and patches

Save this as `overlays/outpost/limits.yaml`. It is a strategic merge patch: it names the Deployment and the container, and Kustomize merges the fields into the base:

```yaml
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
```

Replace `overlays/outpost/kustomization.yaml` with the full version, which adds the labels, the generator merge and the patches:

```yaml
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
```

Apply it and check the result:

```sh
kubectl apply -k overlays/outpost
kubectl -n outpost rollout status deployment/outpost-shuttle --timeout=120s
kubectl -n outpost get deployment,service,configmap
kubectl -n outpost get deployment outpost-shuttle -o jsonpath='{.spec.template.spec.containers[0].envFrom}'
```

The patch file uses the base name `shuttle`, because patches are matched before the name prefix is added. The Deployment now has three replicas. The `envFrom` field shows the generated ConfigMap name with the hash, which Kustomize wrote into the Deployment for you.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/module-03/labs/lab-01 --keep
```

All checks pass. Clean up when you are done:

```sh
astrona destroy ats-025-lab-060-03-01
```
