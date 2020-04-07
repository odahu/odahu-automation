###################################################################################
# Common required
###################################################################################
variable "tls_crt" {
  description = "TLS certificate to use for SSL termination"
}

variable "tls_key" {
  description = "TLS certificate private key to use for SSL termination"
}

variable "aws_region" {
  description = "Region of AWS resources"
}

###################################################################################
# Common optional
###################################################################################
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

###################################################################################
# Odahuflow required
###################################################################################
variable "odahuflow_version" {
  description = "Odahuflow release version"
}

variable "odahu_ui_version" {
  description = "Version of odahu-ui helm chart"
}

variable "cluster_domain_name" {
  description = "Odahuflow cluster FQDN"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
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

variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
}

variable "odahuflow_connections" {
  default     = []
  description = "TODO"
}

###################################################################################
# Odahuflow optional
###################################################################################

variable "jupyterhub_enabled" {
  default     = false
  type        = bool
  description = "Flag to install JupyterHub (true) or not (false)"
}

variable "jupyterlab_version" {
  default     = "latest"
  description = "Tag of docker images used as JupyterHub notebooks"
}

variable "packager_version" {}

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
# PostgreSQL
########################
variable "postgres" {
  default = {
    enabled : true,
    storage_size : "8Gi",
    replica_count : 1,
    password : "odahu"
  }
  type = object({
    enabled : bool,
    storage_size : string,
    replica_count : number,
    password : string
  })
  description = "PostgreSQL configuration"
}

########################
# Airflow
########################
variable "airflow" {
  default = {
    enabled : false,
    storage_size : "1Gi",
    log_storage_size : "1Gi",
    fernet_key : "changeme",
    dag_repo : "https://github.com/odahu/odahu-examples.git"
  }
  type = object({
    enabled : bool,
    storage_size : string,
    log_storage_size : string,
    fernet_key : string,
    dag_repo : string
  })
  description = "Airflow configuration"
}

variable "odahu_airflow_plugin_version" {
  description = "Odahuflow Airflow plugn version"
}

