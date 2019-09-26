provider "google" {
  version = "2.16.0"
  region  = var.region
  zone    = var.zone
  project = var.project_id
}

provider "helm" {
  version         = "0.10.2"
  namespace       = "kube-system"
  service_account = "tiller"
  install_tiller  = false
  tiller_image    = var.tiller_image
}

provider "kubernetes" {
  version                  = "1.9.0"
  config_context_auth_info = var.config_context_auth_info
  config_context_cluster   = var.config_context_cluster
}

provider "template" {
  version = "~> 2.1"
}