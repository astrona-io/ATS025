members=json.loads(command(['kubectl', '-n', 'kube-system', 'exec', 'etcd-astro-ats-025-lab-050-01-01-control-plane', '--', 'etcdctl', '--endpoints=https://127.0.0.1:2379', '--cacert=/etc/kubernetes/pki/etcd/ca.crt', '--cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt', '--key=/etc/kubernetes/pki/etcd/healthcheck-client.key', 'member', 'list', '--write-out=json']).stdout)['members']
assert len(members)==3 and len({member['ID'] for member in members})==3, 'Use three real etcd members'
nodes=json.loads(kubectl('get','nodes','-l','node-role.kubernetes.io/control-plane','-o','json'))['items']
assert len(nodes)==3 and all(any(c['type']=='Ready' and c['status']=='True' for c in node['status']['conditions']) for node in nodes), 'Keep all three control planes ready'
