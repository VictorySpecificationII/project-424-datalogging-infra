#!/bin/bash

# Exit immediately if a command fails
set -e

NAMESPACE="kafka"
STRIMZI_VERSION="latest"
KAFKA_IMAGE="quay.io/strimzi/kafka:0.48.0-kafka-4.1.0"
CLUSTER_NAME="my-cluster"
TOPIC_NAME="my-topic"

echo "Creating namespace '$NAMESPACE'..."
microk8s kubectl create namespace "$NAMESPACE" || echo "Namespace '$NAMESPACE' already exists."

echo "Deploying Strimzi cluster operator..."
microk8s kubectl create -f "https://strimzi.io/install/$STRIMZI_VERSION?namespace=$NAMESPACE" -n "$NAMESPACE"

echo "Waiting for Strimzi operator to be ready..."
microk8s kubectl rollout status deployment/strimzi-cluster-operator -n "$NAMESPACE"

echo "Creating Kafka cluster..."
microk8s kubectl apply -f "https://strimzi.io/examples/$STRIMZI_VERSION/kafka/kafka-single-node.yaml" -n "$NAMESPACE"

echo "Waiting for Kafka cluster '$CLUSTER_NAME' to be ready..."
microk8s kubectl wait kafka/$CLUSTER_NAME --for=condition=Ready --timeout=300s -n "$NAMESPACE"

echo "Patching broker to node port"
microk8s kubectl patch svc my-cluster-kafka-bootstrap -n kafka -p '{"spec": {"type": "NodePort"}}'

echo "Kafka cluster '$CLUSTER_NAME' is ready."

echo "You can now produce messages using the following command:"
echo "microk8s kubectl -n $NAMESPACE run kafka-producer -ti --image=$KAFKA_IMAGE --rm=true --restart=Never -- bin/kafka-console-producer.sh --bootstrap-server ${CLUSTER_NAME}-kafka-bootstrap:9092 --topic $TOPIC_NAME"

echo "And consume messages using the following command:"
echo "microk8s kubectl -n $NAMESPACE run kafka-consumer -ti --image=$KAFKA_IMAGE --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server ${CLUSTER_NAME}-kafka-bootstrap:9092 --topic $TOPIC_NAME --from-beginning"

