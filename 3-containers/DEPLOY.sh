#!/usr/bin/env bash
set -euo pipefail

# variables
RESOURCE_GROUP='201100-gophercon'
LOCATION='eastus'
SUBSCRIPTION_ID=$(az account show | jq -r .id)
SCOPE="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}"
# RANDOM_STR='da39a3'
RANDOM_STR=$(echo -n "$SCOPE" | shasum | head -c 6)
CREATE_IF_EXISTS="false"
# automatically set by actions workflow, but in case we're running locally
# [[ -z "${GITHUB_SHA:-}" ]] && GITHUB_SHA='test'
[[ -z "${GITHUB_SHA:-}" ]] && GITHUB_SHA=$(git rev-parse --short HEAD)

REPOSITORY_NAME="hello-gopher"
# create container registry
REGISTRY_NAME="acr${RANDOM_STR}"
az acr create -g $RESOURCE_GROUP -l $LOCATION --name $REGISTRY_NAME --sku Basic --admin-enabled true
# build image
CONTAINER_IMAGE=$REPOSITORY_NAME:$(date +%y%m%d)-${GITHUB_SHA}
az acr build -r $REGISTRY_NAME -t $CONTAINER_IMAGE --file Dockerfile .
# create container instance
REGISTRY_PASSWORD=$(az acr credential show -n $REGISTRY_NAME | jq -r .passwords[0].value)
CONTAINER_NAME="aci-${REPOSITORY_NAME}-${RANDOM_STR}"
az container create --resource-group $RESOURCE_GROUP --location $LOCATION \
    --name $CONTAINER_NAME \
    --image "${REGISTRY_NAME}.azurecr.io/${CONTAINER_IMAGE}" \
    --registry-login-server "${REGISTRY_NAME}.azurecr.io" \
    --registry-username $REGISTRY_NAME \
    --registry-password $REGISTRY_PASSWORD \
    --cpu 1 \
    --memory 1 \
    --ports 80 \
    --environment-variables LISTEN_PORT=80 \
    --dns-name-label ${REPOSITORY_NAME}-${RANDOM_STR}
FQDN=$(az container show -g $RESOURCE_GROUP --name $CONTAINER_NAME | jq -r .ipAddress.fqdn)
echo "http://${FQDN}"
