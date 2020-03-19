##################
# Common
##################
variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "config_context_auth_info" {
  description = "Kubernetes cluster context auth"
}

variable "config_context_cluster" {
  description = "Kubernetes cluster context name"
}

variable "project_id" {
  description = "Target project id"
}

variable "zone" {
  description = "Default zone"
}

variable "region" {
  description = "Region of resources"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "tiller_image" {
  default = "gcr.io/kubernetes-helm/tiller:v2.14.3"
}

variable "cluster_domain_name" {
  description = "Odahuflow cluster FQDN"
}

variable "tls_key" {
  description = "TLS key for Odahuflow cluster"
}

variable "tls_crt" {
  description = "TLS certificate file for Odahuflow cluster"
}

##################
# Odahuflow app
##################
variable "odahuflow_version" {
  description = "Odahuflow release version"
}

variable "odahu_airflow_plugin_version" {
  description = "Odahuflow Airflow plugn version"
}

variable "docker_repo" {
  description = "Odahuflow Docker repo url"
}

variable "docker_username" {
  default     = ""
  description = "Odahuflow Docker repo username"
}

variable "docker_password" {
  default     = ""
  description = "Odahuflow Docker repo password"
}

variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
}

variable "odahu_ui_version" {
  description = "Version of odahu-ui helm chart"
}

variable "data_bucket" {
  description = "Odahuflow data storage bucket"
}

variable "mlflow_toolchain_version" {
  description = "Version of odahuflow-mlflow helm chart"
}

variable "oauth_oidc_issuer_url" {
  description = "OAuth2/OIDC provider Issuer URL"
}

variable "oauth_oidc_token_endpoint" {
  type        = string
  description = "OpenID Provider Token URL"
}

variable "oauth_client_id" {
  description = "OAuth2 Client ID"
}

variable "oauth_client_secret" {
  description = "OAuth2 Client Secret"
}

variable "model_authorization_enabled" {
  description = "Is model authorization enabled"
  default     = "false"
}

# TODO: Remove after implementation of the issue https://github.com/legion-platform/legion/issues/1008
variable "odahuflow_connection_decrypt_token" {
  default = "Token for getting a decrypted connection"
}

variable "jupyterhub_enabled" {
  default     = false
  type        = bool
  description = "Flag to install JupyterHub (true) or not (false)"
}

variable "jupyterlab_version" {
  default     = "latest"
  description = "Tag of docker images used as JupyterHub notebooks"
}

variable "packager_version" {
  description = ""
}

variable "odahuflow_connections" {
  default     = []
  description = "TODO"
}

variable "node_pools" {
  default = {}
}

variable "service_accounts" {
  type = object({
    airflow : object({
      client_id : string
      client_secret : string
    })
    test : object({
      client_id : string
      client_secret : string
    })
    resource_uploader : object({
      client_id : string
      client_secret : string
    })
    operator : object({
      client_id : string
      client_secret : string
    })
  })
  description = "Service accounts credentials"
}

variable "oauth_mesh_enabled" {
  type        = bool
  description = "OAuth2 inside service mesh via Envoy filter"
}

variable "vault" {
  default = {
    enabled : false
  }
  type = object({
    enabled : bool
  })
  description = "Vault configuration"
}

########################
# NFS
########################
variable "nfs" {
  default = {
    enabled : false,
    storage_size : "10Gi"
  }
  type = object({
    enabled : bool,
    storage_size : string
  })
  description = "NFS configuration"
}

########################
# Airflow
########################
variable "airflow" {
  default = {
    enabled : false,
    storage_size : "1Gi",
    log_storage_size : "1Gi",
    fernet_key : "changeme"
  }
  type = object({
    enabled : bool,
    storage_size : string,
    log_storage_size : string,
    fernet_key : string
  })
  description = "Airflow configuration"
}

variable "postgres_password" {}

##################
# Test
##################

variable "wine_data_url" {
  description = "Wine example data URL"
}

