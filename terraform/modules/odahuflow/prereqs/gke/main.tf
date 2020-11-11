locals {
  collector_sa_key_one_line  = jsonencode(jsondecode(base64decode(google_service_account_key.collector_sa_key.private_key)))
  jupyterhub_sa_key_one_line = jsonencode(jsondecode(base64decode(google_service_account_key.jupyterhub_sa_key.private_key)))

  model_docker_user        = "_json_key"
  model_docker_password    = local.collector_sa_key_one_line
  model_docker_web_ui_link = "https://${local.model_docker_repo}"
  model_docker_repo        = "${data.google_container_registry_repository.odahuflow_registry.repository_url}/${var.cluster_name}"

  gsa_collector_name       = "${var.cluster_name}-collector"
  gsa_jupyterhub_name      = "${var.cluster_name}-jupyterhub"
  gcp_bucket_registry_name = "artifacts.${var.project_id}.appspot.com"
  log_bucket_name          = var.log_bucket == "" ? "${var.cluster_name}-log-storage" : var.log_bucket
}

########################################################
# GCS data bucket
########################################################
resource "google_storage_bucket" "data" {
  name          = var.data_bucket
  location      = var.region
  storage_class = "REGIONAL"
  force_destroy = true

  encryption {
    default_kms_key_name = var.kms_key_id
  }

  labels = {
    project = "odahuflow"
    env     = var.cluster_name
  }
}

########################################################
# GCS log bucket
########################################################
resource "google_storage_bucket" "log" {
  name          = local.log_bucket_name
  location      = var.region
  storage_class = "REGIONAL"
  force_destroy = true

  encryption {
    default_kms_key_name = var.kms_key_id
  }

  labels = {
    project = "odahuflow"
    env     = var.cluster_name
  }

  lifecycle_rule {
    condition {
      age = var.log_expiration_days
    }
    action {
      type = "Delete"
    }
  }
}

########################################################
# Google Cloud Collector Service Account
########################################################
resource "google_service_account" "collector_sa" {
  account_id   = local.gsa_collector_name
  display_name = local.gsa_collector_name
  project      = var.project_id
}

resource "google_service_account_iam_binding" "collector_web_identity" {
  service_account_id = google_service_account.collector_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members            = var.collector_sa_list
}

resource "google_service_account_key" "collector_sa_key" {
  service_account_id = google_service_account.collector_sa.name
}

resource "google_storage_bucket_iam_member" "odahuflow_data_store_legacy_write" {
  bucket = google_storage_bucket.data.name
  member = "serviceAccount:${google_service_account.collector_sa.email}"
  role   = "roles/storage.legacyBucketWriter"
}

resource "google_storage_bucket_iam_member" "odahuflow_data_store" {
  bucket = google_storage_bucket.data.name
  member = "serviceAccount:${google_service_account.collector_sa.email}"
  role   = "roles/storage.objectAdmin"
}

resource "google_storage_bucket_iam_member" "odahuflow_log_store_legacy_write" {
  bucket = google_storage_bucket.log.name
  member = "serviceAccount:${google_service_account.collector_sa.email}"
  role   = "roles/storage.legacyBucketWriter"
}

resource "google_storage_bucket_iam_member" "odahuflow_log_store" {
  bucket = google_storage_bucket.log.name
  member = "serviceAccount:${google_service_account.collector_sa.email}"
  role   = "roles/storage.objectAdmin"
}

resource "google_storage_bucket_iam_member" "odahuflow_registry" {
  bucket = local.gcp_bucket_registry_name
  member = "serviceAccount:${google_service_account.collector_sa.email}"
  role   = "roles/storage.admin"
}

resource "google_kms_crypto_key_iam_member" "collector_kms_encrypt_decrypt" {
  crypto_key_id = var.kms_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.collector_sa.email}"
}

########################################################
# Google Cloud Jupyterhub Service Account
########################################################
resource "google_service_account" "jupyterhub_sa" {
  account_id   = local.gsa_jupyterhub_name
  display_name = local.gsa_jupyterhub_name
  project      = var.project_id
}

resource "google_service_account_key" "jupyterhub_sa_key" {
  service_account_id = google_service_account.jupyterhub_sa.name
}

resource "google_storage_bucket_iam_member" "odahuflow_data_store_viewer" {
  bucket = google_storage_bucket.data.name
  member = "serviceAccount:${google_service_account.jupyterhub_sa.email}"
  role   = "roles/storage.objectViewer"
}

resource "google_storage_bucket_iam_member" "odahuflow_registry_viewer" {
  bucket = local.gcp_bucket_registry_name
  member = "serviceAccount:${google_service_account.jupyterhub_sa.email}"
  role   = "roles/storage.objectViewer"
}

########################################################
# Google Cloud Registry
########################################################
data "google_container_registry_repository" "odahuflow_registry" {
  project = var.project_id
}
