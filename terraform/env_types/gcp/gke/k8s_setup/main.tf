########################################################
# K8S setup
########################################################

module "gpu_drivers" {
  source = "../../../../modules/k8s/gpu_drivers_setup"
}

module "nginx_ingress_tls" {
  source         = "../../../../modules/k8s/nginx-ingress/tls"
  cluster_name   = var.cluster_name
  tls_secret_key = var.tls_key
  tls_secret_crt = var.tls_crt
}

module "nginx_ingress_prereqs" {
  source       = "../../../../modules/k8s/nginx-ingress/prereqs/gke"
  region       = var.region
  project_id   = var.project_id
  cluster_name = var.cluster_name
  allowed_ips  = concat(var.allowed_ips, [var.pods_cidr])
  network_name = var.network_name
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
  source               = "../../../../modules/k8s/monitoring"
  cluster_domain       = "odahu.${var.cluster_name}.${var.root_domain}"
  helm_repo            = var.helm_repo
  odahu_infra_version  = var.odahu_infra_version
  grafana_admin        = var.grafana_admin
  grafana_pass         = var.grafana_pass
  monitoring_namespace = var.monitoring_namespace
  tls_secret_key       = var.tls_key
  tls_secret_crt       = var.tls_crt
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
  opa_policies          = var.opa_policies
}

module "gke-saa" {
  source              = "../../../../modules/k8s/gke-saa"
  cluster_type        = var.cluster_type
  helm_repo           = var.helm_repo
  odahu_infra_version = var.odahu_infra_version
}

module "tekton" {
  source              = "../../../../modules/k8s/tekton"
  helm_repo           = var.helm_repo
  odahu_infra_version = var.odahu_infra_version
}


module "vault" {
  source = "../../../../modules/k8s/vault"
}
