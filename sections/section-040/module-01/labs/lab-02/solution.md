---
draft: true
exam_objectives:
- Manage the lifecycle of Kubernetes clusters
---
# Save And Inspect An Etcd Snapshot Solution

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-025-lab-040-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-025-lab-040-01-02" || exit 1
node_name="astro-ats-025-lab-040-01-02-control-plane"
worker_name="astro-ats-025-lab-040-01-02-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Inspect And Explain

The isolated environment has two healthy probe replicas, an internal Service and two client Pods. The required result has not been configured.

Inspect the current objects before changing them:

```sh
kubectl -n starfleet get pods -o wide
kubectl get nodes -o wide
```

Save /tmp/training-snapshot.db using authenticated etcdctl from the lab etcd Pod. Use etcdutl snapshot status to validate the saved file. Record ConfigMap snapshot-review with result validated, revision and totalKey matching that inspection. Keep API access available. Do not overwrite live etcd data directories; a restore needs a separate recovery workflow.

Save this as `configmap-snapshot-review.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: snapshot-review
  namespace: starfleet
data:
  result: validated
```

Save this as `record-snapshot.py`:

```python
import json,subprocess,tempfile
from pathlib import Path
assert subprocess.check_output(['kubectl','config','current-context'],text=True).strip()=='kind-astro-ats-025-lab-040-01-02'
status=json.loads(subprocess.check_output(['kubectl','-n','kube-system','exec','etcd-astro-ats-025-lab-040-01-02-control-plane','--','etcdutl','snapshot','status','/tmp/training-snapshot.db','--write-out=json'],text=True))
report={'apiVersion':'v1','kind':'ConfigMap','metadata':{'name':'snapshot-review','namespace':'starfleet'},'data':{'result':'validated','revision':str(status['revision']),'totalKey':str(status['totalKey'])}}
with tempfile.TemporaryDirectory(prefix='training-snapshot-') as temporary:
    target=Path(temporary)/'configmap-snapshot.json';target.write_text(json.dumps(report));subprocess.run(['kubectl','apply','-f',str(target)],check=True)
```

Apply the scoped correction:

```sh
kubectl -n kube-system exec etcd-astro-ats-025-lab-040-01-02-control-plane -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key snapshot save /tmp/training-snapshot.db
kubectl apply -f configmap-snapshot-review.yaml
python3 record-snapshot.py
```

## Verify The Result

Observe the actual result. A denied request returns a nonzero status when the denial works, so run it separately from a shell sequence that stops on error. Status convergence and a successful request establish different parts of the result.

```sh
kubectl -n starfleet get configmaps
kubectl -n starfleet get deployment probe -o yaml
```

Save a real datastore snapshot and inspect its revision and key count without restoring the live cluster. The commands above deliberately target one environment. Keep its remaining components available so an unrelated failure cannot stand in for the required denial or correction. No example command output is presented as evidence of a completed run. A matching field alone does not establish that a process used it or that a controller reconciled it.

After recording your result, remove the independent lab with `astrona destroy ats-025-lab-040-01-02`.

## Common pitfalls

> [!WARNING]
> Confirm the private context and exact node names before a change. Check the stated scope and live result. Do not change unrelated components to hide the original fault.
