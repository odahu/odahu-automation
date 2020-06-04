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

variable "docker_tag" {
  description = "Tag of Docker containers used as JupyterHub Notebooks"
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

variable "jupyterhub_culling_enabled" {
  default     = true
  type        = bool
  description = "JupyterHub will automatically delete any user pods that have no activity for a period of time"
}

variable "jupyterhub_puller_enabled" {
  default     = false
  type        = bool
  description = "With the hook-image-puller enabled, the user images will be pulled to the nodes before the hub pod is updated to utilize the new image"
}

variable "jupyterhub_culling_timeout" {
  default     = "1200"
  description = "Time in seconds of the user's browser inactivity which is defined as no response by JupyterHub"
}

variable "jupyterhub_culling_frequency" {
  default     = "300"
  description = "Period in seconds with which JupyterHub pings browser session to check whether it is open"
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

variable "helm_timeout" {
  default = "900"
}
