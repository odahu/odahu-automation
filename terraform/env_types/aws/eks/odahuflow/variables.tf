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

###################################################################################
# Odahuflow required
###################################################################################
variable "odahuflow_version" {
  description = "Odahuflow release version"
}

variable "root_domain" {
  description = "Odahuflow cluster root domain"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "docker_repo" {
  description = "Odahuflow Docker repo url"
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
