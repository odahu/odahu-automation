provider "helm" {
  version = "1.3.2"

  kubernetes {
    config_context = var.config_context_auth_info
  }
}

provider "kubernetes" {
  version                  = "1.13.2"
  config_context_auth_info = var.config_context_auth_info
  config_context_cluster   = var.config_context_cluster
}

provider "aws" {
  version = "3.42.0"
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

provider "google" {
  version     = "3.68.0"
  project     = var.gcp_project_id
  credentials = var.gcp_credentials
}
