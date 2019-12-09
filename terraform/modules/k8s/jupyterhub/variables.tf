variable "docker_repo" {
  description = "Odahuflow Docker repo url"
}

variable "jupyterhub_enabled" {
  default     = false
  type        = bool
  description = "Flag to install JupyterHub (true) or not (false)"
}

variable "jupyterhub_namespace" {
  default = "jupyterhub"
}

variable "jupyterhub_helm_repo" {
  description = "Jupyterhub helm repo address"
  default     = "https://jupyterhub.github.io/helm-chart/"
}

variable "jupyterhub_chart_version" {
  description = "Jupyterhub chart version"
  default     = "0.8.2"
}

variable "jupyterhub_secret_token" {
  description = "Jupyterhub secret token"
  default     = ""
}

variable "oauth_client_id" {
  description = "OAuth 2 Client ID"
}

variable "oauth_client_secret" {
  description = "OAuth 2 Client Secret"
}

variable "oauth_oidc_issuer_url" {
  description = "OAuth 2 JWT token issuer"
}

variable "cluster_domain" {
  description = "Odahuflow cluster domain"
}

variable "tls_secret_crt" {
  description = "Ingress TLS certificate"
  default     = ""
}

variable "tls_secret_key" {
  description = "Ingress TLS key"
  default     = ""
}
