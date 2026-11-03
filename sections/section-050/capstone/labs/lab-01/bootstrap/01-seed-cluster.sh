#!/usr/bin/env bash
# Starting state: an empty-looking review record, a six-member etcd proposal, and a controller ServiceAccount with the broad edit role.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
echo "[lab] Ready."
