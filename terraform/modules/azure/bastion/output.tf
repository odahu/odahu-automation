output "privkey" {
  value = var.bastion_enabled ? tls_private_key.bastion_deploy[0].private_key_pem : ""
}

output "public_ip" {
  value       = var.bastion_enabled ? azurerm_public_ip.bastion[0].ip_address : ""
  description = "Public IP for bastion host"
}
