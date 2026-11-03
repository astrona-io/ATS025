---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-080/module-03/labs/lab-01
```

## Step 1: Give the Deployment an identity

```sh
kubectl -n beacon-system create serviceaccount beacon-operator
kubectl -n beacon-system set serviceaccount deployment/beacon-operator beacon-operator
kubectl -n beacon-system rollout status deployment/beacon-operator --timeout=120s
```

The first command creates the ServiceAccount. The second edits the pod template, which starts a new ReplicaSet. The third waits until the new pod is available.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-080/module-03/labs/lab-01 --keep
```

The identity check passes. The permission checks fail, because the ServiceAccount has no role yet.

## Step 2: Grant exactly what the loop needs

Save this as `operator-rbac.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: beacon-operator
rules:
  - apiGroups: ["training.astrona.io"]
    resources: ["beacons", "beacons/status"]
    verbs: ["get", "list", "watch", "update", "patch"]
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: beacon-operator
subjects:
  - kind: ServiceAccount
    name: beacon-operator
    namespace: beacon-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: beacon-operator
```

Apply it and check both directions yourself:

```sh
kubectl apply -f operator-rbac.yaml
kubectl auth can-i update beacons.training.astrona.io/status --as=system:serviceaccount:beacon-system:beacon-operator
kubectl auth can-i delete nodes --as=system:serviceaccount:beacon-system:beacon-operator
```

The first check prints `yes` and the second prints `no`.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-080/module-03/labs/lab-01 --keep
```

The permission, least-privilege and wildcard checks pass.

## Step 3: Set the watch namespace and create the first resource

```sh
kubectl -n beacon-system set env deployment/beacon-operator WATCH_NAMESPACE=starfleet
kubectl -n beacon-system rollout status deployment/beacon-operator --timeout=120s
kubectl apply -f - <<'BEACON'
apiVersion: training.astrona.io/v1
kind: Beacon
metadata:
  name: first-beacon
  namespace: starfleet
spec:
  channel: alpha
BEACON
```

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-080/module-03/labs/lab-01 --keep
```

All checks pass. Clean up when you are done:

```sh
astrona destroy ats-025-lab-080-03-01
```
