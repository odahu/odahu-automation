########################################################
# K8S setup
########################################################
module "base_setup" {
  source         = "../../../../modules/k8s/base_setup"
  cluster_name   = var.cluster_name
  tls_secret_crt = var.tls_crt
  tls_secret_key = var.tls_key
}

module "nginx-ingress" {
  source         = "../../../../modules/k8s/nginx-ingress"
  cluster_type   = var.cluster_type
  az_list        = var.az_list
  aws_lb_subnets = var.public_subnet_cidrs
  region         = var.region
  project_id     = var.project_id
  cluster_name   = var.cluster_name
  allowed_ips    = var.allowed_ips
  root_domain    = var.root_domain
  dns_zone_name  = var.dns_zone_name
}

module "auth" {
  source                = "../../../../modules/k8s/auth"
  cluster_name          = var.cluster_name
  root_domain           = var.root_domain
  oauth_client_id       = var.oauth_client_id
  oauth_client_secret   = var.oauth_client_secret
  oauth_redirect_url    = "https://odahu.${var.cluster_name}.${var.root_domain}/oauth2/callback"
  oauth_oidc_issuer_url = "${var.keycloak_url}/auth/realms/${var.keycloak_realm}"
  oauth_oidc_audience   = var.keycloak_realm_audience
  oauth_cookie_expire   = "168h0m0s"
  oauth_cookie_secret   = var.oauth_cookie_secret
  oauth_oidc_scope      = var.oauth_scope
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
  tls_secret_key       = var.tls_key
  tls_secret_crt       = var.tls_crt
  helm_repo            = var.helm_repo
  odahu_infra_version  = var.odahu_infra_version
}

module "gke-saa" {
  source              = "../../../../modules/k8s/gke-saa"
  cluster_type        = var.cluster_type
  helm_repo           = var.helm_repo
  odahu_infra_version = var.odahu_infra_version
}

module "kube2iam" {
  source       = "../../../../modules/k8s/kube2iam"
  cluster_type = var.cluster_type
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

