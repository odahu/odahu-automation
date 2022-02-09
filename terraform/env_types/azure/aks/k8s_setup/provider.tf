provider "azurerm" {
  version = "2.29.0"
  features {}
}

provider "helm" {
  version = "1.3.2"

  kubernetes {
    config_context = local.config_context_cluster
  }
}

provider "kubernetes" {
  version                  = "1.13.2"
  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster
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

provider "random" {
  version = "2.2.1"
}

#resource "azurerm_network_security_group" "nsg_ci_agentpool" {
#  location            = "eastus"
#  name                = "aks-agentpool-67207258-nsg"
#  resource_group_name = "aks-ci-k8s"
#}
#
#resource "azurerm_lb" "lb_ci" {
#  location            = "eastus"
#  name                = "kubernetes"
#  resource_group_name = "aks-ci-k8s"
#}