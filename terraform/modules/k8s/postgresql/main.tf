locals {
  pg_version      = "11.8.0-debian-10-r13"
  pg_registry     = "docker.io"
  pg_repository   = "bitnami/postgresql-repmgr"
  debug_log_level = "true"
  helm_repo       = "bitnami"
  helm_version    = "3.2.7"
  pg_volume_name  = "postgresql-data"
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

resource "kubernetes_persistent_volume_claim" "pgsql" {
  count = var.configuration.enabled ? 1 : 0
  metadata {
    name      = local.pg_volume_name
    namespace = kubernetes_namespace.pgsql[0].metadata[0].annotations.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.configuration.storage_size
      }
    }
  }
  wait_until_bound = false
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
      password       = var.configuration.password
      debug          = local.debug_log_level
      pg_version     = local.pg_version
      pg_registry    = local.pg_registry
      pg_repository  = local.pg_repository
      replica_count  = var.configuration.replica_count
      databases      = join(" ", var.databases)
      pg_volume_name = local.pg_volume_name
    })
  ]

  depends_on = [
    var.monitoring_dependency,
    kubernetes_persistent_volume_claim.pgsql[0]
  ]
}
