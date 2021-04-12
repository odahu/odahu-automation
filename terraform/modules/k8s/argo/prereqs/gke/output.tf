output "argo_sa_annotations" {
  value = {
    "iam.gke.io/gcp-service-account" = google_service_account.argo.email
  }
}

output "argo_artifact_repository_config" {
  value = {
    gcs = {
      bucket    = var.bucket,
      endpoint  = "storage.googleapis.com",
      keyFormat = "argo/{{workflow.namespace}}/{{workflow.name}}/"
    }
  }
}
