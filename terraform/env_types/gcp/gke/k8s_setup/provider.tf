provider "google" {
  version = "2.20.1"
}

provider "helm" {
  version         = "0.10.4"
  namespace       = "kube-system"
  service_account = "tiller"
  insecure        = "true"
}

provider "kubernetes" {
  version                  = "1.9.0"
  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster
}

provider "null" {
  version = "~> 2.1.2"
}

provider "template" {
  version = "~> 2.1.2"
}

provider "external" {
  version = "~> 1.2"
}
