output "model_docker_user" {
  value = local.model_docker_user
}

output "model_docker_password" {
  value = local.model_docker_password
}

output "model_docker_repo" {
  value = local.model_docker_repo
}

output "model_docker_web_ui_link" {
  value = local.model_docker_web_ui_link
}

output "dockercfg" {
  value = local.dockercfg
}

output "model_output_bucket" {
  value = "${var.legion_data_bucket}/output"
}

output "model_output_secret" {
  value     = "${azurerm_storage_account.legion_data.primary_blob_endpoint}${data.azurerm_storage_account_sas.legion.sas}"
  sensitive = true
}

output "model_output_web_ui_link" {
  value = "${azurerm_storage_container.legion_bucket.id}/output"
}

output "feedback_storage_link" {
  value = "${azurerm_storage_container.legion_bucket.id}/model_log"
}

output "storage_account" {
  value = azurerm_storage_account.legion_data.name
}
