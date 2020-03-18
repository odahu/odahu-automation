output "wine_conn_private_key" {
  value = google_service_account_key.airflow.private_key
}

