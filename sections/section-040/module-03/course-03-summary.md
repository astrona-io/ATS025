---
draft: true
exam_objectives:
- Manage the lifecycle of Kubernetes clusters
---
# Summary

etcd keeps every object of a Kubernetes cluster. On a kubeadm cluster it runs as a static pod that the kubelet starts from a manifest on the control plane node. It stores data in `/var/lib/etcd` and reads its certificates from `/etc/kubernetes/pki/etcd`, and it accepts only clients with a certificate that the etcd certificate authority signed.

`etcdctl snapshot save` takes a consistent copy of a live member into one file. It needs the endpoint, the certificate authority file and a client certificate with its key. `etcdutl snapshot status` checks the file without a server and prints the hash, the revision and the number of keys. A file that exists is not proof of a good backup, so you check it and copy it off the node.

A snapshot is a point in time. Everything that changed after it is lost on restore. It also does not hold certificates, the kubeadm files on the node, volume data or container images, and it can contain Secrets, so the file needs access control.

`etcdutl snapshot restore` writes a new data directory with a new cluster identity and refuses to overwrite an existing one. The restore does not change the running etcd. The etcd static pod uses the new data only after its `hostPath` volume points at the new directory. The API server stays stopped during the switch so that it cannot write to the old data.

After a restore you check three layers: etcd health, the API server readiness and the objects themselves. Controllers then reconcile the restored objects with the real state, which can recreate or remove resources.

The key facts to remember are these:

- Use `etcdctl` for live servers and `etcdutl` for files.
- Check every snapshot with `etcdutl snapshot status` and store it off the node.
- A restore creates a new directory, and the manifest must point at it.
- Stop the API server during the switch and verify at three layers afterwards.

<!-- astrona:playground:destroy -->
