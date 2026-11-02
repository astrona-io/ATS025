report=get('configmap','node-report')['data']
assert report['runtime']==command(['podman','exec','astro-ats-025-lab-020-01-01-control-plane','containerd','--version']).stdout.strip(), 'Record the actual runtime'
assert report['kubelet']==command(['podman','exec','astro-ats-025-lab-020-01-01-control-plane','kubelet','--version']).stdout.strip(), 'Record the actual kubelet'
assert report['operatingSystem']==command(['podman','exec','astro-ats-025-lab-020-01-01-control-plane','cat','/etc/os-release']).stdout.strip(), 'Record the actual node OS'
