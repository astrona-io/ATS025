status=json.loads(kubectl('-n','kube-system','exec','etcd-astro-ats-025-lab-040-01-02-control-plane','--','etcdutl','snapshot','status','/tmp/training-snapshot.db','--write-out=json'))
report=get('configmap','snapshot-review')['data']
assert int(report['revision'])==status['revision']>0 and int(report['totalKey'])==status['totalKey']>0, 'Record validated datastore contents'
assert kubectl('get','--raw=/readyz')=='ok', 'Do not break the live datastore'
