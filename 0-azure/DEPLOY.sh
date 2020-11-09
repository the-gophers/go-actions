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

az group show --name ${RESOURCE_GROUP}

az resource list --resource-group ${RESOURCE_GROUP} | jq -c '.[]'

