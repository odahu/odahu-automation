provider "helm" { 
  version         = "v0.10.0" 
  install_tiller  = false 
} 
 
######################################################## 
# Auth setup 
######################################################## 
 
# Oauth2 proxy 
data "template_file" "oauth2-proxy_values" { 
  template = "${file("${path.module}/templates/oauth2-proxy.yaml")}" 
  vars = { 
    cluster_name              = "${var.cluster_name}" 
    root_domain               = "${var.root_domain}" 
    oauth_image_repository    = "${var.oauth_image_repository}" 
    oauth_image_tag           = "${var.oauth_image_tag}" 
    oauth_client_id           = "${var.oauth_client_id}" 
    oauth_client_secret       = "${var.oauth_client_secret}" 
    oauth_cookie_secret       = "${var.oauth_cookie_secret}" 
    oauth_cookie_expire       = "${var.oauth_cookie_expire}" 
    oauth_redirect_url        = "${var.oauth_redirect_url}" 
    oauth_oidc_issuer_url     = "${var.oauth_oidc_issuer_url}" 
    oauth_oidc_audience       = "${var.oauth_oidc_audience}" 
    oauth_oidc_scope          = "${var.oauth_oidc_scope}" 
  } 
} 
 
resource "helm_release" "oauth2-proxy" { 
    name            = "oauth2-proxy" 
    chart           = "stable/oauth2-proxy" 
    version         = "${var.oauth_helm_chart_version}" 
    namespace       = "kube-system" 
    recreate_pods   = "true" 
 
    values = [ 
      "${data.template_file.oauth2-proxy_values.rendered}" 
    ] 
} 