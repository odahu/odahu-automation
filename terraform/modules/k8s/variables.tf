##################
# Common
##################
variable "project_id" {
  description = "Target project id"
}
variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}
variable "config_context_auth_info" {
  description = "Legion cluster context auth"
}
variable "config_context_cluster" {
  description = "Legion cluster context name"
}
variable "aws_profile" {
  description = "AWS profile name"
}
variable "aws_credentials_file" {
  description = "AWS credentials file location"
}
variable "zone" {
  description = "Default zone"
}
variable "region" {
  description = "Region of resources"
}
variable "region_aws" {
  description = "Region of AWS resources"
}
variable "secrets_storage" {
  description = "Cluster secrets storage"
}
variable "legion_helm_repo" {
  description = "Legion helm repo"
}
variable "root_domain" {
  description = "Legion cluster root domain"
}
variable "allowed_ips" {
  type    = "list"
  description = "CIDR to allow access from"
}
variable "tls_namespaces" {
  default = ["default", "kube-system"]
  description = "Default namespaces with TLS secret"
}
variable "cluster_context" {
  description = "Kubectl cluster context"
}
variable "dns_zone_name" {
  description = "Cluster root DNS zone name"
}
variable "network_name" {
  description = "The VPC network to host the cluster in"
}
variable "ingress_whitelist_cidr" {
  default = ["127.0.0.1/32"]
  description = "Nginx ingress authorized cidr"
}

########################
# Kubernetes Dashboard
########################
variable "dashboard_tls_secret_name" {
  default     = "kubernetes-dashboard-certs"
  description = "Cluster root DNS zone name"
}

########################
# Prometheus monitoring
########################
variable "monitoring_namespace" {
  default     = "kube-monitoring"
  description = "clusterwide monitoring namespace"
}
variable "legion_infra_version" {
  description = "Legion infra release version"
}
variable "alert_slack_url" {
  description = "Alert slack usrl"
}
variable "grafana_admin" {
  description = "Grafana admion username"
}
variable "grafana_pass" {
  description = "Grafana admin password"
}
variable "docker_repo" {
  description = "Legion Docker repo url"
}
variable "monitoring_prometheus_operator_crd_url" {
  default     = "https://raw.githubusercontent.com/coreos/prometheus-operator/v0.29.0/example/prometheus-operator-crd"
  description = "Prometheus operator CRD url"
}
variable "prometheus_crds" {
  default = ["alertmanager", "prometheus", "prometheusrule", "servicemonitor"]
  description = "Default namespaces with TLS secret"
}
variable "grafana_storage_class" {
  default     = "standard"
  description = "Grafana storage class"
}

##################
# Auth setup
##################
variable "codecentric_helm_repo" {
  default = "https://codecentric.github.io/helm-charts"
  description = "Codecentric helm repo for Kyecloak"
}
variable "gatekeeper_helm_repo" {
  default = "https://gabibbo97.github.io/charts/"
  description = "Keycloak gatekeeper helm repo"
}
variable "dex_replicas" {
  default = 1
  description = "Number of dex replicas"
}
variable "github_org_name" {
  description = "Github Organization for dex authentication"
}
variable "dex_github_clientid" {
  description = "Github Organization clientID"
}
variable "dex_github_clientSecret" {
  description = "Github Organization client Secret"
}
variable "dex_client_secret" {
  description = "Dex default client Secret"
}
variable "dex_client_id" {
  description = "Dex default client Secret"
}
variable "dex_static_user_email" {
  description = "Dex static user email"
}
variable "dex_static_user_pass" {
  description = "Dex static user pass"
}
variable "dex_static_user_hash" {
  description = "Dex static user hash"
}
variable "dex_static_user_name" {
  description = "Dex static user username"
}
variable "dex_static_user_id" {
  description = "Dex static user user id"
}
variable "dex_cookie_expire" {
  default = "3600"
  description = "Dex oauth2 cookie expiration"
}
variable "keycloak_admin_user" {
  description = "Keycloak admin user"
}
variable "keycloak_admin_pass" {
  description = "Keycloak admin pass"
}
variable "keycloak_db_user" {
  description = "Keycloak db admin user"
}
variable "keycloak_db_pass" {
  description = "Keycloak db admin pass"
}
variable "keycloak_pg_user" {
  description = "Keycloak postgres user"
}
variable "keycloak_pg_pass" {
  description = "Keycloak postgres pass"
}
variable "keycloak_client_secret" {
  description = "keycloak default client Secret"
}
variable "keycloak_client_id" {
  description = "keycloak default client Secret"
}
