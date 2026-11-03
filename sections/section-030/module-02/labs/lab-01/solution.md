---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-030/module-02/labs/lab-01
```

## Step 1: Read the stored cluster configuration

kubeadm stored the cluster-wide settings in the ConfigMap `kubeadm-config`, under the key `ClusterConfiguration`:

```sh
kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}'
```

The output is a YAML document. Write down four values: `kubernetesVersion`, `clusterName`, and `podSubnet` and `serviceSubnet` from the `networking` block. The Kubernetes version starts with `v`.

## Step 2: Record the values

Replace the four placeholders with the values you wrote down. Save this as `configmap-cluster-review.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-review
  namespace: starfleet
data:
  kubernetesVersion: <VERSION>
  clusterName: <CLUSTER_NAME>
  podSubnet: <POD_SUBNET>
  serviceSubnet: <SERVICE_SUBNET>
```

Apply it:

```sh
kubectl apply -f configmap-cluster-review.yaml
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-030/module-02/labs/lab-01 --keep
```

The check `cluster-review-matches-kubeadm-config` now passes. It recomputes the values from `kubeadm-config`, so a value copied from an example fails.

## Step 3: Look at the draft

Print the draft file:

```sh
kubectl -n starfleet get configmap kubeadm-plan -o jsonpath='{.data.kubeadm\.yaml}'
```

The draft has one document, the old API version `v1beta3`, an old Kubernetes version, and a `podSubnet` at the top level. The file needs two documents, `v1beta4`, the running version and a `networking` block.

## Step 4: Replace the draft

Replace `<VERSION>` with the version you recorded. Keep the indentation: the file content is a block of text inside the ConfigMap. Save this as `configmap-kubeadm-plan.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kubeadm-plan
  namespace: starfleet
data:
  kubeadm.yaml: |
    apiVersion: kubeadm.k8s.io/v1beta4
    kind: InitConfiguration
    nodeRegistration:
      name: outpost-cp-1
    ---
    apiVersion: kubeadm.k8s.io/v1beta4
    kind: ClusterConfiguration
    clusterName: outpost
    kubernetesVersion: <VERSION>
    controlPlaneEndpoint: outpost-api.example.test:6443
    networking:
      podSubnet: 10.200.0.0/16
      serviceSubnet: 10.201.0.0/16
```

Apply it:

```sh
kubectl apply -f configmap-kubeadm-plan.yaml
```

Then check the result:

```sh
kubectl -n starfleet get configmap kubeadm-plan -o jsonpath='{.data.kubeadm\.yaml}'
```

The output shows both documents. Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-030/module-02/labs/lab-01
```

All five checks pass. Then remove the lab:

```sh
astrona destroy ats-025-lab-030-02-01
```

## Common pitfalls

> [!WARNING]
> Do not copy the pod and Service ranges of the running cluster into the plan; the task gives different ranges. Do not leave `podSubnet` at the top level, and do not keep `v1beta3`. Do not edit the `kubeadm-config` ConfigMap in `kube-system`; the plan is a separate ConfigMap.
