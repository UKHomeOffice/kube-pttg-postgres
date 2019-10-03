#!/bin/bash

export KUBE_NAMESPACE=${KUBE_NAMESPACE}
export KUBE_SERVER=${KUBE_SERVER}
export WHITELIST=${WHITELIST:-0.0.0.0/0}

if [[ -z ${VERSION} ]] ; then
    export VERSION=${IMAGE_VERSION}
fi

echo "deploy ${VERSION} to ${ENVIRONMENT} namespace - using Kube token stored as drone secret"

if [[ ${ENVIRONMENT} == "pr" ]] ; then
    export KUBE_TOKEN=${PTTG_IP_PR}
    export DNS_PREFIX=
    export KC_REALM=pttg-production
else
    export KUBE_TOKEN=${PTTG_IP_DEV}
    export DNS_PREFIX=${ENVIRONMENT}.notprod.
    export KC_REALM=pttg-qa
fi

# Production RDS is up constantly
# dev/test RDS stops every night and starts every morning
# feat/preprod RDS stops every night and is started on demand (by deploying pttg-postgres or scaling up from zero)
export START_RDS_EVERY_MORNING=false
export STOP_RDS_EVERY_NIGHT=false
if [[ ${ENVIRONMENT} == "dev" ]] || [[ ${ENVIRONMENT} == "test" ]] ; then
    export START_RDS_EVERY_MORNING=true
fi
if [[ ${ENVIRONMENT} != "pr" ]] ; then
    export STOP_RDS_EVERY_NIGHT=true
fi

export DOMAIN_NAME=fs.${DNS_PREFIX}pttg.homeoffice.gov.uk

echo "DOMAIN_NAME is $DOMAIN_NAME"

cd kd || exit 1

kd --insecure-skip-tls-verify \
    -f networkPolicy.yaml \
    -f rds-configmap.yaml\
    -f service.yaml \
    -f start-rds-cronjob.yaml \
    -f stop-rds-cronjob.yaml \
    -f deployment.yaml
