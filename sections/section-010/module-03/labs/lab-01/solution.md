---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Grant Cluster-Scoped Read Access With A ClusterRole — Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Before you change anything, `astrona submit` reports that all four checks fail: the leftover binding uses a built-in role, `scout` cannot read nodes or volumes, `scout` cannot get `/metrics`, and the `view` role lets `scout` read pods and namespaces.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-010/module-03/labs/lab-01
```

## Step 1: Look at the starting grant

Find out what the leftover binding gives away:

```sh
kubectl get clusterrolebinding scout-view -o wide
kubectl auth can-i --list --as=system:serviceaccount:starfleet:scout
```

The binding connects `scout` to the built-in `view` ClusterRole at cluster scope. The list shows read verbs on many resources, including pods and namespaces. The `view` role does not cover nodes, PersistentVolumes or `/metrics`, so it is both too broad and not the right grant.

## Step 2: Create the ClusterRole

Save this as `cluster-inspector.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-inspector
rules:
  - apiGroups: [""]
    resources: ["nodes", "persistentvolumes"]
    verbs: ["get", "list", "watch"]
  - nonResourceURLs: ["/metrics"]
    verbs: ["get"]
```

Apply it:

```sh
kubectl apply -f cluster-inspector.yaml
```

The role grants nothing yet, because no binding names it. Run `astrona submit --keep`. All four checks still fail.

## Step 3: Bind it and remove the leftover binding

Save this as `scout-cluster-inspector.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: scout-cluster-inspector
subjects:
  - kind: ServiceAccount
    name: scout
    namespace: starfleet
roleRef:
  kind: ClusterRole
  name: cluster-inspector
  apiGroup: rbac.authorization.k8s.io
```

Apply it and delete the leftover binding:

```sh
kubectl apply -f scout-cluster-inspector.yaml
kubectl delete clusterrolebinding scout-view
```

The `roleRef` field of an existing binding cannot be changed. That is why the old binding is deleted and a new one is created, rather than edited.

## Step 4: Check the allowed and the denied access

The first four answers are `yes`. The rest are `no`:

```sh
kubectl auth can-i list nodes --as=system:serviceaccount:starfleet:scout
kubectl auth can-i watch persistentvolumes --as=system:serviceaccount:starfleet:scout
kubectl auth can-i get /metrics --as=system:serviceaccount:starfleet:scout
kubectl get --raw /metrics --as=system:serviceaccount:starfleet:scout > /dev/null
kubectl auth can-i delete nodes --as=system:serviceaccount:starfleet:scout
kubectl auth can-i list pods -n starfleet --as=system:serviceaccount:starfleet:scout
kubectl auth can-i get secrets -n starfleet --as=system:serviceaccount:starfleet:scout
kubectl auth can-i get /logs --as=system:serviceaccount:starfleet:scout
```

The `kubectl get --raw` command sends a real request. It prints nothing on success and an error line if the request is refused.

## Step 5: Submit

```sh
astrona submit
```

All four checks pass.

## Why the other approaches fail

- A RoleBinding to `cluster-inspector` in `starfleet` does not grant nodes or PersistentVolumes: a RoleBinding only applies inside its own namespace, and these resources are not namespaced. The access checks fail.
- Putting `/metrics` in the same rule as `nodes` is rejected by the API server, because a rule may name resources or non-resource URLs but not both.
- Keeping `scout-view` leaves read access to pods and namespaces. RBAC permissions add up, so the leftover binding must go.
- A wildcard rule, or binding `cluster-admin`, fails the binding-shape check.
