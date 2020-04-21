output "wine_connection" {
  value = {}
}

output "airflow_variables" {
  value = {
    "WINE_BUCKET" = var.wine_bucket
  }
}

output "syncer_helm_values" {
  value = templatefile("${path.module}/templates/syncer.yaml", {
    data_bucket_name   = var.dags_bucket
    data_bucket_region = var.region
    subpath            = "/dags"
    syncer_iam_role    = aws_iam_role.syncer.name
  })
}
