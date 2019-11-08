##################
# Common
##################
variable "azure_resource_group" {
  description = "Azure base resource group name"
  default     = ""
}

variable "cluster_type" {
  default     = "azure/aks"
  description = "Legion cluster cloud provider type"
}

variable "config_context_auth_info" {
  default     = ""
  description = "Legion cluster context auth"
}

variable "config_context_cluster" {
  default     = ""
  description = "Legion cluster context name"
}

variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "legion_helm_repo" {
  description = "Legion helm repo"
}

variable "legion_infra_version" {
  description = "Legion infra release version"
}

variable "root_domain" {
  description = "Legion cluster root domain"
}

variable "docker_repo" {
  description = "Legion Docker repo url"
}

variable "tls_key" {
  description = "TLS key for Legion cluster"
}

variable "tls_crt" {
  description = "TLS certificate for Legion cluster"
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

variable "alert_slack_url" {
  description = "Slack alerts url"
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

variable "keycloak_realm" {
  description = "Keycloak realm"
}

variable "keycloak_url" {
  description = "Keycloak URL"
}

variable "keycloak_realm_audience" {
  description = "Keycloak real audience"
}

variable "oauth_scope" {
  description = "Scope for OAuth"
}

########################
# Istio
########################
variable "istio_namespace" {
  default     = "istio-system"
  description = "istio namespace"
}
