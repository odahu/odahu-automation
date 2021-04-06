locals {
  gsa_argo_name = "${var.cluster_name}-argo"
  workflows_namespace = var.configuration.workflows_namespace == "" ? var.configuration.namespace : var.configuration.workflows_namespace
}

resource "google_service_account" "argo" {
  account_id   = "${var.cluster_name}-argo-sa"
  display_name = "${var.cluster_name}-argo-sa"
  project      = var.project_id
}

resource "google_service_account_key" "argo" {
  service_account_id = google_service_account.argo.name
  depends_on         = [google_project_iam_member.iam]
}

resource "google_project_iam_member" "iam" {
  member  = "serviceAccount:${google_service_account.argo.email}"
  project = var.project_id
  role    = "roles/storage.objectViewer"
}

resource "google_storage_bucket_iam_member" "argo_store_legacy_write" {
  bucket     = var.bucket
  member     = "serviceAccount:${google_service_account.argo.email}"
  role       = "roles/storage.legacyBucketWriter"
  depends_on = [google_service_account.argo]
}

resource "google_storage_bucket_iam_member" "odahu_store" {
  bucket     = var.bucket
  member     = "serviceAccount:${google_service_account.argo.email}"
  role       = "roles/storage.objectAdmin"
  depends_on = [google_service_account.argo]
}

resource "google_kms_crypto_key_iam_member" "argo_kms_decrypt" {
  count = var.kms_key_id == "" ? 0 : 1

  crypto_key_id = var.kms_key_id
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  member        = "serviceAccount:${google_service_account.argo.email}"
}

resource "google_service_account_iam_binding" "argo_web_identity" {
  service_account_id = google_service_account.argo.name
  role               = "roles/iam.workloadIdentityUser"

  members = ["serviceAccount:${var.project_id}.svc.id.goog[${var.configuration.namespace}|argo]", "serviceAccount:${var.project_id}.svc.id.goog[${local.workflows_namespace}|argo-workflow]"]
}

resource "google_service_account_key" "argo_sa_key" {
  service_account_id = google_service_account.argo.name
}
