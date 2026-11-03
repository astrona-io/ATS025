---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/capstone/labs/lab-01
```

## Step 1: Read the topology and the leaders

```sh
kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}'
kubectl -n kube-system get pods -l component=etcd
kubectl -n kube-system get lease kube-scheduler -o jsonpath='{.spec.holderIdentity}{"\n"}'
kubectl -n kube-system get lease kube-controller-manager -o jsonpath='{.spec.holderIdentity}{"\n"}'
kubectl -n starfleet get configmap ha-proposal -o jsonpath='{.data.members}{"\n"}'
```

Take `controlPlaneEndpoint` from the top of the `ClusterConfiguration`. The `etcd` block with `local:` means stacked. Count the etcd pods. This cluster has one member, so the quorum is 1 and the fault tolerance is 0.

## Step 2: Calculate the proposal

The proposal has six members. The quorum is six divided by two, plus one, which is 4. The fault tolerance is 6 minus 4, which is 2. Five members also tolerate two failures, so the smallest odd number with the same tolerance is 5. An even number adds a member without adding fault tolerance.

## Step 3: Write the report

Replace the values in the angle brackets with what you read. Save this as `configmap-ha-report.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ha-report
  namespace: starfleet
data:
  controlPlaneEndpoint: "<ENDPOINT>"
  etcdTopology: stacked
  etcdMembers: "1"
  quorum: "1"
  faultTolerance: "0"
  schedulerLeader: "<SCHEDULER_HOLDER>"
  controllerManagerLeader: "<MANAGER_HOLDER>"
  proposalQuorum: "4"
  proposalTolerance: "2"
  proposalOddMembers: "5"
  verdict: single-point-of-failure
```

Apply it and submit:

```sh
kubectl apply -f configmap-ha-report.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/capstone/labs/lab-01 --keep
```

The report checks pass. The permission check still fails.

## Step 4: Give the controller lease access only

Remove the broad binding:

```sh
kubectl -n mission-system delete rolebinding mission-edit
```

Save this as `role-leader-election.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: leader-election
  namespace: mission-system
rules:
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ["get", "create", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: leader-election
  namespace: mission-system
subjects:
  - kind: ServiceAccount
    name: mission-controller
    namespace: mission-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: leader-election
```

Apply it, check one permission and submit:

```sh
kubectl apply -f role-leader-election.yaml
kubectl auth can-i update leases.coordination.k8s.io -n mission-system --as=system:serviceaccount:mission-system:mission-controller
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/capstone/labs/lab-01 --keep
```

The `can-i` command prints `yes`, and all six checks pass.

Clean up when you are done:

```sh
astrona destroy ats-025-lab-050-capstone-01
```
