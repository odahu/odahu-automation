resource "random_string" "name" {
  count       = 3
  length      = 20
  upper       = false
  lower       = true
  number      = true
  min_numeric = 5
  special     = false
}

data "azurerm_public_ip" "egress" {
  name                = var.ip_egress_name
  resource_group_name = var.resource_group
}

locals {
  storage_tags = merge(
    { "purpose" = "Odahuflow models storage" },
    var.tags
  )
  registry_tags = merge(
    { "purpose" = "Odahuflow models images registry" },
    var.tags
  )

  model_docker_user        = azurerm_container_registry.odahuflow.admin_username
  model_docker_password    = base64encode(azurerm_container_registry.odahuflow.admin_password)
  model_docker_repo        = "${azurerm_container_registry.odahuflow.login_server}/${var.cluster_name}"
  model_docker_web_ui_link = "https://${local.model_docker_repo}"

  sas_token_period = "168h" # - 7 days # 8760h - 1 year

  log_bucket             = var.log_bucket == "" ? azurerm_storage_container.odahuflow_data_bucket.name : try(azurerm_storage_container.odahuflow_log_bucket[0].name, "")
  log_sas_token          = var.log_bucket == "" ? data.azurerm_storage_account_sas.odahuflow_data.sas : try(data.azurerm_storage_account_sas.odahuflow_logs[0].sas, "")
  log_storage_account    = var.log_bucket == "" ? azurerm_storage_account.odahuflow_data.name : try(azurerm_storage_account.odahuflow_logs[0].name, "")
  log_storage_access_key = var.log_bucket == "" ? azurerm_storage_account.odahuflow_data.primary_access_key : try(azurerm_storage_account.odahuflow_logs[0].primary_access_key, "")
}

########################################################
# Azure Container Registry
########################################################
resource "azurerm_container_registry" "odahuflow" {
  name                = random_string.name[0].result
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true

  tags = local.registry_tags
}

########################################################
# Azure Blob data container
########################################################
resource "azurerm_storage_account" "odahuflow_data" {
  name                     = random_string.name[1].result
  resource_group_name      = var.resource_group
  location                 = var.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  network_rules {
    default_action = "Allow"
    bypass         = ["Logging", "Metrics", "AzureServices"]
    ip_rules = concat(
      # Removing /32 networks masks just in case
      # https://docs.microsoft.com/en-us/azure/storage/common/storage-network-security#grant-access-from-an-internet-ip-range
      split(", ", replace(join(", ", var.allowed_ips), "/32", "")),
      list(data.azurerm_public_ip.egress.ip_address)
    )
  }

  tags       = local.storage_tags
  depends_on = [azurerm_container_registry.odahuflow]
}

resource "azurerm_storage_account_customer_managed_key" "data" {
  storage_account_id = azurerm_storage_account.odahuflow_data.id
  key_vault_id       = var.kms_vault_id
  key_name           = basename(var.kms_key_id)
}

data "azurerm_storage_account_sas" "odahuflow_data" {
  connection_string = azurerm_storage_account.odahuflow_data.primary_connection_string
  https_only        = true

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  resource_types {
    service   = true
    container = true
    object    = true
  }

  start  = formatdate("YYYY-MM-DD", timestamp())
  expiry = formatdate("YYYY-MM-DD", timeadd(timestamp(), local.sas_token_period))

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = true
    add     = true
    create  = true
    update  = true
    process = false
  }
}

resource "azurerm_storage_container" "odahuflow_data_bucket" {
  name                  = var.data_bucket
  storage_account_name  = azurerm_storage_account.odahuflow_data.name
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.odahuflow_data]
}

########################################################
# Azure Blob logs container
########################################################

resource "azurerm_storage_account" "odahuflow_logs" {
  count = var.log_bucket == "" ? 0 : 1

  name                     = random_string.name[2].result
  resource_group_name      = var.resource_group
  location                 = var.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Allow"
    bypass         = ["Logging", "Metrics", "AzureServices"]
    ip_rules = concat(
      # Removing /32 networks masks just in case
      # https://docs.microsoft.com/en-us/azure/storage/common/storage-network-security#grant-access-from-an-internet-ip-range
      split(", ", replace(join(", ", var.allowed_ips), "/32", "")),
      list(data.azurerm_public_ip.egress.ip_address)
    )
  }

  tags       = local.storage_tags
  depends_on = [azurerm_container_registry.odahuflow]
}

resource "azurerm_storage_account_customer_managed_key" "logs" {
  storage_account_id = azurerm_storage_account.odahuflow_logs.id
  key_vault_id       = var.kms_vault_id
  key_name           = basename(var.kms_key_id)
}

data "azurerm_storage_account_sas" "odahuflow_logs" {
  count = var.log_bucket == "" ? 0 : 1

  connection_string = azurerm_storage_account.odahuflow_logs[0].primary_connection_string
  https_only        = true

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  resource_types {
    service   = true
    container = true
    object    = true
  }

  start  = formatdate("YYYY-MM-DD", timestamp())
  expiry = formatdate("YYYY-MM-DD", timeadd(timestamp(), local.sas_token_period))

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = true
    add     = true
    create  = true
    update  = true
    process = false
  }

  depends_on = [azurerm_storage_account.odahuflow_logs[0], data.azurerm_storage_account_sas.odahuflow_logs[0]]
}

resource "azurerm_storage_container" "odahuflow_log_bucket" {
  count = var.log_bucket == "" ? 0 : 1

  name                  = var.log_bucket
  storage_account_name  = azurerm_storage_account.odahuflow_logs[0].name
  container_access_type = "private"
  metadata              = local.storage_tags
  depends_on            = [azurerm_storage_account.odahuflow_logs[0], data.azurerm_storage_account_sas.odahuflow_logs[0]]
}

########################################################
# Azure log rotation policy
########################################################

resource "azurerm_storage_management_policy" "logs" {
  storage_account_id = var.log_bucket == "" ? azurerm_storage_account.odahuflow_data.id : azurerm_storage_account.odahuflow_logs[0].id

  rule {
    name    = "logrotate"
    enabled = true
    filters {
      prefix_match = ["logs/"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.log_expiration_days
      }
    }
  }
}
