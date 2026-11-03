#!/usr/bin/env bash
# Starting state: a health record full of placeholder values, and a ServiceAccount that has the broad edit role.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
echo "[lab] Ready."
