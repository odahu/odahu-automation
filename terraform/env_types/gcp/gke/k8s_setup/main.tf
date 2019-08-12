########################################################
# K8S setup
########################################################
module "base_setup" {
  source                    = "../../../../modules/k8s/base_setup"
  aws_profile               = "${var.aws_profile}"
  aws_credentials_file      = "${var.aws_credentials_file}"
  zone                      = "${var.zone}"
  region                    = "${var.region}"
  region_aws                = "${var.region_aws}"
  project_id                = "${var.project_id}"
  cluster_name              = "${var.cluster_name}"
  secrets_storage           = "${var.secrets_storage}"
}

module "nginx-ingress" {
  source                    = "../../../../modules/k8s/nginx-ingress"
  zone                      = "${var.zone}"
  region                    = "${var.region}"
  project_id                = "${var.project_id}"
  cluster_name              = "${var.cluster_name}"
  allowed_ips               = ["${var.allowed_ips}"]
  root_domain               = "${var.root_domain}"
  dns_zone_name             = "${var.dns_zone_name}"
  network_name              = "${var.network_name}"
}
module "dashboard" {
  source                    = "../../../../modules/k8s/dashboard"
  aws_profile               = "${var.aws_profile}"
  aws_credentials_file      = "${var.aws_credentials_file}"
  zone                      = "${var.zone}"
  region                    = "${var.region}"
  region_aws                = "${var.region_aws}"
  project_id                = "${var.project_id}"
  cluster_name              = "${var.cluster_name}"
  root_domain               = "${var.root_domain}"
  tls_secret_key            = "${module.base_setup.tls_secret_key}"
  tls_secret_crt            = "${module.base_setup.tls_secret_crt}"
}

module "auth" {
  source                    = "../../../../modules/k8s/auth"
  cluster_name              = "${var.cluster_name}"
  root_domain               = "${var.root_domain}"
  oauth_client_id           = "${var.dex_client_id}"
  oauth_client_secret       = "${var.dex_client_secret}"
  oauth_redirect_url        = "https://auth.${var.cluster_name}.${var.root_domain}/oauth2/callback"
  oauth_oidc_issuer_url     = "${var.keycloak_url}/auth/realms/${var.keycloak_realm}"
  oauth_oidc_audience       = "${var.keycloak_realm_audience}"
  oauth_cookie_expire       = "168h0m0s"
  oauth_cookie_secret       = "${var.oauth2_github_cookieSecret}"
}

module "monitoring" {
  source                    = "../../../../modules/k8s/monitoring"
  aws_profile               = "${var.aws_profile}"
  aws_credentials_file      = "${var.aws_credentials_file}"
  zone                      = "${var.zone}"
  region                    = "${var.region}"
  region_aws                = "${var.region_aws}"
  project_id                = "${var.project_id}"
  cluster_name              = "${var.cluster_name}"
  legion_helm_repo          = "${var.legion_helm_repo}"
  legion_infra_version      = "${var.legion_infra_version}"
  alert_slack_url           = "${var.alert_slack_url}"
  root_domain               = "${var.root_domain}"
  grafana_admin             = "${var.grafana_admin}"
  grafana_pass              = "${var.grafana_pass}"
  docker_repo               = "${var.docker_repo}"
  monitoring_namespace      = "${var.monitoring_namespace}"
  tls_secret_key            = "${module.base_setup.tls_secret_key}"
  tls_secret_crt            = "${module.base_setup.tls_secret_crt}"
}

module "istio" {
  source                    = "../../../../modules/k8s/istio"
  root_domain               = "${var.root_domain}"
  cluster_name              = "${var.cluster_name}"
  monitoring_namespace      = "${var.monitoring_namespace}"
  tls_secret_key            = "${module.base_setup.tls_secret_key}"
  tls_secret_crt            = "${module.base_setup.tls_secret_crt}"
  legion_helm_repo          = "${var.legion_helm_repo}"
  legion_infra_version      = "${var.legion_infra_version}"
}

module "gke-saa" {
  source                    = "../../../../modules/k8s/gke-saa"
  legion_helm_repo          = "${var.legion_helm_repo}"
  legion_infra_version      = "${var.legion_infra_version}"
}
