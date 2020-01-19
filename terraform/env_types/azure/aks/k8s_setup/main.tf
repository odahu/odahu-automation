data "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  resource_group_name = var.azure_resource_group
}

locals {
  config_context_auth_info = var.config_context_auth_info == "" ? data.azurerm_kubernetes_cluster.aks.kube_config.0.username : var.config_context_auth_info
  config_context_cluster   = var.config_context_cluster == "" ? var.cluster_name : var.config_context_cluster
}

########################################################
# K8S setup
########################################################
module "nginx_ingress_tls" {
  source         = "../../../../modules/k8s/nginx-ingress/tls"
  cluster_name   = var.cluster_name
  tls_secret_key = var.tls_key
  tls_secret_crt = var.tls_crt
}

module "nginx_ingress_prereqs" {
  source                = "../../../../modules/k8s/nginx-ingress/prereqs/aks"
  cluster_name          = var.cluster_name
  aks_ip_resource_group = var.azure_resource_group
}

module "nginx_ingress_helm" {
  source      = "../../../../modules/k8s/nginx-ingress/helm"
  helm_values = module.nginx_ingress_prereqs.helm_values
}

module "auth" {
  source                = "../../../../modules/k8s/auth"
  cluster_name          = var.cluster_name
  root_domain           = var.root_domain
  oauth_client_id       = var.oauth_client_id
  oauth_client_secret   = var.oauth_client_secret
  oauth_redirect_url    = "https://odahu.${var.cluster_name}.${var.root_domain}/oauth2/callback"
  oauth_oidc_issuer_url = var.oauth_oidc_issuer_url
  oauth_oidc_audience   = var.oauth_oidc_audience
  oauth_cookie_expire   = "168h0m0s"
  oauth_cookie_secret   = var.oauth_cookie_secret
  oauth_oidc_scope      = var.oauth_oidc_scope
}

module "monitoring" {
  source                = "../../../../modules/k8s/monitoring"
  cluster_domain        = "odahu.${var.cluster_name}.${var.root_domain}"
  helm_repo             = var.helm_repo
  odahu_infra_version   = var.odahu_infra_version
  grafana_admin         = var.grafana_admin
  grafana_pass          = var.grafana_pass
  grafana_storage_class = var.storage_class
  docker_repo           = var.docker_repo
  monitoring_namespace  = var.monitoring_namespace
  tls_secret_key        = var.tls_key
  tls_secret_crt        = var.tls_crt
}

module "istio" {
  source               = "../../../../modules/k8s/istio"
  root_domain          = var.root_domain
  cluster_name         = var.cluster_name
  monitoring_namespace = var.monitoring_namespace
  helm_repo            = var.helm_repo
  odahu_infra_version  = var.odahu_infra_version
  tls_secret_key       = var.tls_key
  tls_secret_crt       = var.tls_crt
}

module "openpolicyagent" {
  source                = "../../../../modules/k8s/openpolicyageent"
  helm_repo             = var.helm_repo
  odahu_infra_version   = var.odahu_infra_version
  mesh_dependency       = module.istio.helm_chart
  oauth_mesh_enabled    = var.oauth_mesh_enabled
  oauth_oidc_jwks_url   = var.oauth_oidc_jwks_url
  oauth_oidc_host       = var.oauth_oidc_host
  oauth_oidc_port       = var.oauth_oidc_port
  oauth_local_jwks      = var.oauth_local_jwks
  oauth_oidc_issuer_url = var.oauth_oidc_issuer_url
  authorization_enabled = var.authorization_enabled
  authz_dry_run         = var.authz_dry_run
  authz_uri             = var.authz_uri
}

module "tekton" {
  source              = "../../../../modules/k8s/tekton"
  helm_repo           = var.helm_repo
  odahu_infra_version = var.odahu_infra_version
}

module "vault" {
  source                  = "../../../../modules/k8s/vault"
  vault_pvc_storage_class = var.storage_class
}
