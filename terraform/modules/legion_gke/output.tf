output "model_docker_user" {
  value = local.model_docker_user
}

output "model_docker_password" {
  value = local.collector_sa_key_one_line
}

output "model_docker_repo" {
  value = "${data.google_container_registry_repository.legion_registry.repository_url}/${var.cluster_name}"
}

output "model_docker_web_ui_link" {
  value = local.model_docker_web_ui_link
}

output "dockercfg" {
  value = local.dockercfg
}

output "legion_data_bucket" {
  value = google_storage_bucket.this.name
}

output "legion_collector_sa" {
  value = google_service_account.collector_sa.email
}

output "model_output_bucket" {
  value = "${google_storage_bucket.this.url}/output"
}

output "model_output_region" {
  value = var.project_id
}

output "model_output_secret" {
  value = local.collector_sa_key_one_line
}

output "model_output_web_ui_link" {
  value = "https://console.cloud.google.com/storage/browser/${google_storage_bucket.this.name}/output?project=${var.project_id}"
}

output "bucket_registry_name" {
  value = "artifacts.${var.project_id}.appspot.com"
}

output "feedback_storage_link" {
  value = "https://console.cloud.google.com/storage/browser/${google_storage_bucket.this.name}/model_log?project=${var.project_id}"
}
