#!/bin/bash

# Ingress controller

## Intall the Ingress
kubectl apply -f nginx-ingress/deployIngressKind.yaml

echo "Ingress Controller Installed"

## Workaround to be able to create ingresses without webhook admission checks
#### From https://stackoverflow.com/questions/61616203/nginx-ingress-controller-failed-calling-webhook
#### From https://stackoverflow.com/questions/61365202/nginx-ingress-service-ingress-nginx-controller-admission-not-found/62044090#62044090 
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission -n ingress-nginx

# Postgress Operator

## create the PGO namespace
kubectl apply -k postgres-operator/kustomize/install/namespace
# install PGO itself in cluster-wide mode
kubectl apply --server-side -k postgres-operator/kustomize/install/default

echo "PGO Installed"

## create the talky postgres cluster
kubectl apply -k postgres-operator/kustomize/postgres

echo "Postgres Cluster Installed"


# ActiveMQ-Artemis Operator

kubectl create -f activemq-artemis/namespace.yaml
bash ./activemq-artemis/operator/deploy/cluster_wide_install_opr.sh activemq-artemis

echo "ActiveMQ-Artemis Operator Installed"

# ActiveMQ-Artemis Broker

kubectl create -f activemq-artemis/broker -n activemq-artemis

echo "ActiveMQ-Artemis Broker Installed"



# Prometheus Operator (kube-prometheus)

## create the prometheus namespace
kubectl create -f prometheus-operator/kustomize/kube-prometheus/manifests/setup
### # Wait until the "servicemonitors" CRD is created. The message "No resources found" means success in this context.
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done

kubectl create -f prometheus-operator/kustomize/kube-prometheus/manifests/

echo "Prometheus-operator (kube-prometheus) Installed"