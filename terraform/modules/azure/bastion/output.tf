output "deploy_privkey" {
  value = tls_private_key.bastion_deploy.private_key_pem
}