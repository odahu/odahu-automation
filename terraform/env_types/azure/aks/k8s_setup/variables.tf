##################
# Common
##################
variable "azure_resource_group" {
  description = "Azure base resource group name"
  default     = ""
}

variable "cluster_type" {
  default     = "azure/aks"
  description = "Odahuflow cluster cloud provider type"
}

variable "config_context_auth_info" {
  default     = ""
  description = "Odahuflow cluster context auth"
}

variable "config_context_cluster" {
  default     = ""
  description = "Odahuflow cluster context name"
}

variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
}

variable "root_domain" {
  description = "Odahuflow cluster root domain"
}

variable "docker_repo" {
  description = "Odahuflow Docker repo url"
}

variable "tls_key" {
  description = "TLS key for Odahuflow cluster"
}

variable "tls_crt" {
  description = "TLS certificate for Odahuflow cluster"
}

variable "storage_class" {
  default     = "default"
  description = "Kubernetes PVC storage class"
}

########################
# Prometheus monitoring
########################
variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "grafana_admin" {
  description = "Grafana admin username"
}

variable "grafana_pass" {
  description = "Grafana admin password"
}

variable "monitoring_namespace" {
  default     = "kube-monitoring"
  description = "clusterwide monitoring namespace"
}

##################
# OAuth2
##################
variable "oauth_client_id" {
  description = "OAuth2 Client ID"
}

variable "oauth_client_secret" {
  description = "OAuth2 Client Secret"
}

variable "oauth_cookie_secret" {
  description = "OAuth2 Cookie Secret"
}

variable "oauth_oidc_issuer_url" {
  description = "OAuth2/OIDC provider Issuer URL"
}

variable "oauth_oidc_audience" {
  description = "Oauth2 access token audience"
}

variable "oauth_oidc_scope" {
  description = "OAuth2 scope"
}

########################
# Istio
########################
variable "istio_namespace" {
  default     = "istio-system"
  description = "istio namespace"
}
