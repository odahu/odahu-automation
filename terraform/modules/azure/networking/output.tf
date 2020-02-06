output "name" {
  value       = azurerm_virtual_network.vpc.name
  description = "Name of created VPC"
}

output "subnet_id" {
  value       = azurerm_subnet.subnet.id
  description = "ID of created VPC subnet"
}

output "subnet_name" {
  value       = azurerm_subnet.subnet.name
  description = "Name of created VPC subnet"
}

output "bastion_ip_id" {
  value       = var.bastion_enabled ? azurerm_public_ip.bastion[0].id : ""
  description = "ID of Public IP for bastion host"
}

output "bastion_ip_name" {
  value       = var.bastion_enabled ? azurerm_public_ip.bastion[0].name : ""
  description = "Name of Public IP for bastion host"
}

output "bastion_ip" {
  value       = var.bastion_enabled ? azurerm_public_ip.bastion[0].ip_address : ""
  description = "Public IP for bastion host"
}
