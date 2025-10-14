#!/bin/bash

microk8s kubectl apply -f namespace.yaml
microk8s kubectl apply -f zookeeper.yaml
microk8s kubectl apply -f kafka-broker-1.yaml
microk8s kubectl apply -f kafka-broker-2.yaml
microk8s kubectl apply -f kafka-broker-3.yaml
microk8s kubectl apply -f kafka-broker-ui.yaml
microk8s kubectl apply -f kafka-broker-init.yaml

