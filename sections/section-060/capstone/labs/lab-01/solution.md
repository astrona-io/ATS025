---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Solution

Solve this lab on `terminal`. Steps 1 and 3 end with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/capstone/labs/lab-01
```

## Step 1: Adopt the hand-applied objects into a release

Save the four chart files under a directory named `chart`. Then try the plain install to see why adoption is needed:

```sh
helm install relay chart --namespace starfleet --set replicaCount=2 --set logLevel=debug
```

Helm refuses, because the Deployment `relay` already exists and has no ownership metadata for this release. The message says the object cannot be imported into the current release because of invalid ownership metadata. Helm checks one label and two annotations. Add them to both objects:

```sh
kubectl -n starfleet label deployment relay app.kubernetes.io/managed-by=Helm --overwrite
kubectl -n starfleet annotate deployment relay meta.helm.sh/release-name=relay meta.helm.sh/release-namespace=starfleet --overwrite
kubectl -n starfleet label service relay app.kubernetes.io/managed-by=Helm --overwrite
kubectl -n starfleet annotate service relay meta.helm.sh/release-name=relay meta.helm.sh/release-namespace=starfleet --overwrite
```

Install again. Helm now takes over the existing objects and updates them to the rendered manifest:

```sh
helm install relay chart --namespace starfleet --set replicaCount=2 --set logLevel=debug --wait --timeout 120s
helm get values relay --namespace starfleet
kubectl -n starfleet get deployment relay
```

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/capstone/labs/lab-01 --keep
```

The identity, release and ownership checks pass. The outpost checks fail because the copy does not exist yet.

## Step 2: Render the chart and build the Kustomize base

Render the chart for the release name `relay-outpost` into a base directory:

```sh
mkdir -p base overlay
helm template relay-outpost chart --namespace outpost > base/relay.yaml
```

`helm template` only prints YAML. It does not contact the cluster and creates no release. Save this as `base/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - relay.yaml
```

## Step 3: Write the overlay and apply it

Save this as `overlay/limits.yaml`. It names the rendered Deployment `relay-outpost` and the container `relay`:

```yaml
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
```

Save this as `overlay/kustomization.yaml`:

```yaml
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
```

Render it, apply it and check the result:

```sh
kubectl kustomize overlay
kubectl apply -k overlay
kubectl -n outpost rollout status deployment/relay-outpost --timeout=120s
kubectl -n outpost get deployment,service
helm list --all-namespaces
```

`helm list` shows only the release `relay`. The outpost copy is plain objects applied by `kubectl`.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/capstone/labs/lab-01 --keep
```

All checks pass. Clean up when you are done:

```sh
astrona destroy ats-025-lab-060-capstone-01
```
