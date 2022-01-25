locals {
  collector_sa_key_one_line = jsonencode(jsondecode(base64decode(google_service_account_key.collector_sa_key.private_key)))

  model_docker_user        = "_json_key"
  model_docker_password    = local.collector_sa_key_one_line
  model_docker_web_ui_link = "https://${local.model_docker_repo}"
  model_docker_repo        = "${data.google_container_registry_repository.odahuflow_registry.repository_url}/${var.cluster_name}"

  gsa_collector_name       = "${var.cluster_name}-collector"
  gsa_jupyterhub_name      = substr("${var.cluster_name}-jupyter-notebook", 0, 30)
  gsa_mlflow_name          = substr("${var.cluster_name}-mlflow", 0, 30)
  gcp_bucket_registry_name = "artifacts.${var.project_id}.appspot.com"
  log_bucket_name          = var.log_bucket == "" ? "${var.cluster_name}-log-storage" : var.log_bucket
  mlflow_bucket_name       = var.mlflow_artifact_bucket == "" ? "${var.cluster_name}-mlflow" : var.mlflow_artifact_bucket

  fluentd = {
    "fluentd" = {
      "resources" = {
        "limits" = {
          "cpu" : var.fluentd_resources.cpu_limits
          "memory" : var.fluentd_resources.memory_limits
        }
        "requests" = {
          "cpu" : var.fluentd_resources.cpu_requests
          "memory" : var.fluentd_resources.memory_requests
        }
      }
    }
  }
}

########################################################
# GCS data bucket
########################################################
resource "google_storage_bucket" "data" {
  name                        = var.data_bucket
  location                    = var.region
  storage_class               = "REGIONAL"
  force_destroy               = true
  uniform_bucket_level_access = var.uniform_bucket_level_access

  encryption {
    default_kms_key_name = var.kms_key_id
  }

  versioning {
    enabled = var.data_enable_versioning
  }

  labels = {
    project = "odahuflow"
    env     = var.cluster_name
  }
}

########################################################
# GCS MLFlow bucket
########################################################
resource "google_storage_bucket" "mlflow" {
  name          = local.mlflow_bucket_name
  location      = var.region
  storage_class = "REGIONAL"
  force_destroy = true

  encryption {
    default_kms_key_name = var.kms_key_id
  }

  versioning {
    enabled = var.mlflow_enable_versioning
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
  name                        = local.log_bucket_name
  location                    = var.region
  storage_class               = "REGIONAL"
  force_destroy               = true
  uniform_bucket_level_access = var.uniform_bucket_level_access

  encryption {
    default_kms_key_name = var.kms_key_id
  }

  versioning {
    enabled = var.log_enable_versioning
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
# GCS Argo artifacts bucket
########################################################
resource "google_storage_bucket" "argo_artifacts" {
  count = var.argo_artifact_bucket == "" ? 0 : 1

  name                        = var.argo_artifact_bucket
  location                    = var.region
  storage_class               = "REGIONAL"
  force_destroy               = true
  uniform_bucket_level_access = var.uniform_bucket_level_access

  encryption {
    default_kms_key_name = var.kms_key_id
  }

  versioning {
    enabled = var.argo_artifacts_enable_versioning
  }

  labels = {
    project = "odahuflow"
    env     = var.cluster_name
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
  count = var.kms_key_id == "" ? 0 : 1

  crypto_key_id = var.kms_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.collector_sa.email}"
}

resource "google_storage_bucket_iam_member" "odahuflow_mlflow_store_legacy_read" {
  bucket = google_storage_bucket.mlflow.name
  member = "serviceAccount:${google_service_account.collector_sa.email}"
  role   = "roles/storage.legacyBucketReader"
}

########################################################
# Google Cloud Jupyterhub Service Account
########################################################

resource "google_service_account" "jupyter_notebook" {
  account_id   = local.gsa_jupyterhub_name
  display_name = local.gsa_jupyterhub_name
  project      = var.project_id
}

resource "google_storage_bucket_iam_member" "jupyter_data_store_legacy_write" {
  bucket = google_storage_bucket.data.name
  member = "serviceAccount:${google_service_account.jupyter_notebook.email}"
  role   = "roles/storage.legacyBucketWriter"
}

resource "google_storage_bucket_iam_member" "jupyter_data_store_admin" {
  bucket = google_storage_bucket.data.name
  member = "serviceAccount:${google_service_account.jupyter_notebook.email}"
  role   = "roles/storage.objectAdmin"
}

resource "google_storage_bucket_iam_member" "jupyter_notebook_registry_viewer" {
  bucket = local.gcp_bucket_registry_name
  member = "serviceAccount:${google_service_account.jupyter_notebook.email}"
  role   = "roles/storage.objectViewer"
}

resource "google_kms_crypto_key_iam_member" "jupyter_notebook_kms_encrypt_decrypt" {
  count = var.kms_key_id == "" ? 0 : 1

  crypto_key_id = var.kms_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.jupyter_notebook.email}"
}

resource "google_service_account_iam_binding" "jupyter_notebook_web_identity" {
  service_account_id = google_service_account.jupyter_notebook.name
  role               = "roles/iam.workloadIdentityUser"
  members            = ["serviceAccount:${var.project_id}.svc.id.goog[jupyterhub/notebook]"]
}

########################################################
# Google Cloud MLFlow Service Account
########################################################

resource "google_service_account" "mlflow" {
  account_id   = local.gsa_mlflow_name
  display_name = local.gsa_mlflow_name
  project      = var.project_id
}

resource "google_storage_bucket_iam_member" "mlflow_data_store_legacy_write" {
  bucket = google_storage_bucket.mlflow.name
  member = "serviceAccount:${google_service_account.mlflow.email}"
  role   = "roles/storage.legacyBucketWriter"
}

resource "google_storage_bucket_iam_member" "mlflow_data_store_admin" {
  bucket = google_storage_bucket.mlflow.name
  member = "serviceAccount:${google_service_account.mlflow.email}"
  role   = "roles/storage.objectAdmin"
}

resource "google_kms_crypto_key_iam_member" "mlflow_kms_encrypt_decrypt" {
  count = var.kms_key_id == "" ? 0 : 1

  crypto_key_id = var.kms_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.mlflow.email}"
}

resource "google_service_account_iam_binding" "mlflow_web_identity" {
  service_account_id = google_service_account.mlflow.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[odahu-flow/mlflow]",
    "serviceAccount:${var.project_id}.svc.id.goog[odahu-flow-training/default]"
  ]
}

########################################################
# Google Cloud Registry
########################################################
data "google_container_registry_repository" "odahuflow_registry" {
  project = var.project_id
}
