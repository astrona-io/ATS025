---
draft: true
exam_objectives:
- Prepare underlying infrastructure for installing a Kubernetes cluster
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-020/capstone/labs/lab-01
```

## Step 1: Read the node facts

```sh
kubectl get nodes -o jsonpath='{.items[0].metadata.annotations.kubeadm\.alpha\.kubernetes\.io/cri-socket}{"\n"}{.items[0].status.nodeInfo.containerRuntimeVersion}{"\n"}'
```

The command prints two lines: the runtime socket and the runtime version. The version starts with `containerd://`.

## Step 2: Read the stored kubelet configuration

```sh
kubectl -n kube-system get configmap kubelet-config -o jsonpath='{.data.kubelet}'
```

Find `cgroupDriver` and `failSwapOn`. If `failSwapOn` is not there, the default is `true`.

## Step 3: Read the control plane flags and ports

```sh
kubectl -n kube-system get pod -l component=kube-apiserver -o jsonpath='{.items[0].spec.containers[0].livenessProbe.httpGet.port}{"\n"}'
kubectl -n kube-system get pod -l component=kube-apiserver -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' | grep service-cluster-ip-range
kubectl -n kube-system get pod -l component=etcd -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' | grep listen-client-urls
kubectl -n kube-system get pod -l component=kube-controller-manager -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' | grep cluster-cidr
```

The last command prints nothing when the flag is not set. Use `none` in that case. For `etcdClientPort`, take the port of the first URL in the list.

## Step 4: Write the review

Save this as `configmap-readiness-review.yaml` and replace each placeholder with a value you noted:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: readiness-review
  namespace: starfleet
data:
  criSocket: <SOCKET>
  containerRuntimeVersion: <RUNTIME>
  cgroupDriver: <DRIVER>
  failSwapOn: "<TRUE-OR-FALSE>"
  apiserverPort: "<API-PORT>"
  etcdClientPort: "<ETCD-PORT>"
  podCIDR: <POD-CIDR-OR-none>
  serviceCIDR: <SERVICE-CIDR>
```

Apply it:

```sh
kubectl apply -f configmap-readiness-review.yaml
```

Then check the result:

```sh
kubectl -n starfleet get configmap readiness-review -o yaml
```

ConfigMap values are text, so numbers and booleans need quotes.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-020/capstone/labs/lab-01 --keep
```

All six checks must pass. If `kubelet-config-untouched` fails, you changed the stored configuration; the lab keeps a checksum of it.

When you finish, remove the lab:

```sh
astrona destroy ats-025-lab-020-capstone-01
```
