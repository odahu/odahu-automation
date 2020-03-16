provider "helm" {
  version = "1.0.0"

  kubernetes {
    config_context = var.config_context_auth_info
  }
}

provider "kubernetes" {
  version                = "1.11.0"
  config_context_cluster = var.config_context_auth_info
}

provider "null" {
  version = "2.1.2"
}
