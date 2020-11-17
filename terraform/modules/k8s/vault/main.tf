locals {
  pg_credentials_plain = ((length(var.pgsql.secret_namespace) != 0) && (length(var.pgsql.secret_name) != 0)) ? 0 : 1

  pg_username = local.pg_credentials_plain == 1 ? var.pgsql.db_password : lookup(lookup(data.kubernetes_secret.pg[0], "data", {}), "username", "")
  pg_password = local.pg_credentials_plain == 1 ? var.pgsql.db_user : lookup(lookup(data.kubernetes_secret.pg[0], "data", {}), "password", "")

  vault_helm_version     = "1.4.0"
  vault_version          = "1.5.0"
  vault_unsealer_version = "1.4.0"
  vault_debug_log_level  = "true"
  vault_pvc_name         = "vault-file"
  pg_client_image        = "postgres:12-alpine"
}

data "kubernetes_secret" "pg" {
  count = local.pg_credentials_plain == 0 ? 1 : 0
  metadata {
    name      = var.pgsql.secret_name
    namespace = var.pgsql.secret_namespace
  }
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
    "postgresql-password" = local.pg_password
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
            "--username=${local.pg_username}",
            "${var.pgsql.db_name}",
            "--file=/opt/vault/vault-pgsql-init.sql"
          ]
        }
        restart_policy = "OnFailure"
      }
    }
    backoff_limit = 3

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
  chart      = "vault"
  version    = local.vault_helm_version
  namespace  = var.namespace
  repository = var.helm_repo
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
        local.pg_username,
        local.pg_password,
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
