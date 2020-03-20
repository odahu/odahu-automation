module "nginx_ingress_tls" {
  source             = "../../../modules/k8s/nginx-ingress/tls"
  cluster_name       = var.cluster_name
  services_namespace = var.services_namespace
  tls_namespaces     = [var.services_namespace]
  tls_secret_key     = var.tls_key
  tls_secret_crt     = var.tls_crt
}

module "nginx_ingress_helm" {
  source      = "../../../modules/k8s/nginx-ingress/helm"
  namespace   = var.services_namespace
  helm_values = {
    "controller.service.type"     = "LoadBalancer"
    "defaultBackend.service.type" = "ClusterIP"
  }
}

module "auth" {
  source                = "../../../modules/k8s/auth"
  namespace             = var.services_namespace
  domain_name           = var.cluster_domain_name
  oauth_client_id       = var.oauth_client_id
  oauth_client_secret   = var.oauth_client_secret
  oauth_oidc_issuer_url = var.oauth_oidc_issuer_url
  oauth_oidc_audience   = var.oauth_oidc_audience
  oauth_cookie_expire   = "168h0m0s"
  oauth_cookie_secret   = var.oauth_cookie_secret
  oauth_oidc_scope      = var.oauth_oidc_scope
}

module "monitoring" {
  source               = "../../../modules/k8s/monitoring"
  namespace            = var.services_namespace
  cluster_domain       = var.cluster_domain_name
  helm_repo            = var.helm_repo
  odahu_infra_version  = var.odahu_infra_version
  grafana_admin        = var.grafana_admin
  grafana_pass         = var.grafana_pass
}
