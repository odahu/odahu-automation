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
  source            = "../../modules/k8s"
  project_id        = "${var.project_id}"
  cluster_name      = "${var.cluster_name}"
  allowed_ips       = "${var.allowed_ips}"
  secrets_storage   = "${var.secrets_storage}"
  tls_name          = "$var.tls_name}"
}