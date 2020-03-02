provider "aws" {
  version = "2.33.0"
  region  = var.aws_region
}

provider "helm" {
  version         = "1.0.0"

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

provider "random" {
  version = "2.2.1"
}
