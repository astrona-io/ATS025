#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

openssl genrsa -out "$WORK/jane.key" 2048
openssl req -new -key "$WORK/jane.key" -out "$WORK/jane.csr" -subj "/CN=jane/O=reviewers"

REQUEST="$(base64 < "$WORK/jane.csr" | tr -d '\n')"
sed "s|REQUEST_PLACEHOLDER|$REQUEST|" "$DIR/csr.yaml" > "$WORK/csr-jane.yaml"
kubectl apply -f "$WORK/csr-jane.yaml"
kubectl certificate approve jane

for i in $(seq 1 30); do
  if [ -n "$(kubectl get csr jane -o jsonpath='{.status.certificate}')" ]; then
    break
  fi
  sleep 2
done

kubectl apply -f "$DIR/solution.yaml"
echo "[solution] Applied."
