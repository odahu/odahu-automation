# Prerequisities

- [Create Azure Service Principal](https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html#creating-a-service-principal) account and declare environment variables, necessary for Terraform provider.
```bash
$ export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
$ export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
$ export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
$ export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
$ export TF_VAR_sp_client_id=${ARM_CLIENT_ID}
$ export TF_VAR_sp_secret=${ARM_CLIENT_SECRET}
```

- Login as service principal using [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli):
```bash
$ az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
```

- Turn on all necessary Azure Preview functions ([VMSS](https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler), [multiple AKS node pools](https://docs.microsoft.com/en-us/azure/aks/use-multiple-node-pools), [AKS availability zones](https://docs.microsoft.com/en-us/azure/aks/availability-zones), [secure access to the AKS API](https://docs.microsoft.com/en-us/Azure/aks/api-server-authorized-ip-ranges)):
```bash
$ az extension add --name aks-preview
$ az feature register --namespace Microsoft.ContainerService -n VMSSPreview
$ az feature register --namespace Microsoft.ContainerService -n MultiAgentpoolPreview
$ az feature register --namespace Microsoft.ContainerService -n AvailabilityZonePreview
$ az feature register --namespace Microsoft.ContainerService -n APIServerSecurityPreview
$ az provider register -n Microsoft.ContainerService
```

- Create resource group for Terraform remote backend and all base resources of AKS cluster:
```bash
$ export CLUSTER_NAME="legion-test"
$ export RG=${CLUSTER_NAME}
$ az group create --name $RG --location eastus --tags environment=Testing cluster=$CLUSTER_NAME
```

- Create public IP that will be used as Kubernetes cluster endpoint
```bash
$ az network public-ip create --name $CLUSTER_NAME --resource-group $RG --allocation-method Static \
    --sku Basic --version IPv4 --tags environment=Testing cluster=$CLUSTER_NAME purpose="Kubernetes cluster endpoint"
```

- Create storage account in this storage group:
```bash
$ export AZURE_STORAGE_ACCOUNT="storage7868768" # Some unique name without dashes, underscores and capitals
$ az storage account create --resource-group $RG \
	--name $AZURE_STORAGE_ACCOUNT --sku Standard_LRS --encryption-services blob \
	--tags environment=Testing cluster=$CLUSTER_NAME purpose="Terraform Backend storage"
```

- Create storage container (aka blob bucket):
```bash
$ export STORAGE_CONTAINER="tfstates-bucket"
$ az storage container create --name $STORAGE_CONTAINER --account-name $AZURE_STORAGE_ACCOUNT \
	--metadata environment=Testing cluster=$CLUSTER_NAME purpose="Terraform Backend storage"
```