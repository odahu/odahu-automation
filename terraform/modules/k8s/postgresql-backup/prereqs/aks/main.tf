
locals {
  storage_account   = var.backup_settings.enabled ? split("/", var.backup_settings.bucket_name)[0] : ""
  storage_container = var.backup_settings.enabled ? split("/", var.backup_settings.bucket_name)[1] : ""
  sas_token_period  = "8760h"
}

data "azurerm_storage_account" "backup" {
  count               = var.backup_settings.enabled ? 1 : 0
  name                = local.storage_account
  resource_group_name = var.resource_group
}

# We have to use the storage account-level SAS because rclone cannot work with
# container blob level SAS
data "azurerm_storage_account_sas" "backup" {
  count             = var.backup_settings.enabled ? 1 : 0
  connection_string = data.azurerm_storage_account.backup[0].primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = formatdate("YYYY-MM-DD", timestamp())
  expiry = formatdate("YYYY-MM-DD", timeadd(timestamp(), local.sas_token_period))

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = false
  }
}
