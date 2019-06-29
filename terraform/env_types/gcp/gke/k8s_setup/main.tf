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

module "dex" {
  source                    = "../../../../modules/k8s/dex"
  aws_profile               = "${var.aws_profile}"
  aws_credentials_file      = "${var.aws_credentials_file}"
  zone                      = "${var.zone}"
  region                    = "${var.region}"
  region_aws                = "${var.region_aws}"
  project_id                = "${var.project_id}"
  cluster_name              = "${var.cluster_name}"
  legion_infra_version      = "${var.legion_infra_version}"
  legion_helm_repo          = "${var.legion_helm_repo}"
  root_domain               = "${var.root_domain}"
  dns_zone_name             = "${var.dns_zone_name}"
  github_org_name           = "${var.github_org_name}"
  dex_github_clientid       = "${var.dex_github_clientid}"
  dex_github_clientSecret   = "${var.dex_github_clientSecret}"
  dex_client_secret         = "${var.dex_client_secret}"
  dex_static_user_email     = "${var.dex_static_user_email}"
  dex_static_user_pass      = "${var.dex_static_user_pass}"
  dex_static_user_hash      = "${var.dex_static_user_hash}"
  dex_static_user_name      = "${var.dex_static_user_name}"
  dex_static_user_id        = "${var.dex_static_user_id}"
  dex_client_id             = "${var.dex_client_id}"
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

module "gke-saa" {
  source                    = "../../../../modules/k8s/gke-saa"
  legion_helm_repo          = "${var.legion_helm_repo}"
  legion_infra_version      = "${var.legion_infra_version}"
}
