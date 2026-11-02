---
draft: true
exam_objectives:
- Prepare underlying infrastructure for installing a Kubernetes cluster
---
# Inspect Node Runtime And Host Prerequisites Solution

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-025-lab-020-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-025-lab-020-01-01" || exit 1
node_name="astro-ats-025-lab-020-01-01-control-plane"
worker_name="astro-ats-025-lab-020-01-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Inspect And Explain

The isolated environment has two healthy probe replicas, an internal Service and two client Pods. The required result has not been configured.

Inspect the current objects before changing them:

```sh
kubectl -n starfleet get pods -o wide
kubectl get nodes -o wide
```

Create ConfigMap `node-report` recording the exact control-plane node name, `runtime` from containerd --version, `kubelet` from kubelet --version and `operatingSystem` from /etc/os-release. Keep the cluster available. This inspects a kubeadm-built kind node; it does not perform a fresh operating-system installation or install a CSI driver.

Save this as `configmap-node-report.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: node-report
  namespace: starfleet
data:
  node: astro-ats-025-lab-020-01-01-control-plane
```

Save this as `record-node.py`:

```python
import json,subprocess,tempfile
from pathlib import Path
CONTEXT="kind-astro-ats-025-lab-020-01-01"
NODE="astro-ats-025-lab-020-01-01-control-plane"
def run(*args):
    result=subprocess.run(args,check=True,text=True,capture_output=True,timeout=30)
    return result.stdout.strip()
assert run('kubectl','config','current-context')==CONTEXT, 'Select the private environment'
assert run('podman','inspect',NODE,'--format','{{index .Config.Labels "io.x-k8s.kind.cluster"}}')=='astro-ats-025-lab-020-01-01', 'Refusing an unrelated node container'
def node(*args):return run('podman','exec',NODE,*args)

report_name='node-report'
report={'node':NODE,'runtime':node('containerd','--version'),'kubelet':node('kubelet','--version'),'operatingSystem':node('cat','/etc/os-release')}

with tempfile.TemporaryDirectory(prefix='training-report-') as temporary:
    source=Path(temporary)/'configmap-report.json'
    source.write_text(json.dumps({'apiVersion':'v1','kind':'ConfigMap','metadata':{'name':report_name,'namespace':'starfleet'},'data':report}))
    run('kubectl','apply','-f',str(source))

```

Apply the scoped correction:

```sh
python3 record-node.py
```

## Verify The Result

Observe the actual result. A denied request returns a nonzero status when the denial works, so run it separately from a shell sequence that stops on error. Status convergence and a successful request establish different parts of the result.

```sh
kubectl -n starfleet get configmaps
kubectl -n starfleet get deployment probe -o yaml
```

Collect actual node prerequisites and distinguish the runtime, kubelet and network configuration. The commands above deliberately target one environment. Keep its remaining components available so an unrelated failure cannot stand in for the required denial or correction. No example command output is presented as evidence of a completed run. A matching field alone does not establish that a process used it or that a controller reconciled it.

After recording your result, remove the independent lab with `astrona destroy ats-025-lab-020-01-01`.

## Common pitfalls

> [!WARNING]
> Confirm the private context and exact node names before a change. Check the stated scope and live result. Do not change unrelated components to hide the original fault.
