#!/usr/bin/env bash
# Check: the issued certificate has CN=jane and O=reviewers, is signed by the
# cluster CA and has not expired.
set -uo pipefail

if ! command -v openssl >/dev/null 2>&1; then
  echo "FAIL: openssl is not installed on the machine that runs the check"
  exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
fail=0

kubectl get csr jane -o jsonpath='{.status.certificate}' 2>/dev/null | base64 -d > "$WORK/jane.crt" 2>/dev/null
if [ ! -s "$WORK/jane.crt" ]; then
  echo "FAIL: no certificate found in CertificateSigningRequest jane"
  exit 1
fi

subject="$(openssl x509 -in "$WORK/jane.crt" -noout -subject -nameopt RFC2253 2>/dev/null | sed 's/^subject= *//')"
if ! printf '%s\n' "$subject" | grep -Eq '(^|,)CN=jane(,|$)'; then
  echo "FAIL: subject '$subject' does not have CN=jane"
  fail=1
fi
if ! printf '%s\n' "$subject" | grep -Eq '(^|,)O=reviewers(,|$)'; then
  echo "FAIL: subject '$subject' does not have O=reviewers"
  fail=1
fi

kubectl -n default get configmap kube-root-ca.crt -o jsonpath='{.data.ca\.crt}' > "$WORK/ca.crt" 2>/dev/null
if ! openssl verify -CAfile "$WORK/ca.crt" "$WORK/jane.crt" >/dev/null 2>&1; then
  echo "FAIL: the certificate is not signed by the cluster CA"
  fail=1
fi

if ! openssl x509 -in "$WORK/jane.crt" -noout -checkend 0 >/dev/null 2>&1; then
  echo "FAIL: the certificate has expired"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: certificate has CN=jane and O=reviewers, is signed by the cluster CA and is valid"
fi
exit "$fail"
