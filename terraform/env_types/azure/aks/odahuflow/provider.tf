provider "azurerm" {
  version = "1.43.0"
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

provider "local" {
  version = "1.4.0"
}

provider "template" {
  version = "2.1.2"
}

provider "random" {
  version = "2.2.1"
}

provider "null" {
  version = "2.1.2"
}
