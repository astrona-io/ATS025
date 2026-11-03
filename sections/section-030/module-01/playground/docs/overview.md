---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Guided Practice: Prepare Short-Lived Node Discovery Credentials

Use a host shell with the private kubeconfig for this module playground. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

<!-- astrona:playground:renew -->

```sh
export KUBECONFIG="$(astrona kubeconfig ats-025-playground-030-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-025-playground-030-01" || exit 1
node_name="astro-ats-025-playground-030-01-control-plane"
worker_name="astro-ats-025-playground-030-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Inspect And Explain

The isolated environment has two healthy probe replicas, an internal Service and two client Pods. The required result has not been configured.

Inspect the current objects before changing them:

```sh
kubectl -n starfleet get pods -o wide
kubectl get nodes -o wide
```

Create a kubeadm bootstrap token with a ten-minute lifetime in this lab. Record only its six-character tokenID and the sha256 CA public-key hash in ConfigMap join-review, together with the node name. Keep the credential Secret intact for grading. Never put the full token in the ConfigMap. This practices discovery preparation on an existing cluster; it does not claim a fresh control-plane initialization or node join.

Save this as `configmap-join-review.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: join-review
  namespace: starfleet
data:
  node: astro-ats-025-playground-030-01-control-plane
```

Save this as `prepare-discovery.py`:

```python
import json,subprocess,tempfile
from pathlib import Path
CONTEXT="kind-astro-ats-025-playground-030-01"
NODE="astro-ats-025-playground-030-01-control-plane"
def run(*args):
    result=subprocess.run(args,check=True,text=True,capture_output=True,timeout=30)
    return result.stdout.strip()
assert run('kubectl','config','current-context')==CONTEXT, 'Select the private environment'
assert run('podman','inspect',NODE,'--format','{{index .Config.Labels "io.x-k8s.kind.cluster"}}')=='astro-ats-025-playground-030-01', 'Refusing an unrelated node container'
def node(*args):return run('podman','exec',NODE,*args)

token=node('kubeadm','token','create','--ttl','10m')
token_id=token.split('.')[0]
ca_hash=node('sh','-c','openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt -noout | openssl pkey -pubin -outform DER | openssl dgst -sha256').split()[-1]
report_name='join-review'
report={'node':NODE,'tokenID':token_id,'caPublicKeyHash':'sha256:'+ca_hash}

with tempfile.TemporaryDirectory(prefix='training-report-') as temporary:
    source=Path(temporary)/'configmap-report.json'
    source.write_text(json.dumps({'apiVersion':'v1','kind':'ConfigMap','metadata':{'name':report_name,'namespace':'starfleet'},'data':report}))
    run('kubectl','apply','-f',str(source))

```

Apply the scoped correction:

```sh
python3 prepare-discovery.py
```

## Verify The Result

Observe the actual result. A denied request returns a nonzero status when the denial works, so run it separately from a shell sequence that stops on error. Status convergence and a successful request establish different parts of the result.

```sh
kubectl -n starfleet get configmaps
kubectl -n starfleet get deployment probe -o yaml
```

Create short-lived bootstrap discovery credentials and record the trusted CA public-key hash. The commands above deliberately target one environment. Keep its remaining components available so an unrelated failure cannot stand in for the required denial or correction. No example command output is presented as evidence of a completed run. A matching field alone does not establish that a process used it or that a controller reconciled it.


## Common pitfalls

> [!WARNING]
> Confirm the private context and exact node names before a change. Check the stated scope and live result. Do not change unrelated components to hide the original fault.
