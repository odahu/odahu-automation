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
    data_bucket_name   = var.dag_bucket
    data_bucket_region = var.region
    subpath            = var.dag_bucket_path
    iam_role_arn       = aws_iam_role.syncer.arn
  })
}
