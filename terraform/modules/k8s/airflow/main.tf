locals {
  odahu_airflow_plugin_version = "1.1.0-rc13"

  airflow_version      = "1.10.9"
  airflow_helm_version = "6.3.0"
  airflow_helm_repo    = "stable"
  debug_log_level      = "true"

  deploy_helm_timeout = "300"

  airflow_variables = {
    "WINE_BUCKET" = var.wine_bucket,
    "GCP_PROJECT" = var.project_id
  }

  odahu_conn = {
    "auth_url"      = var.oauth_oidc_token_endpoint,
    "client_id"     = var.service_account.client_id,
    "client_secret" = var.service_account.client_secret,
    "scope"         = "openid profile offline_access groups"
  }

  google_sa_key = google_service_account_key.airflow.private_key

  gcp_wine_conn = {
    "extra__google_cloud_platform__project"      = var.project_id,
    "extra__google_cloud_platform__keyfile_dict" = replace(base64decode(google_service_account_key.airflow.private_key), "/\n/", ""),
    "extra__google_cloud_platform__scope"        = "https://www.googleapis.com/auth/cloud-platform"
  }
}

resource "kubernetes_namespace" "this" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

resource "kubernetes_secret" "postgres" {
  count = var.configuration.enabled ? 1 : 0

  metadata {
    name      = "airflow-postgres"
    namespace = var.namespace
  }
  data = {
    "postgresql-password" = var.postgres_password
  }
  type       = "Opaque"
  depends_on = [kubernetes_namespace.this]
}

module "docker_credentials" {
  source          = "../docker_auth"
  docker_repo     = var.docker_repo
  docker_username = var.docker_username
  docker_password = var.docker_password
  namespaces      = [kubernetes_namespace.this.metadata[0].annotations.name]
}

resource "helm_release" "airflow" {
  count      = var.configuration.enabled ? 1 : 0
  name       = "airflow"
  chart      = "airflow"
  version    = local.airflow_helm_version
  namespace  = var.namespace
  repository = local.airflow_helm_repo
  timeout    = local.deploy_helm_timeout

  values = [
    templatefile("${path.module}/templates/airflow.yaml", {
      airflow_version              = local.airflow_version
      airflow_variables            = jsonencode(local.airflow_variables)
      domain                       = var.domain
      docker_repo                  = var.docker_repo
      fernet_key                   = var.configuration.fernet_key
      gcp_wine_conn                = jsonencode(local.gcp_wine_conn)
      log_storage_size             = var.configuration.log_storage_size
      namespace                    = var.namespace
      odahu_conn                   = jsonencode(local.odahu_conn)
      odahu_airflow_plugin_version = local.odahu_airflow_plugin_version
      storage_size                 = var.configuration.storage_size
    }),
  ]

  depends_on = [kubernetes_namespace.this, kubernetes_secret.postgres, var.nfs_dependency]
}
