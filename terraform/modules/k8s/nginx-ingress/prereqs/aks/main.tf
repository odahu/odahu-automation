locals {
  ingress_tags = merge(var.tags, { "purpose" = "Kubernetes cluster ingress" })
}

data "azurerm_subnet" "aks_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.network_name
  resource_group_name  = var.resource_group
}

resource "azurerm_public_ip" "ingress" {
  name                = "${var.cluster_name}-ingress"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.ingress_tags

  lifecycle {
    ignore_changes = [
      tags["created-on"]
    ]
  }

  provisioner "local-exec" {
    when    = destroy
    command = "timeout 300 bash ${path.module}/../../../../../../scripts/azure_lb_checker.sh destroy \"${self.resource_group_name}-k8s\" \"${self.name}\""
  }
}

resource "azurerm_network_security_group" "ingress" {
  name                = "${var.cluster_name}-ingress"
  location            = azurerm_public_ip.ingress.location
  resource_group_name = azurerm_public_ip.ingress.resource_group_name
  tags                = local.ingress_tags

  lifecycle {
    ignore_changes = [
      tags["created-on"]
    ]
  }

  security_rule {
    name                         = "allow-ingress"
    description                  = "Rule to pass http(s) traffic from trusted subnets"
    priority                     = 1102
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_ranges      = ["80", "443"]
    source_address_prefixes      = var.allowed_ips
    destination_address_prefixes = [azurerm_public_ip.ingress.ip_address, data.azurerm_subnet.aks_subnet.address_prefix]
  }

  security_rule {
    name                       = "deny-ingress"
    description                = "Default deny rule for http(s)"
    priority                   = 1103
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "Internet"
    destination_address_prefix = azurerm_public_ip.ingress.ip_address
  }
  depends_on = [azurerm_public_ip.ingress]
}

resource "azurerm_subnet_network_security_group_association" "ingress" {
  subnet_id                 = data.azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.ingress.id
  
  depends_on = [azurerm_network_security_group.ingress]
}
