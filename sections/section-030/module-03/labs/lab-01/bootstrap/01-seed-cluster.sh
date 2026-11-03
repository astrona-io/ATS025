#!/usr/bin/env bash
# Starting state: a stale pki-map record that names old certificate files.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
echo "[lab] Ready."
