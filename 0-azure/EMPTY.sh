#!/usr/bin/env bash
set -euo pipefail

# variables
RESOURCE_GROUP='201100-gophercon'

echo "emptying resource group: ${RESOURCE_GROUP}"
az deployment group create --resource-group $RESOURCE_GROUP \
	--template-file azuredeploy.json \
	--mode Complete \
	--name empty

