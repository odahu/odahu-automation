provider "helm" {
  version         = "0.9.1"
  install_tiller  = true
  namespace       = "kube-system"
  service_account = "tiller"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.14.0"
}

provider "google" {
  version     = "~> 2.2"
  region      = "${var.region}"
  zone        = "${var.zone}"
  project     = "${var.project_id}"
}

provider "aws" {
  version                   = "2.13"
  region                    = "${var.region_aws}"
  shared_credentials_file   = "${var.aws_credentials_file}"
  profile                   = "${var.aws_profile}"
}

########################################################
# Kubernetes Dashboard
########################################################
data "template_file" "dashboard_values" {
  template = "${file("${path.module}/templates/dashboard-ingress.yaml")}"
  vars = {
    cluster_name              = "${var.cluster_name}"
    root_domain               = "${var.root_domain}"
    dashboard_tls_secret_name = "${var.dashboard_tls_secret_name}"
  }
}

resource "helm_release" "kubernetes-dashboard" {
    name      = "kubernetes-dashboard"
    chart     = "stable/kubernetes-dashboard"
    namespace = "kube-system"
    version   = "0.6.8"
    values = [
      "${data.template_file.dashboard_values.rendered}"
    ]
}

resource "kubernetes_secret" "tls_dashboard" {
  metadata {
    name        = "${var.dashboard_tls_secret_name}"
    namespace   = "kube-system"
  }
  data {
    "tls.key"   = "${var.tls_secret_key}"
    "tls.crt"   = "${var.tls_secret_crt}}"
  }
  type          = "kubernetes.io/tls"
}
