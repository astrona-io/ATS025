#!/usr/bin/env bash
# Check: joinGroup is the subject of the ClusterRoleBinding
# kubeadm:node-autoapprove-bootstrap and autoApproveRole is its roleRef.
set -uo pipefail

subject="$(kubectl get clusterrolebinding kubeadm:node-autoapprove-bootstrap -o jsonpath='{.subjects[0].name}' 2>/dev/null || true)"
role="$(kubectl get clusterrolebinding kubeadm:node-autoapprove-bootstrap -o jsonpath='{.roleRef.name}' 2>/dev/null || true)"
if [ -z "$subject" ] || [ -z "$role" ]; then
  echo "FAIL: ClusterRoleBinding kubeadm:node-autoapprove-bootstrap not found"
  exit 1
fi

status=0
actual="$(kubectl -n starfleet get configmap init-review -o go-template='{{index .data "joinGroup"}}' 2>/dev/null || true)"
if [ "$actual" != "$subject" ]; then
  echo "FAIL: joinGroup is '${actual}', the binding subject is '${subject}'"; status=1
else
  echo "PASS: joinGroup is ${actual}"
fi
actual="$(kubectl -n starfleet get configmap init-review -o go-template='{{index .data "autoApproveRole"}}' 2>/dev/null || true)"
if [ "$actual" != "$role" ]; then
  echo "FAIL: autoApproveRole is '${actual}', the binding role is '${role}'"; status=1
else
  echo "PASS: autoApproveRole is ${actual}"
fi
exit "$status"
