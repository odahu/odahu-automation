locals {
  project_roles = [
    "roles/storage.objectViewer"
  ]

  storage_roles = [
    "roles/storage.legacyBucketWriter",
    "roles/storage.objectAdmin"
  ]

  gcp_backup_sa_name = "${var.cluster_name}-backup-sa"
}

resource "google_service_account" "backup_sa" {
  count        = var.backup_settings.enabled ? 1 : 0
  account_id   = local.gcp_backup_sa_name
  display_name = local.gcp_backup_sa_name
  project      = var.gcp_project_id
}

resource "google_project_iam_member" "backup_sa" {
  for_each = {
    for role in local.project_roles : role => role if var.backup_settings.enabled
  }
  member  = "serviceAccount:${google_service_account.backup_sa[0].email}"
  project = var.gcp_project_id
  role    = each.value
}

resource "google_storage_bucket_iam_member" "backup_sa" {
  for_each = {
    for role in local.storage_roles : role => role if var.backup_settings.enabled
  }
  bucket = var.backup_settings.bucket_name
  member = "serviceAccount:${google_service_account.backup_sa[0].email}"
  role   = each.value
  depends_on = [
    google_service_account.backup_sa[0]
  ]
}

resource "google_service_account_key" "backup_sa" {
  count              = var.backup_settings.enabled ? 1 : 0
  service_account_id = google_service_account.backup_sa[0].name
  depends_on = [
    google_project_iam_member.backup_sa,
    google_storage_bucket_iam_member.backup_sa
  ]
}
