output "deploy_privkey" {
  value = var.bastion_enabled ? tls_private_key.bastion_deploy[0].private_key_pem : ""
}
