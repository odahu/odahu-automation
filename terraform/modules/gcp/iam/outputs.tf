output "service_account" {
  value = google_service_account.nodes_sa.email
}

output "service_account_key" {
  value = google_service_account_key.nodes_sa_key.private_key
}
