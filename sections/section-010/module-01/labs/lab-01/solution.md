---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Grant A ServiceAccount Pod Read Access With A Role — Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Before you change anything, `astrona submit` reports that all five checks fail, because the Role and the binding do not exist and the leftover binding in `outpost` gives `shuttle` write access.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-010/module-01/labs/lab-01
```

## Step 1: Find what shuttle holds today

List the RoleBindings in all namespaces and look for the ServiceAccount:

```sh
kubectl get rolebindings -A -o wide
kubectl auth can-i --list -n outpost --as=system:serviceaccount:starfleet:shuttle
```

The binding `shuttle-helper` in `outpost` names `shuttle` and the built-in `edit` ClusterRole. The list for `outpost` shows write verbs on pods, Deployments and Secrets. This grant is the reason for the extra permissions.

## Step 2: Create the Role

Save this as `role-pod-reader.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: starfleet
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
```

Apply it:

```sh
kubectl apply -f role-pod-reader.yaml
```

The Role grants nothing yet. Run `astrona submit --keep`. The Role check passes, and the other four checks still fail.

## Step 3: Bind the Role to the ServiceAccount

Save this as `rolebinding-shuttle.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: shuttle-pod-reader
  namespace: starfleet
subjects:
  - kind: ServiceAccount
    name: shuttle
    namespace: starfleet
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Apply it:

```sh
kubectl apply -f rolebinding-shuttle.yaml
```

Then check the result. The answer is `yes`:

```sh
kubectl auth can-i list pods -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

Run `astrona submit --keep`. The checks for the Role, the binding and the reads pass. The check for other grants still fails.

## Step 4: Remove the leftover grant

RBAC grants add up, so the new Role does not take anything away. Delete the leftover binding:

```sh
kubectl delete rolebinding shuttle-helper -n outpost
```

Then check the denied actions. Every answer is `no`:

```sh
kubectl auth can-i create pods -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i get secrets -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i get pods/log -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i list pods -n outpost --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i create deployments.apps -n outpost --as=system:serviceaccount:starfleet:shuttle
```

## Step 5: Submit

```sh
astrona submit
```

All five checks pass.

## Why the other approaches fail

- Binding the built-in `view` or `edit` role in `starfleet` gives more than pod reads, and the "nothing more" check fails.
- A subject without the namespace `starfleet` is rejected by the API server, and a wrong namespace names another ServiceAccount.
- A ClusterRoleBinding to a pod-reading ClusterRole gives pod reads in every namespace, so the check for other grants fails.
- A rule with the verb `*` or the resource `*` fails the Role check.
- Editing the `roleRef` of `shuttle-helper` is rejected, because a `roleRef` cannot change. Delete the binding instead.
