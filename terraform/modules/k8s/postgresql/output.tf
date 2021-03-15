output "pgsql_credentials" {
  value = var.configuration.enabled ? {
    for db in var.databases :
    db => {
      namespace = var.namespace
      secret    = replace("${db}.${var.configuration.cluster_name}.credentials.postgresql.acid.zalan.do", "_", "-")
    }
  } : {}
  sensitive = true
}

output "pgsql_endpoint" {
  value = var.configuration.enabled ? format("%s.%s.svc.cluster.local", var.configuration.cluster_name,
  try(kubernetes_namespace.pgsql[0].metadata[0].annotations.name, "postgresql")) : ""
}
