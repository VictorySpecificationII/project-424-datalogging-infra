#!/bin/bash

# Create namespaces first
microk8s kubectl apply -f namespace.yaml

# Kafka
microk8s kubectl apply -f kafka-cluster.yaml
microk8s kubectl apply -f kafka-ui.yaml
microk8s kubectl apply -f kafka-rest-proxy.yaml

# Flink
microk8s kubectl apply -f flink-cluster.yaml

# Cassandra
microk8s kubectl apply -f cassandra.yaml

# Optional: Wait for pods to be ready (basic, simple approach)
echo "Waiting for all pods to be ready..."
microk8s kubectl wait --for=condition=ready pod -n kafka --all --timeout=300s
microk8s kubectl wait --for=condition=ready pod -n flink --all --timeout=300s
microk8s kubectl wait --for=condition=ready pod -n cassandra --all --timeout=300s

echo "Deployment complete!"
