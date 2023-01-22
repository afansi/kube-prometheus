#!/bin/bash

echo "Deploying cluster-wide Operator"

#read -p "Enter namespaces to watch (empty for all namespaces): " WATCH_NAMESPACE
#if [ -z ${WATCH_NAMESPACE} ]; then
#  WATCH_NAMESPACE="*"
#fi

## this script allow watching the namespaces
OPERATOR_NAMESPACE="default"
WATCH_NAMESPACE="*"

if [ -z "$1" ]; then
    OPERATOR_NAMESPACE="default"
else
    OPERATOR_NAMESPACE="$1"
fi
if [ -z "$2" ]; then
    WATCH_NAMESPACE="*"
else
    WATCH_NAMESPACE="$2"
fi

DEPLOY_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/resources"

if oc version; then
    KUBE_CLI=oc
else
    KUBE_CLI=kubectl
fi

$KUBE_CLI create -f $DEPLOY_PATH/crd_artemis.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI create -f $DEPLOY_PATH/crd_artemis_security.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI create -f $DEPLOY_PATH/crd_artemis_address.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI create -f $DEPLOY_PATH/crd_artemis_scaledown.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI create -f $DEPLOY_PATH/service_account.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI create -f $DEPLOY_PATH/cluster_role.yaml -n $OPERATOR_NAMESPACE
SERVICE_ACCOUNT_NS="$(kubectl get -n $OPERATOR_NAMESPACE -f $DEPLOY_PATH/service_account.yaml -o jsonpath='{.metadata.namespace}')"
sed "s/namespace:.*/namespace: ${SERVICE_ACCOUNT_NS}/" $DEPLOY_PATH/cluster_role_binding.yaml | kubectl apply -n $OPERATOR_NAMESPACE -f -
$KUBE_CLI create -f $DEPLOY_PATH/election_role.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI create -f $DEPLOY_PATH/election_role_binding.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI create -f $DEPLOY_PATH/operator_config.yaml -n $OPERATOR_NAMESPACE
sed -e "/WATCH_NAMESPACE/,/- name/ { /WATCH_NAMESPACE/b; /valueFrom:/bx; /- name/b; d; :x s/valueFrom:/value: '${WATCH_NAMESPACE}'/}" $DEPLOY_PATH/operator.yaml | kubectl apply -n $OPERATOR_NAMESPACE -f -
