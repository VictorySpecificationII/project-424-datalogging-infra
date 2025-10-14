#!/bin/bash

echo "Installing cert-manager..."
microk8s kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.8.1/cert-manager.yaml

