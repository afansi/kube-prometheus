#!/bin/bash

OPERATOR_NAMESPACE="default"

if [ -z "$1" ]; then
    OPERATOR_NAMESPACE="default"
else
    OPERATOR_NAMESPACE="$1"
fi

echo "Undeploy everything..."

DEPLOY_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/resources"

if oc version; then
    KUBE_CLI=oc
else
    KUBE_CLI=kubectl
fi

$KUBE_CLI delete -f $DEPLOY_PATH/crd_artemis.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI delete -f $DEPLOY_PATH/crd_artemis_security.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI delete -f $DEPLOY_PATH/crd_artemis_address.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI delete -f $DEPLOY_PATH/crd_artemis_scaledown.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI delete -f $DEPLOY_PATH/service_account.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI delete -f $DEPLOY_PATH/cluster_role.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI delete -f $DEPLOY_PATH/namespace_role.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI delete -f $DEPLOY_PATH/cluster_role_binding.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI delete -f $DEPLOY_PATH/namespace_role_binding.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI delete -f $DEPLOY_PATH/election_role.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI delete -f $DEPLOY_PATH/election_role_binding.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI delete -f $DEPLOY_PATH/operator_config.yaml -n $OPERATOR_NAMESPACE
$KUBE_CLI delete -f $DEPLOY_PATH/operator.yaml -n $OPERATOR_NAMESPACE
