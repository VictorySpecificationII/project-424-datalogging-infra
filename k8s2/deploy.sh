#!/bin/bash
microk8s kubectl apply -f namespace.yaml
microk8s kubectl apply -f kafka-cluster.yaml
microk8s kubectl apply -f kafka-ui.yaml
microk8s kubectl apply -f kafka-rest-proxy.yaml
