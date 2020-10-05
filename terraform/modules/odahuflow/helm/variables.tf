####################
### Distribution ###
####################

variable "helm_repo" {
  type        = string
  description = "ODAHU flow helm repo"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm chart deploy timeout in seconds"
}

variable "docker_repo" {
  type        = string
  description = "ODAHU flow Docker repo url"
}

variable "docker_secret_name" {
  type        = string
  default     = "repo-json-key"
  description = "ODAHU flow Docker repo secret name to create"
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

variable "odahuflow_version" {
  type        = string
  description = "ODAHU flow release version"
}

variable "packager_version" {
  type        = string
  description = "Packager version"
}

variable "mlflow_toolchain_version" {
  type        = string
  description = "Version of odahu-flow-mlflow helm chart"
}

variable "odahu_ui_version" {
  type        = string
  description = "Version of odahu-ui helm chart"
}

###############
### Ingress ###
###############

variable "cluster_domain" {
  type        = string
  description = "ODAHU flow cluster domain"
}

variable "tls_secret_crt" {
  type        = string
  default     = ""
  description = "ODAHU flow cluster TLS certificate"
}

variable "tls_secret_key" {
  type        = string
  default     = ""
  description = "ODAHU flow cluster TLS key"
}

##################
# Namespaces
##################

variable "odahuflow_namespace" {
  type        = string
  default     = "odahu-flow"
  description = "ODAHU flow k8s namespace"
}

variable "odahuflow_training_namespace" {
  type        = string
  default     = "odahu-flow-training"
  description = "ODAHU flow training k8s namespace"
}

variable "odahuflow_packaging_namespace" {
  type        = string
  default     = "odahu-flow-packaging"
  description = "ODAHU flow packaging k8s namespace"
}

variable "odahuflow_deployment_namespace" {
  type        = string
  default     = "odahu-flow-deployment"
  description = "ODAHU flow deployment k8s namespace"
}

variable "knative_namespace" {
  type        = string
  default     = "knative-serving"
  description = "Knative Serving component namespace"
}

variable "vault_namespace" {
  type        = string
  description = "Vault namespace"
}

variable "vault_tls_secret_name" {
  type        = string
  description = "Vault TLS secret name in vault namespace"
}

variable "fluentd_namespace" {
  type        = string
  default     = "fluentd"
  description = "Fluentd namespace"
}

##################
# ODAHU flow app
##################

variable "odahuflow_connections" {
  type        = any
  default     = []
  description = "Initial list of ODAHU flow connections (https://docs.odahu.org/ref_connections.html)"
}

##################
# ODAHU flow config
##################

variable "odahuflow_training_timeout" {
  type        = string
  default     = ""
  description = "ODAHU Flow maximum timeout for model training process (example: '24h')"
}

variable "extra_external_urls" {
  type = list(object({
    name     = string
    url      = string
    imageUrl = string
  }))
  default = []
}

variable "connection_vault_configuration" {
  type = object({
    secretEnginePath = string
    role             = string
    url              = string
  })
  default = {
    secretEnginePath = "odahu-flow/connections"
    role             = "odahu-flow"
    url              = "https://vault.vault:8200"
  }
}

variable "node_pools" {
  type = any
}

variable "model_deployment_jws_configuration" {
  type = object({
    enabled = bool
    url     = string
    issuer  = string
  })
  default = {
    enabled = false
    url     = ""
    issuer  = ""
  }
}

variable "resource_uploader_sa" {
  type = object({
    client_id     = string
    client_secret = string
  })
}

variable "operator_sa" {
  type = object({
    client_id     = string
    client_secret = string
  })
}

variable "service_catalog_sa" {
  type = object({
    client_id     = string
    client_secret = string
  })
}

variable "oauth_oidc_issuer_url" {
  type        = string
  description = "OpenID Provider URL"
}

variable "oauth_oidc_signout_endpoint" {
  type        = string
  description = "OpenID end_session_endpoint URL"
}

variable "oauth_oidc_token_endpoint" {
  type        = string
  description = "OpenID Provider Token URL"
}

variable "oauth_mesh_enabled" {
  type        = bool
  description = "OAuth2 inside service mesh via Envoy filter"
}

variable "vault_enabled" {
  type        = bool
  description = "Enabled vault deployment or not"
}

variable "airflow_enabled" {
  type        = bool
  description = "Is Airflow deployment enabled"
}

variable "pgsql" {
  type = object({
    enabled          = bool
    db_host          = string
    db_name          = string
    db_user          = string
    db_password      = string
    secret_namespace = string
    secret_name      = string
  })
  default = {
    enabled          = false
    db_host          = ""
    db_name          = ""
    db_user          = ""
    db_password      = ""
    secret_namespace = ""
    secret_name      = ""
  }
  description = "PostgreSQL settings for ODAHU flow services"
}
