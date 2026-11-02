import base64
from datetime import datetime,timezone
report=get('configmap','join-review')['data']
assert len(report['tokenID'])==6, 'Record only the bootstrap token identifier'
secret=get('secret','bootstrap-token-'+report['tokenID'],namespace='kube-system')
assert secret['type']=='bootstrap.kubernetes.io/token', 'Create an actual bootstrap credential'
expiration=datetime.fromisoformat(base64.b64decode(secret['data']['expiration']).decode().replace('Z','+00:00'))
assert 0<(expiration-datetime.now(timezone.utc)).total_seconds()<=610, 'Keep the credential short lived'
actual=command(['podman','exec','astro-ats-025-lab-030-01-01-control-plane','sh','-c','openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt -noout | openssl pkey -pubin -outform DER | openssl dgst -sha256']).stdout.split()[-1]
assert report['caPublicKeyHash']=='sha256:'+actual, 'Use the trusted discovery hash'
assert set(report)=={'node','tokenID','caPublicKeyHash'}, 'Do not store the full token in a ConfigMap'
