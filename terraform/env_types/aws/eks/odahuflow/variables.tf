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
  default     = ""
  description = "Kubernetes cluster context auth"
}

variable "config_context_cluster" {
  default     = ""
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

variable "dns" {
  description = "Odahuflow cluster DNS settings"
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

# TODO: Remove after implementation of the issue https://github.com/odahuflow-platform/odahuflow/issues/1008
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

variable "packager_version" {}

variable "node_pools" {
  default = {}
}

variable "service_accounts" {
  type = object({
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