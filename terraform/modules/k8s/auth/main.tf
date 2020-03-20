######################################################## 
# Auth setup 
######################################################## 

locals {
  ingress_tls_secret_name   = "odahu-flow-tls"
  oauth_redirect_url_suffix = "oauth2/callback"

  oauth_redirect_url = var.oauth_redirect_url == "" ? "https://${var.domain_name}/${local.oauth_redirect_url_suffix}" : var.oauth_redirect_url
  
  oauth_proxy_values = {
    domain_name             = var.domain_name
    oauth_image_repository  = var.oauth_image_repository
    oauth_image_tag         = var.oauth_image_tag
    oauth_client_id         = var.oauth_client_id
    oauth_client_secret     = var.oauth_client_secret
    oauth_cookie_secret     = var.oauth_cookie_secret
    oauth_cookie_expire     = var.oauth_cookie_expire
    oauth_redirect_url      = local.oauth_redirect_url
    oauth_oidc_issuer_url   = var.oauth_oidc_issuer_url
    oauth_oidc_audience     = var.oauth_oidc_audience
    oauth_oidc_scope        = var.oauth_oidc_scope
    ingress_tls_secret_name = local.ingress_tls_secret_name
  }
}

resource "helm_release" "oauth2-proxy" {
  name          = "oauth2-proxy"
  chart         = "stable/oauth2-proxy"
  version       = var.oauth_helm_chart_version
  namespace     = var.namespace
  recreate_pods = "true"
  timeout       = "600"

  values = [
    templatefile("${path.module}/templates/oauth2-proxy.yaml", local.oauth_proxy_values)
  ]
}
