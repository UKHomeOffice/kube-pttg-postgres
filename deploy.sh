#!/usr/bin/env bash
export KUBE_NAMESPACE=${KUBE_NAMESPACE:-${DRONE_DEPLOY_TO}}
export KUBE_SERVER=${KUBE_SERVER}

cd kd
kd --insecure-skip-tls-verify \
   --file deployment.yaml \
   --file service.yaml \
   --retries 50
