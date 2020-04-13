########################################################
# Create virtual network
########################################################

resource "azurerm_virtual_network" "vpc" {
  name                = "${var.cluster_name}-vpc"
  address_space       = [var.subnet_cidr]
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
}

########################################################
# Create subnet for AKS nodes in VPC
########################################################

resource "azurerm_subnet" "subnet" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefix       = var.subnet_cidr
  service_endpoints = [
    "Microsoft.ContainerRegistry",
    "Microsoft.Storage"
  ]
}
