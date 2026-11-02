---
draft: true
exam_objectives:
- Understand extension interfaces (CNI, CSI, CRI, etc.)
---
# Trace The Runtime And Network Interfaces

Collect actual node prerequisites and distinguish the runtime, kubelet and network configuration.

## Starting state

The isolated environment has two healthy probe replicas, an internal Service and two client Pods. The required result has not been configured.

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-025-lab-070-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-025-lab-070-01-01" || exit 1
node_name="astro-ats-025-lab-070-01-01-control-plane"
worker_name="astro-ats-025-lab-070-01-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Required result

Create ConfigMap `node-report` recording the exact control-plane node name, `runtime` from containerd --version, `kubelet` from kubelet --version and `operatingSystem` from /etc/os-release. Also record `criReady: true` from crictl info and `cniFiles` from /etc/cni/net.d. Keep the cluster available. This inspects a kubeadm-built kind node; it does not perform a fresh operating-system installation or install a CSI driver.

## Verify The Result

The grader checks the required object fields and actual observations. Wait for controller convergence before submitting. Preserve the task's namespace, workload names and unrelated components.
