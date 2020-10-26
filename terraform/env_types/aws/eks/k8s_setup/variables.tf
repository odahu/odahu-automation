##################
# Common
##################
variable "cluster_type" {
  type        = string
  description = "Cloud provider"
}

variable "tls_key" {
  type        = string
  description = "TLS key for ODAHU flow cluster"
}

variable "tls_crt" {
  type        = string
  description = "TLS certificate file for ODAHU flow cluster"
}

variable "aws_region" {
  type        = string
  default     = "eu-central-1"
  description = "Region of AWS resources"
}

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

variable "helm_repo" {
  type        = string
  description = "ODAHU flow helm repo"
}

variable "odahu_infra_version" {
  type        = string
  description = "ODAHU flow infra release version"
}

variable "cluster_domain_name" {
  type        = string
  description = "ODAHU flow cluster FQDN"
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

########################
# Prometheus monitoring
########################
variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "grafana_admin" {
  type        = string
  default     = "grafana_admin"
  description = "Grafana admin username"
}

variable "grafana_pass" {
  type        = string
  description = "Grafana admin password"
}

##################
# OAuth2
##################
variable "oauth_client_id" {
  type        = string
  description = "OAuth2 Client ID"
}

variable "oauth_client_secret" {
  type        = string
  description = "OAuth2 Client Secret"
}

variable "oauth_cookie_secret" {
  type        = string
  description = "OAuth2 Cookie Secret"
}

variable "oauth_oidc_issuer_url" {
  type        = string
  description = "OAuth2/OIDC provider Issuer URL"
}

variable "oauth_oidc_audience" {
  type        = string
  description = "Oauth2 access token audience"
}

variable "oauth_oidc_scope" {
  type        = string
  description = "OAuth2 scope"
}

########################
# Istio
########################
variable "istio_namespace" {
  type        = string
  default     = "istio-system"
  description = "istio namespace"
}

########################
# NFS
########################
variable "nfs" {
  type = object({
    enabled      = bool
    storage_size = string
  })
  default = {
    enabled      = false
    storage_size = "10Gi"
  }
  description = "NFS configuration"
}
