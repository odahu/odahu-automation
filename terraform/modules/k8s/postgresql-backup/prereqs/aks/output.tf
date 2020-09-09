output "backup_job_config" {
  value = {
    rclone = var.backup_settings.enabled ? templatefile("${path.module}/templates/rclone.tpl", {
      sas_url = format(
        "%s%s",
        data.azurerm_storage_account.backup[0].primary_blob_endpoint,
        length(data.azurerm_storage_account_sas.backup) > 0 ? data.azurerm_storage_account_sas.backup[0].sas : ""
      )
    }) : ""

    bucket = local.storage_container

    annotations = {}
  }
  sensitive = true
}
