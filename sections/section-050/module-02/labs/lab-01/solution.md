---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/module-02/labs/lab-01
```

## Step 1: Read the topology

```sh
kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}'
kubectl get nodes -l node-role.kubernetes.io/control-plane
kubectl -n kube-system get pods -l component=etcd
```

Find `controlPlaneEndpoint` at the top level of the `ClusterConfiguration`. Find the `etcd` block: the line `local:` below it means a stacked topology. Count the nodes in the second output and the pods in the third output.

Read the client URL from the annotation that kubeadm puts on the etcd pod:

```sh
kubectl -n kube-system get pod -l component=etcd -o jsonpath='{.items[0].metadata.annotations.kubeadm\.kubernetes\.io/etcd\.advertise-client-urls}'
```

## Step 2: Calculate the quorum

Quorum is the number of members divided by two, rounded down, plus one. The fault tolerance is the number of members minus the quorum. This cluster has one etcd member, so the quorum is 1 and the fault tolerance is 0.

Read the proposal and calculate the same values:

```sh
kubectl -n starfleet get configmap ha-proposal -o jsonpath='{.data.members}'
```

With four members the quorum is 3 and the fault tolerance is 1. Three members also tolerate one failure, so the smallest odd number with the same tolerance is 3.

## Step 3: Write the record

Replace the values in the angle brackets with what you read in the two steps above. Save this as `configmap-topology-review.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: topology-review
  namespace: starfleet
data:
  controlPlaneEndpoint: "<ENDPOINT>"
  etcdTopology: stacked
  controlPlaneNodes: "1"
  etcdMembers: "1"
  etcdClientUrl: "<CLIENT_URL>"
  quorum: "1"
  faultTolerance: "0"
  proposalQuorum: "3"
  proposalTolerance: "1"
  proposalOddMembers: "3"
```

Apply it and submit:

```sh
kubectl apply -f configmap-topology-review.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/module-02/labs/lab-01 --keep
```

All six checks pass when every value matches the cluster. A check that names one key tells you which value to read again.

Clean up when you are done:

```sh
astrona destroy ats-025-lab-050-02-01
```
