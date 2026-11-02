import json,subprocess,tempfile
from pathlib import Path
CONTEXT="kind-astro-ats-025-lab-030-01-01"
NODE="astro-ats-025-lab-030-01-01-control-plane"
def run(*args):
    result=subprocess.run(args,check=True,text=True,capture_output=True,timeout=30)
    return result.stdout.strip()
assert run('kubectl','config','current-context')==CONTEXT, 'Select the private environment'
assert run('podman','inspect',NODE,'--format','{{index .Config.Labels "io.x-k8s.kind.cluster"}}')=='astro-ats-025-lab-030-01-01', 'Refusing an unrelated node container'
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

