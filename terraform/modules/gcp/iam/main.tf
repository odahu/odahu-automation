resource "google_service_account" "nodes_sa" {
  account_id   = "${var.cluster_name}-nodes-sa"
  display_name = "${var.cluster_name}-nodes-sa"
  project      = var.project_id
}

# Create a Service Account key by default
resource "google_service_account_key" "nodes_sa_key" {
  depends_on         = [google_project_iam_member.iam]
  service_account_id = google_service_account.nodes_sa.name
}

resource "google_project_iam_member" "iam" {
  count   = length(var.service_account_iam_roles)
  member  = "serviceAccount:${google_service_account.nodes_sa.email}"
  project = var.project_id
  role    = var.service_account_iam_roles[count.index]
}

