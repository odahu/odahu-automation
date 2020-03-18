provider "google" {
  version = "2.20.2"
  region  = var.region
  zone    = var.zone
  project = var.project_id
}

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

provider "template" {
  version = "2.1.2"
}

provider "random" {
  version = "2.2.1"
}

provider "null" {
  version = "2.1.2"
}
