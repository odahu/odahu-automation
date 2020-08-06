provider "azurerm" {
  version = "2.21.0"
  features {}
}

provider "helm" {
  version = "1.2.4"

  kubernetes {
    config_context = local.config_context_cluster
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
