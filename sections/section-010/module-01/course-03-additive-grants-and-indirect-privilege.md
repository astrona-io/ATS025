---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Additive Grants And Indirect Privilege

Reviewing one Role tells you little about what an identity can do. An identity can have many bindings, and groups bring more of them. Some verbs also give access that the verb name does not show. This part shows how the API server adds grants together, how to see the full result for one identity and which grants give indirect access to credentials. These skills decide whether a grant really follows least privilege.

## No deny rule

RBAC has only allow rules. A request is allowed when at least one rule in at least one applicable binding matches it. A rule cannot take a permission away. If one Role omits a verb and another binding grants it, the identity holds the verb.

The set of applicable bindings is found from the identity of the caller. The API server collects the bindings that name the user, every group of the user and, for a ServiceAccount, its built-in groups. The effective permission is the union of all their rules. To remove a permission you must remove every grant that gives it.

## Watch two grants add up

Start with `shuttle` holding one binding to a Role that reads pods in `starfleet`. The first two commands below create that pair. The next two create a second Role with different verbs on a different resource, and a second binding for the same ServiceAccount:

<!-- astrona:playground:renew -->

```sh
kubectl create role pod-reader -n starfleet --verb=get,list,watch --resource=pods
kubectl create rolebinding shuttle-pod-reader -n starfleet --role=pod-reader --serviceaccount=starfleet:shuttle
kubectl create role configmap-editor -n starfleet --verb=get,update --resource=configmaps
kubectl create rolebinding shuttle-configmap-editor -n starfleet --role=configmap-editor --serviceaccount=starfleet:shuttle
```

If a command reports `AlreadyExists`, the object is left from an earlier step in the same playground and you can go on. Then list everything `shuttle` may do in the namespace. The flag `--list` prints a table of resources, non-resource URLs, resource names and verbs:

```sh
kubectl auth can-i --list -n starfleet --as=system:serviceaccount:starfleet:shuttle
```

The table now shows the rows of both Roles together: the pod reads and the ConfigMap rows. It also shows a few rows that you did not create, such as `selfsubjectreviews` and the discovery paths. Every authenticated caller receives these rows from built-in bindings, so a "no permission" ServiceAccount is not completely empty.

To take the ConfigMap grant away, delete its binding. Deleting only the Role would leave a binding that points at a Role that no longer exists, which grants nothing but stays in the cluster as clutter:

```sh
kubectl delete rolebinding shuttle-configmap-editor -n starfleet
```

## Grants that give more than they say

Some permissions reach beyond their resource. Four are worth knowing for every review.

- `get`, `list` or `watch` on `secrets` returns the secret data. A `list` request returns the full content of every Secret in the namespace, not only the names. A grant to "list secrets" is therefore a grant to read every credential in the namespace.
- `create` on `pods` lets the caller choose what the pod mounts and which ServiceAccount it runs as. A pod can mount any Secret or ConfigMap in its own namespace and run as any ServiceAccount there, without a separate permission. The caller can then read those credentials from inside the pod.
- `pods/exec` and `pods/attach` run commands in an existing container. The container may hold a mounted token or Secret that the caller was never allowed to read.
- `create` on `rolebindings` or `roles` lets the caller write RBAC objects. The API server limits this: a caller may not create a role with permissions that the caller does not hold, unless the caller has the `escalate` verb on roles.

Check the first point yourself. Give `scout` a grant that looks like read-only monitoring, then read a credential with it:

```sh
kubectl create role secret-lister -n starfleet --verb=list --resource=secrets
kubectl create rolebinding scout-secret-lister -n starfleet --role=secret-lister --serviceaccount=starfleet:scout
kubectl get secrets -n starfleet -o yaml --as=system:serviceaccount:starfleet:scout
```

The third command prints the Secret `warp-key` including its `data` field, as base64 text. The role only allowed `list`, and the API still returned the contents. Remove the test grant when you finish:

```sh
kubectl delete rolebinding scout-secret-lister -n starfleet
```

## Choose the narrowest grant

Least privilege means that each identity holds only the rules its job needs, in the smallest scope that works. Four habits follow from what you have seen.

Write the verbs from the work, not from a label such as "read". A workload that only fetches a pod by name needs `get`; a controller that watches a collection needs `list` and `watch` too. Name the resources and the API group exactly, and do not use a wildcard. Use `resourceNames` where the verb allows it. Bind in the smallest namespace set that works, and bind a ServiceAccount, not a broad group such as `system:authenticated`.

After each change, test both sides. Ask for the actions that must be allowed and for the ones that must be denied, with `kubectl auth can-i --as`. A grant that passes only the "allowed" tests may still give too much.

```sh
kubectl auth can-i get secrets -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i create pods -n starfleet --as=system:serviceaccount:starfleet:shuttle
kubectl auth can-i list pods -n outpost --as=system:serviceaccount:starfleet:shuttle
```

All three answers are `no` for `shuttle` while it holds only the pod-reader binding. The first two are denied because the Role has no rule for them. The third is denied because the binding applies in `starfleet` only.

## Review one identity from start to finish

A review of one identity follows the same steps each time. First list the bindings in the namespace and read the subjects. Then list the rules with `--list`. Then ask the questions about the dangerous verbs one by one, and check that the answers match the job.

```sh
kubectl get rolebindings -n starfleet -o wide
kubectl auth can-i get secrets -n starfleet --as=system:serviceaccount:starfleet:scout
```

The `-o wide` output adds the role and the users, groups and ServiceAccounts of each binding. If a binding names a group, run the check again with `--as-group` to see what that group brings. The result is a short written statement: the identity may read pods in one namespace and may do nothing else. A statement that you cannot write in one sentence usually means that the grant is too broad.

## What the impersonation check does not prove

`kubectl auth can-i --as` asks the authorizer a question about a name. It does not prove that a pod has a usable token, and it does not run admission, which may still reject a later object. It needs the right to impersonate, which the cluster administrator holds. It is a fast and exact test of RBAC and nothing else.

You can now read the effective permissions of an identity, spot the grants that reach credentials and choose the smallest scope that does the work. The question still open is how to grant access to resources that belong to no namespace, because a Role cannot name them.

## Common pitfalls

> [!WARNING]
> Removing a rule from one Role does not take the permission away while another binding for the identity or its groups still grants it. A grant that lists Secrets or creates pods gives access to credentials, even though neither verb says so. Delete bindings when you test, or the extra grants stay in the cluster and change later results. A passing "allowed" check does not prove least privilege: test the denied actions too.
