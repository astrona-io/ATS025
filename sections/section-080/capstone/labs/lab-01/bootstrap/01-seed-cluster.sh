#!/usr/bin/env bash
# Starting state: two namespaces and an operator Deployment that has no CRD, no identity and no permissions.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
echo "[lab] Ready."
