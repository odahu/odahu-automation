provider "helm" {
  version         = "0.10.2"
  install_tiller  = false

  kubernetes {
    config_context = var.config_context_auth_info
  }
}

provider "kubernetes" {
  version                  = "1.9.0"
  config_context_auth_info = var.config_context_auth_info
  config_context_cluster   = var.config_context_cluster
}

provider "aws" {
  version = "2.33.0"
  region  = var.aws_region
}
