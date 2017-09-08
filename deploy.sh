#!/usr/bin/env bash
export KUBE_NAMESPACE=${KUBE_NAMESPACE:-${DRONE_DEPLOY_TO}}

if [ $ENVIRONMENT == "prod" ]
then
    export KUBE_TOKEN=${PROD_KUBE_TOKEN}
fi

cd kd
kd --insecure-skip-tls-verify \
   --file deployment.yaml \
   --file service.yaml \
   --retries 50
