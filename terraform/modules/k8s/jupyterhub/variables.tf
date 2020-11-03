variable "docker_repo" {
  type        = string
  description = "ODAHU flow Docker repo url"
}

variable "cloud_settings" {
  type = object({
    type = string
    settings = any
  })
  default = {
    type = "gcp"
    settings = {}
  }
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

variable "docker_tag" {
  type        = string
  description = "Tag of Docker containers used as JupyterHub Notebooks"
}

variable "jupyterhub_enabled" {
  type        = bool
  default     = false
  description = "Flag to install JupyterHub (true) or not (false)"
}

variable "jupyterhub_namespace" {
  type        = string
  default     = "jupyterhub"
  description = "JupyterHub Kubernetes namespace"
}

variable "jupyterhub_secret_token" {
  type        = string
  default     = ""
  description = "JupyterHub secret token"
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
  type        = number
  default     = 1200
  description = "Time in seconds of the user's browser inactivity which is defined as no response by JupyterHub"
}

variable "jupyterhub_culling_frequency" {
  type        = number
  default     = 300
  description = "Period in seconds with which JupyterHub pings browser session to check whether it is open"
}

variable "oauth_client_id" {
  type        = string
  description = "OAuth 2 Client ID"
}

variable "oauth_client_secret" {
  type        = string
  description = "OAuth 2 Client Secret"
}

variable "oauth_oidc_issuer_url" {
  type        = string
  description = "OAuth 2 JWT token issuer"
}

variable "cluster_domain" {
  type        = string
  description = "ODAHU flow cluster domain"
}

variable "tls_secret_crt" {
  type        = string
  default     = ""
  description = "Ingress TLS certificate"
}

variable "tls_secret_key" {
  type        = string
  default     = ""
  description = "Ingress TLS key"
}

variable "helm_chart_version" {
  type        = string
  default     = "0.8.2"
  description = "JupyterHub chart version"
}

variable "helm_repo" {
  type        = string
  default     = "https://jupyterhub.github.io/helm-chart"
  description = "URL of used Helm chart repository"
}

variable "helm_timeout" {
  type        = number
  default     = 900
  description = "Helm chart deploy timeout in seconds"
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
  description = "PostgreSQL settings for JupyterHub"
}
