locals {
  pg_version          = "11.7.0-debian-10-r51-test"
  pg_registry         = "gcr.io"
  pg_repository       = "or2-msq-epmd-legn-t1iylu/odahu-infra/postgresql-repmgr"
  debug_log_level     = "true"
  helm_repo           = "bitnami"
  helm_version        = "2.0.1"
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

module "docker_credentials" {
  source          = "../docker_auth"
  docker_repo     = var.docker_repo
  docker_username = var.docker_username
  docker_password = var.docker_password
  namespaces      = [kubernetes_namespace.this[0].metadata[0].annotations.name]
}

resource "helm_release" "this" {
  count      = var.configuration.enabled ? 1 : 0
  name       = "db"
  chart      = "postgresql-ha"
  version    = local.helm_version
  namespace  = var.namespace
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
    }),
  ]

  depends_on = [kubernetes_namespace.this, var.monitoring_dependency, module.docker_credentials]
}
