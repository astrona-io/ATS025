---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-030/capstone/labs/lab-01
```

## Step 1: Read the stored configuration

```sh
kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}'
```

The command prints the `ClusterConfiguration` text. Note `kubernetesVersion`, `certificatesDir` and the `podSubnet` line under `networking`.

## Step 2: Read the discovery and bootstrap facts

```sh
kubectl -n kube-public get configmap cluster-info -o jsonpath='{.data.kubeconfig}'
kubectl get clusterrolebinding kubeadm:node-autoapprove-bootstrap -o yaml
```

The first command prints a kubeconfig; note the value of the `server:` line. The second prints the binding; note `subjects[0].name` and `roleRef.name`.

## Step 3: Read the worker node and the kubelet configuration

```sh
kubectl get nodes -l '!node-role.kubernetes.io/control-plane'
kubectl -n kube-system get configmap kubelet-config -o jsonpath='{.data.kubelet}'
```

The first command lists the worker node. In the second output, find the `clusterDNS` list and note its first address.

## Step 4: Write the review

Save this as `configmap-init-review.yaml` and replace each placeholder with a value you noted:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: init-review
  namespace: starfleet
data:
  kubernetesVersion: <VERSION>
  podSubnet: <POD-SUBNET>
  certificatesDir: <DIRECTORY>
  apiServerEndpoint: <SERVER-URL>
  joinGroup: <GROUP>
  autoApproveRole: <CLUSTER-ROLE>
  workerNodeName: <NODE>
  clusterDNS: <ADDRESS>
```

Apply it:

```sh
kubectl apply -f configmap-init-review.yaml
```

Then check the result:

```sh
kubectl -n starfleet get configmap init-review -o yaml
```

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-030/capstone/labs/lab-01 --keep
```

All six checks must pass. Each failure names the key and the value it expected.

When you finish, remove the lab:

```sh
astrona destroy ats-025-lab-030-capstone-01
```
