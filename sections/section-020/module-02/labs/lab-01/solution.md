---
draft: true
exam_objectives:
- Prepare underlying infrastructure for installing a Kubernetes cluster
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-020/module-02/labs/lab-01
```

## Step 1: Read the stored kubelet configuration

```sh
kubectl -n kube-system get configmap kubelet-config -o jsonpath='{.data.kubelet}'
```

The command prints a YAML text. Find the lines `cgroupDriver` and `failSwapOn`. If `failSwapOn` is not there, the kubelet default `true` applies. Note both values.

## Step 2: Read the node status

```sh
kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.containerRuntimeVersion}{"\n"}{.items[0].status.nodeInfo.kubeletVersion}{"\n"}{.items[0].status.nodeInfo.kernelVersion}{"\n"}{.items[0].status.nodeInfo.osImage}{"\n"}'
```

The command prints four lines in this order: runtime, kubelet version, kernel version and operating system image. The runtime value starts with `containerd://`.

## Step 3: Write the record

Save this as `configmap-host-readiness.yaml` and replace each placeholder with a value you noted:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: host-readiness
  namespace: starfleet
data:
  cgroupDriver: <DRIVER>
  failSwapOn: <TRUE-OR-FALSE>
  containerRuntimeVersion: <RUNTIME>
  kubeletVersion: <KUBELET>
  kernelVersion: <KERNEL>
  osImage: <OS>
```

Apply it:

```sh
kubectl apply -f configmap-host-readiness.yaml
```

Then check the result:

```sh
kubectl -n starfleet get configmap host-readiness -o yaml
```

Put quotes around `failSwapOn` values if your editor changes them: ConfigMap values are text, so `"true"` is correct and the bare word `true` is not accepted in `data`.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-020/module-02/labs/lab-01 --keep
```

All six checks must pass. If `cgroup-driver` or `swap-setting` fails, compare the value with the stored configuration. If `runtime-and-kubelet` or `kernel-and-os` fails, compare with the node status and look for a missing prefix or a trailing space. If `kubelet-config-untouched` fails, you changed the stored configuration; the lab keeps a checksum of it.

When you finish, remove the lab:

```sh
astrona destroy ats-025-lab-020-02-01
```
