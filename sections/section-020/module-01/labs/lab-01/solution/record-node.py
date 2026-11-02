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

