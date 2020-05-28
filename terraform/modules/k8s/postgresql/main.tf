locals {
  pg_version      = "11.8.0-debian-10-r13"
  pg_registry     = "docker.io"
  pg_repository   = "bitnami/postgresql-repmgr"
  debug_log_level = "true"
  helm_repo       = "bitnami"
  helm_version    = "3.2.7"
}

resource "kubernetes_namespace" "pgsql" {
  count = var.configuration.enabled ? 1 : 0
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

resource "helm_release" "pgsql" {
  count      = var.configuration.enabled ? 1 : 0
  name       = "db"
  chart      = "postgresql-ha"
  version    = local.helm_version
  namespace  = kubernetes_namespace.pgsql[0].metadata[0].annotations.name
  repository = local.helm_repo
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/values.yaml", {
      password         = var.configuration.password
      storage_size     = var.configuration.storage_size
      debug            = local.debug_log_level
      pg_version       = local.pg_version
      pg_registry      = local.pg_registry
      pg_repository    = local.pg_repository
      replica_count    = var.configuration.replica_count
      allowed_networks = var.allowed_networks
      databases        = join(" ", var.databases)
    })
  ]

  depends_on = [
    var.monitoring_dependency
  ]
}
