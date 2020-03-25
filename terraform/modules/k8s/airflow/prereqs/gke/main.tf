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
