---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Rebuild Access For Three Identities With RBAC — Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Before you change anything, `astrona submit` reports that all six checks fail.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-010/capstone/labs/lab-01
```

## Step 1: Replace the cluster administrator binding for shuttle

First see what the leftover binding gives, then write the narrow grant. Save this as `shuttle.yaml`:

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
---
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

Apply it and delete the leftover binding:

```sh
kubectl apply -f shuttle.yaml
kubectl delete clusterrolebinding shuttle-admin
```

RBAC grants add up, so the new Role takes nothing away until the old binding is gone. Run `astrona submit --keep`. The first check passes.

## Step 2: Give scout read access to nodes

Nodes belong to no namespace, so the grant needs a ClusterRole and a ClusterRoleBinding. Save this as `scout.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: scout-node-reader
subjects:
  - kind: ServiceAccount
    name: scout
    namespace: starfleet
roleRef:
  kind: ClusterRole
  name: node-reader
  apiGroup: rbac.authorization.k8s.io
```

Apply it, then check the result. The first answer is `yes` and the other two are `no`:

```sh
kubectl apply -f scout.yaml
kubectl auth can-i list nodes --as=system:serviceaccount:starfleet:scout
kubectl auth can-i list pods -n starfleet --as=system:serviceaccount:starfleet:scout
kubectl auth can-i list persistentvolumes --as=system:serviceaccount:starfleet:scout
```

Run `astrona submit --keep`. The second check passes.

## Step 3: Create the key and the request for jane

The subject of the certificate is fixed when you create the request. The common name becomes the username and the organization becomes the group. Work in an empty directory:

```sh
openssl genrsa -out jane.key 2048
openssl req -new -key jane.key -out jane.csr -subj "/CN=jane/O=reviewers"
base64 < jane.csr | tr -d '\n'
```

Save this as `csr-jane.yaml` and replace `<REQUEST>` with the text from the last command:

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: jane
spec:
  request: <REQUEST>
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400
  usages:
    - client auth
```

Apply and approve the request. Then read the subject of the issued certificate:

```sh
kubectl apply -f csr-jane.yaml
kubectl certificate approve jane
kubectl get csr jane -o jsonpath='{.status.certificate}' | base64 -d > jane.crt
openssl x509 -in jane.crt -noout -subject
```

The subject holds `CN=jane` and `O=reviewers`. If it does not, delete the request with `kubectl delete csr jane` and start this step again with the right subject. Run `astrona submit --keep`. The two certificate checks pass.

## Step 4: Bind the group reviewers to the view role

Save this as `reviewers.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: reviewers-view
  namespace: starfleet
subjects:
  - kind: Group
    name: reviewers
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
```

Apply it:

```sh
kubectl apply -f reviewers.yaml
```

Then check the result. The first two answers are `yes` and the rest are `no`:

```sh
kubectl auth can-i list pods -n starfleet --as=jane --as-group=reviewers
kubectl auth can-i list deployments.apps -n starfleet --as=jane --as-group=reviewers
kubectl auth can-i get secrets -n starfleet --as=jane --as-group=reviewers
kubectl auth can-i list pods -n outpost --as=jane --as-group=reviewers
kubectl auth can-i list nodes --as=jane --as-group=reviewers
```

## Step 5: Submit

```sh
astrona submit
```

All six checks pass.

## Why the other approaches fail

- A ClusterRoleBinding to `view` for `reviewers` gives reads in `outpost` too, and the binding check and the access check fail.
- A RoleBinding for `scout` to a node role does nothing for nodes, because a RoleBinding applies only inside its namespace and nodes have none.
- Keeping `shuttle-admin` leaves full administrator access, because grants add up.
- A binding for the user `jane` only does not satisfy the group check.
- A request with the wrong signer or without `client auth` is never signed, so the certificate stays empty.
