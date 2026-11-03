#!/usr/bin/env bash
# Starting state: a topology-review record full of placeholder values, and a proposal that asks for four etcd members.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
echo "[lab] Ready."
