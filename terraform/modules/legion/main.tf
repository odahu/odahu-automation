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
# Legion intallation
########################################################
data "template_file" "legion_values" {
  template = "${file("${path.module}/templates/legion-values.yaml")}"
  vars = {
    monitoring_namespace  = "${var.monitoring_namespace}"
    alert_slack_url       = "${var.alert_slack_url}"
    root_domain           = "${var.root_domain}"
    cluster_name          = "${var.cluster_name}"
    grafana_admin         = "${var.grafana_admin}"
    grafana_pass          = "${var.grafana_pass}"
    docker_repo           = "${var.docker_repo}"
    legion_infra_version  = "${var.legion_infra_version}"

  }
}

resource "local_file" "foo" {
    content     = "${data.template_file.legion_values.rendered}"
    filename = "/tmp/mv.yaml"
}

# resource "helm_release" "monitoring" {
#     name        = "monitoring"
#     chart       = "monitoring"
#     version     = "${var.legion_infra_version}"
#     namespace   = "${var.monitoring_namespace}"
#     repository  = "${data.helm_repository.legion.metadata.0.name}"

#     values = [
#       "${data.template_file.monitoring_values.rendered}"
#     ]
# }
