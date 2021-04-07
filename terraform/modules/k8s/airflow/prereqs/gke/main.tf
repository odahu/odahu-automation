locals {
  gsa_syncer_name = "${var.cluster_name}-syncer"
}

resource "google_service_account" "airflow" {
  account_id   = "${var.cluster_name}-airflow-sa"
  display_name = "${var.cluster_name}-airflow-sa"
  project      = var.project_id
}

resource "google_service_account_key" "airflow" {
  service_account_id = google_service_account.airflow.name
  depends_on         = [google_project_iam_member.iam]
}

resource "google_project_iam_member" "iam" {
  member  = "serviceAccount:${google_service_account.airflow.email}"
  project = var.project_id
  role    = "roles/storage.objectViewer"
}

resource "google_storage_bucket_iam_member" "odahu_store_legacy_write" {
  bucket     = var.wine_bucket
  member     = "serviceAccount:${google_service_account.airflow.email}"
  role       = "roles/storage.legacyBucketWriter"
  depends_on = [google_service_account.airflow]
}

resource "google_storage_bucket_iam_member" "odahu_store" {
  bucket     = var.wine_bucket
  member     = "serviceAccount:${google_service_account.airflow.email}"
  role       = "roles/storage.objectAdmin"
  depends_on = [google_service_account.airflow]
}

resource "google_kms_crypto_key_iam_member" "airflow_kms_decrypt" {
  count = var.kms_key_id == "" ? 0 : 1

  crypto_key_id = var.kms_key_id
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  member        = "serviceAccount:${google_service_account.airflow.email}"
}

########################################################
# Dag syncer Google Cloud Service Account
########################################################
resource "google_service_account" "syncer_sa" {
  account_id   = local.gsa_syncer_name
  display_name = local.gsa_syncer_name
  project      = var.project_id
}

resource "google_service_account_iam_binding" "collector_web_identity" {
  service_account_id = google_service_account.syncer_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = ["serviceAccount:${var.project_id}.svc.id.goog[airflow/odahu-syncer]"]
}

resource "google_service_account_key" "syncer_sa_key" {
  service_account_id = google_service_account.syncer_sa.name
}

resource "google_storage_bucket_iam_member" "odahuflow_store_reader" {
  bucket = var.dag_bucket
  member = "serviceAccount:${google_service_account.syncer_sa.email}"
  role   = "roles/storage.objectViewer"
}
