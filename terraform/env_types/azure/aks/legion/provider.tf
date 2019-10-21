provider "azurerm" {
  version = "1.35.0"
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
  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster
}

provider "local" {
  version = "~> 1.4"
}

provider "template" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}
