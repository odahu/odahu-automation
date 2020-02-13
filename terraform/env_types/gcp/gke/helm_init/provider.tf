provider "helm" {
  version         = "0.10.4"
  namespace       = "kube-system"
  service_account = "tiller"
  install_tiller  = true
  tiller_image    = var.tiller_image
  init_helm_home  = true

  kubernetes {
    config_context = local.config_context_auth_info
  }
}

provider "kubernetes" {
  version                  = "1.11.0"
  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster
}

provider "null" {
  version = "2.1.2"
}
