---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/module-03/labs/lab-01
```

## Step 1: Read the leaders and the Lease duration

```sh
kubectl -n kube-system get lease kube-scheduler -o jsonpath='{.spec.holderIdentity}{"\n"}{.spec.leaseDurationSeconds}{"\n"}'
kubectl -n kube-system get lease kube-controller-manager -o jsonpath='{.spec.holderIdentity}{"\n"}'
```

The holder identity is the name of the node, an underscore and a unique suffix. Copy it exactly.

## Step 2: Read the flag, the probes and the endpoints

```sh
kubectl -n kube-system get pod -l component=kube-scheduler -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' | grep leader-elect
kubectl -n kube-system get pod -l component=kube-apiserver -o jsonpath='{.items[0].spec.containers[0].livenessProbe.httpGet.path}{"\n"}{.items[0].spec.containers[0].readinessProbe.httpGet.path}{"\n"}'
kubectl -n default get endpointslices -l kubernetes.io/service-name=kubernetes -o wide
```

The first command prints the flag line, and you use the text after `=`. The second prints the two probe paths. The third lists the API server addresses. In this cluster there is one.

## Step 3: Write the record

Replace the values in the angle brackets with what you read. Save this as `configmap-control-plane-health.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: control-plane-health
  namespace: starfleet
data:
  schedulerLeader: "<SCHEDULER_HOLDER>"
  controllerManagerLeader: "<MANAGER_HOLDER>"
  leaseDurationSeconds: "<SECONDS>"
  leaderElectFlag: "<FLAG_VALUE>"
  apiServerLivenessPath: "<LIVENESS_PATH>"
  apiServerReadinessPath: "<READINESS_PATH>"
  apiServerEndpointCount: "1"
```

Apply it and submit:

```sh
kubectl apply -f configmap-control-plane-health.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/module-03/labs/lab-01 --keep
```

The first four checks pass when the values match. The permission check still fails.

## Step 4: Replace the broad binding with lease access

Remove the broad binding:

```sh
kubectl -n starfleet delete rolebinding scout-edit
```

Save this as `role-leader-election.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: leader-election
  namespace: starfleet
rules:
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ["get", "create", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: leader-election
  namespace: starfleet
subjects:
  - kind: ServiceAccount
    name: scout-controller
    namespace: starfleet
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: leader-election
```

Apply it, check the permissions and submit:

```sh
kubectl apply -f role-leader-election.yaml
kubectl auth can-i update leases.coordination.k8s.io -n starfleet --as=system:serviceaccount:starfleet:scout-controller
kubectl auth can-i get secrets -n starfleet --as=system:serviceaccount:starfleet:scout-controller
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/module-03/labs/lab-01 --keep
```

The first `can-i` command prints `yes` and the second prints `no`. All six checks pass.

Clean up when you are done:

```sh
astrona destroy ats-025-lab-050-03-01
```
