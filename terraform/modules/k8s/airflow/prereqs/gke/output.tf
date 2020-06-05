output "wine_connection" {
  value = {
    "extra__google_cloud_platform__project"      = var.project_id,
    "extra__google_cloud_platform__keyfile_dict" = replace(base64decode(google_service_account_key.airflow.private_key), "/\n/", ""),
    "extra__google_cloud_platform__scope"        = "https://www.googleapis.com/auth/cloud-platform"
  }
}

output "airflow_variables" {
  value = {
    "WINE_BUCKET" = var.wine_bucket,
    "GCP_PROJECT" = var.project_id
  }
}

output "syncer_helm_values" {
  value = templatefile("${path.module}/templates/syncer.yaml", {
    data_bucket_name   = var.dag_bucket
    data_bucket_region = var.region
    subpath            = var.dag_bucket_path
    syncer_sa          = google_service_account.syncer_sa.email
  })
}

