output "pgsql_credentials" {
  value = var.configuration.enabled ? {
    for db in var.databases :
    db => {
      username = lookup(lookup(lookup(data.kubernetes_secret.pg, db, {}), "data", {}), "username", "")
      password = lookup(lookup(lookup(data.kubernetes_secret.pg, db, {}), "data", {}), "password", "")
    }
  } : {}
  sensitive = true
}

output "pgsql_endpoint" {
  value = var.configuration.enabled ? format("%s.%s.svc", var.configuration.cluster_name,
  try(kubernetes_namespace.pgsql[0].metadata[0].annotations.name, "postgresql")) : ""
}
