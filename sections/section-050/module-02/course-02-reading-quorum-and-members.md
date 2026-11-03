---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Reading Quorum And Members From A Running Cluster

An etcd cluster does not need every member to be alive. It needs a majority. This part turns that rule into a formula, reads the member list of a real etcd cluster, and then walks through the steps that grow and shrink a stacked control plane without losing the majority.

## Quorum and fault tolerance

etcd uses the Raft algorithm. Raft elects one member as the leader. The leader accepts every write, copies it to the other members, and counts a write as committed only when a majority of the members have stored it. That majority is called the quorum.

The quorum for `n` members is `n / 2` rounded down, plus 1. The fault tolerance is the number of members that can fail while the quorum still exists: `n` minus the quorum.

| Members | Quorum | Fault tolerance |
| --- | --- | --- |
| 1 | 1 | 0 |
| 2 | 2 | 0 |
| 3 | 2 | 1 |
| 4 | 3 | 1 |
| 5 | 3 | 2 |
| 6 | 4 | 2 |
| 7 | 4 | 3 |

Two facts come out of the table. Two members tolerate no failure, so they are worse than one in practice: either member lost stops the cluster, and there are two members that can be lost. An even number adds a member without adding fault tolerance: four members tolerate one failure, like three, and six tolerate two, like five. That is why clusters use an odd number of members, usually three or five.

If the quorum is lost, etcd cannot elect a leader and cannot commit writes. The API servers then cannot read or write cluster state reliably. The pods that already run on the worker nodes keep running, because the kubelet works from its local copy, but nothing can be scheduled, scaled or changed.

## Read the members of a live cluster

The etcd image contains the `etcdctl` command. You run it inside the etcd pod with `kubectl exec`, and you give it the address and the three certificate files that kubeadm creates for etcd.

<!-- astrona:playground:renew -->

Store the name of the etcd pod and a short command prefix in shell variables:

```sh
ETCD_POD="$(kubectl -n kube-system get pod -l component=etcd -o jsonpath='{.items[0].metadata.name}')"
etcdctl_in_pod() {
  kubectl -n kube-system exec "$ETCD_POD" -- etcdctl \
    --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key "$@"
}
```

List the members:

```sh
etcdctl_in_pod member list -w table
```

The table has one row per member. The columns are the member `ID`, the `STATUS` (`started`), the `NAME`, the peer address that other members use (`PEER ADDRS`), the client address that API servers use (`CLIENT ADDRS`) and `IS LEARNER`. A learner is a member that receives the log but does not vote, so it does not count toward the quorum. In the playground the table has one row.

Ask each member for its status and health:

```sh
etcdctl_in_pod endpoint status -w table
etcdctl_in_pod endpoint health
```

The status table shows the database size, the leader flag and the Raft term. Exactly one member has `IS LEADER` set to `true`. The health command reports whether the endpoint answers a request in time. Run both in a cluster with several members and you would use `--cluster`, which makes `etcdctl` ask every member that it finds in the member list.

## Calculate the quorum from the cluster

Count the members from the live cluster instead of trusting a document. In a stacked cluster, the number of etcd pods is the number of members, and the shell can do the arithmetic:

```sh
MEMBERS="$(kubectl -n kube-system get pods -l component=etcd -o name | wc -l)"
QUORUM=$((MEMBERS / 2 + 1))
echo "members=$MEMBERS quorum=$QUORUM tolerance=$((MEMBERS - QUORUM))"
```

With one member the line reads `members=1 quorum=1 tolerance=0`. Change `MEMBERS` by hand to 3, 4 and 5 and read the result against the table above.

## Adding a control-plane node

Growing a stacked cluster means adding a node that runs the four programs and one new etcd member. kubeadm does the work in one command on the new node, after the first control-plane node was created with an endpoint and `--upload-certs`. These commands are for real hosts and are not run in the playground.

```sh
kubeadm join api.starfleet.example:6443 \
  --token <TOKEN> \
  --discovery-token-ca-cert-hash sha256:<HASH> \
  --control-plane \
  --certificate-key <KEY>
```

The `--control-plane` flag tells kubeadm that this node joins as a control-plane node. The certificate key decrypts the certificates that `--upload-certs` stored. kubeadm then writes the static pod manifests, creates the new etcd member and registers it with the existing members. Current kubeadm versions first add the member as a learner and promote it when it has caught up, so a slow new member never blocks the quorum.

Add one node at a time and wait for the previous member to be healthy. Going from one member to two raises the quorum from 1 to 2, so for a short time both members are needed. If the new member is not reachable, the quorum is lost and the cluster stops.

## Removing a node and its etcd member

Shrinking or replacing a node needs the etcd member removed as well, or the member list keeps a dead member and counts it toward the majority. The steps for a healthy node are:

1. Drain the node with `kubectl drain` so workloads move away.
2. Run `kubeadm reset` on the node. In a stacked cluster, it removes the local etcd member from the etcd cluster before it cleans the node.
3. Delete the node object with `kubectl delete node`.

When the node is already dead, `kubeadm reset` cannot run on it. Then you remove the member by its ID with `etcdctl member remove <ID>` from a healthy member, and delete the node object. Do this quickly: a three-member cluster with one dead member has a fault tolerance of 0 until the dead member is removed and a new one is added.

## Worked example: lose two of three

A three-member cluster loses two nodes at the same moment. One member remains, but the quorum is 2. The remaining etcd cannot elect a leader, so the API server on that node reports errors for most requests. Restarting the remaining API server does not help, because the missing majority is the problem.

The recovery has two routes. If one lost node returns, the quorum returns and etcd continues. If both nodes are gone for good, an administrator restores a snapshot into a new single-member etcd cluster and grows it again. Both routes show why the number of members and their separate failure domains matter more than the number of API servers.

## What you know now, and what is open

You can calculate the quorum and the fault tolerance, read a member list, and describe the steps to add and remove a stacked control-plane node. The open question is what keeps the API servers reachable and which components elect a leader. Those are separate mechanisms from etcd quorum.

## Common pitfalls

> [!WARNING]
> - Running two etcd members for "redundancy". Two members tolerate no failure.
> - Choosing an even member count. The extra member adds load and no fault tolerance.
> - Adding two control-plane nodes at the same moment. The quorum can change before both members are healthy.
> - Deleting a dead node with `kubectl delete node` and forgetting `etcdctl member remove`. The dead member still counts toward the quorum.
> - Running `etcdctl` without the certificate options. It fails with a transport error, because etcd requires client certificates.
