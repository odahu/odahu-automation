provider "kubernetes" {
  config_context_auth_info  = "gke_or2-msq-epmd-legn-t1iylu_us-east1-b_legion-dev"
  config_context_cluster    = "gke_or2-msq-epmd-legn-t1iylu_us-east1-b_legion-dev"
}

provider "helm" {
  install_tiller  = true
  namespace       = "kube-system"
  service_account = "tiller"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.11.0"
}

provider "google" {
  version     = "~> 2.2"
  region      = "${var.region}"
  zone        = "${var.zone}"
  project     = "${var.project_id}"
}


########################################################
# K8S setup
########################################################
module "k8s_setup" {
  source                    = "../../../modules/k8s"
  project_id                = "${var.project_id}"
  cluster_name              = "${var.cluster_name}"
  allowed_ips               = "${var.allowed_ips}"
  secrets_storage           = "${var.secrets_storage}"
  tls_name                  = "${var.tls_name}"
  legion_helm_repo          = "${var.legion_helm_repo}"
  legion_infra_version      = "${var.legion_infra_version}"
  alert_slack_url           = "${var.alert_slack_url}"
  root_domain               = "${var.root_domain}"
  grafana_admin             = "${var.grafana_admin}"
  grafana_pass              = "${var.grafana_pass}"
  docker_repo               = "${var.docker_repo}"
  cluster_context           = "${var.cluster_context}"
  github_org_name           = "${var.github_org_name}"
  dex_github_clientid       = "${var.dex_github_clientid}"
  dex_github_clientSecret   = "${var.dex_github_clientSecret}"
  dex_client_secret         = "${var.dex_client_secret}"
}
