########################################################
# K8S setup
########################################################
module "k8s_setup" {
  source                    = "../../../modules/k8s"
  config_context_auth_info  = "${var.config_context_auth_info}"
  config_context_cluster    = "${var.config_context_cluster}"
  aws_profile               = "${var.aws_profile}"
  aws_credentials_file      = "${var.aws_credentials_file}"
  zone                      = "${var.zone}"
  region                    = "${var.region}"
  region_aws                = "${var.region_aws}"
  project_id                = "${var.project_id}"
  cluster_name              = "${var.cluster_name}"
  allowed_ips               = ["${var.allowed_ips}"]
  secrets_storage           = "${var.secrets_storage}"
  legion_helm_repo          = "${var.legion_helm_repo}"
  legion_infra_version      = "${var.legion_infra_version}"
  alert_slack_url           = "${var.alert_slack_url}"
  root_domain               = "${var.root_domain}"
  dns_zone_name             = "${var.dns_zone_name}"
  grafana_admin             = "${var.grafana_admin}"
  grafana_pass              = "${var.grafana_pass}"
  docker_repo               = "${var.docker_repo}"
  cluster_context           = "${var.cluster_context}"
  monitoring_namespace      = "${var.monitoring_namespace}"
  network_name              = "${var.network_name}"
}
