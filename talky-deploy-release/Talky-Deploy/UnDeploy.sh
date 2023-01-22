#!/bin/bash

# Prometheus Operator 

kubectl delete --ignore-not-found=true -f prometheus-operator/kustomize/kube-prometheus/manifests/ -f prometheus-operator/kustomize/kube-prometheus/manifests/setup

echo "Prometheus-operator (kube-prometheus) Uninstalled"

# ActiveMQ-Artemis Broker

kubectl delete -f activemq-artemis/broker -n activemq-artemis

echo "ActiveMQ-Artemis broker Uninstalled"

# ActiveMQ-Artemis Operator

bash ./activemq-artemis/operator/deploy/undeploy_all.sh activemq-artemis
kubectl delete -f activemq-artemis/namespace.yaml

echo "ActiveMQ-Artemis Operator Uninstalled"


# Delete the postgres cluster

kubectl delete -k postgres-operator/kustomize/postgres

echo "Postgres Cluster Uninstalled"


# Postgress Operator

## unistall PGO in cluster-wide mode
kubectl delete -k postgres-operator/kustomize/install/default
## unistall PGO namespace
kubectl delete -k postgres-operator/kustomize/install/namespace

echo "PGO Uninstalled"

# Ingress controller

kubectl delete -f nginx-ingress/deployIngressKind.yaml

echo "Ingress Controller Uninstalled"