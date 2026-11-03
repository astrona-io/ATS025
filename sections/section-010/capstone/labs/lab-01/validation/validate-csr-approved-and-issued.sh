#!/usr/bin/env bash
# Check: a CertificateSigningRequest named jane exists, uses the client
# signer with the client auth usage, is approved and holds a certificate.
set -uo pipefail

fail=0
if ! kubectl get csr jane >/dev/null 2>&1; then
  echo "FAIL: CertificateSigningRequest jane does not exist"
  exit 1
fi

signer="$(kubectl get csr jane -o jsonpath='{.spec.signerName}' 2>/dev/null)"
if [ "$signer" != "kubernetes.io/kube-apiserver-client" ]; then
  echo "FAIL: signerName is '$signer', expected kubernetes.io/kube-apiserver-client"
  fail=1
fi

usages="$(kubectl get csr jane -o jsonpath='{.spec.usages[*]}' 2>/dev/null)"
case " $usages " in
  *" client auth "*) ;;
  *) echo "FAIL: usages '$usages' do not include client auth"; fail=1 ;;
esac

approved="$(kubectl get csr jane -o jsonpath='{.status.conditions[?(@.type=="Approved")].status}' 2>/dev/null)"
if [ "$approved" != "True" ]; then
  echo "FAIL: the request is not approved"
  fail=1
fi

cert="$(kubectl get csr jane -o jsonpath='{.status.certificate}' 2>/dev/null)"
if [ -z "$cert" ]; then
  echo "FAIL: status.certificate is empty, the request has not been signed"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: CertificateSigningRequest jane is approved and a certificate is issued"
fi
exit "$fail"
