provider "google" {
  version = "2.20.1"
  region  = var.gcp_region
  zone    = var.gcp_zone
  project = local.gcp_project_id
}

provider "helm" {
  version         = "0.10.4"
  namespace       = "kube-system"
  service_account = "tiller"
  install_tiller  = false
  tiller_image    = var.tiller_image
}

provider "kubernetes" {
  version                  = "1.9.0"
  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster
}

provider "external" {
  version = "~> 1.2"
}

provider "template" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

provider "null" {
  version = "~> 2.1"
}
