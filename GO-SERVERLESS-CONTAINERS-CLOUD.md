# Go for Serverless and Containers in the Cloud

## Getting Started
This is a GitHub template repo, so when you click "Use this template", it will create a new copy of this 
template in your org or personal repo of choice. Once you have created a repo from this template, you 
should be able to clone and navigate to the root of the repository.

### What's in Here?

### 0. Azure

```shell script
.
├── .github
│   └── workflows
│       ├── 0-azure.yml
│       ├── 0-azure-empty.yml
│       └── 0-azure-storage.yml
└── 0-azure
    ├── README.md
    ├── azuredeploy.json
    └── DEPLOY.sh
```

#### [README.md](./README.md)

Instructions on how to create an Azure Service Principal and create a GitHub Actions Secret (`AZURE_CREDENTIALS`) that will authenticate your GitHub Actions workflow to the Cloud.

**This step is a requirement for `2. Serverless Go Functions` and `3. Containers and Serverless Container Instances`**

#### [.github/workflows/0-azure.yml](./.github/workflows/0-azure.yml)

Our first Azure Actions workflow, triggered on `push` and `workflow_dispatch` events, that will use the `azure/login@v1` action to authenticate using the `AZURE_CREDENTIALS` GitHub secret, and run `0-azure/DEPLOY.sh` which runs two Azure CLI commands, `az group show` and `az resource list`.

#### [.github/workflows/0-azure-empty.yml](./.github/workflows/0-azure-empty.yml)

A manually triggered (`workflow_dispatch`) workflow that will use `az deployment group create` to deploy an empty Azure Resource Manager (ARM) template, `azuredeploy.json`, that will remove all the Azure Resources in our Resource Group.

#### [.github/workflows/0-azure-storage.yml](./.github/workflows/0-azure-storage.yml)

A stand-alone action (currently triggered on `workflow_dispatch`) that will install our Go CLI for Azure Storage, `azcopy`, authenticate against Azure using our `Service Principal` from our `AZURE_CREDENTIALS` GitHub Secret, and use the `azcopy sync` command to sync the contents of our local repository to an Azure Storage Container. 

Note: you will need to tweak this workflow according to how you would like to use it.

### 2. Serverless Go Functions

```shell script
.
├── .github
│   └── workflows
│       └── 2-functions.yml
└── 2-functions
     ├── README.md
     ├── ...
     ├── BUILD.sh
     └── DEPLOY.sh
     ├── main.go
     ├── host.json
     ├── healthz
     │    └── function.json
     └── TimerTrigger
          └── function.json
```

#### [README.md](./README.md)

Links to this README.md.

#### [.github/workflows/2-functions.yml](./.github/workflows/2-functions.yml)

Similar to `0-azure.yml`, this workflow runs our `2-functions/DEPLOY.sh`. It is triggered on `push` event, which is filtered to the path `2-functions/**`.

#### [2-functions/DEPLOY.sh](./2-functions/DEPLOY.sh)

A bash script that uses the Azure CLI (`az`) to:

- Create an Azure Storage account (`az acr create`)
- Create an Azure Functions App (`az functionapp create`)
- Set an environment variable, `SERVER_NAME`, for our application (`az functionapp config appsettings`) that includes the `GITHUB_SHA` variable in the format `hello-gopher-${GITHUB_SHA}"`
- Build our Go binary via `BUILD.sh`, using the Go version installed by default within GitHub Actions. Note: Commented out is the option to use `docker run` and `BUILD.sh` to build our binary using the `golang:1.15.3` containers.
- `zip` our binary to `deploy.zip` and deploy it to Azure Functions (`az functionapp deployment`)
- Confirm our function is up and running by running `curl` against our `https://${FUNCTION_NAME}.azurewebsites.net/api/healthz`, which outputs the name of the function, including the `GITHUB_SHA` above.

#### [2-functions/BUILD.sh](./2-functions/BUILD.sh)

Builds our Go binary as above. Optionally used inside a docker container should we choose to build our Go application inside of Docker.

#### [2-functions/main.go](./2-functions/main.go)

The entrypoint for our Go Functions application. A simple HTTP web server.

#### [2-functions/healthz/function.json](./2-functions/healthz/function.json)

The function definition for our `/api/healthz` endpoint which is triggered via an `HTTP Trigger`.

#### [2-functions/TimerTrigger/function.json](./2-functions/TimerTrigger/function.json)

The function definition for our `TimerTrigger` function, which is triggered via a cron-style `Timer trigger`.

### 3. Containers and Serverless Container Instances

```shell script
.
├── .github
│   └── workflows
│       └── 3-containers.yml
└── 3-containers
    ├── README.md
    ├── Dockerfile
    ├── main.go   
    └── DEPLOY.sh
```

#### [README.md](./README.md)

Links to this README.md

#### [.github/workflows/3-containers.yml](./.github/workflows/3-containers.yml)

Similar to `0-azure.yml`, this workflow runs our `3-containers/DEPLOY.sh`. It is triggered on `push` event, which is filtered to the path `3-containers/**`.

#### [3-containers/DEPLOY.sh](./3-containers/DEPLOY.sh)

A bash script that uses the Azure CLI (`az`) to:

- Create an Azure Container Registry (`az acr create`)
- Build our docker container, which builds our Go HTTP application via multi-stage build, inside the registry using Azure Container Registry Quick Tasks (`az acr build`)
- Get the credentials for our private Container Registry (`az acr get-credentials`)
- Deploy an Azure Container Instance (`az container create`), listening on Port 80

#### [3-containers/Dockerfile](./3-containers/DEPLOY.sh)

A simple Dockerfile that uses `golang:rc-alpine` image to perform a multi-stage build of our `hello-echo` echo server, using a `scratch` as the output image.

#### [3-containers/main.go](./3-containers/DEPLOY.sh)

A simple Go echo-server that listens on 3 endpoints, `/`, `/echo` and `/host`, with the ability to override the default port (80) via the `LISTEN_PORT` environment variable.

The `httpLog` function logs incoming requests to standard error.
