##################
# Common
##################
variable "cluster_type" {
  description = "Cluster type"
}

variable "project_id" {
  description = "Target project id"
}

variable "zone" {
  default     = "us-east1-b"
  description = "Default zone"
}

variable "region" {
  default     = "us-east1"
  description = "Region of resources"
}

variable "aws_region" {
  default     = "us-east-1"
  description = "Region of resources"
}

variable "config_context_auth_info" {
  description = "Odahuflow cluster context auth"
}

variable "config_context_cluster" {
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

variable "dns_zone_name" {
  description = "Cluster root DNS zone name"
}

variable "network_name" {
  description = "The VPC network to host the cluster in"
}

variable "tls_key" {
  description = "TLS key for Odahuflow cluster"
}

variable "tls_crt" {
  description = "TLS certificate file for Odahuflow cluster"
}

########################
# Prometheus monitoring
########################
variable "allowed_ips" {
  type        = list(string)
  description = "CIDR to allow access from"
}

variable "pods_cidr" {
  description = "CIDR to use for cluster pods"
}

variable "grafana_admin" {
  description = "Grafana admion username"
}

variable "grafana_pass" {
  description = "Grafana admin password"
}

variable "cluster_context" {
  description = "Kubectl cluster context"
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
