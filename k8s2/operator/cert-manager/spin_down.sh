#!/bin/bash

echo "=== Deleting cert-manager ==="
microk8s kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v1.8.1/cert-manager.yaml || true

echo "=== Deleting cert-manager CRDs ==="
for crd in $(microk8s kubectl get crds | grep cert-manager | awk '{print $1}'); do
    echo "Deleting CRD $crd"
    microk8s kubectl delete crd $crd || true
done

echo "=== Cleanup complete ==="

