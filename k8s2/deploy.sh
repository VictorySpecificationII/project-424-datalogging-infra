#!/bin/bash
microk8s kubectl apply -f namespace.yaml
microk8s kubectl apply -f zookeeper-cluster.yaml
microk8s kubectl wait --for=condition=Ready pod -l app=zookeeper -n perrinn-424-rt-streaming --timeout=300s
microk8s kubectl apply -f zoonavigator-ui.yaml
microk8s kubectl wait --for=condition=Ready pod -l app=zoonavigator -n perrinn-424-rt-streaming --timeout=180s
microk8s kubectl apply -f kafka-cluster.yaml
microk8s kubectl wait --for=condition=Ready pod -l app=kafka-broker-1 -n perrinn-424-rt-streaming --timeout=180s
microk8s kubectl wait --for=condition=Ready pod -l app=kafka-broker-2 -n perrinn-424-rt-streaming --timeout=180s
microk8s kubectl wait --for=condition=Ready pod -l app=kafka-broker-3 -n perrinn-424-rt-streaming --timeout=180s
microk8s kubectl wait --for=condition=complete job/init-kafka -n perrinn-424-rt-streaming --timeout=180s
microk8s kubectl apply -f kafka-ui.yaml
microk8s kubectl wait --for=condition=Ready pod -l app=kafka-ui -n perrinn-424-rt-streaming --timeout=180s
microk8s kubectl apply -f kafka-rest-proxy.yaml
