output "namespace" {
  value = var.configuration.enabled ? helm_release.vault[0].namespace : null
}

output "tls_secret" {
  value = var.configuration.enabled ? var.vault_tls_secret_name : null
}
