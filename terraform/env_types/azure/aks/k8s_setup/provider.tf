provider "azurerm" {
  version = "2.3.0"
  features {}
}

provider "helm" {
  version = "1.0.0"

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

provider "template" {
  version = "2.1.2"
}
