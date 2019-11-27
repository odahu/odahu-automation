output "extra_external_urls" {
  value = [
    {
      name = "Feedback storage"
      url  = "https://console.cloud.google.com/storage/browser/${google_storage_bucket.this.name}/model_log?project=${var.project_id}"
    }
  ]
}

output "odahuflow_connections" {
  value = [
    {
      id = "docker-ci",
      spec = {
        type        = "docker",
        username    = local.model_docker_user,
        password    = local.collector_sa_key_one_line
        uri         = "${data.google_container_registry_repository.odahuflow_registry.repository_url}/${var.cluster_name}"
        description = "Default GCR docker repository for model packaging"
        webUILink   = local.model_docker_web_ui_link
      }
    },
    {
      id = "models-output",
      spec = {
        type        = "gcs",
        keySecret   = local.collector_sa_key_one_line
        uri         = "${google_storage_bucket.this.url}/output"
        region      = var.project_id
        description = "Storage for trained artifacts"
        webUILink   = "https://console.cloud.google.com/storage/browser/${google_storage_bucket.this.name}/output?project=${var.project_id}"
      }
    }
  ]
}

output "fluent_helm_values" {
  value = templatefile("${path.module}/templates/fluentd.yaml", {
    data_bucket  = google_storage_bucket.this.name,
    collector_sa = google_service_account.collector_sa.email
  })
}