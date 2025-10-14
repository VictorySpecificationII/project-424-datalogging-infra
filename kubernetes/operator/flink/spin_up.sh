#!/bin/bash

echo "Installing Flink Operator..."
microk8s kubectl apply -f https://github.com/spotify/flink-on-k8s-operator/releases/download/v0.5.5/flink-operator.yaml
echo "Spinning up Flink Cluster..."
microk8s kubectl apply -f https://raw.githubusercontent.com/spotify/flink-on-k8s-operator/refs/heads/master/config/samples/flinkoperator_v1beta1_flinksessioncluster.yaml
echo "Patching job manager to NodePort"
microk8s kubectl patch svc flinksessioncluster-sample-jobmanager -n default -p '{"spec": {"type": "NodePort"}}'
