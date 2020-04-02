provider "aws" {
  version = "2.52.0"
  region  = var.aws_region
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_context = var.config_context_auth_info
  }
}

provider "kubernetes" {
  version                  = "1.11.0"
  config_context_auth_info = var.config_context_auth_info
  config_context_cluster   = var.config_context_cluster
}

provider "null" {
  version = "2.1.2"
}

provider "random" {
  version = "2.2.1"
}
