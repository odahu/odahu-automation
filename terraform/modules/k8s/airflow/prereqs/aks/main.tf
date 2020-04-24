locals {
  gsa_syncer_name = "${var.cluster_name}-syncer"
}

data "azurerm_storage_account" "odahuflow_data" {
  name                = var.sa_name
  resource_group_name = var.resource_group
}

data "azurerm_storage_container" "dags" {
  name                 = var.dags_bucket
  storage_account_name = data.azurerm_storage_account.odahuflow_data.name
}
