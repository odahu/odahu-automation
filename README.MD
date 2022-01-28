
## Overview
This repository contains automation for ODAHU provisioning and configuration.
For more details and technical documentation see the ODAHU documentation repository https://odahu.epam.com/docs/latest/index.html


## ODAHU infrastructure setup with Terraform
Prerequisites:
 For each of the clusters you need to have have the next preconfigured items:
 - GCS Bucket for terraform state with name equal to "<CLUSTER_NAME>-tfstate"
 - Create `cluster_profile.json` file with terraform variables (should be specified for each terraform run as a -var-file argument)
 - SSL certificate and private key should be defined as `tls_crt` and `tls_key` variables in `cluster_profile.json`
 - SSH public key should be defined as `ssh_key` variable in `cluster_profile.json`
 - Reserve Static IP "<CLUSTER_NAME>-nat-gw" and add this IP to Oauth provider (Keycloak for example)

In order to setup legion cluster at GCP with provided modules you have to trigger terraform for each of the ODAHU infrastructure layer.
The order of infrastructure components provisioning is the next:
GKE cluster:
 - gke_create: creates all components at GCP including GKE Kubernetes cluster itself
 - helm_init: setup Helm with required permissions on GKE cluster
 - k8s_setup: setup all Kubernetes components and dependencies required for ODAHU platform
 - legion: install ODAHU Helm chart itself with required platform components
EKS cluster:
 - TBC

Terraform modules for each of the layer could be applied by running the set of commands below from the corresponding module directory:
### TERRAFORM INIT

```bash
CLUSTER_NAME=<CLUSTER_NAME_HERE> TF_DATA_DIR=/tmp/.terraform_${CLUSTER_NAME}_${PWD##*/} bash -c 'terraform init -backend-config="bucket=${CLUSTER_NAME}-tfstate"'
```

### TERRAFORM PLAN

```bash
CLUSTER_NAME=<CLUSTER_NAME_HERE> TF_DATA_DIR=/tmp/.terraform_${CLUSTER_NAME}_${PWD##*/} bash -c 'terraform plan \
-var-file=/PATH/TO/VARIABLES.json \
-var="agent_cidr=<YOUR_IP_HERE>/32"'
```

### TERRAFORM APPLY

```bash
CLUSTER_NAME=<CLUSTER_NAME_HERE> TF_DATA_DIR=/tmp/.terraform_${CLUSTER_NAME}_${PWD##*/} bash -c 'terraform apply \
-var-file=/PATH/TO/VARIABLES.json \
-var="agent_cidr=<YOUR_IP_HERE>/32"'
```

There is also a helper script which allows you to create fully configured ODAHU cluster with a single command.
The easiest way to run the script is to use prebuilt docker image containing all required components.
You should pass cluster_profile.json file with all parameters required for cluster setup (refer to vars_template.yaml for details) and appropriate credentials for cloud operations (e.g `GOOGLE_CREDENTIALS`, `AWS_ACCESS_KEY`, etc.).
Here is the example of command which mounts all dependencies to the docker container and triggers a cluster creation:

```bash
docker run -v <local_path_to_cluster_profile.json>:/tmp/cluster_profile.json -v <path_to_local_gcp_credentials_file.json>/:/tmp/gcp_credentials_file.json -e PROFILE=/tmp/cluster_profile.json -e GOOGLE_CREDENTIALS=/tmp/gcp_credentials_file.json terraform:latest tf_runner create
```

Mandatory parameters are `PROFILE` and `GOOGLE_CREDENTIALS` environment variables which point to the mounted files required for cluster provisioning.
The same way [`tf_runner`](tools/tf_runner.sh) script could be executed locally if you have all dependencies available.

## Cluster profile preparation
In order to setup ODAHU cluster with all components you should have cluster profile with all parameters required for platform setup.
The file should be provided as a json file to terraform modules with -var-file argument. All required variables with their purposes could be find in [`vars_template.yaml`](vars_template.yaml) file in this repository.
You may want to create cluster profile manually or use [`hiera_exporter`](tools/hiera_exporter) helper script to pull the data from hiera data storage.

# Hiera data export
Hiera allows you to store hierarchical data in yaml format and request required data structures matching request filters.
For ODAHU CI/CD purposes we use separate profiles repository (as you may want to do as well) with yaml files describing clusters setup.
Place `private_key.pkcs7.pem` and `public_key.pkcs7.pem` keys to expected location (`/etc/puppetlabs/puppet/eyaml/` by default) and trigger [`hiera_exporter`](tools/hiera_exporter) script from hieradata directory with proper arguments.
This will generate Terraform compatible variables json file which should be used with Terraform modules for clusters setup.

# Cluster profile parameters for the Security system

In order to activate security system that provides authentication and authorization cluster profile parameters below should be filled.

(For more information see docs about [security](http://docs.odahu.epam.com/gen_security.html) and docs about [odahu helm charts configuration](http://docs.odahu.epam.com/odahu/odahu-docs/out/tutorials_installation.html#install-open-policy-agent-optional))


Security subsystem activation parameters:

```yaml
authorization_enabled: true
authz_dry_run: false
```

Service accounts client credentials (every account should be OAuth2 client with Client Credentials Grant):

```yaml
service_accounts:
  airflow:
    client_id: <your-client-id-here>
    client_secret: <your-client-secret-here>
  operator:
    client_id: <your-client-id-here>
    client_secret: <your-client-secret-here>
  resource_uploader:
    client_id: <your-client-id-here>
    client_secret: <your-client-secret-here>
  test:
    client_id: <your-client-id-here>
    client_secret: <your-client-secret-here>
```

OpenID Connect Provider settings. (For more information about OpenID see [specification docs](https://openid.net/specs/openid-connect-core-1_0.html))

```yaml
oauth_local_jwks: <base64 encoded local JWKS>
oauth_mesh_enabled: true  # enable mesh 
oauth_oidc_audience: legion
oauth_oidc_host: <oidc hostname>
oauth_oidc_issuer_url: <OpenID Issuer url>
oauth_oidc_jwks_url: <OpenID Remote JWKS url>
oauth_oidc_port: 443
oauth_oidc_scope: openid profile email offline_access groups  
oauth_oidc_token_endpoint: <OpenID Token endpoint>
```
