import json,subprocess,tempfile
from pathlib import Path
assert subprocess.check_output(['kubectl','config','current-context'],text=True).strip()=='kind-astro-ats-025-lab-040-01-02'
status=json.loads(subprocess.check_output(['kubectl','-n','kube-system','exec','etcd-astro-ats-025-lab-040-01-02-control-plane','--','etcdutl','snapshot','status','/tmp/training-snapshot.db','--write-out=json'],text=True))
report={'apiVersion':'v1','kind':'ConfigMap','metadata':{'name':'snapshot-review','namespace':'starfleet'},'data':{'result':'validated','revision':str(status['revision']),'totalKey':str(status['totalKey'])}}
with tempfile.TemporaryDirectory(prefix='training-snapshot-') as temporary:
    target=Path(temporary)/'configmap-snapshot.json';target.write_text(json.dumps(report));subprocess.run(['kubectl','apply','-f',str(target)],check=True)
