##################
# Common
##################
variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
  type        = string
}

variable "config_context_auth_info" {
  description = "Kubernetes cluster context auth"
  type        = string
}

variable "config_context_cluster" {
  description = "Kubernetes cluster context name"
  type        = string
}

variable "project_id" {
  description = "Target project id"
  type        = string
}

variable "zone" {
  description = "Default zone"
  type        = string
}

variable "region" {
  description = "Region of resources"
  type        = string
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
  type        = string
}

variable "cluster_domain_name" {
  description = "Odahuflow cluster FQDN"
  type        = string
}

variable "tls_key" {
  description = "TLS key for Odahuflow cluster"
  type        = string
}

variable "tls_crt" {
  description = "TLS certificate file for Odahuflow cluster"
  type        = string
}

##################
# Odahuflow app
##################
variable "odahuflow_version" {
  description = "Odahuflow release version"
  type        = string
}

variable "odahuflow_training_timeout" {
  default     = ""
  description = "ODAHU Flow maximum timeout for model training process (example: '24h')"
  type        = string
}

variable "odahu_airflow_plugin_version" {
  description = "Odahuflow Airflow plugn version"
  type        = string
}

variable "docker_repo" {
  description = "Odahuflow Docker repo url"
  type        = string
}

variable "docker_username" {
  default     = ""
  description = "Odahuflow Docker repo username"
  type        = string
}

variable "docker_password" {
  default     = ""
  description = "Odahuflow Docker repo password"
  type        = string
}

variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
  type        = string
}

variable "odahu_ui_version" {
  description = "Version of odahu-ui helm chart"
  type        = string
}

variable "data_bucket" {
  description = "Odahuflow data storage bucket"
  type        = string
}

variable "mlflow_toolchain_version" {
  description = "Version of odahuflow-mlflow helm chart"
  type        = string
}

variable "oauth_oidc_issuer_url" {
  description = "OAuth2/OIDC provider Issuer URL"
  type        = string
}

variable "oauth_oidc_token_endpoint" {
  type        = string
  description = "OpenID Provider Token URL"
}

variable "oauth_oidc_signout_endpoint" {
  type        = string
  description = "OpenID end_session_endpoint URL"
}

variable "oauth_client_id" {
  description = "OAuth2 Client ID"
  type        = string
}

variable "oauth_client_secret" {
  description = "OAuth2 Client Secret"
  type        = string
}

variable "model_authorization_enabled" {
  description = "Is model authorization enabled"
  default     = "false"
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

##################
# Test
##################

variable "wine_data_url" {
  description = "Wine example data URL"
}

variable "examples_version" {
  description = "Wine examples version"
}
