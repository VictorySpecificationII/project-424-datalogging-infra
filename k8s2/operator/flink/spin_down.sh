#!/bin/bash

set -e

echo "=== Deleting all Flink custom resources ==="
microk8s kubectl delete flinkclusters --all --all-namespaces || true

echo "=== Deleting Flink CRD ==="
microk8s kubectl delete crd flinkclusters.flinkoperator.k8s.io || true

echo "=== Deleting Flink Operator ==="
microk8s kubectl delete -f https://github.com/spotify/flink-on-k8s-operator/releases/download/v0.5.5/flink-operator.yaml || true

echo "=== Deleting Flink example cluster YAML (session/job) ==="
microk8s kubectl delete -f https://raw.githubusercontent.com/spotify/flink-on-k8s-operator/refs/heads/master/config/samples/flinkoperator_v1beta1_flinksessioncluster.yaml || true

echo "=== Cleanup complete ==="
