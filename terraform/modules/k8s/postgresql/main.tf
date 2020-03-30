locals {
  pg_version          = "11.7.0-debian-10-r51"
  pg_registry         = "gcr.io"
  pg_repository       = "or2-msq-epmd-legn-t1iylu/odahu/postgresql-repmgr"
  debug_log_level     = "true"
  helm_repo           = "bitnami"
  helm_version        = "2.0.1"
  deploy_helm_timeout = "600"
}

resource "kubernetes_namespace" "this" {
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
  namespaces      = [kubernetes_namespace.this.metadata[0].annotations.name]
}

resource "helm_release" "this" {
  count      = var.configuration.enabled ? 1 : 0
  name       = "db"
  chart      = "postgresql-ha"
  version    = local.helm_version
  namespace  = kubernetes_namespace.this.metadata[0].annotations.name
  repository = local.helm_repo
  timeout    = local.deploy_helm_timeout

  values = [
    templatefile("${path.module}/templates/values.yaml", {
      pg_registry      = local.pg_registry
      pg_repository    = local.pg_repository
      password         = var.configuration.password
      storage_size     = var.configuration.storage_size
      debug            = local.debug_log_level
      pg_version       = local.pg_version
      replica_count    = var.configuration.replica_count
      allowed_networks = var.allowed_networks
    }),
  ]

  depends_on = [kubernetes_namespace.this, var.monitoring_dependency, module.docker_credentials]
}
