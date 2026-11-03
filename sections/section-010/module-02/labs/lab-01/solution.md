---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Issue A Client Certificate And Grant Pod Read Access — Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Before you change anything, `astrona submit` reports that every check fails, because the request, the certificate and the binding do not exist.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-010/module-02/labs/lab-01
```

## Step 1: Create the key and the request

The subject of the certificate is fixed when you create the request. The common name becomes the username and the organization becomes the group. Work in an empty directory:

```sh
openssl genrsa -out jane.key 2048
openssl req -new -key jane.key -out jane.csr -subj "/CN=jane/O=reviewers"
```

The two files `jane.key` and `jane.csr` now exist. The request file is the only one that goes to the cluster.

## Step 2: Submit the request to the cluster

Print the request as one line of base64 text:

```sh
base64 < jane.csr | tr -d '\n'
```

Save this as `csr-jane.yaml` and replace `<REQUEST>` with the text from the command:

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

Apply it:

```sh
kubectl apply -f csr-jane.yaml
```

Then check the result. The condition column reads `Pending`:

```sh
kubectl get csr jane
```

## Step 3: Approve the request and read the certificate

Approve the request. The signer in the controller manager then writes the certificate into the object:

```sh
kubectl certificate approve jane
kubectl get csr jane -o jsonpath='{.status.certificate}' | base64 -d > jane.crt
openssl x509 -in jane.crt -noout -subject
```

The subject holds `CN=jane` and `O=reviewers`. If the subject is wrong, delete the request with `kubectl delete csr jane`, create a new request file with the right subject and start again. Run `astrona submit --keep`. The checks for the request and the certificate pass, and the two checks for the binding and the access still fail.

## Step 4: Create the Role and the RoleBinding

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
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: reviewers-pod-reader
  namespace: starfleet
subjects:
  - kind: Group
    name: reviewers
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Apply it:

```sh
kubectl apply -f role-pod-reader.yaml
```

Then check the allowed verb and the verbs that must stay denied. The first answer is `yes` and the other three are `no`:

```sh
kubectl auth can-i list pods -n starfleet --as=jane --as-group=reviewers
kubectl auth can-i delete pods -n starfleet --as=jane --as-group=reviewers
kubectl auth can-i list pods -n outpost --as=jane --as-group=reviewers
kubectl auth can-i get secrets -n starfleet --as=jane --as-group=reviewers
```

## Step 5: Submit

```sh
astrona submit
```

All four checks pass.

## Why the other approaches fail

- A binding for the user `jane` only does not satisfy the binding check, which asks for the group `reviewers`.
- A ClusterRoleBinding or a binding to `view` or `edit` gives access outside `starfleet` or more verbs, and the access check fails.
- A request with the wrong signer or without `client auth` is never signed, so the certificate stays empty.
