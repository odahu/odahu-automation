provider "google" {
  version = "2.20.3"
  region  = var.region
  zone    = var.zone
  project = var.project_id
}

provider "helm" {
  version = "1.3.1"

  kubernetes {
    config_context = var.config_context_auth_info
  }
}

provider "kubernetes" {
  version                  = "1.13.2"
  config_context_auth_info = var.config_context_auth_info
  config_context_cluster   = var.config_context_cluster
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

provider "random" {
  version = "2.2.1"
}
