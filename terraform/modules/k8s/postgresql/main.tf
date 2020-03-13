locals {
  pg_version          = "11.7.0-debian-10-r13"
  debug_log_level     = "true"
  helm_repo           = "bitnami"
  helm_version        = "1.4.6"
  deploy_helm_timeout = "600"
}

resource "kubernetes_namespace" "this" {
  count = var.configuration.enabled ? 1 : 0
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

resource "helm_release" "this" {
  count      = var.configuration.enabled ? 1 : 0
  name       = "db"
  chart      = "postgresql-ha"
  version    = local.helm_version
  namespace  = var.namespace
  repository = local.helm_repo
  timeout    = local.deploy_helm_timeout

  values = [
    templatefile("${path.module}/templates/values.yaml", {
      password         = var.password
      storage_size     = var.configuration.storage_size
      debug            = local.debug_log_level
      pg_version       = local.pg_version
      replica_count    = var.configuration.replica_count
      allowed_networks = var.allowed_networks
    }),
  ]

  depends_on = [kubernetes_namespace.this, var.monitoring_dependency]
}
