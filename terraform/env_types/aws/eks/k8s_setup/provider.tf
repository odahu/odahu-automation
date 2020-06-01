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

provider "aws" {
  version = "2.52.0"
  region  = var.aws_region
}

provider "local" {
  version = "1.4.0"
}

provider "null" {
  version = "2.1.2"
}

provider "template" {
  version = "2.1.2"
}
