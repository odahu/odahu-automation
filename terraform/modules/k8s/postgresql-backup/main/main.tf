locals {
  pg_cluster_name   = split(".", var.pg_endpoint)[0]
  pg_namespace      = split(".", var.pg_endpoint)[1]
  pg_databases_list = join(" ", var.pg_databases)
  pg_backup_image = format(
    "%s/%s:%s",
    var.docker_repo,
    var.docker_image,
    var.docker_tag
  )
  pg_backup_retention = var.backup_settings.retention == "" ? "5y" : var.backup_settings.retention
}

module "docker_credentials" {
  source             = "../../../k8s/docker_auth"
  docker_repo        = var.docker_repo
  docker_username    = var.docker_username
  docker_password    = var.docker_password
  docker_secret_name = var.docker_secret_name
  namespaces         = [local.pg_namespace]
}

resource "kubernetes_secret" "pg_backup" {
  count = var.backup_settings.enabled ? 1 : 0
  metadata {
    name      = "odahu-pg-backup"
    namespace = local.pg_namespace
  }
  data = {
    "rclone.conf" = var.backup_job_config.rclone
  }
  type = "Opaque"
}

resource "kubernetes_config_map" "pg_backup" {
  count = var.backup_settings.enabled ? 1 : 0
  metadata {
    name      = "odahu-pg-backup"
    namespace = local.pg_namespace
  }
  data = {
    "pg_backup.sh" = file("${path.module}/files/pg_backup.sh")
  }
}

resource "kubernetes_service_account" "pg_backup" {
  count = var.backup_settings.enabled ? 1 : 0
  metadata {
    name      = "odahu-pg-backup"
    namespace = local.pg_namespace
  }
  image_pull_secret {
    name = var.docker_secret_name
  }
}

resource "kubernetes_cron_job" "pg_backup" {
  count = var.backup_settings.enabled ? 1 : 0
  metadata {
    name      = "odahu-pg-backup"
    namespace = local.pg_namespace
  }
  spec {
    concurrency_policy            = "Forbid"
    failed_jobs_history_limit     = 5
    successful_jobs_history_limit = 5
    schedule                      = var.backup_settings.schedule
    starting_deadline_seconds     = 10
    job_template {
      metadata {}
      spec {
        backoff_limit = 0
        template {
          metadata {
            annotations = var.backup_job_config.annotations
          }
          spec {
            restart_policy       = "Never"
            service_account_name = kubernetes_service_account.pg_backup[0].metadata[0].name
            volume {
              name = "rclone-config"
              secret {
                secret_name = kubernetes_secret.pg_backup[0].metadata[0].name
              }
            }
            volume {
              name = "backup-script"
              config_map {
                name         = kubernetes_config_map.pg_backup[0].metadata[0].name
                default_mode = "0755"
              }
            }
            container {
              name    = "pg-backup"
              image   = local.pg_backup_image
              command = ["/usr/local/sbin/pg_backup.sh"]
              security_context {
                privileged = false
              }
              env {
                name  = "PG_DATABASES"
                value = local.pg_databases_list
              }
              env {
                name  = "BACKUP_BUCKET"
                value = var.backup_job_config.bucket
              }
              env {
                name  = "BACKUP_RETENTION"
                value = local.pg_backup_retention
              }
              env {
                name  = "PGHOST"
                value = var.pg_endpoint
              }
              env {
                name = "PGUSER"
                value_from {
                  secret_key_ref {
                    name = format(
                      "postgres.%s.credentials.%s.acid.zalan.do",
                      local.pg_cluster_name,
                      local.pg_namespace
                    )
                    key = "username"
                  }
                }
              }
              env {
                name = "PGPASSWORD"
                value_from {
                  secret_key_ref {
                    name = format(
                      "postgres.%s.credentials.%s.acid.zalan.do",
                      local.pg_cluster_name,
                      local.pg_namespace
                    )
                    key = "password"
                  }
                }
              }
              volume_mount {
                name       = "rclone-config"
                mount_path = "/etc/rclone/"
              }
              volume_mount {
                name       = "backup-script"
                mount_path = "/usr/local/sbin/"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service_account.pg_backup[0],
    kubernetes_secret.pg_backup[0]
  ]
}
