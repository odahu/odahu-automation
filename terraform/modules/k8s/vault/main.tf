locals {
  vault_helm_version     = "1.4.0"
  vault_version          = "1.5.0"
  vault_unsealer_version = "1.4.0"
  vault_helm_repo        = "banzaicloud-stable"
  vault_debug_log_level  = "true"
  vault_pvc_name         = "vault-file"
  pg_client_image        = "postgres:12-alpine"
}

resource "kubernetes_namespace" "vault" {
  count = var.configuration.enabled ? 1 : 0
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

resource "kubernetes_secret" "postgres" {
  count = var.configuration.enabled && var.pgsql.enabled ? 1 : 0
  metadata {
    name      = "vault-pgsql"
    namespace = var.namespace
  }
  data = {
    "postgresql-password" = var.pgsql.db_password
  }
  type = "Opaque"

  depends_on = [kubernetes_namespace.vault[0]]
}

resource "kubernetes_config_map" "vault_pgsql_init" {
  count = var.configuration.enabled && var.pgsql.enabled ? 1 : 0
  metadata {
    name      = "vault-pgsql-init"
    namespace = var.namespace
  }
  data = {
    "vault-pgsql-init.sql" = "${file("${path.module}/files/vault-pgsql-init.sql")}"
  }
  depends_on = [kubernetes_namespace.vault[0]]
}

resource "kubernetes_job" "vault_pgsql_init" {
  count = var.configuration.enabled && var.pgsql.enabled ? 1 : 0

  metadata {
    name      = "vault-pgsql-init"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {}
      spec {
        volume {
          name = "sql-init"
          config_map {
            name = kubernetes_config_map.vault_pgsql_init[0].metadata[0].name
          }
        }
        container {
          env {
            name  = "PGHOST"
            value = var.pgsql.db_host
          }
          env {
            name = "PGPASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres[0].metadata[0].name
                key  = "postgresql-password"
              }
            }
          }
          volume_mount {
            name       = "sql-init"
            mount_path = "/opt/vault/vault-pgsql-init.sql"
            sub_path   = "vault-pgsql-init.sql"
          }
          name  = "psql"
          image = local.pg_client_image
          command = [
            "psql",
            "--username=${var.pgsql.db_user}",
            "${var.pgsql.db_name}",
            "--file=/opt/vault/vault-pgsql-init.sql"
          ]
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 0

    ttl_seconds_after_finished = 180
  }

  wait_for_completion = true

  depends_on = [
    kubernetes_config_map.vault_pgsql_init[0],
    kubernetes_secret.postgres[0]
  ]
}

resource "helm_release" "vault" {
  count      = var.configuration.enabled ? 1 : 0
  name       = "vault"
  chart      = "${local.vault_helm_repo}/vault"
  version    = local.vault_helm_version
  namespace  = var.namespace
  repository = local.vault_helm_repo
  timeout    = var.helm_timeout
  values = [
    templatefile("${path.module}/templates/vault_values.yaml", {
      namespace              = var.namespace
      vault_version          = local.vault_version
      vault_unsealer_version = local.vault_unsealer_version
      vault_debug_log_level  = local.vault_debug_log_level
      vault_tls_secret_name  = var.vault_tls_secret_name

      pgsql_enabled = var.pgsql.enabled
      pgsql_url = format(
        "postgres://%s:%s@%s:%s/%s",
        var.pgsql.db_user,
        var.pgsql.db_password,
        var.pgsql.db_host,
        "5432",
        var.pgsql.db_name
      )
    })
  ]
  depends_on = [
    kubernetes_job.vault_pgsql_init[0]
  ]
}
