provider "azurerm" {
  version = "2.29.0"
  features {}
}

provider "random" {
  version = "2.2.1"
}

provider "local" {
  version = "1.4.0"
}

provider "null" {
  version = "2.1.2"
}

provider "tls" {
  version = "2.1.1"
}

provider "external" {
  version = "1.2.0"
}


resource "azurerm_network_security_group" "nsg_ci" {
  location            = "eastus"
  name                = "aks-ci-ingress"
  resource_group_name = "aks-ci"
}