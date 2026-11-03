release=json.loads(command(['helm','status','demo','-n','starfleet','-o','json']).stdout)
assert release['info']['status']=='deployed', 'Keep a deployed Helm release'
values=json.loads(command(['helm','get','values','demo','-n','starfleet','-o','json']).stdout)
assert values['replicaCount']==2, 'Keep the required effective capacity'
