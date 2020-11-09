# Deploy to Azure with GitHub Actions

You will need an Azure Subscription (e.g. [Free](https://aka.ms/azure-free-account) or [Student](https://aka.ms/azure-student-account)) to be able to authenticate your GitHub Actions against Azure.

## 1. Create Azure Service Principal 

Open your local [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) (+[jq](https://stedolan.github.io/jq/download/)), the [Azure Cloud Shell (bash)](https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart) or <https://shell.azure.com/> and run the following snippet:

```bash
RESOURCE_GROUP='201100-gophercon'
LOCATION='eastus'
SUBSCRIPTION_ID=$(az account show | jq -r .id)

az group create -n $RESOURCE_GROUP -l $LOCATION

SP=$(az ad sp create-for-rbac --sdk-auth -n $RESOURCE_GROUP --role contributor \
    --scopes "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}")
echo $SP | jq -c
```

## 2. Create GitHub Actions Secret

Copy the JSON output above and create a secret named `AZURE_CREDENTIALS` under `Settings > Secrets` in your GitHub repository's [Settings](../../../settings/secrets).

## 3. Modify [DEPLOY.sh](DEPLOY.sh) and trigger a build

1. Set the correct variables for `RESOURCE_GROUP`, etc, under `# variables` in [DEPLOY.sh](DEPLOY.sh).
1. Modify [DEPLOY.txt](DEPLOY.txt) to trigger a build.

