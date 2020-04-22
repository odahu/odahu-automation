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
    data_bucket_name      = var.dags_bucket
    subpath               = "/dags"
    azure_storage_account = data.azurerm_storage_account.odahuflow_data.name
    azure_storage_key     = data.azurerm_storage_account.odahuflow_data.primary_access_key
  })
}
