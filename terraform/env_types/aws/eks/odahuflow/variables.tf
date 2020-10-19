###################################################################################
# Common required
###################################################################################
variable "tls_crt" {
  type        = string
  description = "TLS certificate to use for SSL termination"
}

variable "tls_key" {
  type        = string
  description = "TLS certificate private key to use for SSL termination"
}

variable "aws_region" {
  type        = string
  description = "Region of AWS resources"
}

###################################################################################
# Common optional
###################################################################################
variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "config_context_auth_info" {
  type        = string
  description = "Kubernetes cluster context auth"
}

variable "config_context_cluster" {
  type        = string
  description = "Kubernetes cluster context name"
}

###################################################################################
# ODAHU flow required
###################################################################################
variable "odahuflow_version" {
  type        = string
  description = "ODAHU flow release version"
}

variable "odahu_automation_version" {
  type        = string
  description = "ODAHU flow automation image version"
}

variable "odahuflow_training_timeout" {
  type        = string
  default     = ""
  description = "ODAHU Flow maximum timeout for model training process (example: '24h')"
}

variable "odahu_ui_version" {
  type        = string
  description = "Version of odahu-ui helm chart"
}

variable "cluster_domain_name" {
  type        = string
  description = "ODAHU flow cluster FQDN"
}

variable "helm_repo" {
  type        = string
  description = "ODAHU flow helm repo"
}

variable "docker_repo" {
  type        = string
  description = "ODAHU flow Docker repo url"
}

variable "docker_username" {
  type        = string
  default     = ""
  description = "ODAHU flow Docker repo username"
}

variable "docker_password" {
  type        = string
  default     = ""
  description = "ODAHU flow Docker repo password"
}

variable "data_bucket" {
  type        = string
  description = "ODAHU flow data storage bucket"
}

variable "log_bucket" {
  type        = string
  default     = ""
  description = "ODAHU flow logs storage bucket"
}

variable "log_expiration_days" {
  type        = number
  default     = 1
  description = "ODAHU flow logs expiration days"
}

variable "mlflow_toolchain_version" {
  type        = string
  description = "Version of odahuflow-mlflow helm chart"
}

variable "oauth_oidc_issuer_url" {
  type        = string
  description = "OAuth2/OIDC provider Issuer URL"
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
  type        = string
  description = "OAuth2 Client ID"
}

variable "oauth_client_secret" {
  type        = string
  description = "OAuth2 Client Secret"
}

variable "odahu_infra_version" {
  type        = string
  description = "ODAHU flow infra release version"
}

variable "odahuflow_connections" {
  type        = any
  default     = []
  description = "Initial list of ODAHU flow connections (https://docs.odahu.org/ref_connections.html)"
}

###################################################################################
# ODAHU flow optional
###################################################################################

variable "jupyterhub_enabled" {
  type        = bool
  default     = false
  description = "Flag to install JupyterHub (true) or not (false)"
}

variable "jupyterlab_version" {
  type        = string
  default     = "latest"
  description = "Tag of docker images used as JupyterHub notebooks"
}

variable "packager_version" {
  type        = string
  description = "Version of ODAHU flow model packager"
}

variable "node_pools" {
  type        = any
  default     = {}
  description = "Default node pools configuration"
}

variable "service_accounts" {
  type = object({
    airflow = object({
      client_id     = string
      client_secret = string
    })
    test = object({
      client_id     = string
      client_secret = string
    })
    resource_uploader = object({
      client_id     = string
      client_secret = string
    })
    operator = object({
      client_id     = string
      client_secret = string
    })
    service_catalog = object({
      client_id     = string
      client_secret = string
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
    enabled = false
  }
  type = object({
    enabled = bool
  })
  description = "Vault configuration"
}

########################
# Airflow
########################
variable "airflow" {
  type = object({
    enabled          = bool
    storage_size     = string
    log_storage_size = string
    fernet_key       = string
    dag_repo         = string
    dag_bucket       = string
    dag_bucket_path  = string
  })
  default = {
    enabled          = false
    storage_size     = "1Gi"
    log_storage_size = "1Gi"
    fernet_key       = "changeme"
    dag_repo         = "https://github.com/odahu/odahu-examples.git"
    dag_bucket       = ""
    dag_bucket_path  = ""
  }
  description = "Airflow configuration"
}

variable "odahu_airflow_plugin_version" {
  type        = string
  description = "ODAHU flow Airflow plugn version"
}

variable "examples_version" {
  type        = string
  description = "Wine examples version"
}

########################
# PostgreSQL
########################
variable "postgres" {
  type = object({
    cluster_name  = string
    enabled       = bool
    storage_size  = string
    replica_count = number
  })
  default = {
    enabled       = true
    storage_size  = "8Gi"
    replica_count = 1
    cluster_name  = "odahu-db"
  }
  description = "PostgreSQL configuration"
}

variable "odahu_database" {
  type        = string
  description = "Name of database for ODAHU entities"
}

variable "backup_settings" {
  type = object({
    enabled     = bool
    bucket_name = string
    schedule    = string
    retention   = string
  })
  default = {
    enabled     = false
    bucket_name = ""
    schedule    = ""
    retention   = ""
  }
  description = "Configuration for PostgreSQL backups"
}
