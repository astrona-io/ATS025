report=get('configmap','node-report')['data']
assert report['runtime']==command(['podman','exec','astro-ats-025-playground-070-01-control-plane','containerd','--version']).stdout.strip(), 'Record the actual runtime'
assert report['kubelet']==command(['podman','exec','astro-ats-025-playground-070-01-control-plane','kubelet','--version']).stdout.strip(), 'Record the actual kubelet'
assert report['operatingSystem']==command(['podman','exec','astro-ats-025-playground-070-01-control-plane','cat','/etc/os-release']).stdout.strip(), 'Record the actual node OS'
info=json.loads(command(['podman','exec','astro-ats-025-playground-070-01-control-plane','crictl','info']).stdout)
assert any(condition['type']=='RuntimeReady' and condition['status'] is True for condition in info['status']['conditions']), 'The CRI runtime must be ready'
assert report['criReady']=='true' and report['cniFiles']==command(['podman','exec','astro-ats-025-playground-070-01-control-plane','ls','/etc/cni/net.d']).stdout.strip(), 'Observe configured CNI files'
