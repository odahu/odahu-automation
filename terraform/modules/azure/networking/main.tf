data "azurerm_public_ip" "aks_ext" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group
}

data "http" "external_ip" {
  url = "http://ifconfig.co"
}

data "external" "check_ip_in_cidrs" {
  program = ["python3", "${path.module}/scripts/check_ip_in_cidrs.py"]
  query = {
    ip = chomp(data.http.external_ip.body)
    cidrlist = join(", ", var.allowed_ips)
  }
}

locals {
  allowed_subnets = split(", ", data.external.check_ip_in_cidrs.result.cidrlist)
}

resource "azurerm_public_ip" "bastion" {
  name                = "${var.cluster_name}-bastion"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  tags                = var.tags
}

########################################################
# Create virtual network
########################################################

resource "azurerm_virtual_network" "vpc" {
  name                = "${var.cluster_name}-vpc"
  address_space       = [ var.subnet_cidr ]
  location            = var.location
  resource_group_name = var.resource_group
  tags                = var.tags
}

########################################################
# Create subnet for AKS nodes in VPC
########################################################

resource "azurerm_subnet" "subnet" {
  name                      = "${var.cluster_name}-subnet"
  resource_group_name       = var.resource_group
  virtual_network_name      = azurerm_virtual_network.vpc.name
  address_prefix            = var.subnet_cidr
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.cluster_name}-security"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                         = "allow-bastion-ssh"
    description                  = "Allow SSH traffic to bastion host from trusted subnets"
    priority                     = 111
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_ranges      = [ "22" ]
    source_address_prefixes      = local.allowed_subnets
    destination_address_prefixes = [ azurerm_public_ip.bastion.ip_address, var.subnet_cidr ]
  }
  security_rule {
    name                         = "allow-ingress"
    description                  = "Rule to pass http(s) traffic from trusted subnets"
    priority                     = 112
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_ranges      = [ "80", "443" ]
    source_address_prefixes      = concat(list(azurerm_public_ip.bastion.ip_address), local.allowed_subnets)
    destination_address_prefixes = [ data.azurerm_public_ip.aks_ext.ip_address, var.subnet_cidr ]
  }
  security_rule {
    name                       = "deny-ingress"
    description                = "Default deny rule for http(s)"
    priority                   = 113
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = [ "80", "443" ]
    source_address_prefix      = "Internet"
    destination_address_prefix = data.azurerm_public_ip.aks_ext.ip_address
  }
  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "aks_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}
