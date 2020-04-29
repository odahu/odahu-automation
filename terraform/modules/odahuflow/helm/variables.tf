####################
### Distribution ###
####################

variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "docker_repo" {
  description = "Odahuflow Docker repo url"
}

variable "docker_secret_name" {
  default     = "repo-json-key"
  description = "Odahuflow Docker repo secret name to create"
}

variable "docker_username" {
  default     = ""
  description = "Odahuflow Docker repo username"
}

variable "docker_password" {
  default     = ""
  description = "Odahuflow Docker repo password"
}

variable "odahuflow_version" {
  description = "Odahuflow release version"
}

variable "packager_version" {
  description = "Packager version"
}

variable "mlflow_toolchain_version" {
  description = "Version of odahu-flow-mlflow helm chart"
}

variable "odahu_ui_version" {
  description = "Version of odahu-ui helm chart"
}

###############
### Ingress ###
###############

variable "cluster_domain" {
  description = "Odahuflow cluster domain"
}

variable "tls_secret_crt" {
  description = "Odahuflow cluster TLS certificate"
  default     = ""
}

variable "tls_secret_key" {
  description = "Odahuflow cluster TLS key"
  default     = ""
}

##################
# Namespaces
##################

variable "odahuflow_namespace" {
  default     = "odahu-flow"
  description = "odahu-flow k8s namespace"
}

variable "odahuflow_training_namespace" {
  default     = "odahu-flow-training"
  description = "odahu-flow training k8s namespace"
}

variable "odahuflow_packaging_namespace" {
  default     = "odahu-flow-packaging"
  description = "odahu-flow packaging k8s namespace"
}

variable "odahuflow_deployment_namespace" {
  default     = "odahu-flow-deployment"
  description = "odahu-flow deployment k8s namespace"
}

variable "vault_namespace" {
  default     = "vault"
  description = "Vault namespace"
}

variable "fluentd_namespace" {
  default     = "fluentd"
  description = "Fluentd namespace"
}

##################
# Odahuflow app
##################

variable "odahuflow_connections" {
  default     = []
  description = "TODO"
}

##################
# Odahuflow config
##################

variable "odahuflow_training_timeout" {
  default     = ""
  description = "ODAHU Flow maximum timeout for model training process (example: '24h')"
  type        = string
}

variable "extra_external_urls" {
  default = []
  type = list(object({
    name     = string,
    url      = string,
    imageUrl = string,
  }))
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
    client_id : string
    client_secret : string
  })
}


variable "operator_sa" {
  type = object({
    client_id : string
    client_secret : string
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

variable "helm_timeout" {
  default = "600"
}
