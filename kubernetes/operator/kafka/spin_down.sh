#!/bin/bash

# Exit immediately if a command fails
set -e

NAMESPACE="kafka"
STRIMZI_VERSION="latest"
CLUSTER_NAME="my-cluster"

echo "Deleting Kafka cluster and Strimzi custom resources..."
microk8s kubectl -n "$NAMESPACE" delete $(microk8s kubectl get kafka -o name -n "$NAMESPACE") || echo "No Kafka clusters found."

echo "Deleting Persistent Volume Claims (PVCs) used by the cluster..."
microk8s kubectl delete pvc -l strimzi.io/name=${CLUSTER_NAME}-kafka -n "$NAMESPACE" || echo "No PVCs found."

echo "Deleting Strimzi cluster operator..."
microk8s kubectl -n "$NAMESPACE" delete -f "https://strimzi.io/install/$STRIMZI_VERSION?namespace=$NAMESPACE" || echo "Strimzi operator not found."

echo "Optionally, delete the namespace '$NAMESPACE'? (y/N)"
read -r DELETE_NS
if [[ "$DELETE_NS" =~ ^[Yy]$ ]]; then
    echo "Deleting namespace '$NAMESPACE'..."
    microk8s kubectl delete namespace "$NAMESPACE" || echo "Namespace '$NAMESPACE' already deleted."
fi

echo "Spin-down completed."
