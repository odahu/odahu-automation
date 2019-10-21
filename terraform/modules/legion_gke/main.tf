locals {
  collector_sa_key_one_line = jsonencode(jsondecode(base64decode(google_service_account_key.collector_sa_key.private_key)))

  model_docker_user        = "_json_key"
  model_docker_password    = local.collector_sa_key_one_line
  model_docker_web_ui_link = "https://${local.model_docker_repo}"
  model_docker_repo        = "${data.google_container_registry_repository.legion_registry.repository_url}/${var.cluster_name}"

  dockercfg = {
    "https://gcr.io" = {
      email    = ""
      username = local.model_docker_user
      password = local.model_docker_password
    }
  }

  gsa_collector_name   = "${var.cluster_name}-collector"
  gcp_bucket_registry_name = "artifacts.${var.project_id}.appspot.com"
}

########################################################
# GCS bucket
########################################################
resource "google_storage_bucket" "this" {
  name          = var.legion_data_bucket
  location      = var.region
  storage_class = "REGIONAL"
  force_destroy = true

  labels = {
    project = "legion"
    env     = var.cluster_name
  }
}

########################################################
# Google Cloud Service Account
########################################################
resource "google_service_account" "collector_sa" {
  account_id   = local.gsa_collector_name
  display_name = local.gsa_collector_name
  project      = var.project_id
}

resource "google_service_account_key" "collector_sa_key" {
  service_account_id = google_service_account.collector_sa.name
}

resource "google_storage_bucket_iam_member" "legion_store_legacy_write" {
  bucket = google_storage_bucket.this.name
  member = "serviceAccount:${google_service_account.collector_sa.email}"
  role   = "roles/storage.legacyBucketWriter"
}

resource "google_storage_bucket_iam_member" "legion_store" {
  bucket = google_storage_bucket.this.name
  member = "serviceAccount:${google_service_account.collector_sa.email}"
  role   = "roles/storage.objectAdmin"
}

resource "google_storage_bucket_iam_member" "legion_registry" {
  bucket = local.gcp_bucket_registry_name
  member = "serviceAccount:${google_service_account.collector_sa.email}"
  role   = "roles/storage.admin"
}

########################################################
# Google Cloud Registry
########################################################
data "google_container_registry_repository" "legion_registry" {
  project = var.project_id
}
