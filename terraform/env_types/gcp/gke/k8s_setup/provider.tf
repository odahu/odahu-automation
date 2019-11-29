provider "google" {
  version = "2.20.0"
}

provider "helm" {
  version         = "0.10.4"
  namespace       = "kube-system"
  service_account = "tiller"
  insecure        = "true"
}

provider "kubernetes" {
  version                  = "1.9.0"
  config_context_auth_info = var.config_context_auth_info
  config_context_cluster   = var.config_context_cluster
}

provider "null" {
  version = "~> 2.1.2"
}

provider "template" {
  version = "~> 2.1.2"
}
